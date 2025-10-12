#!/bin/bash

# 서비스 상태 확인 스크립트
# 현재 프로젝트의 오픈소스 서비스들을 확인하고 실행 상태를 표시합니다.

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 서비스 정의 배열
# 형식: "서비스명:컨테이너명:포트:설명"
SERVICES=(
    "prometheus:prometheus:9090:시계열 데이터베이스 및 모니터링 시스템"
    "grafana:grafana:3000:데이터 시각화 및 대시보드 플랫폼"
    "gitlab:gitlab:80:Git 저장소 관리 시스템"
    "jenkins:jenkins:8080:CI/CD 자동화 서버"
    "kong_gateway:kong:8000:API 게이트웨이 및 마이크로서비스 관리"
    "lite_llm:litellm:4000:LLM API 게이트웨이"
    "n8n:n8n:5678:워크플로우 자동화 플랫폼"
    "nexus:nexus:8081:아티팩트 저장소 관리자"
    "ragas:ragas:8000:RAG 평가 시스템"
)

# 프로젝트에서 구성 가능한 서비스들
PROJECT_SERVICES=(
    "prometheus"
    "grafana"
    "gitlab"
    "jenkins"
    "kong_gateway"
    "lite_llm"
    "n8n"
    "nexus"
    "ragas"
)

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}     서비스 상태 확인 스크립트${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${CYAN}📋 구성 가능한 서비스들:${NC}"
echo ""

# 서비스별 상태 확인 함수
check_service_status() {
    local service_name=$1
    local container_name=$2
    local port=$3
    local description=$4

    echo -e "${PURPLE}🔧 ${service_name}${NC}"
    echo -e "   설명: ${description}"
    echo -e "   포트: ${port}"
    echo -e "   컨테이너명: ${container_name}"

    # 컨테이너 상태 확인 (더 정확한 방법 사용)
    local status=$(docker ps -a --filter "name=${container_name}" --format "{{.Status}}" 2>/dev/null | head -1)
    local ports=$(docker ps -a --filter "name=${container_name}" --format "{{.Ports}}" 2>/dev/null | head -1)

    if [ ! -z "$status" ]; then
        # 컨테이너가 존재함
        if [[ $status == *"Up"* ]]; then
            echo -e "   상태: ${GREEN}✅ 실행 중${NC}"
            if [ ! -z "$ports" ] && [ "$ports" != "0.0.0.0:0->0/tcp" ]; then
                echo -e "   포트매핑: ${GREEN}${ports}${NC}"
            else
                echo -e "   포트매핑: ${YELLOW}매핑되지 않음${NC}"
            fi
        elif [[ $status == *"Exited"* ]]; then
            echo -e "   상태: ${RED}❌ 중지됨${NC}"
        elif [[ $status == *"Created"* ]]; then
            echo -e "   상태: ${YELLOW}⏸️  생성됨 (실행되지 않음)${NC}"
        else
            echo -e "   상태: ${YELLOW}⚠️  알 수 없음: ${status}${NC}"
        fi
    else
        echo -e "   상태: ${RED}❌ 컨테이너 없음${NC}"
    fi
    echo ""
}

# 각 서비스 상태 확인
for service_info in "${SERVICES[@]}"; do
    IFS=':' read -r service_name container_name port description <<< "$service_info"
    check_service_status "$service_name" "$container_name" "$port" "$description"
done

echo -e "${CYAN}📊 전체 서비스 현황 요약:${NC}"
echo ""

# 요약 정보 생성
total_services=${#SERVICES[@]}
running_containers=$(docker ps --filter "status=running" --format "{{.Names}}" | wc -l)
total_containers=$(docker ps -a --format "{{.Names}}" | wc -l)

echo -e "총 서비스 수: ${total_services}"
echo -e "실행 중인 컨테이너 수: ${GREEN}${running_containers}${NC}"
echo -e "전체 컨테이너 수: ${total_containers}"
echo ""

# 현재 프로젝트의 서비스들 중 실행 중인 것들 확인
echo -e "${CYAN}현재 프로젝트 서비스별 실행 현황:${NC}"
for service in "${PROJECT_SERVICES[@]}"; do
    container_name="${service}"
    if docker ps -a --filter "name=${container_name}" --format "{{.Names}}" | grep -q "^${container_name}$"; then
        status=$(docker ps -a --filter "name=${container_name}" --format "{{.Status}}" | head -1)
        if [[ $status == *"Up"* ]]; then
            echo -e "${service}: ${GREEN}✅ 실행 중${NC}"
        else
            echo -e "${service}: ${RED}❌ 중지됨${NC}"
        fi
    else
        echo -e "${service}: ${YELLOW}⏸️  구성되지 않음${NC}"
    fi
done

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}💡 사용법:${NC}"
echo -e "   ${YELLOW}./check-services.sh${NC} - 서비스 상태 확인"
echo -e "   ${YELLOW}docker-compose up -d 서비스명${NC} - 서비스 시작"
echo -e "   ${YELLOW}docker-compose down 서비스명${NC} - 서비스 중지"
echo -e "${BLUE}========================================${NC}"
