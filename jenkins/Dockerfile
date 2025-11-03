# Jenkins 공식 이미지를 기반으로 사용
FROM jenkins/jenkins:lts

# apt-get을 업데이트하고, Docker와 같은 필요한 도구들을 설치
# 이 단계는 Jenkins 컨테이너 내에서 Docker 명령어를 실행해야 할 때 유용합니다.
USER root
RUN apt-get update && apt-get install -y docker.io

# apt-get을 업데이트하고 curl, sudo를 설치 (root 권한으로 실행)
USER root
RUN apt-get update && apt-get install -y curl sudo

# docker-compose 설치
RUN curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Jenkins 사용자로 다시 전환
USER jenkins

# 컨테이너 시작 시 실행될 명령어를 지정 (선택 사항)
# ENTRYPOINT ["/usr/local/bin/jenkins.sh"]