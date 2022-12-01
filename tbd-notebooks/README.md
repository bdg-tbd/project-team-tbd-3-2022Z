# tbd-notebooks

## Quick start

### prepare workdir
```
mkdir ~/tbd_ml/
cd ~/tbd_ml/
git clone git@github.com:bdg-tbd/tbd-notebooks.git
```

### run docker image
docker  run -v \`pwd\`:/home/jovyan/work/ -p 8888:8888 jupyter/pyspark-notebook  


### run notebooks from spark_ml folder:
1. run load_data.ipynb to download sample csv data and read it using sparkSQL

2. run =ml.ipynb to learn how to build machine learning pipeline with SparkML




