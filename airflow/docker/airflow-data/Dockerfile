ARG AIRFLOW_BASE_IMAGE="apache/airflow:2.10.5-python3.11"

FROM ${AIRFLOW_BASE_IMAGE}

USER root
RUN mkdir -p /data && chown airflow /data

USER airflow
