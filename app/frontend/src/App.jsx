
import { useEffect, useState } from "react";
import {
  Activity,
  Bot,
  CheckCircle2,
  CircleAlert,
  Cloud,
  RefreshCw,
  Search,
  Send,
  Users,
  Terminal
} from "lucide-react";

const examples = [
  {
    label: "Pod crash",
    log: "Pod backend-7c9d is in CrashLoopBackOff. The application container exits with code 1."
  },
  {
    label: "IAM permission",
    log: "GKE application failed to access Secret Manager. Error: 403 Permission denied."
  },
  {
    label: "Image pull",
    log: "Pod employee-api reports ImagePullBackOff while pulling its Artifact Registry image."
  }
];

async function readJson(url, options = {}) {
  const response = await fetch(url, options);
  const data = await response.json().catch(() => ({}));

  if (!response.ok) {
    throw new Error(data.detail || `Request failed (${response.status})`);
  }

  return data;
}

export default function App() {
  const [page, setPage] = useState("employees");
  const [employees, setEmployees] = useState([]);
  const [employeeSearch, setEmployeeSearch] = useState("");
  const [employeeStatus, setEmployeeStatus] = useState("checking");
  const [agentStatus, setAgentStatus] = useState("checking");
  const [log, setLog] = useState("");
  const [service, setService] = useState("GKE");
  const [resource, setResource] = useState("deployment/employee-api");
  const [analysis, setAnalysis] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  async function loadEmployees() {
    setEmployeeStatus("checking");
    try {
      const data = await readJson("/api/employees");
      setEmployees(data);
      setEmployeeStatus("online");
    } catch {
      setEmployeeStatus("offline");
    }
  }

  async function checkAgent() {
    setAgentStatus("checking");
    try {
      await readJson("/troubleshooter/health");
      setAgentStatus("online");
    } catch {
      setAgentStatus("offline");
    }
  }

  useEffect(() => {
    loadEmployees();
    checkAgent();
  }, []);

  const filteredEmployees = employees.filter((employee) => {
    const query = employeeSearch.trim().toLowerCase();
    return (
      String(employee.id).includes(query) ||
      employee.name.toLowerCase().includes(query) ||
      employee.department.toLowerCase().includes(query)
    );
  });

  async function submitLog(event) {
    event.preventDefault();
    setError("");
    setAnalysis("");
    setLoading(true);

    try {
      const result = await readJson("/troubleshooter/analyze", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ log, service, resource })
      });
      setAnalysis(result.analysis);
    } catch (err) {
      setError(
        `${err.message}. Check that the agent is running and Vertex AI is configured.`
      );
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="app-shell">
      <aside className="sidebar">
        <div className="brand">
          <div className="brand-icon"><Cloud size={23} /></div>
          <div>
            <strong>CloudOps AI</strong>
            <span>GKE Learning Lab</span>
          </div>
        </div>

        <div className="nav-label">WORKSPACE</div>
        <button
          className={`nav-item ${page === "employees" ? "active" : ""}`}
          onClick={() => setPage("employees")}
        >
          <Users size={18} /> Employee directory
        </button>
        <button
          className={`nav-item ${page === "troubleshooter" ? "active" : ""}`}
          onClick={() => setPage("troubleshooter")}
        >
          <Bot size={18} /> AI troubleshooter
        </button>

        <div className="sidebar-bottom">
          <div className="nav-label">SERVICE HEALTH</div>
          <HealthRow label="Employee API" status={employeeStatus} />
          <HealthRow label="AI Agent API" status={agentStatus} />
          <p className="sidebar-note">
            Demo environment · Sample employee data only
          </p>
        </div>
      </aside>

      <main className="main">
        <header className="topbar">
          <div>
            <div className="eyebrow">GCP · GKE · FASTAPI</div>
            <h1>
              {page === "employees" ? "Employee directory" : "AI troubleshooter"}
            </h1>
          </div>
          <div className="environment"><span /> Learning environment</div>
        </header>

        {page === "employees" ? (
          <section className="content">
            <div className="welcome-card">
              <div>
                <div className="welcome-kicker">YOUR APPLICATION</div>
                <h2>Employee service</h2>
                <p>Explore sample employee data served by your FastAPI backend.</p>
              </div>
              <div className="welcome-art"><Users size={38} /></div>
            </div>

            <div className="stat-grid">
              <StatCard
                label="Employees loaded"
                value={employees.length}
                icon={<Users />}
              />
              <StatCard
                label="Employee API"
                value={employeeStatus === "online" ? "Online" : employeeStatus === "checking" ? "Checking" : "Offline"}
                icon={<Activity />}
              />
              <StatCard
                label="AI agent"
                value={agentStatus === "online" ? "Online" : agentStatus === "checking" ? "Checking" : "Offline"}
                icon={<Bot />}
              />
            </div>

            <section className="panel">
              <div className="panel-header">
                <div>
                  <h3>Employees</h3>
                  <p>Demo records from GET /api/employees</p>
                </div>
                <button className="secondary-button" onClick={loadEmployees}>
                  <RefreshCw size={15} /> Refresh
                </button>
              </div>

              <div className="search-box">
                <Search size={17} />
                <input
                  value={employeeSearch}
                  onChange={(event) => setEmployeeSearch(event.target.value)}
                  placeholder="Search name, department or ID..."
                />
              </div>

              {employeeStatus === "offline" ? (
                <div className="notice error-notice">
                  <CircleAlert size={19} />
                  <div>
                    <strong>Employee API unavailable</strong>
                    <p>Start the Employee API on port 8000 and refresh.</p>
                  </div>
                </div>
              ) : (
                <div className="table-wrap">
                  <table>
                    <thead>
                      <tr>
                        <th>ID</th>
                        <th>Employee</th>
                        <th>Department</th>
                        <th>Designation</th>
                      </tr>
                    </thead>
                    <tbody>
                      {filteredEmployees.map((employee) => (
                        <tr key={employee.id}>
                          <td className="id-cell">#{employee.id}</td>
                          <td><strong>{employee.name}</strong></td>
                          <td>{employee.department}</td>
                          <td>{employee.designation}</td>
                        </tr>
                      ))}
                      {filteredEmployees.length === 0 && (
                        <tr>
                          <td colSpan="4" className="empty-state">
                            No matching employees found.
                          </td>
                        </tr>
                      )}
                    </tbody>
                  </table>
                </div>
              )}
            </section>
          </section>
        ) : (
          <section className="content">
            <div className="welcome-card agent-welcome">
              <div>
                <div className="welcome-kicker">GEMINI · VERTEX AI</div>
                <h2>Investigate an error</h2>
                <p>Paste a GCP or GKE log and get a beginner-friendly troubleshooting plan.</p>
              </div>
              <div className="welcome-art"><Bot size={40} /></div>
            </div>

            <div className="notice info-notice">
              <Terminal size={19} />
              <div>
                <strong>Analysis only</strong>
                <p>This demo analyzes text you provide. It does not fetch Cloud Logging entries or execute fixes automatically.</p>
              </div>
            </div>

            <section className="panel">
              <div className="panel-header">
                <div>
                  <h3>Log investigation</h3>
                  <p>Remove secrets, tokens and personal data before submitting logs.</p>
                </div>
              </div>

              <div className="example-list">
                {examples.map((example) => (
                  <button
                    className="example-chip"
                    key={example.label}
                    onClick={() => setLog(example.log)}
                  >
                    {example.label}
                  </button>
                ))}
              </div>

              <form onSubmit={submitLog}>
                <div className="form-grid">
                  <label>
                    GCP service
                    <select value={service} onChange={(event) => setService(event.target.value)}>
                      <option>GKE</option>
                      <option>Cloud Run</option>
                      <option>Compute Engine</option>
                      <option>IAM</option>
                      <option>Secret Manager</option>
                      <option>Artifact Registry</option>
                    </select>
                  </label>
                  <label>
                    Resource
                    <input
                      value={resource}
                      onChange={(event) => setResource(event.target.value)}
                      maxLength={200}
                      placeholder="deployment/employee-api"
                    />
                  </label>
                </div>

                <label className="log-label">
                  Error log
                  <textarea
                    value={log}
                    onChange={(event) => setLog(event.target.value)}
                    required
                    minLength={5}
                    maxLength={15000}
                    rows={8}
                    placeholder="Paste your GCP or GKE error log here..."
                  />
                  <span className="character-count">{log.length}/15000 characters</span>
                </label>

                <button className="primary-button" type="submit" disabled={loading || log.trim().length < 5}>
                  {loading ? <RefreshCw className="spin" size={17} /> : <Send size={17} />}
                  {loading ? "Analyzing log..." : "Analyze with AI"}
                </button>
              </form>

              {error && (
                <div className="notice error-notice result-notice">
                  <CircleAlert size={19} />
                  <div><strong>Analysis failed</strong><p>{error}</p></div>
                </div>
              )}

              {analysis && (
                <div className="analysis-result">
                  <div className="result-title">
                    <div className="result-icon"><Bot size={20} /></div>
                    <div><h3>Agent analysis</h3><p>Generated from the supplied log text</p></div>
                  </div>
                  <pre>{analysis}</pre>
                </div>
              )}
            </section>
          </section>
        )}
      </main>
    </div>
  );
}

function HealthRow({ label, status }) {
  const text = status === "online" ? "Online" : status === "offline" ? "Offline" : "Checking";
  return (
    <div className="health-row">
      <span className={`health-dot ${status}`} />
      <span>{label}</span>
      <small>{text}</small>
    </div>
  );
}

function StatCard({ label, value, icon }) {
  return (
    <div className="stat-card">
      <div className="stat-icon">{icon}</div>
      <div><span>{label}</span><strong>{value}</strong></div>
      {value === "Online" && <CheckCircle2 className="stat-check" size={17} />}
    </div>
  );
}
