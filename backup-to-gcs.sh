#!/bin/bash

# ============================================================================
# 서비스 데이터 백업을 Google Cloud Storage로 업로드하는 스크립트
# ============================================================================

set -e  # 오류 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# =============================================================================
# 설정 섹션 (사용자 수정 영역)
# =============================================================================

# 🚨 서비스 계정 키 파일 절대 경로 (필수)
SERVICE_ACCOUNT_KEY="/home/gpuadmin/private_service/secret_keys/hist-poc-use-cases-54b0305f7e4e.json"
# SERVICE_ACCOUNT_KEY="/Users/danniel.kil/Documents/workspace/private_service/secret_keys/hist-poc-use-cases-54b0305f7e4e.json"

# GCS 버킷 설정 (필수)
GCS_BUCKET="gs://private_service"

# 프로젝트 ID 설정 (선택사항)
GCP_PROJECT_ID="hist-poc-use-cases"

# 백업 설정 (선택사항)
BACKUP_ROOT_DIR="${BACKUP_ROOT_DIR:-./backups}"
BACKUP_COMPRESSION_LEVEL="${BACKUP_COMPRESSION_LEVEL:-6}"  # 1-9, 높을수록 압축률 높음
BACKUP_PARALLEL="${BACKUP_PARALLEL:-false}"               # true면 병렬 백업, false면 순차 백업

# 로그 설정 (선택사항)
LOG_LEVEL="${LOG_LEVEL:-INFO}"            # DEBUG, INFO, WARN, ERROR
LOG_MAX_FILES="${LOG_MAX_FILES:-30}"      # 보관할 로그 파일 최대 개수

# 제외할 파일/폴더 패턴 (공백으로 구분)
EXCLUDE_PATTERNS="${EXCLUDE_PATTERNS:-*.tmp *.log.* .git __pycache__ node_modules}"

# 백업 스케줄 설정 (선택사항) - cron 표현식
# 매일 새벽 2시에 백업: "0 2 * * *"
BACKUP_SCHEDULE="${BACKUP_SCHEDULE:-0 2 * * *}"

# =============================================================================
# 설정 섹션 끝
# =============================================================================

# crontab 환경 변수 설정 (gsutil 인증을 위해 필수)
# gsutil/gcloud가 이 환경 변수를 사용하여 서비스 계정 키 파일을 찾습니다.
export GOOGLE_APPLICATION_CREDENTIALS="$SERVICE_ACCOUNT_KEY"

# 환경 변수 설정이 완료되면, 스크립트 전체에서 사용할 gsutil 경로를 정의합니다.
GSUTIL_PATH=$(command -v gsutil || echo "/usr/bin/gsutil")
if [ ! -f "$GSUTIL_PATH" ]; then
    GSUTIL_PATH="/usr/bin/gsutil" # 일반적인 리눅스 환경 기본 경로로 폴백
fi


# 로그 디렉토리 구조 설정 (/logs/backup/yyyy/mm/dd)
CURRENT_DATE=$(date +%Y/%m/%d)
LOG_DIR="./logs/backup/$CURRENT_DATE"
TEMP_DIR="/tmp/backup-temp"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILENAME="backup_$TIMESTAMP.log"
LOG_FILE="$LOG_DIR/$LOG_FILENAME"

# 백업할 서비스들 정의 (data 또는 logs 폴더가 있는 서비스들)
SERVICES=(
    # "airflow:logs"
    # "gitlab:data:logs"
    "grafana:data"
    # "jenkins:data"
    "kong_gateway:data"
    # "ollama:data"
    # "open_web_ui:data"
    "prometheus:data"
)

# 로그 함수
log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"

    # 로그 디렉토리가 준비되지 않았을 수 있으므로 임시로 stderr에도 출력
    echo -e "$message" >&2

    # 로그 파일이 설정되어 있다면 파일에도 기록
    if [ -n "$LOG_FILE" ] && [ -w "$(dirname "$LOG_FILE")" ]; then
        echo -e "$message" >> "$LOG_FILE" 2>/dev/null || true
    fi
}

# crontab 설정 가이드 함수
setup_cron_guide() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}   Crontab 설정 가이드${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo -e "${YELLOW}1. Sudo 권한 설정 (비밀번호 없이 실행)${NC}"
    echo ""
    echo "다음 명령어를 실행하여 sudoers 설정 파일을 생성합니다:"
    echo ""
    echo -e "${GREEN}sudo tee /etc/sudoers.d/backup-script << 'EOF'
# Backup script - Allow tar and chown without password
$(whoami) ALL=(ALL) NOPASSWD: /bin/tar
$(whoami) ALL=(ALL) NOPASSWD: /bin/chown
EOF${NC}"
    echo ""
    echo "설정 파일 권한 설정:"
    echo -e "${GREEN}sudo chmod 0440 /etc/sudoers.d/backup-script${NC}"
    echo ""
    echo "설정 검증:"
    echo -e "${GREEN}sudo visudo -c${NC}"
    echo ""
    echo -e "${YELLOW}2. Crontab 등록${NC}"
    echo ""
    echo "crontab 편집:"
    echo -e "${GREEN}crontab -e${NC}"
    echo ""
    echo "다음 내용을 추가 (매일 새벽 2시 실행 예시):"
    echo ""
    echo -e "${GREEN}# 서비스 백업 (매일 새벽 2시)
0 2 * * * cd $(pwd) && $(realpath "$0") >> $(pwd)/logs/backup/cron.log 2>&1${NC}"
    echo ""
    echo -e "${YELLOW}3. 설정 확인${NC}"
    echo ""
    echo "crontab 목록 확인:"
    echo -e "${GREEN}crontab -l${NC}"
    echo ""
    echo "수동 테스트 실행:"
    echo -e "${GREEN}$(realpath "$0")${NC}"
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${PURPLE}💡 팁:${NC}"
    echo "  • sudoers 설정 후 터미널을 재시작하세요"
    echo "  • cron 로그는 ./logs/backup/cron.log에서 확인하세요"
    echo "  • 테스트는 --dry-run 옵션으로 먼저 해보세요"
    echo -e "${BLUE}========================================${NC}"
}

# 사용법 출력 함수
usage() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}     서비스 백업 스크립트 (GCS)${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo -e "${YELLOW}사용법:${NC}"
    echo "  $0 [옵션]"
    echo ""
    echo -e "${YELLOW}중요:${NC}"
    echo "  • Docker 볼륨 백업을 위해 sudo 권한이 필요합니다"
    echo "  • 스크립트 실행 시 sudo 비밀번호를 입력해야 할 수 있습니다"
    echo ""
    echo -e "${YELLOW}옵션:${NC}"
    echo "  --bucket BUCKET_NAME    GCS 버킷 이름 설정"
    echo "  --service SERVICE_NAME  특정 서비스만 백업"
    echo "  --dry-run              실제 업로드 없이 테스트만 실행"
    echo "  --debug                디버깅 정보 출력"
    echo "  --setup-cron           crontab 설정 도움말 표시"
    echo "  --help                 도움말 표시"
    echo ""
    echo -e "${YELLOW}환경변수:${NC}"
    echo "  GCS_BUCKET             기본 GCS 버킷 설정"
    echo "  GOOGLE_APPLICATION_CREDENTIALS (스크립트 내부에서 설정됨)"
    echo ""
    echo -e "${BLUE}========================================${NC}"
}

# 로그 디렉토리 생성 함수
create_log_directory() {
    if [ ! -d "$LOG_DIR" ]; then
        mkdir -p "$LOG_DIR"
        log "${BLUE}📁 로그 디렉토리를 생성했습니다: $LOG_DIR${NC}"
    fi
}

# 사전 체크 함수
precheck() {
    log "${BLUE}🔍 사전 체크를 시작합니다...${NC}"

    # 로그 디렉토리 생성
    create_log_directory

    # sudo 권한 확인 (Docker 볼륨 백업을 위해 필요)
    log "${BLUE}🔑 sudo 권한을 확인합니다...${NC}"
    
    # 실제 사용할 tar 명령어로 NOPASSWD 설정 확인
    # --version은 실제로 아무것도 하지 않으면서 권한만 체크
    if sudo -n tar --version &> /dev/null; then
        log "${GREEN}✅ sudo tar 권한 확인 완료 (NOPASSWD 설정됨 - crontab 사용 가능)${NC}"
    elif sudo -v &> /dev/null && sudo tar --version &> /dev/null; then
        log "${GREEN}✅ sudo tar 권한 확인 완료${NC}"
        log "${YELLOW}💡 crontab 사용을 원하시면 --setup-cron 옵션을 참고하세요.${NC}"
    else
        log "${RED}❌ 오류: sudo tar 권한이 필요합니다.${NC}"
        log "${YELLOW}💡 Docker 볼륨을 백업하려면 sudo 권한이 필요합니다.${NC}"
        log "${YELLOW}💡 crontab 설정이 필요하면: $0 --setup-cron${NC}"
        exit 1
    fi

    # Google Cloud SDK (gsutil) 확인
    if ! command -v "$GSUTIL_PATH" &> /dev/null; then
        log "${RED}❌ 오류: gsutil이 설치되지 않았거나 경로를 찾을 수 없습니다: $GSUTIL_PATH${NC}"
        log "${YELLOW}💡 Google Cloud SDK를 설치해주세요: https://cloud.google.com/sdk/docs/install${NC}"
        exit 1
    fi

    # 서비스 계정 키 파일 존재 확인
    if [ ! -f "$SERVICE_ACCOUNT_KEY" ]; then
        log "${RED}❌ 오류: 서비스 계정 키 파일이 존재하지 않습니다: $SERVICE_ACCOUNT_KEY${NC}"
        log "${YELLOW}💡 키 파일 경로를 확인하거나, 파일이 서버에 있는지 확인하세요.${NC}"
        exit 1
    fi
    log "${GREEN}✅ 서비스 계정 키 파일 확인 완료${NC}"

    # 서비스 계정 활성화 (gsutil이 환경 변수를 무시하는 경우 대비)
    log "${BLUE}🔐 서비스 계정 인증을 활성화합니다...${NC}"
    if command -v gcloud &> /dev/null; then
        if gcloud auth activate-service-account --key-file="$SERVICE_ACCOUNT_KEY" >> "$LOG_FILE" 2>&1; then
            log "${GREEN}✅ gcloud 서비스 계정 활성화 완료${NC}"
        else
            log "${YELLOW}⚠️  경고: gcloud 서비스 계정 활성화 실패 (gsutil 환경 변수로 재시도)${NC}"
        fi
    else
        log "${YELLOW}⚠️  gcloud가 설치되지 않음. GOOGLE_APPLICATION_CREDENTIALS 환경 변수만 사용합니다.${NC}"
    fi

    # GCS 인증 확인 (서비스 계정을 사용하여 접근 테스트)
    # gsutil 경로를 명시적으로 사용하여 crontab 환경 문제 방지
    if ! "$GSUTIL_PATH" ls "$GCS_BUCKET" &> /dev/null; then
        log "${RED}❌ 오류: GCS 버킷에 접근할 수 없습니다. (버킷 이름 혹은 서비스 계정 권한 문제)${NC}"
        log "${YELLOW}💡 GCS 버킷 이름($GCS_BUCKET)과 서비스 계정의 'Storage Object Admin' 권한을 확인해주세요.${NC}"
        log "${YELLOW}💡 디버깅: gcloud auth list 및 gsutil version -l을 실행해보세요.${NC}"
        exit 1
    fi

    # 필요한 디렉토리 생성
    mkdir -p "$BACKUP_ROOT_DIR"
    mkdir -p "$TEMP_DIR"

    log "${GREEN}✅ 사전 체크 완료${NC}"
}

# 서비스 백업 함수
backup_service() {
    local service_info=$1
    local service_name=$(echo "$service_info" | cut -d: -f1)
    local backup_paths=$(echo "$service_info" | cut -d: -f2-)

    log "${CYAN}📦 $service_name 서비스 백업을 시작합니다...${NC}"

    # 서비스 디렉토리 확인
    if [ ! -d "$service_name" ]; then
        log "${YELLOW}⚠️  경고: $service_name 디렉토리가 존재하지 않습니다. 건너뜁니다.${NC}"
        return 0
    fi

    local service_backup_dir="$BACKUP_ROOT_DIR/$service_name/$TIMESTAMP"
    mkdir -p "$service_backup_dir"

    # 백업할 경로들을 처리
    local paths_array=($(echo "$backup_paths" | tr ':' ' '))
    local backup_success=true

    for path in "${paths_array[@]}"; do
        local full_path="$service_name/$path"

        if [ -d "$full_path" ]; then
            log "${BLUE}📂 백업 중: $full_path${NC}"

            # 압축 파일 이름 생성
            local compressed_file="$TEMP_DIR/$(basename "$path" | tr '/' '_')_$TIMESTAMP.tar.gz"

            # 압축 실행 (sudo 사용하여 권한 문제 해결)
            if sudo tar -czf "$compressed_file" -C "$service_name" "$path" 2>> "$LOG_FILE"; then
                # 생성된 파일의 소유권을 현재 사용자로 변경
                sudo chown $(whoami):$(whoami) "$compressed_file" 2>> "$LOG_FILE"
                log "${GREEN}✅ 압축 완료: $compressed_file${NC}"

                # GCS 업로드
                local gcs_path="$GCS_BUCKET/$service_name/$(basename "$compressed_file")"
                # gsutil 경로를 명시적으로 사용하여 crontab 환경 문제 방지
                if "$GSUTIL_PATH" cp "$compressed_file" "$gcs_path" 2>> "$LOG_FILE"; then
                    log "${GREEN}✅ GCS 업로드 완료: $gcs_path${NC}"
                else
                    log "${RED}❌ GCS 업로드 실패: $compressed_file${NC}"
                    log "${RED}   (인증/권한 문제일 수 있습니다. $SERVICE_ACCOUNT_KEY를 확인하세요.)${NC}"
                    backup_success=false
                fi

                # 임시 파일 정리
                rm -f "$compressed_file"
            else
                log "${RED}❌ 압축 실패: $full_path${NC}"
                backup_success=false
            fi
        else
            log "${YELLOW}⚠️  경고: $full_path 디렉토리가 존재하지 않습니다.${NC}"
        fi
    done

    if [ "$backup_success" = true ]; then
        log "${GREEN}✅ $service_name 서비스 백업 완료${NC}"
        return 0
    else
        log "${RED}❌ $service_name 서비스 백업 실패${NC}"
        return 1
    fi
}

# 모든 서비스 백업 함수
backup_all_services() {
    log "${PURPLE}🚀 전체 백업을 시작합니다...${NC}"

    local failed_services=()
    local success_count=0

    for service_info in "${SERVICES[@]}"; do
        if backup_service "$service_info"; then
            ((success_count++))
        else
            failed_services+=("$service_info")
        fi
        echo ""  # 빈 줄 추가
    done

    # 결과 요약
    log "${BLUE}📊 백업 결과 요약:${NC}"
    log "${GREEN}✅ 성공: $success_count 개 서비스${NC}"

    if [ ${#failed_services[@]} -gt 0 ]; then
        log "${RED}❌ 실패: ${#failed_services[@]} 개 서비스${NC}"
        log "${RED}   실패한 서비스들: ${failed_services[*]}${NC}"
        return 1
    else
        log "${GREEN}🎉 전체 백업 성공!${NC}"
        return 0
    fi
}

# 정리 함수
cleanup() {
    log "${BLUE}🧹 임시 파일을 정리합니다...${NC}"
    rm -rf "$TEMP_DIR"
    log "${GREEN}✅ 정리 완료${NC}"
}

# 디버깅 정보 출력 함수
debug_info() {
    log "${PURPLE}🐛 디버깅 정보:${NC}"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    log "${CYAN}[환경 정보]${NC}"
    log "• 현재 사용자: $(whoami)"
    log "• 작업 디렉토리: $(pwd)"
    log "• 서비스 계정 키: $SERVICE_ACCOUNT_KEY"
    log "• 키 파일 존재: $([ -f "$SERVICE_ACCOUNT_KEY" ] && echo "✅ Yes" || echo "❌ No")"
    log "• GOOGLE_APPLICATION_CREDENTIALS: $GOOGLE_APPLICATION_CREDENTIALS"
    
    log "${CYAN}[GCloud 인증 정보]${NC}"
    if command -v gcloud &> /dev/null; then
        log "• gcloud 버전: $(gcloud --version | head -n1)"
        log "• 활성 계정:"
        gcloud auth list 2>&1 | while IFS= read -r line; do log "  $line"; done
        log "• 현재 프로젝트: $(gcloud config get-value project 2>/dev/null || echo 'Not set')"
    else
        log "• gcloud: ❌ 설치되지 않음"
    fi
    
    log "${CYAN}[GSUtil 정보]${NC}"
    if command -v gsutil &> /dev/null; then
        log "• gsutil 경로: $(which gsutil)"
        log "• gsutil 버전: $(gsutil version -l 2>&1 | head -n1)"
        log "• boto 설정 파일: $([ -f ~/.boto ] && echo "✅ ~/.boto 존재" || echo "❌ ~/.boto 없음")"
    else
        log "• gsutil: ❌ 설치되지 않음"
    fi
    
    log "${CYAN}[GCS 버킷 접근 테스트]${NC}"
    log "• 버킷: $GCS_BUCKET"
    if gsutil ls "$GCS_BUCKET" &> /dev/null; then
        log "• 접근 상태: ✅ 성공"
        log "• 버킷 내용 (최근 5개):"
        gsutil ls "$GCS_BUCKET" 2>&1 | head -n5 | while IFS= read -r line; do log "  $line"; done
    else
        log "• 접근 상태: ❌ 실패"
        log "• 오류 상세:"
        gsutil ls "$GCS_BUCKET" 2>&1 | while IFS= read -r line; do log "  $line"; done
    fi
    
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 메인 실행 함수
main() {
    local specific_service=""
    local dry_run=false
    local debug_mode=false

    # 인자 처리
    while [[ $# -gt 0 ]]; do
        case $1 in
            --bucket)
                GCS_BUCKET="$2"
                shift 2
                ;;
            --service)
                specific_service="$2"
                shift 2
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --debug)
                debug_mode=true
                shift
                ;;
            --setup-cron)
                setup_cron_guide
                exit 0
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                log "${RED}❌ 알 수 없는 옵션: $1${NC}"
                usage
                exit 1
                ;;
        esac
    done

    log "${BLUE}========================================${NC}"
    log "${BLUE}    서비스 백업 시작 (GCS 업로드)${NC}"
    log "${BLUE}========================================${NC}"
    log "백업 시간: $(date)"
    log "GCS 버킷: $GCS_BUCKET"
    log "로그 파일: $LOG_FILE"
    log "로그 디렉토리: $LOG_DIR"
    log "인증 키: $SERVICE_ACCOUNT_KEY"
    echo ""

    # 드라이 런 모드 확인
    if [ "$dry_run" = true ]; then
        log "${YELLOW}🔄 드라이 런 모드 - 실제 업로드 없이 테스트합니다.${NC}"
    fi

    # 사전 체크
    precheck

    # 디버그 모드 실행
    if [ "$debug_mode" = true ]; then
        debug_info
        log "${YELLOW}🔍 디버그 모드 종료. 백업을 진행하려면 --debug 옵션 없이 실행하세요.${NC}"
        exit 0
    fi

    # 백업 실행
    if [ -n "$specific_service" ]; then
        log "${CYAN}🎯 특정 서비스 백업: $specific_service${NC}"

        # 서비스 찾기
        local found=false
        for service_info in "${SERVICES[@]}"; do
            local service_name=$(echo "$service_info" | cut -d: -f1)
            if [ "$service_name" = "$specific_service" ]; then
                if [ "$dry_run" = false ]; then
                    backup_service "$service_info"
                else
                    log "${YELLOW}드라이 런: $service_name 서비스 백업을 시뮬레이션합니다.${NC}"
                fi
                found=true
                break
            fi
        done

        if [ "$found" = false ]; then
            log "${RED}❌ 오류: '$specific_service' 서비스를 찾을 수 없습니다.${NC}"
            exit 1
        fi
    else
        if [ "$dry_run" = false ]; then
            backup_all_services
        else
            log "${YELLOW}드라이 런: 전체 서비스 백업을 시뮬레이션합니다.${NC}"
            log "${YELLOW}드라이 런에서는 실제 백업이 수행되지 않습니다.${NC}"
        fi
    fi

    # 정리
    cleanup

    log "${BLUE}========================================${NC}"
    log "${GREEN}🎉 백업 프로세스 완료!${NC}"
    log "${BLUE}========================================${NC}"
}

# 스크립트 실행
main "$@"
