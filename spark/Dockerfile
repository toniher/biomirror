FROM bde2020/spark-base:3.0.0-hadoop3.2

RUN mkdir /app
COPY cleanIdmapping.py /app
COPY rewrite-IDmapping.py /app
COPY requirements.txt /tmp/requirements.txt

RUN pip install -r /tmp/requirements.txt
RUN pip3 install -r /tmp/requirements.txt

# Store input and output
VOLUME /scratch
