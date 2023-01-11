# tbd-notebooks

## run docker image to open phase2b notebooks
docker run -v \`pwd\`:/home/jovyan/work/ --rm -p 8888:8888 -p 4040:4040 -p 54321:54321 -it jupyter/pyspark-notebook:spark-3.2.1 




