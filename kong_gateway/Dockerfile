FROM kong:latest

# Kong Gateway 커스텀 설정을 위한 디렉토리 생성
RUN mkdir -p /usr/local/kong/custom

# 필요한 플러그인이나 설정 파일을 복사할 수 있는 구조
# 예시:
# COPY kong.conf /usr/local/kong/custom/kong.conf
# COPY plugins/ /usr/local/kong/custom/plugins/

# 기본적으로 kong 이미지는 완전한 Kong Gateway를 포함하므로
# 특별한 커스터마이징이 없다면 이 정도로 충분합니다.

# Kong Gateway 실행 준비 완료
CMD ["/docker-entrypoint.sh", "kong", "docker-start"]
