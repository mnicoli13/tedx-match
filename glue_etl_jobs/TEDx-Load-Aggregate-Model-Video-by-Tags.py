import sys
import json
import pyspark
from pyspark.sql.functions import col, collect_list, struct
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame

#--------------------------------------------------
# Script: load_aggregate_model.py
# Purpose: Lettura file TEDx, aggregazione tags e related videos,
#          creazione collection tedx_data e video_by_tag in MongoDB
# Usage:  aws glue ... --JOB_NAME <job_name> --script-location s3://.../load_aggregate_model.py
#--------------------------------------------------

# Parametri Glue
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

# Inizializzazione contesti
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

#--------------------------------------------------
# 1) Lettura dataset principali
#--------------------------------------------------
tedx_dataset_path = "s3://tedx-2025-data-mp-27042025/final_list.csv"
details_dataset_path = "s3://tedx-2025-data-mp-27042025/details.csv"
tags_dataset_path = "s3://tedx-2025-data-mp-27042025/tags.csv"
related_videos_path = "s3://tedx-2025-data-mp-27042025/related_videos.csv"

# 1.a) final_list.csv
tedx_dataset = spark.read \
    .option("header", "true") \
    .option("quote", '"') \
    .option("escape", '"') \
    .csv(tedx_dataset_path)

# 1.b) details.csv
details_dataset = spark.read \
    .option("header", "true") \
    .option("quote", '"') \
    .option("escape", '"') \
    .csv(details_dataset_path) \
    .select(
        col("id").alias("id_ref"),
        col("description"),
        col("duration"),
        col("publishedAt"),
        col("presenterDisplayName")
    )

# Join tra final_list e details
tedx_dataset_main = tedx_dataset \
    .join(details_dataset, tedx_dataset.id == details_dataset.id_ref, "left") \
    .drop("id_ref")

# 1.c) tags.csv
tags_dataset = spark.read \
    .option("header", "true") \
    .csv(tags_dataset_path)

# 1.d) related_videos.csv
watch_next_dataset = spark.read \
    .option("header", "true") \
    .csv(related_videos_path)

#--------------------------------------------------
# 2) Aggregazioni e join
#--------------------------------------------------
# 2.a) Aggregazione tags per video
tags_dataset_agg = tags_dataset \
    .groupBy(col("id").alias("id_ref")) \
    .agg(collect_list("tag").alias("tags"))

# 2.b) Aggregazione related videos per video
watch_next_dataset_agg = watch_next_dataset \
    .groupBy(col("id").alias("id_ref")) \
    .agg(collect_list("related_id").alias("watch_next"))

# 2.c) Creazione dataset principale con tags e watch_next
tedx_dataset_agg = tedx_dataset_main \
    .join(tags_dataset_agg, col("id") == tags_dataset_agg.id_ref, "left") \
    .join(watch_next_dataset_agg, col("id") == watch_next_dataset_agg.id_ref, "left") \
    .drop(tags_dataset_agg.id_ref, watch_next_dataset_agg.id_ref) \
    .withColumnRenamed("id", "_id")

#--------------------------------------------------
# 3) Scrittura su MongoDB: collection tedx_data
#--------------------------------------------------
write_mongo_options = {
    "connectionName": "TEDX",
    "database": "unibg_tedx_2025",
    "collection": "tedx_data",
    "ssl": "true",
    "ssl.domain_match": "false"
}
tedx_dataset_dynamic_frame = DynamicFrame.fromDF(tedx_dataset_agg, glueContext, "tedx_data_df")
glueContext.write_dynamic_frame.from_options(
    frame=tedx_dataset_dynamic_frame,
    connection_type="mongodb",
    connection_options=write_mongo_options
)

#--------------------------------------------------
# 4) Creazione collection video_by_tag
#--------------------------------------------------
# 4.a) Prepara master video con i campi utili
tedx_master = tedx_dataset_main \
    .withColumnRenamed("id", "video_id") \
    .withColumnRenamed("slug", "video_slug") \
    .withColumnRenamed("title", "video_title") \
    .withColumnRenamed("url", "video_url") \
    .select(
        "video_id", "video_slug", "video_title", "video_url",
        "description", "duration", "presenterDisplayName", "publishedAt"
    )

# 4.b) Unisci tags e master video
tags_with_videos = tags_dataset \
    .withColumnRenamed("id", "video_id") \
    .select("video_id", "tag") \
    .join(tedx_master, "video_id", "inner")

# 4.c) Raggruppa per tag
video_by_tag_df = tags_with_videos \
    .groupBy("tag") \
    .agg(
        collect_list(
            struct(
                col("video_id"),
                col("video_slug"),
                col("video_title"),
                col("video_url"),
                col("description"),
                col("duration"),
                col("presenterDisplayName"),
                col("publishedAt")
            )
        ).alias("videos")
    )

# 4.d) Scrittura su MongoDB: collection video_by_tag
write_mongo_options_by_tag = {
    "connectionName": "TEDX",
    "database": "unibg_tedx_2025",
    "collection": "video_by_tag",
    "ssl": "true",
    "ssl.domain_match": "false"
}
video_by_tag_dyf = DynamicFrame.fromDF(video_by_tag_df, glueContext, "video_by_tag_df")
glueContext.write_dynamic_frame.from_options(
    frame=video_by_tag_dyf,
    connection_type="mongodb",
    connection_options=write_mongo_options_by_tag
)

# Termina il job Glue
job.commit()
