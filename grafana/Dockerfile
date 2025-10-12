# Grafana Dockerfile
FROM ubuntu:22.04
# FROM grafana/grafana:latest

LABEL maintainer="private_service"

# 타임존 설정
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 필요한 패키지 설치
RUN apt-get update && apt-get install -y \
    wget \
    tar \
    curl \
    apt-transport-https \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Grafana 버전 설정
ENV GRAFANA_VERSION=10.4.0

# Grafana 설치에 필요한 의존성 패키지들 먼저 설치
RUN apt-get update && apt-get install -y \
    libfontconfig1 \
    ca-certificates \
    curl \
    wget \
    musl \
    && rm -rf /var/lib/apt/lists/*

# Grafana ARM64 버전 다운로드 및 설치
RUN wget https://dl.grafana.com/oss/release/grafana_${GRAFANA_VERSION}_arm64.deb \
    && dpkg -i grafana_${GRAFANA_VERSION}_arm64.deb \
    && rm grafana_${GRAFANA_VERSION}_arm64.deb

# Grafana 사용자 생성 (이미 존재하면 무시)
RUN useradd -rs /bin/false grafana || true

# 권한 설정
RUN mkdir -p /var/lib/grafana \
    && chown -R grafana:grafana /var/lib/grafana /etc/grafana /usr/share/grafana
    
# 기존 데이터베이스 파일을 먼저 복사 (빌드 시점에)
# COPY grafana.db /var/lib/grafana/grafana.db

# 또는 빌드 시점에 데이터베이스 초기화를 방지
# RUN mkdir -p /var/lib/grafana \
#     && chown -R grafana:grafana /var/lib/grafana /etc/grafana /usr/share/grafana \
#     && if [ ! -f /var/lib/grafana/grafana.db ]; then \
#          # 데이터베이스 파일이 없으면 새로 생성하지 않음 \
#          echo "데이터베이스 파일이 호스트에서 마운트될 것입니다"; \
#        fi

# 사용자 전환
USER grafana

# 데이터 디렉토리 볼륨 설정
VOLUME [ "/var/lib/grafana" ]

# 포트 노출
EXPOSE 3000

# 헬스체크
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:3000/api/health || exit 1

# 환경 변수 설정 (docker-compose에서 설정할 값들)
ENV GF_SECURITY_ADMIN_USER=admin \
    GF_SECURITY_ADMIN_PASSWORD=admin \
    GF_LOG_LEVEL=info

# 실행 명령
CMD [ "/usr/sbin/grafana-server", \
      "--homepath=/usr/share/grafana", \
      "--config=/etc/grafana/grafana.ini", \
      "--packaging=deb", \
      "cfg:default.log.level=info" ]
