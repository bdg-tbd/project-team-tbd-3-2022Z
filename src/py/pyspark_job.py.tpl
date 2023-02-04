SEED = 20031999
GROUP = 'tbd-2022z-3'
ITERS = 3

CLUSTER = 'k8s'
# CLUSTER = 'dataproc'

# SPARK_EXECUTORS = 1
SPARK_EXECUTORS = 2
# SPARK_EXECUTORS = 6
# SPARK_EXECUTORS = 8

INPUT_FILE_PATH = 'gs://${staging_bucket}/data/ml/input/ds1-1e6.csv'

OUTPUT_FILE_PATH = f'gs://${staging_bucket}/data/ml/output/{CLUSTER}_exec_{SPARK_EXECUTORS}.csv'

######################################################################

try:
    import pyspark

    spark = pyspark.sql.SparkSession.builder.appName("TBD") \
        .config("spark.jars.packages", "com.microsoft.azure:synapseml_2.12:0.9.5") \
        .config("spark.jars.repositories", "https://mmlspark.azureedge.net/maven") \
        .config("spark.kubernetes.allocation.batch.size", 10) \
        .getOrCreate()

    # spark = pyspark.sql.SparkSession.builder.appName("TBD") \
    #     .master("local[*]") \
    #     .config("spark.jars.packages", "com.microsoft.azure:synapseml_2.12:0.9.5") \
    #     .config("spark.jars.repositories", "https://mmlspark.azureedge.net/maven") \
    #     .getOrCreate()

    from pysparkling import *
    import h2o
    hc = H2OContext.getOrCreate()

    ######################################################################

    import logging
    logger = logging.getLogger('driver_logger')

    from pyspark.sql.functions import col, to_date, month, to_timestamp, hour, regexp_replace
    from pyspark.ml.functions import vector_to_array
    from pyspark.ml import Pipeline
    from pyspark.ml.feature import StringIndexer, OneHotEncoder, VectorAssembler

    from timeit import default_timer as timer

    from pyspark.ml.classification import LogisticRegression, GBTClassifier
    from pysparkling.ml import H2OGLM, H2OXGBoostClassifier
    from synapse.ml.lightgbm import LightGBMClassifier

    ######################################################################

    def get_features_df(csv_path):
        df = spark.read.csv(csv_path, inferSchema=True, header="true", nullValue='NA', nanValue='NA',emptyValue='NA')
        df = df.filter('Longitude is not NULL and Latitude is not NULL')
        df = df.withColumn('label', df.label.cast('integer'))
        
        df = df.withColumn('Date', to_date(df.Date, 'dd/MM/yyyy'))
        df = df.withColumn('Month', month(df.Date))
        df = df.withColumn('Time', to_timestamp(df.Time, 'HH:mm'))
        df = df.withColumn('Hour', hour(df.Time))
        
        df = df.withColumn('Light_Conditions', regexp_replace('Light_Conditions', ':', ''))
        
        df = df.drop('V1', 'Accident_Index', 'Location_Easting_OSGR', 'Location_Northing_OSGR', 'Accident_Severity', 'Date', 'Time', 'Local_Authority_(District)', 'Local_Authority_(Highway)', '1st_Road_Number', '2nd_Road_Number', 'LSOA_of_Accident_Location', 'Year')
        
        columns_for_one_hot_encoding = ['Day_of_Week', '1st_Road_Class', 'Road_Type', 'Junction_Control', '2nd_Road_Class', 'Pedestrian_Crossing-Human_Control', 'Pedestrian_Crossing-Physical_Facilities', 'Light_Conditions', 'Weather_Conditions', 'Road_Surface_Conditions', 'Special_Conditions_at_Site', 'Carriageway_Hazards', 'Urban_or_Rural_Area', 'Did_Police_Officer_Attend_Scene_of_Accident', 'Month', 'Hour']
        other_columns = ['Longitude', 'Latitude', 'Police_Force', 'Number_of_Vehicles', 'Number_of_Casualties', 'Speed_limit']

        stringindexer_stages = [StringIndexer(inputCol=c, outputCol='stringindexed_' + c).setHandleInvalid("keep") for c in columns_for_one_hot_encoding]
        onehotencoder_stages = [OneHotEncoder(inputCol='stringindexed_' + c, outputCol='onehot_' + c) for c in columns_for_one_hot_encoding]

        extracted_columns = ['onehot_' + c for c in columns_for_one_hot_encoding]
        vectorassembler_stage = VectorAssembler(inputCols=extracted_columns + other_columns, outputCol='features')
        
        pipeline_stages = stringindexer_stages + onehotencoder_stages + [vectorassembler_stage]
        
        return Pipeline(stages=pipeline_stages).fit(df).transform(df).select(['features', 'label'])

    ######################################################################

    training_df, testing_df = get_features_df(INPUT_FILE_PATH).randomSplit([0.8, 0.2], seed=SEED)

    ######################################################################

    #################### LR sparkML ####################

    def test_sparkML_lr(training_df):
        times = []
        for i in range(ITERS):    
            sparkML_lr = LogisticRegression()

            training_start_time = timer()
            sparkML_lr.fit(training_df)
            training_end_time = timer()

            training_time = training_end_time - training_start_time
            times.append(training_time)
            logger.info(f'===> sparkML LR training time: {training_time}s')
        
        return times

    sparkML_lr_times = test_sparkML_lr(training_df)

    #################### LR H2O-sparklinkg-water ####################

    def test_h2o_lr(training_df):
        times = []
        for i in range(ITERS):    
            h2o_lr = H2OGLM(
                family="binomial",
                featuresCols=['features'],
                labelCol='label'
            )

            training_start_time = timer()
            h2o_lr.fit(training_df)
            training_end_time = timer()

            training_time = training_end_time - training_start_time
            times.append(training_time)
            logger.info(f'===> H2O-sprakling-water LR training time: {training_time}s')
        
        return times

    h2o_lr_times = test_h2o_lr(training_df)

    #################### GBT sparkML ####################

    def test_sparkML_gbt(training_df):
        times = []
        for i in range(ITERS):    
            sparkML_lr = LogisticRegression()

            training_start_time = timer()
            sparkML_lr.fit(training_df)
            training_end_time = timer()

            training_time = training_end_time - training_start_time
            times.append(training_time)
            logger.info(f'===> sparkML GBT training time: {training_time}s')
        
        return times

    sparkML_gbt_times = test_sparkML_gbt(training_df)

    #################### GBT H2O-sparklinkg-water ####################

    def test_h2o_gbt(training_df):
        times = []
        for i in range(ITERS):
            h2o_lr = H2OGLM(
                family="binomial",
                featuresCols=['features'],
                labelCol='label'
            )

            training_start_time = timer()
            h2o_lr.fit(training_df)
            training_end_time = timer()

            training_time = training_end_time - training_start_time
            times.append(training_time)
            logger.info(f'===> H2O-sprakling-water GBT training time: {training_time}s')
        
        return times

    h2o_gbt_times = test_h2o_gbt(training_df)

    #################### GBT SynapseML ####################

    def test_synapseML_gbt(training_df):
        times = []
        for i in range(ITERS):
            synapseML_gbt = LightGBMClassifier(objective="binary", featuresCol="features", labelCol="label")

            training_start_time = timer()
            synapseML_gbt.fit(training_df)
            training_end_time = timer()

            training_time = training_end_time - training_start_time
            times.append(training_time)
            logger.info(f'===> SynapseML GBT training time: {training_time}s')
        
        return times

    synapseML_gbt_times = test_synapseML_gbt(training_df)

    ######################################################################

    training_data = [
        *map(lambda time: (GROUP, CLUSTER, 'LR', 'spark-ml', SPARK_EXECUTORS, time), sparkML_lr_times),
        *map(lambda time: (GROUP, CLUSTER, 'LR', 'h2o', SPARK_EXECUTORS, time), h2o_lr_times),
        *map(lambda time: (GROUP, CLUSTER, 'GBT', 'spark-ml', SPARK_EXECUTORS, time), sparkML_gbt_times),
        *map(lambda time: (GROUP, CLUSTER, 'GBT', 'synapse-ml', SPARK_EXECUTORS, time), synapseML_gbt_times),
        *map(lambda time: (GROUP, CLUSTER, 'GBT', 'h2o', SPARK_EXECUTORS, time), h2o_gbt_times)
    ]

    training_data_columns = ['group', 'cluster', 'model', 'library', 'spark-executors', 'elapsed-time [s]']
    training_data_df = spark.createDataFrame(training_data).toDF(*training_data_columns)
    training_data_df.write.format("csv").mode('overwrite').options(header="true").save(OUTPUT_FILE_PATH)

    ######################################################################

except Exception as e:
    output = f"{e}"
    dfe = spark.createDataFrame([{'error':output}])
    dfe.write.format("csv") \
    .mode('overwrite').options(header="true").save("gs://${staging_bucket}/data/output-error.csv")

spark.stop()
