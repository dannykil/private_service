#!/bin/bash

# ============================================================================
# Google Cloud Storage에서 서비스 데이터를 복원하는 스크립트
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

# 복원 설정 (선택사항)
RESTORE_ROOT_DIR="${RESTORE_ROOT_DIR:-./restored}"
TEMP_DOWNLOAD_DIR="/tmp/restore-temp"

# 로그 설정 (선택사항)
LOG_LEVEL="${LOG_LEVEL:-INFO}"

# =============================================================================
# 설정 섹션 끝
# =============================================================================

# crontab 환경 변수 설정 (gsutil 인증을 위해 필수)
export GOOGLE_APPLICATION_CREDENTIALS="$SERVICE_ACCOUNT_KEY"

# gsutil 경로 설정
GSUTIL_PATH=$(command -v gsutil || echo "/usr/bin/gsutil")
if [ ! -f "$GSUTIL_PATH" ]; then
    GSUTIL_PATH="/usr/bin/gsutil"
fi

# 로그 디렉토리 구조 설정
CURRENT_DATE=$(date +%Y/%m/%d)
LOG_DIR="./logs/restore/$CURRENT_DATE"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILENAME="restore_$TIMESTAMP.log"
LOG_FILE="$LOG_DIR/$LOG_FILENAME"

# 복원할 서비스들 정의
SERVICES=(
    # "airflow"
    # "gitlab"
    "grafana"
    # "jenkins"
    "kong_gateway"
    # "ollama"
    # "open_web_ui"
    # "prometheus"
)

# 로그 함수
log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    
    echo -e "$message" >&2
    
    if [ -n "$LOG_FILE" ] && [ -w "$(dirname "$LOG_FILE")" ]; then
        echo -e "$message" >> "$LOG_FILE" 2>/dev/null || true
    fi
}

# 사용법 출력 함수
usage() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}     서비스 복원 스크립트 (GCS)${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo -e "${YELLOW}사용법:${NC}"
    echo "  $0 [옵션]"
    echo ""
    echo -e "${YELLOW}중요:${NC}"
    echo "  • 압축 해제를 위해 sudo 권한이 필요할 수 있습니다"
    echo "  • 기존 데이터가 덮어쓰여질 수 있으니 주의하세요"
    echo ""
    echo -e "${YELLOW}옵션:${NC}"
    echo "  --bucket BUCKET_NAME    GCS 버킷 이름 설정"
    echo "  --service SERVICE_NAME  특정 서비스만 복원"
    echo "  --list                  GCS에 있는 백업 목록 조회"
    echo "  --date YYYYMMDD         특정 날짜의 백업 복원 (예: 20251025)"
    echo "  --latest                최신 백업 복원 (기본값)"
    echo "  --target-dir DIR        복원할 대상 디렉토리 (기본: ./restored)"
    echo "  --dry-run              실제 복원 없이 테스트만 실행"
    echo "  --debug                디버깅 정보 출력"
    echo "  --help                 도움말 표시"
    echo ""
    echo -e "${YELLOW}환경변수:${NC}"
    echo "  GCS_BUCKET             기본 GCS 버킷 설정"
    echo "  GOOGLE_APPLICATION_CREDENTIALS (스크립트 내부에서 설정됨)"
    echo ""
    echo -e "${YELLOW}예시:${NC}"
    echo "  # 모든 서비스의 최신 백업 복원"
    echo "  $0 --latest"
    echo ""
    echo "  # 특정 서비스만 복원"
    echo "  $0 --service grafana --latest"
    echo ""
    echo "  # 특정 날짜의 백업 복원"
    echo "  $0 --date 20251025"
    echo ""
    echo "  # GCS 백업 목록 조회"
    echo "  $0 --list"
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

    # 서비스 계정 활성화
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

    # GCS 인증 확인
    if ! "$GSUTIL_PATH" ls "$GCS_BUCKET" &> /dev/null; then
        log "${RED}❌ 오류: GCS 버킷에 접근할 수 없습니다.${NC}"
        log "${YELLOW}💡 GCS 버킷 이름($GCS_BUCKET)과 서비스 계정 권한을 확인해주세요.${NC}"
        exit 1
    fi

    # 필요한 디렉토리 생성
    mkdir -p "$RESTORE_ROOT_DIR"
    mkdir -p "$TEMP_DOWNLOAD_DIR"

    log "${GREEN}✅ 사전 체크 완료${NC}"
}

# GCS 백업 목록 조회 함수
list_backups() {
    local service_filter="$1"
    
    log "${BLUE}📋 GCS 백업 목록을 조회합니다...${NC}"
    echo ""
    
    if [ -n "$service_filter" ]; then
        log "${CYAN}서비스: $service_filter${NC}"
        echo ""
        "$GSUTIL_PATH" ls "$GCS_BUCKET/$service_filter/" 2>/dev/null | sort -r || {
            log "${YELLOW}⚠️  '$service_filter' 서비스의 백업이 없습니다.${NC}"
            return 1
        }
    else
        for service in "${SERVICES[@]}"; do
            log "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            log "${CYAN}서비스: $service${NC}"
            log "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            "$GSUTIL_PATH" ls "$GCS_BUCKET/$service/" 2>/dev/null | sort -r || {
                log "${YELLOW}⚠️  백업이 없습니다.${NC}"
            }
            echo ""
        done
    fi
}

# 최신 백업 파일 찾기 함수
get_latest_backup() {
    local service_name="$1"
    local gcs_path="$GCS_BUCKET/$service_name/"
    
    # GCS에서 해당 서비스의 최신 파일 찾기
    local latest_file=$("$GSUTIL_PATH" ls "$gcs_path" 2>/dev/null | grep ".tar.gz$" | sort -r | head -n1)
    
    if [ -z "$latest_file" ]; then
        log "${YELLOW}⚠️  '$service_name' 서비스의 백업 파일을 찾을 수 없습니다.${NC}"
        return 1
    fi
    
    echo "$latest_file"
}

# 특정 날짜의 백업 파일 찾기 함수
get_backup_by_date() {
    local service_name="$1"
    local target_date="$2"  # YYYYMMDD 형식
    local gcs_path="$GCS_BUCKET/$service_name/"
    
    # GCS에서 해당 날짜의 파일 찾기
    local dated_file=$("$GSUTIL_PATH" ls "$gcs_path" 2>/dev/null | grep ".tar.gz$" | grep "$target_date" | sort -r | head -n1)
    
    if [ -z "$dated_file" ]; then
        log "${YELLOW}⚠️  '$service_name' 서비스의 $target_date 날짜 백업을 찾을 수 없습니다.${NC}"
        return 1
    fi
    
    echo "$dated_file"
}

# 서비스 복원 함수
restore_service() {
    local service_name="$1"
    local backup_date="$2"  # "latest" 또는 YYYYMMDD 형식
    local target_dir="$3"
    
    log "${CYAN}📦 $service_name 서비스 복원을 시작합니다...${NC}"
    
    # 백업 파일 찾기
    local backup_file
    if [ "$backup_date" = "latest" ]; then
        backup_file=$(get_latest_backup "$service_name")
    else
        backup_file=$(get_backup_by_date "$service_name" "$backup_date")
    fi
    
    if [ $? -ne 0 ] || [ -z "$backup_file" ]; then
        log "${RED}❌ 백업 파일을 찾을 수 없습니다.${NC}"
        return 1
    fi
    
    log "${BLUE}📥 다운로드 중: $backup_file${NC}"
    
    # 로컬 다운로드 경로
    local local_file="$TEMP_DOWNLOAD_DIR/$(basename "$backup_file")"
    
    # GCS에서 다운로드
    if ! "$GSUTIL_PATH" cp "$backup_file" "$local_file" 2>> "$LOG_FILE"; then
        log "${RED}❌ 다운로드 실패: $backup_file${NC}"
        return 1
    fi
    
    log "${GREEN}✅ 다운로드 완료${NC}"
    
    # 복원 대상 디렉토리 생성
    local restore_target="$target_dir/$service_name"
    mkdir -p "$restore_target"
    
    log "${BLUE}📂 압축 해제 중: $local_file${NC}"
    
    # 압축 해제 (sudo 사용이 필요할 수 있음)
    if tar -xzf "$local_file" -C "$restore_target" 2>> "$LOG_FILE"; then
        log "${GREEN}✅ 압축 해제 완료: $restore_target${NC}"
        
        # 다운로드한 파일 정리
        rm -f "$local_file"
        
        log "${GREEN}✅ $service_name 서비스 복원 완료${NC}"
        log "${BLUE}📁 복원 위치: $restore_target${NC}"
        return 0
    else
        # sudo로 재시도
        log "${YELLOW}⚠️  일반 권한으로 압축 해제 실패. sudo로 재시도합니다...${NC}"
        if sudo tar -xzf "$local_file" -C "$restore_target" 2>> "$LOG_FILE"; then
            # 소유권 변경
            sudo chown -R $(whoami):$(whoami) "$restore_target" 2>> "$LOG_FILE"
            log "${GREEN}✅ 압축 해제 완료 (sudo 사용): $restore_target${NC}"
            
            # 다운로드한 파일 정리
            rm -f "$local_file"
            
            log "${GREEN}✅ $service_name 서비스 복원 완료${NC}"
            log "${BLUE}📁 복원 위치: $restore_target${NC}"
            return 0
        else
            log "${RED}❌ 압축 해제 실패: $local_file${NC}"
            return 1
        fi
    fi
}

# 모든 서비스 복원 함수
restore_all_services() {
    local backup_date="$1"
    local target_dir="$2"
    
    log "${PURPLE}🚀 전체 복원을 시작합니다...${NC}"
    
    local failed_services=()
    local success_count=0
    
    for service_name in "${SERVICES[@]}"; do
        if restore_service "$service_name" "$backup_date" "$target_dir"; then
            ((success_count++))
        else
            failed_services+=("$service_name")
        fi
        echo ""
    done
    
    # 결과 요약
    log "${BLUE}📊 복원 결과 요약:${NC}"
    log "${GREEN}✅ 성공: $success_count 개 서비스${NC}"
    
    if [ ${#failed_services[@]} -gt 0 ]; then
        log "${RED}❌ 실패: ${#failed_services[@]} 개 서비스${NC}"
        log "${RED}   실패한 서비스들: ${failed_services[*]}${NC}"
        return 1
    else
        log "${GREEN}🎉 전체 복원 성공!${NC}"
        return 0
    fi
}

# 정리 함수
cleanup() {
    log "${BLUE}🧹 임시 파일을 정리합니다...${NC}"
    rm -rf "$TEMP_DOWNLOAD_DIR"
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
    else
        log "• gcloud: ❌ 설치되지 않음"
    fi
    
    log "${CYAN}[GSUtil 정보]${NC}"
    if command -v gsutil &> /dev/null; then
        log "• gsutil 경로: $(which gsutil)"
        log "• gsutil 버전: $(gsutil version -l 2>&1 | head -n1)"
    else
        log "• gsutil: ❌ 설치되지 않음"
    fi
    
    log "${CYAN}[GCS 버킷 접근 테스트]${NC}"
    log "• 버킷: $GCS_BUCKET"
    if gsutil ls "$GCS_BUCKET" &> /dev/null; then
        log "• 접근 상태: ✅ 성공"
    else
        log "• 접근 상태: ❌ 실패"
    fi
    
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 메인 실행 함수
main() {
    local specific_service=""
    local backup_date="latest"
    local target_dir="$RESTORE_ROOT_DIR"
    local dry_run=false
    local debug_mode=false
    local list_mode=false
    
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
            --date)
                backup_date="$2"
                shift 2
                ;;
            --latest)
                backup_date="latest"
                shift
                ;;
            --target-dir)
                target_dir="$2"
                shift 2
                ;;
            --list)
                list_mode=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --debug)
                debug_mode=true
                shift
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
    log "${BLUE}    서비스 복원 시작 (GCS 다운로드)${NC}"
    log "${BLUE}========================================${NC}"
    log "복원 시간: $(date)"
    log "GCS 버킷: $GCS_BUCKET"
    log "로그 파일: $LOG_FILE"
    log "복원 대상 디렉토리: $target_dir"
    log "인증 키: $SERVICE_ACCOUNT_KEY"
    echo ""
    
    # 사전 체크
    precheck
    
    # 목록 조회 모드
    if [ "$list_mode" = true ]; then
        list_backups "$specific_service"
        exit 0
    fi
    
    # 디버그 모드
    if [ "$debug_mode" = true ]; then
        debug_info
        log "${YELLOW}🔍 디버그 모드 종료.${NC}"
        exit 0
    fi
    
    # 드라이 런 모드 확인
    if [ "$dry_run" = true ]; then
        log "${YELLOW}🔄 드라이 런 모드 - 실제 복원 없이 테스트합니다.${NC}"
        list_backups "$specific_service"
        exit 0
    fi
    
    # 복원 실행
    if [ -n "$specific_service" ]; then
        log "${CYAN}🎯 특정 서비스 복원: $specific_service${NC}"
        log "${CYAN}   백업 날짜: $backup_date${NC}"
        echo ""
        
        restore_service "$specific_service" "$backup_date" "$target_dir"
    else
        log "${CYAN}📦 모든 서비스 복원${NC}"
        log "${CYAN}   백업 날짜: $backup_date${NC}"
        echo ""
        
        restore_all_services "$backup_date" "$target_dir"
    fi
    
    # 정리
    cleanup
    
    log "${BLUE}========================================${NC}"
    log "${GREEN}🎉 복원 프로세스 완료!${NC}"
    log "${BLUE}========================================${NC}"
    log "${YELLOW}💡 복원된 파일은 '$target_dir'에 있습니다.${NC}"
    log "${YELLOW}💡 필요한 경우 해당 디렉토리의 파일을 서비스 디렉토리로 이동하세요.${NC}"
}

# 스크립트 실행
main "$@"

