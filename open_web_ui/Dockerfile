# base image를 설정합니다. Open WebUI의 공식 이미지를 사용합니다.
# FROM ghcr.io/open-webui/open-webui:main
FROM ghcr.io/open-webui/open-webui:0.6.5

# 필요한 경우, 추가적인 환경 변수를 여기서 설정할 수 있습니다.
# 예를 들어, UI 테마나 기타 설정을 미리 정의할 수 있습니다.
ENV OPENAI_API_BASE=http://your-ollama-host:11434/v1

# 컨테이너의 포트를 노출합니다.
EXPOSE 8080

# 컨테이너가 시작될 때 실행할 명령어를 정의합니다.
# 공식 이미지에 이미 Entrypoint가 설정되어 있으므로, 굳이 추가할 필요는 없습니다.
# CMD ["/app/start.sh"]