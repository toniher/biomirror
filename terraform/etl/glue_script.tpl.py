# TODO: More things could become params

import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Script generated for node Data Catalog table
DataCatalogtable_node1 = glueContext.create_dynamic_frame.from_catalog(
    database="${glue_s3_db}",
    table_name="clean_dat_gz",
    transformation_ctx="DataCatalogtable_node1",
)

# Script generated for node Select Fields
SelectFields_node2 = SelectFields.apply(
    frame=DataCatalogtable_node1,
    paths=["col0", "col1", "col2"],
    transformation_ctx="SelectFields_node2",
)

# Script generated for node Apply Mapping
ApplyMapping_node1660995524267 = ApplyMapping.apply(
    frame=SelectFields_node2,
    mappings=[
        ("col0", "string", "uniprot", "string"),
        ("col1", "string", "db", "string"),
        ("col2", "string", "external", "string"),
    ],
    transformation_ctx="ApplyMapping_node1660995524267",
)

# Script generated for node Data Catalog table
DataCatalogtable_node3 = glueContext.write_dynamic_frame.from_catalog(
    frame=ApplyMapping_node1660995524267,
    database="${glue_rds_db}",
    table_name="biomirror_idmapping",
    transformation_ctx="DataCatalogtable_node3",
)

job.commit()
