DATA_PATH='./output/google_storage_output'

gsutil -m cp -r "gs://tbd-2022z-3-staging/data/ml/output/*" $DATA_PATH

find $DATA_PATH -type f -name '*.csv' -exec cat {} + |
    grep "^tbd-2022z-3" |
    sort |
    (echo 'group,cluster,model,library,spark-executors,elapsed-time [s]' && cat) > ./output/times.csv
