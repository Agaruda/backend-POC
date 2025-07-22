from fastapi import FastAPI

app = FastAPI(title="Agaruda Backend")


@app.get("/")
async def root():
    return {"message": "Hello from Agaruda Backend!"}


@app.get("/health")
async def health_check():
    return {"status": "healthy"}


@app.get("/test")
async def test():
    return {"message": "Hello from Agaruda Backend!"}
