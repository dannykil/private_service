#!/bin/bash
echo "Kong Gateway 초기화 시작..."

# 기존 컨테이너 정리
docker-compose stop kong-gateway kong-manager kong-database 2>/dev/null || true

# 데이터베이스만 시작
docker-compose up -d kong-database

# 데이터베이스 준비 대기 (서버 환경에서는 더 길게)
sleep 20

# 초기화 실행 (네트워크 이름 수정: kong-net 사용)
echo "데이터베이스 초기화 중..."
docker run --rm --network kong-net \
  -e KONG_DATABASE=postgres \
  -e KONG_PG_HOST=kong-database \
  -e KONG_PG_USER=kong \
  -e KONG_PG_PASSWORD=kong \
  kong:latest kong migrations bootstrap

if [ $? -eq 0 ]; then
    echo "초기화 성공! Kong 서비스 시작 중..."
    docker-compose up -d kong-gateway kong-manager
    echo "Kong Gateway 설치 완료!"
else
    echo "초기화 실패!"
    exit 1
fi