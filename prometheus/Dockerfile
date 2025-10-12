# Prometheus Dockerfile
FROM ubuntu:22.04
# FROM prom/prometheus:latest

LABEL maintainer="private_service"

# 타임존 설정
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# 필요한 패키지 설치
RUN apt-get update && apt-get install -y \
    wget \
    tar \
    && rm -rf /var/lib/apt/lists/*

# Prometheus 버전 설정
ENV PROMETHEUS_VERSION=2.48.0

# Prometheus 디렉토리 생성 및 설정
RUN mkdir -p /etc/prometheus /prometheus

# Prometheus 다운로드 및 설치
RUN wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz \
    && tar -xzf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz \
    && mv prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus /usr/local/bin/ \
    && mv prometheus-${PROMETHEUS_VERSION}.linux-amd64/promtool /usr/local/bin/ \
    && mv prometheus-${PROMETHEUS_VERSION}.linux-amd64/consoles /etc/prometheus/ \
    && mv prometheus-${PROMETHEUS_VERSION}.linux-amd64/console_libraries /etc/prometheus/ \
    && rm -rf prometheus-${PROMETHEUS_VERSION}.linux-amd64*

# 사용자 생성
RUN useradd -rs /bin/false prometheus

# 권한 설정
RUN chown -R prometheus:prometheus /etc/prometheus /prometheus

# 사용자 전환
USER prometheus

# 설정 파일을 호스트의 설정 파일로 교체할 수 있도록 볼륨 설정
VOLUME [ "/etc/prometheus", "/prometheus" ]

# 포트 노출
EXPOSE 9090

# 헬스체크
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:9090/-/healthy || exit 1

# 기본 설정 파일 생성 (호스트에서 마운트될 파일로 교체 가능)
COPY prometheus.yml /etc/prometheus/prometheus.yml

# 실행 명령
CMD [ "/usr/local/bin/prometheus", \
      "--config.file=/etc/prometheus/prometheus.yml", \
      "--storage.tsdb.path=/prometheus", \
      "--web.console.libraries=/etc/prometheus/console_libraries", \
      "--web.console.templates=/etc/prometheus/consoles", \
      "--web.enable-lifecycle" ]

