# Python 3.11 slim 이미지 사용
FROM python:3.11-slim

# 작업 디렉토리 설정
WORKDIR /app

# 필요한 패키지 목록 복사
COPY requirements.txt .

# Python 패키지 설치
RUN pip install --no-cache-dir -r requirements.txt

# 애플리케이션 코드 복사
COPY serving.py .

# 포트 8001 노출
EXPOSE 8001

# 컨테이너 실행 시 uvicorn으로 FastAPI 서버 시작
CMD ["uvicorn", "serving:app", "--host", "0.0.0.0", "--port", "8001"]
