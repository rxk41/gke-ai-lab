
from fastapi import FastAPI, HTTPException

app = FastAPI(title="Employee API")

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


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/api/employees")
def list_employees():
    return EMPLOYEES


@app.get("/api/employees/{employee_id}")
def get_employee(employee_id: int):
    for employee in EMPLOYEES:
        if employee["id"] == employee_id:
            return employee

    raise HTTPException(
        status_code=404,
        detail="Employee not found",
    )
