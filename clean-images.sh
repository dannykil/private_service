#!/bin/bash

# ============================================================================
# Script to find and remove Docker images with <none> repository
# ============================================================================

echo "=== Docker 이미지 정리 스크립트 ==="
echo ""

# 1단계: <none> 레포지토리 이미지를 찾기
echo "1. <none> 레포지토리 이미지를 검색합니다..."
DANGLING_IMAGES=$(docker images | grep "^<none>" | awk '{print $3}')

if [ -z "$DANGLING_IMAGES" ]; then
    echo "   <none> 레포지토리 이미지가 없습니다."
    exit 0
fi

echo "   발견된 <none> 이미지들:"
echo "$DANGLING_IMAGES" | while read image_id; do
    if [ ! -z "$image_id" ]; then
        echo "   - 이미지 ID: $image_id"
    fi
done

echo ""

# 2단계: 사용자에게 삭제 확인 요청
echo "2. 위 이미지들을 삭제하시겠습니까? (y/N)"
read -r confirm

if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "   삭제를 취소했습니다."
    exit 0
fi

# 3단계: 이미지 삭제
echo ""
echo "3. 이미지들을 삭제합니다..."
echo "$DANGLING_IMAGES" | while read image_id; do
    if [ ! -z "$image_id" ]; then
        echo "   삭제 중: $image_id"
        docker rmi "$image_id" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "   ✓ 성공적으로 삭제됨"
        else
            echo "   ✗ 삭제 실패 (이미 사용 중이거나 다른 컨테이너에서 참조 중)"
        fi
    fi
done

echo ""
echo "=== 이미지 정리 완료 ==="

# 4단계: 정리 후 이미지 목록 표시 (선택사항)
echo ""
echo "정리 후 남은 이미지 목록:"
docker images
