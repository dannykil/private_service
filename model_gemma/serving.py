"""
LLM 서빙 서버 (포트 8001)
- LLM 객체를 메모리에 유지하여 콜드스타트 방지
- 한 번 실행 후 계속 띄워둠
"""
from fastapi import FastAPI
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from langchain_ollama import OllamaLLM
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser
from contextlib import asynccontextmanager
from datetime import datetime
import os

# LLM 객체를 전역으로 유지
llm = None
chain = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    """서버 시작 시 LLM 초기화 (콜드스타트 1회)"""
    global llm, chain
    
    print("🚀 LLM 서빙 서버 시작 - 모델 초기화 중...")
    
    # 환경 변수에서 Ollama URL 가져오기 (기본값: localhost)
    ollama_base_url = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")
    print(f"🔗 Ollama 서버 연결: {ollama_base_url}")
    
    # LLM 초기화
    llm = OllamaLLM(
        # model="gemma2:9b",
        model="gemma2:2b",
        base_url=ollama_base_url,
        # num_predict=256,  # 응답 토큰 수 제한 (기본값 무제한 → 256)
        num_predict=128,  # 응답 토큰 수 제한 (기본값 무제한 → 256)
    )
    
    # 프롬프트 템플릿 + 체인 구성
    template = """Question: {question}

Answer: Let's think step by step."""
    prompt = PromptTemplate(template=template, input_variables=["question"])
    chain = prompt | llm | StrOutputParser()
    
    # 웜업 요청 (선택사항 - 첫 요청 지연 방지)
    print("🔥 웜업 요청 실행 중...")
    try:

        start_time = datetime.now()

        # _ = llm.invoke("Hello")
        answer = llm.invoke("Hello")

        end_time = datetime.now()
        duration = end_time - start_time

        # print("✅ LLM 웜업 완료! 서버 준비됨")
        print(f"✅ LLM 웜업 완료! 서버 준비됨: {answer}")

        print(f"⏱️  호출시간: {start_time.strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]}")
        print(f"⏱️  응답시간: {end_time.strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]}")
        print(f"⏱️  걸린시간: {duration.total_seconds():.3f}초")

    except Exception as e:
        print(f"⚠️ 웜업 실패 (Ollama 서버 확인 필요): {e}")
    
    yield  # 서버 실행
    
    # 서버 종료 시
    print("👋 LLM 서빙 서버 종료")

app = FastAPI(
    title="LLM Serving Server",
    description="Ollama LLM 서빙 서버 - 콜드스타트 방지용",
    lifespan=lifespan
)

# 요청/응답 스키마
class ChatRequest(BaseModel):
    question: str
    use_chain: bool = False  # True면 프롬프트 템플릿 사용

class ChatResponse(BaseModel):
    answer: str
    # model: str = "gemma2:9b"
    model: str = "gemma2:2b"
    

# 헬스체크
@app.get("/health")
async def health_check():
    print(f"LLM 헬스체크 요청 받음")

    return {"status": "ok", "model_loaded": llm is not None}

# 채팅 엔드포인트
@app.post("/chat", response_model=ChatResponse)
def chat(request: ChatRequest):  # async 제거 → FastAPI가 스레드풀에서 실행
    print(f"LLM 채팅 요청 받음: {request.question}")

    """LLM에 질문하고 응답 받기"""
    # 호출 시작 시간 기록
    start_time = datetime.now()
    
    if request.use_chain:
        # 프롬프트 템플릿 사용
        # answer = chain.invoke({"question": request.question})
        answer = llm.invoke(request.question)
    else:
        # 직접 호출
        answer = llm.invoke(request.question)
    
    # 응답 완료 시간 기록
    end_time = datetime.now()
    duration = end_time - start_time
    
    print(f"LLM 채팅 응답 반환: {answer}")
    print(f"⏱️  호출시간: {start_time.strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]}")
    print(f"⏱️  응답시간: {end_time.strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]}")
    print(f"⏱️  걸린시간: {duration.total_seconds():.3f}초")
    print()
    return ChatResponse(answer=answer)


# 스트리밍 채팅 엔드포인트
@app.post("/chat/stream")
async def chat_stream(request: ChatRequest):
    """LLM 스트리밍 응답 - 토큰 단위로 실시간 전송"""
    print(f"LLM 스트리밍 채팅 요청 받음: {request.question}")
    
    # start_time = None
    # end_time = None
    # duration = None
    
    async def generate():
        # start_time = datetime.now()

        for chunk in llm.stream(request.question):
            print(chunk)
            yield chunk
        
        # end_time = datetime.now()
        # duration = end_time - start_time
    
    
    # print(f"⏱️  호출시간: {start_time.strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]}")
    # print(f"⏱️  응답시간: {end_time.strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]}")
    # print(f"⏱️  걸린시간: {duration.total_seconds():.3f}초")
    
    return StreamingResponse(generate(), media_type="text/plain")


# 직접 실행 시
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
