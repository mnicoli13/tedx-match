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
tedx_dataset_path = "s3://tedx-2025-data-mp-07092025/final_list.csv"
details_dataset_path = "s3://tedx-2025-data-mp-07092025/details.csv"
tags_dataset_path = "s3://tedx-2025-data-mp-07092025/tags.csv"
related_videos_path = "s3://tedx-2025-data-mp-07092025/related_videos.csv"
images_path = "s3://tedx-2025-data-mp-07092025/images.csv"

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

# 1.c) related_videos.csv
watch_next_dataset = spark.read \
    .option("header", "true") \
    .csv(related_videos_path)
    
# 1.d) images.csv
images_dataset = spark.read \
    .option("header", "true") \
    .csv(images_path)

# 1.d) images.csv
tags_dataset = spark.read \
    .option("header","true") \
    .csv(tags_dataset_path)

#--------------------------------------------------
# 2) Aggregazioni e join
#--------------------------------------------------
# 2.a) Aggregazione related images per video
# 2.b) Aggregazione related videos per video
# crea un struct per ogni video correlato
images_dataset_struct = images_dataset.select(
    col("id").alias("id_ref"),              # uso id come id_ref
    struct(
      col("slug"),
      col("url")
    ).alias("thumbnail")
)
images_dataset_agg = images_dataset_struct \
    .groupBy("id_ref") \
    .agg(
      collect_list("thumbnail").alias("thumbnails")
    )
    
# 2.b) Aggregazione related videos per video
# crea un struct per ogni video correlato
watch_next_struct = watch_next_dataset.select(
    col("id").alias("id_ref"),
    struct(
        col("related_id").alias("_id"),
        col("slug"),
        col("title"),
        col("duration"),
        col("viewedCount"),
        col("presenterDisplayName")
    ).alias("related_video")
)

# raggruppa per talk (id_ref) e colleziona tutti i struct in un array
watch_next_dataset_agg = watch_next_struct \
    .groupBy("id_ref") \
    .agg(collect_list("related_video").alias("watch_next"))

    
tags_dataset_agg = tags_dataset \
    .groupBy(col("id").alias("id_ref")) \
    .agg(collect_list("tag").alias("tags"))


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
tedx_dataset_dynamic_frame = DynamicFrame.fromDF(images_dataset_agg, glueContext, "tedx_data_df")
glueContext.write_dynamic_frame.from_options(
    frame=tedx_dataset_dynamic_frame,
    connection_type="mongodb",
    connection_options=write_mongo_options
)

watch_next_dataset_agg.printSchema()
tedx_dataset_agg = tedx_dataset_main \
    .join(images_dataset_agg,     col("id") == images_dataset_agg.id_ref,     "left") \
    .join(watch_next_dataset_agg, col("id") == watch_next_dataset_agg.id_ref, "left") \
    .join(tags_dataset_agg,       col("id") == tags_dataset_agg.id_ref,       "left") \
    .drop(
      images_dataset_agg.id_ref,
      watch_next_dataset_agg.id_ref,
      tags_dataset_agg.id_ref
    ) \
    .withColumnRenamed("id", "_id")

tedx_dataset_agg.printSchema()

# 4.d) Scrittura su MongoDB: collection video_by_tag
write_mongo_options_by_tag = {
    "connectionName": "TEDX",
    "database": "unibg_tedx_2025",
    "collection": "video_with_images",
    "ssl": "true",
    "ssl.domain_match": "false"
}
tedx_dataset_dynamic_frame = DynamicFrame.fromDF(tedx_dataset_agg, glueContext, "nested")

glueContext.write_dynamic_frame.from_options(
    frame=tedx_dataset_dynamic_frame,
    connection_type="mongodb",
    connection_options=write_mongo_options_by_tag
)

# Termina il job Glue
job.commit()

