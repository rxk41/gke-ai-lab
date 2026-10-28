from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="Employee API")


class Employee(BaseModel):
    id: int
    name: str
    department: str
    designation: str


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
