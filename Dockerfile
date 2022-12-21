FROM prefecthq/prefect:2.4.5-python3.8

RUN apt-get update && \
    apt-get install -y vim

RUN cd / && mkdir -p files && mkdir -p prefect_files