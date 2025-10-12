#!/bin/bash

# 서비스 관리 스크립트
# 프로젝트의 모든 오픈소스 서비스들을 쉽게 관리할 수 있습니다.

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 서비스 목록
ALL_SERVICES=("prometheus" "grafana" "gitlab" "jenkins" "kong_gateway" "lite_llm" "n8n" "nexus" "ragas")

# 사용법 출력 함수
usage() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}       서비스 관리 스크립트${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo -e "${YELLOW}사용법:${NC}"
    echo -e "  $0 [명령] [서비스명]"
    echo ""
    echo -e "${YELLOW}명령어:${NC}"
    echo -e "  start [서비스명]     - 서비스 시작"
    echo -e "  stop [서비스명]      - 서비스 중지"
    echo -e "  restart [서비스명]   - 서비스 재시작"
    echo -e "  status               - 서비스 상태 확인"
    echo -e "  start-all            - 모든 서비스 시작"
    echo -e "  stop-all             - 모든 서비스 중지"
    echo -e "  logs [서비스명]      - 서비스 로그 확인"
    echo -e "  setup [서비스명]    - 서비스 초기 설정"
    echo ""
    echo -e "${YELLOW}서비스명 (선택사항):${NC}"
    for service in "${ALL_SERVICES[@]}"; do
        echo -e "  • ${service}"
    done
    echo -e "  (서비스명을 지정하지 않으면 모든 서비스에 적용)"
    echo ""
    echo -e "${BLUE}========================================${NC}"
}

# 서비스 상태 확인 함수
check_service_dir() {
    local service=$1
    if [ ! -d "$service" ]; then
        echo -e "${RED}❌ 오류: ${service} 디렉토리가 존재하지 않습니다.${NC}"
        return 1
    fi

    if [ ! -f "$service/docker-compose.yml" ]; then
        echo -e "${RED}❌ 오류: ${service}/docker-compose.yml 파일이 존재하지 않습니다.${NC}"
        return 1
    fi

    return 0
}

# 서비스 시작 함수
start_service() {
    local service=$1
    echo -e "${BLUE}🚀 ${service} 서비스를 시작합니다...${NC}"

    if ! check_service_dir "$service"; then
        return 1
    fi

    cd "$service"
    docker-compose up -d
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ ${service} 서비스가 성공적으로 시작되었습니다.${NC}"
    else
        echo -e "${RED}❌ ${service} 서비스 시작에 실패했습니다.${NC}"
        return 1
    fi
    cd ..
}

# 서비스 중지 함수
stop_service() {
    local service=$1
    echo -e "${BLUE}⏹️  ${service} 서비스를 중지합니다...${NC}"

    if ! check_service_dir "$service"; then
        return 1
    fi

    cd "$service"
    docker-compose down
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ ${service} 서비스가 성공적으로 중지되었습니다.${NC}"
    else
        echo -e "${RED}❌ ${service} 서비스 중지에 실패했습니다.${NC}"
        return 1
    fi
    cd ..
}

# 서비스 재시작 함수
restart_service() {
    local service=$1
    echo -e "${BLUE}🔄 ${service} 서비스를 재시작합니다...${NC}"

    stop_service "$service"
    sleep 2
    start_service "$service"
}

# 모든 서비스 시작 함수
start_all_services() {
    echo -e "${BLUE}🚀 모든 서비스를 시작합니다...${NC}"
    local failed_services=()

    for service in "${ALL_SERVICES[@]}"; do
        if ! start_service "$service"; then
            failed_services+=("$service")
        fi
        sleep 3  # 서비스 간 간격
    done

    if [ ${#failed_services[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ 모든 서비스가 성공적으로 시작되었습니다.${NC}"
    else
        echo -e "${RED}❌ 다음 서비스들의 시작에 실패했습니다: ${failed_services[*]}${NC}"
        return 1
    fi
}

# 모든 서비스 중지 함수
stop_all_services() {
    echo -e "${BLUE}⏹️  모든 서비스를 중지합니다...${NC}"
    local failed_services=()

    for service in "${ALL_SERVICES[@]}"; do
        if ! stop_service "$service"; then
            failed_services+=("$service")
        fi
    done

    if [ ${#failed_services[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ 모든 서비스가 성공적으로 중지되었습니다.${NC}"
    else
        echo -e "${RED}❌ 다음 서비스들의 중지에 실패했습니다: ${failed_services[*]}${NC}"
        return 1
    fi
}

# 로그 확인 함수
show_logs() {
    local service=$1
    echo -e "${BLUE}📋 ${service} 서비스의 로그를 확인합니다...${NC}"

    if ! check_service_dir "$service"; then
        return 1
    fi

    cd "$service"
    docker-compose logs -f
    cd ..
}

# 서비스 설정 함수
setup_service() {
    local service=$1
    echo -e "${BLUE}🔧 ${service} 서비스를 설정합니다...${NC}"

    if [ ! -d "$service" ]; then
        echo -e "${YELLOW}📁 ${service} 디렉토리를 생성합니다...${NC}"
        mkdir -p "$service"
    fi

    # 필요한 하위 디렉토리 생성
    case $service in
        "gitlab")
            mkdir -p "$service"/{config,logs,data}
            ;;
        "jenkins")
            mkdir -p "$service/jenkins_home"
            ;;
        "kong_gateway")
            mkdir -p "$service/postgres-data"
            ;;
        "lite_llm")
            mkdir -p "$service"/{config,postgres-data}
            ;;
        "nexus")
            mkdir -p "$service"/{data,backup}
            ;;
        "n8n")
            mkdir -p "$service/data"
            ;;
        "ragas")
            mkdir -p "$service"/{app,data,config}
            ;;
    esac

    echo -e "${GREEN}✅ ${service} 서비스 설정이 완료되었습니다.${NC}"
}

# 메인 실행 부분
main() {
    local command=$1
    local service=${2:-}

    case $command in
        "start")
            if [ -z "$service" ]; then
                echo -e "${RED}❌ 오류: 서비스명을 지정해주세요.${NC}"
                usage
                exit 1
            fi
            start_service "$service"
            ;;
        "stop")
            if [ -z "$service" ]; then
                echo -e "${RED}❌ 오류: 서비스명을 지정해주세요.${NC}"
                usage
                exit 1
            fi
            stop_service "$service"
            ;;
        "restart")
            if [ -z "$service" ]; then
                echo -e "${RED}❌ 오류: 서비스명을 지정해주세요.${NC}"
                usage
                exit 1
            fi
            restart_service "$service"
            ;;
        "status")
            ./check-services.sh
            ;;
        "start-all")
            start_all_services
            ;;
        "stop-all")
            stop_all_services
            ;;
        "logs")
            if [ -z "$service" ]; then
                echo -e "${RED}❌ 오류: 서비스명을 지정해주세요.${NC}"
                usage
                exit 1
            fi
            show_logs "$service"
            ;;
        "setup")
            if [ -z "$service" ]; then
                echo -e "${RED}❌ 오류: 서비스명을 지정해주세요.${NC}"
                usage
                exit 1
            fi
            setup_service "$service"
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

# 스크립트 실행
main "$@"
