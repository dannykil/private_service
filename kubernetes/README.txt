### 대쉬보드
https://192.168.56.30:30000/#/login

cat ~/join.sh
>>> master 노드에서 토큰 재성성 후 적용
kubeadm token create --print-join-command > ~/join.sh

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
cat ~/.kube/config

### helm repository 관련 명령어
1) repository 등록(톰캣)
helm repo add bitnami https://charts.bitnami.com/bitnami
2) repository 검색
helm search repo bitnami | grep tomcat
3) repository에서 최신 버전 가져오기
helm repo update
4) repository 삭제
helm repo remove bitnami
5) 톰캣 설치
helm install my-tomcat bitnami/tomcat --version 13.0.9 --set persistence.enabled=false
* persistence volume 사용안하고 파드에 저장

### helm chart 관련 명령어
1) 현재 사용중인 헬름 차트
helm list
2) 상태 확인
helm status my-tomcat
3) 배포 삭제
helm uninstall my-tomcat
4) 톰캣 관리자 페이지에 접속되도록 설치
helm install my-tomcat bitnami/tomcat --version 10.5.17 --set persistence.enabled=false,tomcatAllowRemoteManagement=1
helm install my-tomcat bitnami/tomcat --version 13.0.9 --set persistence.enabled=false,tomcatAllowRemoteManagement=1

### helm chart download 관련 명령어
[다운로드]
helm pull bitnami/tomcat --version 10.5.17
helm pull bitnami/tomcat --version 13.0.9

[압축풀기]
tar -xf ./tomcat-10.5.17.tgz
tar -xf ./tomcat-13.0.9.tgz

[Tomcat 배포]
cd tomcat
helm install my-tomcat . -f values.yaml --set persistence.enabled=false
helm install my-tomcat . -f values.yaml