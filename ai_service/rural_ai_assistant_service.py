import os
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel, Field
from compute_model import run_sustainability_model
from config import config

app = FastAPI()

_bearer_scheme = HTTPBearer(auto_error=False)


def require_service_token(
    credentials: HTTPAuthorizationCredentials | None = Depends(_bearer_scheme),
) -> None:
    """Server-to-server authentication for /compute.

    When AI_SERVICE_TOKEN is configured, every call must present it as a
    Bearer token; comparison is constant-time. When the variable is unset,
    the endpoint stays open for local development only — production
    deployments MUST set it (fail-closed by configuration).
    """
    expected = config.token
    if not expected:
        # Dev-only mode. Documented in deploy/DEPLOYMENT.md: setting
        # AI_SERVICE_TOKEN is mandatory before any networked deployment.
        return
    # Constant-time comparison only (no early-exit != on secrets).
    import hmac

    presented = credentials.credentials if credentials else ""
    if len(presented) != len(expected) or not hmac.compare_digest(
        presented, expected
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid service token",
        )


class ComputePayload(BaseModel):
    value: float = Field(default=10.0, ge=-1e6, le=1e6)


@app.get("/")
def read_root():
    return {
        'status': 'Python AI Engine Online',
        'host': config.host,
        'port': config.port,
        'model_name': config.model_name,
    }


@app.post("/compute")
def compute(
    payload: ComputePayload,
    _: None = Depends(require_service_token),
):
    result = run_sustainability_model(payload.value)
    return {"status": "complete", "score": result}

if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host=config.host, port=config.port)