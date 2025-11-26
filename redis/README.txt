* 목표
1) 라이브러리 버전 
2) 이것도 mvc 아키텍처가 있지 않을까? > 찾기
3) 


* 환경 설정
1) 가상 환경 생성
python -m venv venv
python3 -m venv venv

2) 가상 환경 활성화 (Activate)
운영체제,명령어
Windows (CMD),venv\Scripts\activate.bat
Windows (PowerShell),.\venv\Scripts\Activate.ps1
macOS / Linux,source venv/bin/activate





* redis
1) 명령어
1.1) redis client 접속
docker exec -it redis_server redis-cli
1.2) key 조회
keys *
1.3) 키의 데이터 타입 확인 (TYPE)
TYPE [당신이확인하고싶은_KEY_이름]
TYPE message_history:f62b4c50-1a2b-4c3d-9e0f-1a2b3c4d5e6f
1.4) LangChain 대화 세션 확인 (List 타입)
* [UUID]를 실제 세션 ID로 대체하세요.
LRANGE message_history:[UUID] 0 -1
LRANGE message_store:8fb300fb-1263-44cc-8b37-bf383e8a1f2e 0 -1

2) 이슈
- TypeError: 'NoneType' object is not callable
> 특정 redis-py 버전을 피하고, 안정적으로 알려진 버전을 강제로 설치하여 호환성 문제를 해결하는 것이 가장 확실한 방법
pip install redis==4.5.5 --upgrade --force-reinstall

* 테스트 api 실행
uvicorn test_api:app --reload --port 8000


* LangServe 서버
1) Swagger UI (API 문서): http://localhost:8000/docs
http://localhost:7000/docs

2) LangServe Playground (테스트 환경): http://localhost:8000/agent/playground
http://localhost:7000/agent/playground