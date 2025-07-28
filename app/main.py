from fastapi import FastAPI

app = FastAPI(title="Agaruda Backend", version="1.0.0")


@app.get("/")
async def root():
    return {"message": "Hello from Agaruda Backend!"}


@app.get("/health")
async def health_check():
return {"status": "healthy v6"}


@app.get("/test")
async def test():
    return {"message": "Hello from Agaruda Backend!"}
