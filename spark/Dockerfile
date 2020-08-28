FROM bde2020/spark-master:3.0.0-hadoop3.2

RUN pip install pyspark
RUN pip3 install pyspark

RUN mkdir /app
COPY cleanIdmapping.py /app

# Store input and output
VOLUME /scratch
