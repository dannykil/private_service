docker-compose up -d kong-database kong-gateway kong-manager
docker-compose down kong-database kong-gateway kong-manager

# Kong Gateway 서비스 구성 가이드

## 개요
이 디렉토리에는 Kong Gateway와 관련 서비스들을 위한 Docker Compose 구성이 포함되어 있습니다.

## 서비스 구성 요소

### 1. Kong Database (PostgreSQL)
- **이미지**: postgres:13
- **용도**: Kong Gateway의 설정과 데이터를 저장
- **데이터 위치**: `./kong_gateway/data/` (다른 서비스들과 동일하게 파일로 관리)
- **포트**: 내부 네트워크에서만 접근 가능

### 2. Kong Gateway
- **이미지**: 커스텀 Kong 이미지 (kong:latest 기반)
- **용도**: API Gateway로서 요청 라우팅, 인증, 속도 제한 등의 기능 제공
- **노출 포트**:
  - 8020: Kong Proxy 포트 (HTTP)
  - 8443: Kong Proxy 포트 (HTTPS)
  - 8030: Kong Admin API 포트 (HTTP)
  - 8444: Kong Admin API 포트 (HTTPS)

### 3. Kong Manager (UI)
- **이미지**: 커스텀 Kong 이미지 (kong:latest 기반)
- **용도**: 웹 기반 관리 인터페이스
- **노출 포트**:
  - 22222: Kong Manager 포트 (HTTP)
  - 8445: Kong Manager 포트 (HTTPS)

## 사용 방법

### 1단계: 서비스 시작
프로젝트 루트 디렉토리에서 다음 명령어를 실행하세요:

```bash
docker-compose up -d kong-database kong-gateway kong-manager
```

또는 전체 서비스를 한 번에 시작하려면:

```bash
# 전체 서비스를 한 번에 시작 (Kong 서비스들이 자동으로 시작됨)
docker-compose up -d
```

또는 Kong 서비스만 별도로 관리하려면:

```bash
# Kong 관련 서비스만 시작
docker-compose up -d kong-database kong-gateway kong-manager
```

### 2단계: Kong Gateway 초기화 (최초 실행 시 필수)
Kong Gateway를 처음 실행할 때 데이터베이스 초기화가 필요합니다:

```bash
# 데이터베이스 서비스만 먼저 시작
docker-compose up -d kong-database

# 데이터베이스 준비 대기 (10-15초 정도)
sleep 15

# Kong 데이터베이스 초기화 실행
docker run --rm --network private_service_kong-net \
  -e KONG_DATABASE=postgres \
  -e KONG_PG_HOST=kong-database \
  -e KONG_PG_USER=kong \
  -e KONG_PG_PASSWORD=kong \
  kong:latest kong migrations bootstrap

# 초기화 완료 후 모든 Kong 서비스 시작
docker-compose up -d kong-gateway kong-manager
```

**참고**: 초기화는 Kong Gateway의 수명 주기 동안 단 한 번만 실행하면 됩니다. 초기화 후에는 일반적인 `docker-compose up` 명령어로 서비스를 시작할 수 있습니다.

### 3단계: 서비스 확인
서비스가 정상적으로 실행되었는지 확인:

```bash
# 모든 서비스 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs kong-gateway
docker-compose logs kong-manager
docker-compose logs kong-database
```

## 접근 정보

### Kong Gateway Admin API
- **URL**: http://localhost:8030
- **기능**: API 설정 관리, 플러그인 설정 등

### Kong Manager (웹 UI)
- **URL**: http://localhost:22222
- **기능**: 웹 기반 Kong Gateway 관리 인터페이스

### Kong Gateway Proxy
- **URL**: http://localhost:8020 (프록시 요청용)
- **기능**: 실제 API 요청을 처리하는 게이트웨이 엔드포인트

## 서비스 중단 및 정리

### 서비스 중단
```bash
# Kong 서비스만 중단
docker-compose stop kong-database kong-gateway kong-manager

# 전체 서비스 중단
docker-compose down
```

### 데이터베이스 데이터 삭제 (초기화)
```bash
# Kong 데이터 디렉토리 삭제 (주의: 모든 데이터가 삭제됩니다)
sudo rm -rf ./kong_gateway/data/

# 또는 docker-compose로 전체 정리
docker-compose down -v
```

## 커스터마이징

Kong Gateway 설정을 커스터마이징하려면 `kong_gateway/` 디렉토리에 설정 파일을 추가하고 Dockerfile을 수정하세요.

예시 설정 파일 구조:
```
kong_gateway/
├── Dockerfile
├── kong.conf          # Kong 설정 파일
└── plugins/           # 커스텀 플러그인 디렉토리
    └── custom-plugin/
        ├── handler.lua
        ├── schema.lua
        └── ...
```

## 주요 포트 할당

| 서비스 | 포트 | 설명 |
|--------|------|------|
| Kong Gateway Proxy | 8020 | HTTP 프록시 포트 |
| Kong Gateway Proxy | 8443 | HTTPS 프록시 포트 |
| Kong Admin API | 8030 | HTTP 관리 API |
| Kong Admin API | 8444 | HTTPS 관리 API |
| Kong Manager | 22222 | HTTP 웹 UI |
| Kong Manager | 8445 | HTTPS 웹 UI |
