
import os

import google.auth.transport.requests
import requests
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from google.oauth2 import id_token

app = FastAPI(title="Employee API")

# Private Cloud Run Troubleshooter Agent URL
TROUBLESHOOTER_URL = os.environ.get(
    "TROUBLESHOOTER_URL",
    "https://troubleshooter-agent-krebtafpnq-uc.a.run.app",
).rstrip("/")


class Employee(BaseModel):
    id: int
    name: str
    department: str
    designation: str


class AnalyzeRequest(BaseModel):
    log: str = Field(min_length=5, max_length=15000)
    service: str = "GKE"
    resource: str = "gitops-dev-gke"


EMPLOYEES = [
    {
        "id": 101,
        "name": "Asha Patel",
        "department": "Engineering",
        "designation": "Software Engineer",
    },
    {
        "id": 102,
        "name": "Rahul Shah",
        "department": "Platform",
        "designation": "DevOps Engineer",
    },
]


@app.get("/")
def root():
    return {
        "message": "Welcome to Employee API",
        "status": "running",
        "docs": "/docs",
        "health": "/health",
    }


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/api/employees", response_model=list[Employee])
def list_employees():
    return EMPLOYEES


@app.get("/api/employees/{employee_id}", response_model=Employee)
def get_employee(employee_id: int):
    for employee in EMPLOYEES:
        if employee["id"] == employee_id:
            return employee

    raise HTTPException(
        status_code=404,
        detail="Employee not found",
    )


@app.post("/troubleshooter/analyze")
def analyze_with_ai(request: AnalyzeRequest):
    try:
        # Obtain a short-lived Google identity token.
        # On GKE, this uses the workload's Google credentials.
        auth_request = google.auth.transport.requests.Request()

        token = id_token.fetch_id_token(
            auth_request,
            TROUBLESHOOTER_URL,
        )

        response = requests.post(
            f"{TROUBLESHOOTER_URL}/analyze",
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json",
            },
            json=request.model_dump(),
            timeout=120,
        )

        if response.status_code >= 400:
            raise HTTPException(
                status_code=response.status_code,
                detail=f"Troubleshooter Agent returned an error: {response.text[:1000]}",
            )

        return response.json()

    except HTTPException:
        raise

    except requests.Timeout:
        raise HTTPException(
            status_code=504,
            detail="Troubleshooter Agent request timed out",
        )

    except Exception:
        # Avoid exposing credentials or internal exception details.
        raise HTTPException(
            status_code=502,
            detail="Unable to connect to the Troubleshooter Agent",
        )
