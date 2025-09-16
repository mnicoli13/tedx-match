###### TEDx-Load-Aggregate-Model
######

import sys
import json
import pyspark
#importo funzioni pyspark
#col per accedere una colonna
#collect list, ho in input un array python per produrre una lista univoca
#array join
from pyspark.sql.functions import col, collect_list, array_join 

from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job




##### FROM FILES
tedx_dataset_path = "s3://tedx-2025-data-mp-07092025/final_list.csv"

###### READ PARAMETERS
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

##### START JOB CONTEXT AND JOB
sc = SparkContext()


glueContext = GlueContext(sc)
spark = glueContext.spark_session


    
job = Job(glueContext)
job.init(args['JOB_NAME'], args)


#### READ INPUT FILES TO CREATE AN INPUT DATASET
#header per leggere anche l'intestazionne
tedx_dataset = spark.read \
    .option("header","true") \
    .option("quote", "\"") \
    .option("escape", "\"") \
    .csv(tedx_dataset_path)
    
tedx_dataset.printSchema()


#### FILTER ITEMS WITH NULL POSTING KEY
#conto il numero di righe
count_items = tedx_dataset.count()
#rimuovo quelli senza id
count_items_null = tedx_dataset.filter("id is not null").count()

print(f"Number of items from RAW DATA {count_items}")
print(f"Number of items from RAW DATA with NOT NULL KEY {count_items_null}")

## READ THE DETAILS
details_dataset_path = "s3://tedx-2025-data-mp-07092025/details.csv"
details_dataset = spark.read \
    .option("header","true") \
    .option("quote", "\"") \
    .option("escape", "\"") \
    .csv(details_dataset_path)

#è l'equivalente di un select in sql (trasformazione quindi finora ho fatto solo una count)
details_dataset = details_dataset.select(col("id").alias("id_ref"),
                                         col("description"),
                                         col("duration"),
                                         col("publishedAt"))

# AND JOIN WITH THE MAIN TABLE
#left join = ammetto che ci possano essere alcuni talk senza dettaglio
tedx_dataset_main = tedx_dataset.join(details_dataset, tedx_dataset.id == details_dataset.id_ref, "left") \
    .drop("id_ref")

tedx_dataset_main.printSchema()

## READ TAGS DATASET
tags_dataset_path = "s3://tedx-2025-data-mp-07092025/tags.csv"
tags_dataset = spark.read.option("header","true").csv(tags_dataset_path)


# CREATE THE AGGREGATE MODEL, ADD TAGS TO TEDX_DATASET
#group by id in quanto voglio raggruppare i tag per talk
#collect list mi trasforma un elenco di tag in un'array
#avrò 2 colonne id_ref e tags
tags_dataset_agg = tags_dataset.groupBy(col("id").alias("id_ref")).agg(collect_list("tag").alias("tags"))
tags_dataset_agg.printSchema()
# tedx_dataset_agg = tedx_dataset_main.join(tags_dataset_agg, tedx_dataset.id == tags_dataset_agg.id_ref, "left") \
#     .drop("id_ref") \
#     .select(col("id").alias("_id"), col("*")) \
#     .drop("id") \

# tedx_dataset_agg.printSchema()

watch_next_dataset_path = "s3://tedx-2025-data-mp-07092025/related_videos.csv"
watch_next_dataset = spark.read.option("header","true").csv(watch_next_dataset_path)

# CREATE THE AGGREGATE MODEL, ADD TAGS TO TEDX_DATASET
#group by id in quanto voglio raggruppare i tag per talk
#collect list mi trasforma un elenco di tag in un'array
#avrò 2 colonne id_ref e tags
watch_next_dataset_agg = watch_next_dataset.groupBy(col("id").alias("id_ref")).agg(collect_list("related_id").alias("watch_next"))
watch_next_dataset_agg.printSchema()
tedx_dataset_agg = tedx_dataset_main \
    .join(tags_dataset_agg, col("id") == tags_dataset_agg.id_ref, "left") \
    .join(watch_next_dataset_agg, col("id") == watch_next_dataset_agg.id_ref, "left") \
    .drop(tags_dataset_agg.id_ref, watch_next_dataset_agg.id_ref) \
    .withColumnRenamed("id", "_id")

tedx_dataset_agg.printSchema()

write_mongo_options = {
    "connectionName": "TEDX",
    "database": "unibg_tedx_2025",
    "collection": "tedx_data",
    "ssl": "true",
    "ssl.domain_match": "false"}
from awsglue.dynamicframe import DynamicFrame
tedx_dataset_dynamic_frame = DynamicFrame.fromDF(tedx_dataset_agg, glueContext, "nested")

#scrivo il dataset in mongo
glueContext.write_dynamic_frame.from_options(tedx_dataset_dynamic_frame, connection_type="mongodb", connection_options=write_mongo_options)