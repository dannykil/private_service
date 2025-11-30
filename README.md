# Private Service - 오픈소스 서비스 관리 프로젝트

이 프로젝트는 로컬 머신에서 다양한 오픈소스 서비스들을 Docker 컨테이너로 쉽게 실행하고 관리할 수 있도록 구성되어 있습니다.

## 🚀 지원하는 서비스들

현재 프로젝트에서 구성 가능한 서비스들은 다음과 같습니다:

| 서비스           | 프로필     | 포트        | 설명                                   |
| ---------------- | ---------- | ----------- | -------------------------------------- |
| **Prometheus**   | monitoring | 9090        | 시계열 데이터베이스 및 모니터링 시스템 |
| **Grafana**      | monitoring | 3000        | 데이터 시각화 및 대시보드 플랫폼       |
| **GitLab**       | gitlab     | 80, 443, 22 | Git 저장소 관리 시스템                 |
| **Jenkins**      | jenkins    | 8080, 50000 | CI/CD 자동화 서버                      |
| **Kong Gateway** | kong       | 8020, 8030  | API 게이트웨이 및 마이크로서비스 관리  |
| **Airflow**      | airflow    | 8000, 5432  | 워크플로우 스케줄링 및 모니터링        |
| **Qdrant**       | llm        | 6333, 6334  | 벡터 데이터베이스                      |
| **Redis**        | redis      | 6379        | 인메모리 데이터 저장소                 |
| **n8n**          | n8n        | 5678        | 워크플로우 자동화 플랫폼               |

## 📋 빠른 시작

### Docker Compose 프로필 (Profile) 사용법

이 프로젝트는 단일 `docker-compose.yml` 파일에서 프로필 기반으로 서비스를 관리합니다.

#### 기본 명령어

```bash
# 특정 프로필의 서비스 시작
docker compose --profile <프로필명> up -d

# 특정 프로필의 서비스 종료
docker compose --profile <프로필명> down

# 특정 프로필의 서비스 상태 확인
docker compose --profile <프로필명> ps

# 특정 프로필의 서비스 로그 확인
docker compose --profile <프로필명> logs -f
```

#### 프로필별 서비스 시작 예시

```bash
# Prometheus & Grafana (모니터링) 시작
docker compose --profile monitoring up -d

# Jenkins (CI/CD) 시작
docker compose --profile jenkins up -d

# GitLab (Git 저장소) 시작
docker compose --profile gitlab up -d

# Kong Gateway (API 게이트웨이) 시작
docker compose --profile kong up -d

# Airflow (워크플로우 스케줄러) 시작
docker compose --profile airflow up -d

# Qdrant (벡터 DB) 시작
docker compose --profile llm up -d

# Redis (캐시) 시작
docker compose --profile redis up -d

# n8n (워크플로우 자동화) 시작
docker compose --profile n8n up -d
```

#### 여러 프로필 동시 실행

```bash
# 모니터링 + Jenkins 동시 시작
docker compose --profile monitoring --profile jenkins up -d

# 모든 서비스 종료
docker compose --profile monitoring --profile jenkins --profile gitlab --profile kong --profile airflow --profile llm --profile redis --profile n8n down
```

### 1. 서비스 상태 확인

```bash
# 실행 중인 모든 컨테이너 확인
docker ps

# 모든 컨테이너 확인 (중지된 것 포함)
docker ps -a

# 특정 프로필 서비스 상태
docker compose --profile monitoring ps
```

## 🔧 서비스별 설정 및 사용법

### Prometheus (모니터링)

- **프로필**: `monitoring`
- **웹 UI**: http://localhost:9090
- **기능**: 시계열 데이터 수집 및 쿼리
- **설정**: `prometheus/prometheus.yml`
- **시작**: `docker compose --profile monitoring up -d`

### Grafana (대시보드)

- **프로필**: `monitoring`
- **웹 UI**: http://localhost:3000
- **기본 계정**: admin / admin
- **기능**: 데이터 시각화 및 대시보드 생성
- **데이터 저장**: `./grafana/data`
- **시작**: `docker compose --profile monitoring up -d`

### GitLab (Git 저장소)

- **프로필**: `gitlab`
- **웹 UI**: http://localhost
- **HTTPS**: https://localhost:443
- **SSH Git**: localhost:22
- **기능**: Git 저장소 호스팅 및 프로젝트 관리
- **데이터 저장**: `./gitlab/data`, `./gitlab/logs`, `./gitlab/config`
- **시작**: `docker compose --profile gitlab up -d`
- **초기 비밀번호**: `./gitlab/config/initial_root_password` 참조

### Jenkins (CI/CD)

- **프로필**: `jenkins`
- **웹 UI**: http://localhost:8080
- **Agent 포트**: 50000
- **기능**: 빌드, 테스트, 배포 자동화
- **데이터 저장**: `./jenkins/data`
- **시작**: `docker compose --profile jenkins up -d`
- **Docker-in-Docker**: 지원 (Docker 소켓 마운트)

### Kong Gateway (API 게이트웨이)

- **프로필**: `kong`
- **프록시**: http://localhost:8020
- **관리 API**: http://localhost:8030
- **관리 UI**: http://localhost:22222
- **기능**: API 라우팅, 인증, 속도 제한 등
- **데이터베이스**: PostgreSQL (내장)
- **시작**: `docker compose --profile kong up -d`

### Airflow (워크플로우 스케줄러)

- **프로필**: `airflow`
- **웹 UI**: http://localhost:8000
- **기본 계정**: admin / admin
- **기능**: 데이터 파이프라인 스케줄링 및 모니터링
- **DAG 경로**: `/Users/danniel.kil/Documents/workspace/search-admin/airflow/dags`
- **데이터 저장**: `./airflow/data`, `./airflow/logs`, `./airflow/postgres-data`
- **시작**: `docker compose --profile airflow up -d`

### Qdrant (벡터 데이터베이스)

- **프로필**: `llm`
- **API**: http://localhost:6333
- **웹 UI**: http://localhost:6334
- **기능**: 벡터 검색 및 유사도 검색
- **데이터 저장**: `./qdrant/storage`, `./qdrant/config`
- **PostgreSQL**: localhost:5432 (metadata 저장)
- **시작**: `docker compose --profile llm up -d`

### Redis (캐시 서버)

- **프로필**: `redis`
- **포트**: 6379
- **기능**: 인메모리 데이터 저장소, 캐싱, 세션 관리
- **데이터 저장**: `./redis/redis_data`
- **영속성**: AOF (Append Only File) 활성화
- **시작**: `docker compose --profile redis up -d`

### n8n (워크플로우 자동화)

- **프로필**: `n8n`
- **웹 UI**: http://localhost:5678
- **기본 계정**: admin / admin
- **기능**: 노코드/로우코드 자동화 플랫폼, 다양한 서비스 연동
- **데이터 저장**: `./n8n/data`
- **타임존**: Asia/Seoul
- **시작**: `docker compose --profile n8n up -d`
- **특징**:
  - 워크플로우, 자격증명, 실행 데이터 영구 저장
  - 300개 이상의 앱 통합 지원
  - 시각적 워크플로우 빌더

## 🛠️ 개발자용 설정

### Docker Compose 프로필 관리 팁

```bash
# 자주 사용하는 프로필 조합을 alias로 설정
alias dc-dev="docker compose --profile monitoring --profile redis"
alias dc-all="docker compose --profile monitoring --profile jenkins --profile gitlab --profile kong --profile airflow --profile llm --profile redis --profile n8n"

# 사용 예시
dc-dev up -d      # 개발 환경 시작
dc-all down       # 모든 서비스 종료
```

### 환경변수 설정

```bash
# Airflow 설정 (필요시)
export AIRFLOW__CORE__EXECUTOR=LocalExecutor
export AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql://airflow:airflow@localhost:5432/airflow

# Qdrant 설정 (필요시)
export QDRANT_HOST=localhost
export QDRANT_PORT=6333

# n8n 추가 설정 (필요시)
export N8N_ENCRYPTION_KEY="your-encryption-key"
```

### 사용자 정의 설정

`docker-compose.yml` 파일을 수정하여 설정을 변경할 수 있습니다:

```bash
# docker-compose.yml 편집
vim docker-compose.yml

# 변경 사항 적용
docker compose --profile <프로필명> down
docker compose --profile <프로필명> up -d
```

### 로그 확인

```bash
# 특정 프로필의 모든 서비스 로그
docker compose --profile monitoring logs -f

# 특정 컨테이너 로그
docker logs -f grafana
docker logs -f prometheus
docker logs -f n8n

# 최근 100줄만 확인
docker logs --tail 100 jenkins
```

### 데이터 백업 (컨테이너 삭제 전)

```bash
# 중요 데이터가 저장되는 디렉토리들
./grafana/data          # Grafana 대시보드 및 설정
./jenkins/data          # Jenkins 작업 및 플러그인
./gitlab/data           # GitLab 저장소 및 데이터
./prometheus/data       # Prometheus 메트릭 데이터
./airflow/logs          # Airflow 로그
./qdrant/storage        # Qdrant 벡터 데이터
./redis/redis_data      # Redis 데이터
./n8n/data              # n8n 워크플로우 및 자격증명

# 백업 예시
tar -czf backup_$(date +%Y%m%d).tar.gz ./grafana/data ./jenkins/data ./n8n/data
```

### 문제 해결

```bash
# 컨테이너 상태 확인
docker ps -a

# 특정 프로필 서비스 상태
docker compose --profile monitoring ps

# 시스템 자원 확인
docker system df

# 특정 컨테이너 재시작
docker restart grafana
docker restart n8n

# 로그로 문제 진단
docker logs --tail 50 jenkins

# 컨테이너 내부 접속 (디버깅)
docker exec -it n8n /bin/sh
docker exec -it grafana /bin/bash

# 네트워크 문제 확인
docker network ls
docker network inspect private_service_default

# 포트 충돌 확인
netstat -tuln | grep <포트번호>
lsof -i :<포트번호>

# 로그 및 캐시 정리
docker system prune
docker volume prune
```

### 일반적인 문제 해결

#### 포트 충돌

```bash
# 포트 사용 중인 프로세스 확인
lsof -i :5678  # n8n 포트 예시

# 프로세스 종료
kill -9 <PID>
```

#### 데이터 복원 안됨

```bash
# 볼륨 권한 확인
ls -la ./n8n/data
ls -la ./grafana/data

# 권한 수정 (필요시)
sudo chown -R $USER:$USER ./n8n/data
```

#### 서비스 응답 없음

```bash
# 컨테이너 재시작
docker compose --profile n8n restart

# 전체 재시작
docker compose --profile n8n down
docker compose --profile n8n up -d
```

## 💾 데이터 백업 (GCS - Google Cloud Storage)

프로젝트에는 각 서비스의 데이터를 Google Cloud Storage로 자동 백업하는 기능이 포함되어 있습니다.

### 백업 설정

1. **GCS 버킷 생성** (Google Cloud Console에서)

   ```bash
   # GCS 버킷 생성 예시
   gsutil mb gs://your-backup-bucket-name
   ```

2. **서비스 계정 생성 및 키 다운로드**

   Google Cloud Console에서:

   - IAM & Admin > Service Accounts로 이동
   - 새 서비스 계정 생성
   - **Storage Object Admin** 역할 부여
   - 키 생성 (JSON 형식)
   - 다운로드한 키를 `secret_keys/` 디렉토리에 저장

   ```bash
   # 키 파일 위치 예시
   secret_keys/your-service-account-key.json
   ```

3. **인증 설정 (선택사항 - 로컬 개발용)**

   ```bash
   # Google Cloud 인증 (선택사항)
   gcloud auth login
   gcloud config set project your-project-id
   ```

4. **스크립트 설정 수정**

   `backup-to-gcs.sh` 파일 상단의 설정 섹션에서 서비스 계정 키 경로와 GCS 버킷을 설정하세요:

   ```bash
   # 🚨 서비스 계정 키 파일 절대 경로 (필수)
   SERVICE_ACCOUNT_KEY="/path/to/your-service-account-key.json"

   # GCS 버킷 설정 (필수)
   GCS_BUCKET="gs://your-actual-bucket-name"

   # 선택사항 설정
   GCP_PROJECT_ID="your-project-id"            # Google Cloud 프로젝트 ID
   BACKUP_ROOT_DIR="./backups"                # 백업 파일 저장 디렉토리
   BACKUP_COMPRESSION_LEVEL=6                 # 압축 레벨 (1-9)
   BACKUP_PARALLEL=false                      # 병렬 백업 사용 여부
   LOG_LEVEL="INFO"                          # 로그 레벨
   LOG_MAX_FILES=30                          # 보관할 로그 파일 최대 개수
   EXCLUDE_PATTERNS="*.tmp *.log.* .git"     # 제외할 파일 패턴
   BACKUP_SCHEDULE="0 2 * * *"               # 백업 스케줄 (cron 형식)
   ```

### 백업 실행

```bash
# 전체 서비스 백업
./backup-to-gcs.sh

# 특정 서비스만 백업
./backup-to-gcs.sh --service grafana

# 다른 GCS 버킷 사용
./backup-to-gcs.sh --bucket gs://my-custom-bucket

# 백업 테스트 (실제 업로드 없이)
./backup-to-gcs.sh --dry-run

# 디버깅 정보 출력
./backup-to-gcs.sh --debug

# Crontab 설정 가이드 확인
./backup-to-gcs.sh --setup-cron

# 도움말 확인
./backup-to-gcs.sh --help
```

### Crontab 자동 백업 설정

정기적으로 자동 백업을 수행하려면 다음 단계를 따르세요:

#### 1. Sudo 권한 설정 (비밀번호 없이 실행)

Docker 볼륨 백업을 위해 sudo 권한이 필요하지만, crontab에서는 비밀번호를 입력할 수 없으므로 NOPASSWD 설정이 필요합니다.

```bash
# Sudoers 설정 파일 생성
sudo tee /etc/sudoers.d/backup-script << 'EOF'
# Backup script - Allow tar and chown without password
YOUR_USERNAME ALL=(ALL) NOPASSWD: /bin/tar
YOUR_USERNAME ALL=(ALL) NOPASSWD: /bin/chown
EOF

# 설정 파일 권한 설정
sudo chmod 0440 /etc/sudoers.d/backup-script

# 설정 검증
sudo visudo -c
```

> ⚠️ **주의**: `YOUR_USERNAME`을 실제 사용자 이름으로 변경하세요 (예: `gpuadmin`)

#### 2. Crontab 등록

```bash
# Crontab 편집
crontab -e

# 다음 내용을 추가 (매일 새벽 2시 실행 예시)
# 서비스 백업 (매일 새벽 2시)
0 2 * * * cd /path/to/private_service && /path/to/private_service/backup-to-gcs.sh >> /path/to/private_service/logs/backup/cron.log 2>&1
```

**Cron 스케줄 예시:**

- `0 2 * * *` - 매일 새벽 2시
- `0 */6 * * *` - 6시간마다
- `0 0 * * 0` - 매주 일요일 자정
- `0 3 1 * *` - 매월 1일 새벽 3시

#### 3. 설정 확인

```bash
# Crontab 목록 확인
crontab -l

# 수동 테스트 실행
./backup-to-gcs.sh

# Cron 로그 확인
tail -f ./logs/backup/cron.log
```

#### 4. 자동 설정 가이드 사용

스크립트에 내장된 설정 가이드를 사용하면 더 쉽게 설정할 수 있습니다:

```bash
./backup-to-gcs.sh --setup-cron
```

### 백업 대상

현재 백업이 구성된 서비스들:

- **Airflow**: `airflow/logs`, `airflow/postgres-data`
- **GitLab**: `gitlab/data`, `gitlab/logs`, `gitlab/config`
- **Grafana**: `grafana/data`
- **Jenkins**: `jenkins/data`
- **Kong Gateway**: `kong_gateway/data`
- **Prometheus**: `prometheus/data`
- **Qdrant**: `qdrant/storage`, `qdrant/postgres_data`
- **Redis**: `redis/redis_data`
- **n8n**: `n8n/data`

### 백업 특징

- 🔒 **압축 백업**: 각 폴더를 tar.gz로 압축하여 업로드
- 📅 **타임스탬프**: 백업 파일명에 날짜/시간 포함
- 📊 **진행 상황**: 실시간 로그 및 진행률 표시
- 🧹 **자동 정리**: 임시 파일 자동 삭제
- ⚡ **병렬 처리**: 각 서비스를 독립적으로 백업
- 🔐 **권한 관리**: Docker 볼륨 접근을 위한 sudo 권한 자동 처리
- ☁️ **GCS 통합**: Google Cloud Storage 서비스 계정 인증
- 🤖 **Crontab 지원**: 자동화된 정기 백업 설정 가능
- 🐛 **디버깅 모드**: 문제 해결을 위한 상세 정보 제공

### 백업 로그

모든 백업 작업은 `./logs/backup/YYYY/MM/DD/backup_YYYYMMDD_HHMMSS.log` 구조로 기록됩니다.

예시:

```
logs/backup/
└── 2025/
    └── 10/
        └── 16/
            ├── backup_20251016_095512.log
            └── backup_20251016_143022.log
```

## 📥 데이터 복원 (GCS에서 로컬로)

백업된 데이터를 Google Cloud Storage에서 로컬로 복원하는 기능이 포함되어 있습니다.

### 복원 설정

복원 스크립트는 백업 스크립트와 동일한 서비스 계정 키와 GCS 버킷을 사용합니다.

1. **스크립트 설정 수정**

   `restore-from-gcs.sh` 파일 상단의 설정 섹션에서 서비스 계정 키 경로와 GCS 버킷을 설정하세요:

   ```bash
   # 🚨 서비스 계정 키 파일 절대 경로 (필수)
   SERVICE_ACCOUNT_KEY="/path/to/your-service-account-key.json"

   # GCS 버킷 설정 (필수)
   GCS_BUCKET="gs://your-actual-bucket-name"

   # 선택사항 설정
   GCP_PROJECT_ID="your-project-id"            # Google Cloud 프로젝트 ID
   RESTORE_ROOT_DIR="./restored"              # 복원할 대상 디렉토리
   TEMP_DOWNLOAD_DIR="/tmp/restore-temp"      # 임시 다운로드 디렉토리
   LOG_LEVEL="INFO"                          # 로그 레벨
   ```

2. **복원할 서비스 선택**

   스크립트 내부의 `SERVICES` 배열에서 복원할 서비스를 주석 해제하세요:

   ```bash
   SERVICES=(
       # "airflow"
       # "gitlab"
       "grafana"        # 주석 해제하면 복원됨
       # "jenkins"
       "kong_gateway"   # 주석 해제하면 복원됨
       # "ollama"
       # "open_web_ui"
       "prometheus"     # 주석 해제하면 복원됨
   )
   ```

### 복원 실행

```bash
# GCS 백업 목록 조회
./restore-from-gcs.sh --list

# 모든 서비스의 최신 백업 복원
./restore-from-gcs.sh --latest

# 특정 서비스만 복원
./restore-from-gcs.sh --service grafana --latest

# 특정 날짜의 백업 복원 (YYYYMMDD 형식)
./restore-from-gcs.sh --date 20251025

# 특정 디렉토리에 복원
./restore-from-gcs.sh --target-dir /custom/path --latest

# 복원 테스트 (실제 복원 없이 목록만 조회)
./restore-from-gcs.sh --dry-run

# 디버깅 정보 출력
./restore-from-gcs.sh --debug

# 다른 GCS 버킷 사용
./restore-from-gcs.sh --bucket gs://my-custom-bucket --list

# 도움말 확인
./restore-from-gcs.sh --help
```

### 복원 대상

`SERVICES` 배열에 정의된 서비스들의 백업을 복원할 수 있습니다:

- **Airflow**
- **GitLab**
- **Grafana**
- **Jenkins**
- **Kong Gateway**
- **Prometheus**
- **Qdrant**
- **Redis**
- **n8n**

### 복원 특징

- 📥 **자동 다운로드**: GCS에서 최신 또는 특정 날짜의 백업 다운로드
- 📂 **압축 해제**: tar.gz 파일 자동 압축 해제
- 🔐 **권한 관리**: 필요시 sudo 권한 자동 사용
- 🛡️ **안전한 복원**: 기본적으로 `./restored/` 디렉토리에 복원하여 기존 데이터 보호
- 📋 **백업 목록 조회**: GCS에 있는 모든 백업 파일 확인 가능
- 📅 **날짜별 복원**: 특정 날짜의 백업 선택적 복원
- 🎯 **선택적 복원**: 특정 서비스만 복원 가능
- 🧹 **자동 정리**: 다운로드한 임시 파일 자동 삭제
- 🐛 **디버깅 모드**: 문제 해결을 위한 상세 정보 제공

### 복원 프로세스

1. **GCS 백업 목록 확인**

   ```bash
   ./restore-from-gcs.sh --list
   ```

   출력 예시:

   ```
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   서비스: grafana
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   gs://private_service/grafana/data_20251025_192938.tar.gz
   gs://private_service/grafana/data_20251025_151934.tar.gz
   ```

2. **복원 실행**

   ```bash
   # 최신 백업 복원
   ./restore-from-gcs.sh --latest
   ```

   복원된 파일은 기본적으로 `./restored/` 디렉토리에 저장됩니다:

   ```
   restored/
   ├── grafana/
   │   └── data/
   ├── kong_gateway/
   │   └── data/
   └── prometheus/
       └── data/
   ```

3. **복원된 데이터 적용 (수동)**

   복원된 데이터를 실제 서비스 디렉토리로 이동:

   ```bash
   # 주의: 기존 데이터가 덮어쓰여집니다!

   # 서비스 중지
   ./manage-services.sh stop grafana

   # 기존 데이터 백업 (선택사항)
   mv grafana/data grafana/data.backup

   # 복원된 데이터 이동
   mv restored/grafana/data grafana/data

   # 서비스 시작
   ./manage-services.sh start grafana
   ```

### 복원 로그

모든 복원 작업은 `./logs/restore/YYYY/MM/DD/restore_YYYYMMDD_HHMMSS.log` 구조로 기록됩니다.

예시:

```
logs/restore/
└── 2025/
    └── 10/
        └── 25/
            ├── restore_20251025_150512.log
            └── restore_20251025_193022.log
```

### 복원 시 주의사항

⚠️ **복원 전 확인사항:**

1. **서비스 중지**: 복원 대상 서비스를 먼저 중지하세요
2. **백업 확인**: 복원하기 전에 현재 데이터를 백업하세요
3. **디스크 공간**: 충분한 디스크 공간이 있는지 확인하세요
4. **백업 검증**: `--list` 옵션으로 복원할 백업 파일을 확인하세요
5. **테스트**: 중요한 데이터는 `--dry-run`으로 먼저 테스트하세요

### 복원 예시 시나리오

#### 시나리오 1: Grafana 대시보드 복구

```bash
# 1. Grafana 백업 목록 확인
./restore-from-gcs.sh --service grafana --list

# 2. 최신 백업 복원
./restore-from-gcs.sh --service grafana --latest

# 3. Grafana 중지
./manage-services.sh stop grafana

# 4. 기존 데이터 백업
mv grafana/data grafana/data.old

# 5. 복원된 데이터 이동
mv restored/grafana/data grafana/data

# 6. Grafana 시작
./manage-services.sh start grafana
```

#### 시나리오 2: 특정 날짜로 롤백

```bash
# 10월 23일 백업으로 복원
./restore-from-gcs.sh --date 20251023
```

#### 시나리오 3: 전체 시스템 복원

```bash
# 1. 모든 서비스 중지
./manage-services.sh stop-all

# 2. 백업 목록 확인
./restore-from-gcs.sh --list

# 3. 최신 백업 전체 복원
./restore-from-gcs.sh --latest

# 4. 복원된 데이터 각 서비스로 이동 (스크립트 작성 권장)
# ... 데이터 이동 작업 ...

# 5. 모든 서비스 시작
./manage-services.sh start-all
```

## 📁 프로젝트 구조

```
private_service/
├── docker-compose.yml          # 통합 Docker Compose 설정 (프로필 기반)
├── backup-to-gcs.sh           # GCS 백업 스크립트 (통합 설정 포함)
├── restore-from-gcs.sh        # GCS 복원 스크립트
├── clean-images.sh            # Docker 이미지 정리 스크립트
├── README.md                  # 프로젝트 문서
│
├── logs/                      # 로그 디렉토리
│   ├── backup/               # 백업 로그 (YYYY/MM/DD 구조)
│   └── restore/              # 복원 로그 (YYYY/MM/DD 구조)
│
├── backups/                   # 로컬 백업 디렉토리
│   ├── grafana/
│   ├── kong_gateway/
│   └── prometheus/
│
├── restored/                  # 복원된 데이터 임시 디렉토리
│
├── secret_keys/               # GCS 서비스 계정 키 저장소
│   └── *.json
│
├── prometheus/                # Prometheus (프로필: monitoring)
│   ├── prometheus.yml
│   ├── data/
│   ├── Dockerfile
│   └── README.txt
│
├── grafana/                   # Grafana (프로필: monitoring)
│   ├── data/
│   ├── Dockerfile
│   └── README.txt
│
├── gitlab/                    # GitLab (프로필: gitlab)
│   ├── config/
│   ├── data/
│   ├── logs/
│   ├── Dockerfile
│   └── README.txt
│
├── jenkins/                   # Jenkins (프로필: jenkins)
│   ├── data/
│   ├── Dockerfile
│   ├── Jenkinsfile
│   └── README.txt
│
├── kong_gateway/              # Kong Gateway (프로필: kong)
│   ├── data/
│   ├── Dockerfile
│   ├── kong_init.sh
│   └── README.txt
│
├── airflow/                   # Airflow (프로필: airflow)
│   ├── dags/
│   ├── data/
│   ├── logs/
│   ├── postgres-data/
│   ├── plugins/
│   └── docker/
│       └── airflow-data/
│           └── Dockerfile
│
├── qdrant/                    # Qdrant (프로필: llm)
│   ├── storage/
│   ├── config/
│   └── postgres_data/
│
├── redis/                     # Redis (프로필: redis)
│   ├── redis_data/
│   └── README.txt
│
├── n8n/                       # n8n (프로필: n8n)
│   └── data/                 # 워크플로우, 자격증명, 실행 데이터
│
├── argocd/                    # ArgoCD (미구성)
├── kubernetes/                # Kubernetes 설정
│   ├── docker/
│   ├── resources/
│   └── install scripts
│
├── lite_llm/                  # LiteLLM (미구성)
│   └── README.txt
│
├── nexus/                     # Nexus (미구성)
│
├── ollama/                    # Ollama (주석 처리)
│   ├── data/
│   ├── Dockerfile
│   └── README.txt
│
├── open_web_ui/               # Open WebUI (주석 처리)
│   ├── data/
│   ├── Dockerfile
│   └── README.txt
│
└── ragas/                     # RAGAS (미구성)
    └── README.txt
```

### 프로필별 서비스 그룹

| 프로필       | 서비스                                                               | 용도                |
| ------------ | -------------------------------------------------------------------- | ------------------- |
| `monitoring` | prometheus, grafana                                                  | 시스템 모니터링     |
| `gitlab`     | gitlab                                                               | Git 저장소          |
| `jenkins`    | jenkins                                                              | CI/CD 파이프라인    |
| `kong`       | kong-database, kong-migration, kong-gateway, kong-manager            | API 게이트웨이      |
| `airflow`    | airflow-postgres, airflow-init, airflow-webserver, airflow-scheduler | 워크플로우 스케줄러 |
| `llm`        | qdrant, qdrant-postgres                                              | 벡터 DB 및 LLM 지원 |
| `redis`      | redis                                                                | 캐시 및 세션 저장소 |
| `n8n`        | n8n                                                                  | 워크플로우 자동화   |

## 🚨 주의사항

1. **포트 충돌**: 각 서비스가 사용하는 포트가 충돌하지 않도록 확인하세요.

   - Grafana: 3000
   - n8n: 5678
   - Airflow: 8000
   - Jenkins: 8080
   - Kong: 8020, 8030, 22222
   - Prometheus: 9090
   - Redis: 6379
   - Qdrant: 6333, 6334

2. **자원 사용량**: 모든 서비스를 동시에 실행하면 많은 시스템 자원을 사용합니다.

   - 최소 권장: RAM 16GB, Disk 50GB
   - 전체 실행 시: RAM 32GB+, Disk 100GB+

3. **데이터 영구성**: 각 서비스의 데이터는 로컬 디렉토리에 마운트되므로 컨테이너 재생성 시에도 데이터가 유지됩니다.

   - 데이터 손실 방지를 위해 정기적인 백업 권장
   - `./backup-to-gcs.sh` 사용 권장

4. **보안**: 프로덕션 환경에서는 반드시 적절한 보안 설정을 적용하세요.

   - 기본 비밀번호 변경 (admin/admin 등)
   - HTTPS 설정
   - 방화벽 규칙 적용
   - 민감한 데이터 암호화

5. **프로필 관리**: 필요한 서비스만 선택적으로 실행하세요.

   ```bash
   # 개발 환경 예시
   docker compose --profile monitoring --profile redis up -d

   # 전체 환경 예시
   docker compose --profile monitoring --profile jenkins --profile gitlab --profile kong --profile airflow --profile llm --profile redis --profile n8n up -d
   ```

6. **데이터 디렉토리 권한**: 일부 서비스는 특정 권한이 필요할 수 있습니다.
   ```bash
   # 필요시 권한 조정
   sudo chown -R $USER:$USER ./n8n/data
   sudo chown -R $USER:$USER ./grafana/data
   ```

## 🤝 기여

새로운 서비스를 추가하려면:

1. `docker-compose.yml`에 서비스 정의 추가

   ```yaml
   new-service:
     image: service/image:tag
     container_name: new-service
     ports:
       - '포트:포트'
     volumes:
       - ./new-service/data:/data
     profiles:
       - new-service
   ```

2. 데이터 디렉토리 생성

   ```bash
   mkdir -p ./new-service/data
   ```

3. README.md 업데이트

   - 서비스 목록 테이블에 추가
   - 서비스별 설정 섹션 추가
   - 프로젝트 구조 업데이트

4. 백업 스크립트 업데이트 (필요시)

   - `backup-to-gcs.sh`에 서비스 추가
   - `restore-from-gcs.sh`에 서비스 추가

5. 테스트
   ```bash
   docker compose --profile new-service up -d
   docker compose --profile new-service ps
   docker compose --profile new-service logs -f
   ```

## 📞 지원

문제 발생 시:

1. **로그 확인**

   ```bash
   docker compose --profile <프로필명> logs -f
   docker logs <컨테이너명>
   ```

2. **서비스 상태 확인**

   ```bash
   docker compose --profile <프로필명> ps
   docker ps -a
   ```

3. **공식 문서 참조**

   - [Docker Compose](https://docs.docker.com/compose/)
   - [Prometheus](https://prometheus.io/docs/)
   - [Grafana](https://grafana.com/docs/)
   - [GitLab](https://docs.gitlab.com/)
   - [Jenkins](https://www.jenkins.io/doc/)
   - [Kong](https://docs.konghq.com/)
   - [Airflow](https://airflow.apache.org/docs/)
   - [Qdrant](https://qdrant.tech/documentation/)
   - [Redis](https://redis.io/documentation)
   - [n8n](https://docs.n8n.io/)

4. **일반적인 문제 해결**
   - 포트 충돌: `lsof -i :<포트>` 확인
   - 권한 문제: `sudo chown -R $USER:$USER <디렉토리>`
   - 디스크 공간: `docker system df` 확인
   - 메모리 부족: 불필요한 서비스 종료

## 📚 추가 자료

### 유용한 Docker 명령어

```bash
# 모든 컨테이너 중지
docker stop $(docker ps -q)

# 사용하지 않는 이미지 정리
docker image prune -a

# 볼륨 확인
docker volume ls

# 네트워크 확인
docker network ls

# 리소스 사용량 확인
docker stats

# 컨테이너 리소스 제한
docker update --memory 2g --cpus 2 <컨테이너명>
```

### 프로필 조합 예시

```bash
# 기본 개발 환경
docker compose --profile monitoring --profile redis up -d

# 풀스택 개발 환경
docker compose --profile monitoring --profile jenkins --profile gitlab --profile redis up -d

# AI/ML 개발 환경
docker compose --profile monitoring --profile llm --profile n8n --profile redis up -d

# 전체 프로덕션 환경
docker compose --profile monitoring --profile jenkins --profile gitlab --profile kong --profile airflow --profile llm --profile redis --profile n8n up -d
```

## 폴더 복사

scp -r /Users/danniel.kil/Documents/workspace/private_service root@192.168.56.30:/root/private_service

export EDITOR=vim

## 도커 빌드 캐시 정리

docker system df
docker system prune -a --volumes -f
