namespace 생성
kubectl create namespace airflow

movielens-api 이미지 빌드
docker build -t manning-airflow/movielens-api ./docker/movielens-api

스토리지 생성
kubectl --namespace airflow apply -f resources/data-volume.yml