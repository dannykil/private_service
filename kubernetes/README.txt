### namespace 생성
kubectl create namespace airflow

### movielens-api 이미지 빌드
docker build -t manning-airflow/movielens-api ./docker/movielens-api

### 스토리지 생성
kubectl --namespace airflow apply -f resources/data-volume.yml

### helm 키워드 자동완성 설치
sudo yum install bash-completion
helm completion bash > /etc/bash_completion.d/helm
source /etc/bash_completion.d/helm

### kube config 파일 확인
ls -al ~/.kube
ls -al ~/.kube/config

### helm repository 관련 명령어
1) repository 등록(톰캣)
helm repo add bitnami https://charts.bitnami.com/bitnami
2) repository 검색
helm search repo bitnami | grep tomcat
3) repository에서 최신 버전 가져오기
helm repo update
4) repository 삭제
5) 톰캣 설치
helm install my-tomcat bitnami/tomcat --version 13.0.9 --set persistence.enabled=false
* persistence volume 사용안하고 파드에 저장