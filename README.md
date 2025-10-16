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

2. **인증 설정**

   ```bash
   # Google Cloud 인증
   gcloud auth login
   gcloud config set project your-project-id
   ```

3. **스크립트 설정 수정** (선택사항)

   `backup-to-gcs.sh` 파일 상단의 설정 섹션에서 다음을 수정할 수 있습니다:

   ```bash
   # 필수 설정
   GCS_BUCKET="gs://your-actual-bucket-name"    # GCS 버킷 이름

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

# 도움말 확인
./backup-to-gcs.sh --help
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

## 📁 프로젝트 구조

```
private_service/
├── docker-compose.yml          # 메인 설정 (현재 사용 안함)
├── check-services.sh          # 서비스 상태 확인 스크립트
├── manage-services.sh         # 서비스 관리 스크립트
├── backup-to-gcs.sh           # GCS 백업 스크립트 (통합 설정 포함)
├── README.md                  # 프로젝트 문서
├── logs/                      # 로그 디렉토리 (신규)
│   └── backup/               # 백업 로그 (YYYY/MM/DD 구조)
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
