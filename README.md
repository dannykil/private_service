# Private Service - 오픈소스 서비스 관리 프로젝트

이 프로젝트는 로컬 머신에서 다양한 오픈소스 서비스들을 Docker 컨테이너로 쉽게 실행하고 관리할 수 있도록 구성되어 있습니다.

## 🚀 지원하는 서비스들

현재 프로젝트에서 구성 가능한 서비스들은 다음과 같습니다:

| 서비스           | 포트 | 설명                                   |
| ---------------- | ---- | -------------------------------------- |
| **Prometheus**   | 9090 | 시계열 데이터베이스 및 모니터링 시스템 |
| **Grafana**      | 3000 | 데이터 시각화 및 대시보드 플랫폼       |
| **GitLab**       | 80   | Git 저장소 관리 시스템                 |
| **Jenkins**      | 8080 | CI/CD 자동화 서버                      |
| **Kong Gateway** | 8000 | API 게이트웨이 및 마이크로서비스 관리  |
| **LiteLLM**      | 4000 | LLM API 게이트웨이                     |
| **n8n**          | 5678 | 워크플로우 자동화 플랫폼               |
| **Nexus**        | 8081 | 아티팩트 저장소 관리자                 |
| **RAGAS**        | 8000 | RAG 평가 시스템                        |

## 📋 빠른 시작

### 1. 서비스 상태 확인

```bash
./check-services.sh
```

### 2. 서비스 관리 스크립트 사용

```bash
# 모든 서비스 상태 확인
./manage-services.sh status

# 특정 서비스 시작
./manage-services.sh start prometheus

# 특정 서비스 중지
./manage-services.sh stop grafana

# 모든 서비스 시작
./manage-services.sh start-all

# 모든 서비스 중지
./manage-services.sh stop-all

# 서비스 로그 확인
./manage-services.sh logs jenkins

# 서비스 초기 설정
./manage-services.sh setup gitlab
```

### 3. 개별 서비스 시작 (기존 방식)

```bash
# Prometheus & Grafana 시작 (이미 실행 중)
cd prometheus && docker-compose up -d && cd ..
cd grafana && docker-compose up -d && cd ..

# 새로운 서비스 시작 예시
cd jenkins && docker-compose up -d && cd ..
```

## 🔧 서비스별 설정 및 사용법

### Prometheus (모니터링)

- **웹 UI**: http://localhost:9090
- **기능**: 시계열 데이터 수집 및 쿼리
- **설정**: `prometheus/prometheus.yml`

### Grafana (대시보드)

- **웹 UI**: http://localhost:3000
- **기본 계정**: admin / admin
- **기능**: 데이터 시각화 및 대시보드 생성

### GitLab (Git 저장소)

- **웹 UI**: http://localhost
- **SSH Git**: localhost:2222
- **기능**: Git 저장소 호스팅 및 프로젝트 관리

### Jenkins (CI/CD)

- **웹 UI**: http://localhost:8080
- **기능**: 빌드, 테스트, 배포 자동화

### Kong Gateway (API 게이트웨이)

- **프록시**: http://localhost:8000
- **관리 API**: http://localhost:8001
- **관리 UI**: http://localhost:1337 (Konga)
- **기능**: API 라우팅, 인증, 속도 제한 등

### LiteLLM (LLM 게이트웨이)

- **API**: http://localhost:4000
- **기능**: 다양한 LLM 서비스 통합 API
- **환경변수**: API 키 설정 필요

### n8n (워크플로우 자동화)

- **웹 UI**: http://localhost:5678
- **기능**: 노코드/로우코드 자동화 플랫폼

### Nexus (아티팩트 저장소)

- **웹 UI**: http://localhost:8081
- **기능**: Maven, npm, Docker 이미지 등 저장소 관리

### RAGAS (RAG 평가)

- **API**: http://localhost:8000
- **기능**: RAG 시스템 평가 및 벤치마킹

## 🛠️ 개발자용 설정

### 환경변수 설정 (선택사항)

```bash
# LiteLLM API 키 설정
export OPENAI_API_KEY="your-openai-api-key"
export ANTHROPIC_API_KEY="your-anthropic-api-key"
```

### 사용자 정의 설정

각 서비스 디렉토리에서 `docker-compose.yml` 파일을 수정하여 설정을 변경할 수 있습니다.

### 로그 확인

```bash
# 특정 서비스 로그
./manage-services.sh logs 서비스명

# 또는 직접 확인
cd 서비스명 && docker-compose logs -f
```

### 문제 해결

```bash
# 컨테이너 상태 확인
docker ps -a

# 시스템 자원 확인
docker system df

# 로그 정리
docker system prune
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

- **Airflow**: `airflow/logs`
- **GitLab**: `gitlab/data`, `gitlab/logs`
- **Grafana**: `grafana/data`
- **Jenkins**: `jenkins/data`
- **Kong Gateway**: `kong_gateway/data`
- **Ollama**: `ollama/data`
- **Open Web UI**: `open_web_ui/data`
- **Prometheus**: `prometheus/data`

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
- **Ollama**
- **Open Web UI**
- **Prometheus**

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
├── docker-compose.yml          # 메인 설정 (현재 사용 안함)
├── check-services.sh          # 서비스 상태 확인 스크립트
├── manage-services.sh         # 서비스 관리 스크립트
├── backup-to-gcs.sh           # GCS 백업 스크립트 (통합 설정 포함)
├── restore-from-gcs.sh        # GCS 복원 스크립트
├── README.md                  # 프로젝트 문서
├── logs/                      # 로그 디렉토리
│   ├── backup/               # 백업 로그 (YYYY/MM/DD 구조)
│   └── restore/              # 복원 로그 (YYYY/MM/DD 구조)
├── restored/                  # 복원된 데이터 임시 디렉토리
├── prometheus/                # 프로메테우스 설정 및 데이터
│   ├── prometheus.yml
│   └── data/
├── grafana/                   # 그라파나 설정 및 데이터
│   └── data/
├── gitlab/                    # GitLab 설정
│   └── docker-compose.yml
├── jenkins/                   # Jenkins 설정
│   └── docker-compose.yml
├── kong_gateway/              # Kong 게이트웨이 설정
│   └── docker-compose.yml
├── lite_llm/                  # LiteLLM 설정
│   └── docker-compose.yml
├── n8n/                       # n8n 설정
│   └── docker-compose.yml
├── nexus/                     # Nexus 설정
│   └── docker-compose.yml
└── ragas/                     # RAGAS 설정
    └── docker-compose.yml
```

## 🚨 주의사항

1. **포트 충돌**: 각 서비스가 사용하는 포트가 충돌하지 않도록 확인하세요.
2. **자원 사용량**: 모든 서비스를 동시에 실행하면 많은 시스템 자원을 사용합니다.
3. **데이터 영구성**: 각 서비스의 데이터는 Docker 볼륨에 저장되므로 컨테이너 재생성 시 데이터가 유지됩니다.
4. **보안**: 프로덕션 환경에서는 적절한 보안 설정을 적용하세요.

## 🤝 기여

새로운 서비스를 추가하려면:

1. 해당 서비스 디렉토리 생성
2. `docker-compose.yml` 파일 작성
3. `check-services.sh`와 `manage-services.sh`에 서비스 정보 추가
4. 문서 업데이트

## 📞 지원

문제 발생 시 로그를 확인하고, 필요시 각 서비스의 공식 문서를 참조하세요.

## 폴더 복사

scp -r /Users/danniel.kil/Documents/workspace/private_service root@192.168.56.30:/root/private_service

export EDITOR=vim
