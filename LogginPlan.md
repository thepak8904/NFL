# ✅ Azure Logging Plan (Simple & Clear)

This document explains **what logs we should collect**, **why**, and **what actions we need to take**.

---

## 1. 🔹 Logs We Must Always Collect (Minimum Required)

| Log Type            | Why We Need It                            | Enabled by Azure? | Sent to Log Analytics? | What We Must Do       |
|---------------------|--------------------------------------------|-------------------|------------------------|------------------------|
| Activity Logs       | Tracks who did what (create, delete, etc.)| ✅ Yes             | ❌ No                   | Manually send to Log Analytics |
| Azure Firewall Logs | Shows traffic allowed/denied/threats      | ❌ No              | ❌ No                   | Enable manually         |
| NSG Flow Logs       | Subnet-level traffic details               | ❌ No              | ❌ No                   | Enable for key subnets |
| Key Vault Logs      | Who accessed secrets/keys                  | ❌ No              | ❌ No                   | Enable manually         |
| Azure AD Logs       | Sign-ins and user activity (security)      | ❌ No              | ❌ No                   | Link manually to Log Analytics |

---

## 2. 🔸 Logs We Recommend If the Service Is Used

| Service             | Reason to Log                              | Action Required      |
|---------------------|---------------------------------------------|----------------------|
| Cosmos DB           | Query stats, latency, throttling            | Enable if used       |
| Data Factory        | Pipeline success/failure                    | Enable if used       |
| Synapse             | SQL + pipeline diagnostics                  | Enable if used       |
| API Management      | API requests, backend errors                | Enable if used       |
| App Gateway / WAF   | Web traffic visibility & attacks            | Enable if used       |

---

## 3. 🗃 Retention Plan

- Keep logs in **Log Analytics for 2–3 months**
- After that, send to **Datadog** for long-term use
- No need to store in Storage Account unless required by compliance

---

## 4. 🧠 Summary – What We Must Do

- ✅ Activity Logs: Already enabled, but we must redirect to Log Analytics
- ✅ Firewall / NSG / KV / Azure AD: We must **manually enable logging**
- ⚠️ Only log other services (Cosmos, DFactory, etc.) **if we use them**
- ✅ Keep logs short-term in Azure
- 🔄 Final logs will go to **Datadog** for long-term monitoring

---

