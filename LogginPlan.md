# ✅ Azure Logging Plan (Simple & Clear)

This document explains **what logs we should collect**, **why**, and **what actions we need to take**.

---

## 1. 🔹 Logs Collection (Minimum Required)

| Log Type            | Why We Need It                            | Enabled by Azure? | Sent to Log Analytics? | What We Must Do       |
|---------------------|--------------------------------------------|-------------------|------------------------|------------------------|
| Activity Logs       | Tracks who did what (create, delete, etc.)| ✅ Yes             | ❌ No                   | Manually send to Log Analytics |
| Azure Firewall Logs | Shows traffic allowed/denied/threats      | ❌ No              | ❌ No                   | Enable manually         |
| NSG Flow Logs       | Subnet-level traffic details               | ❌ No              | ❌ No                   | Enable for key subnets |
| Key Vault Logs      | Who accessed secrets/keys                  | ❌ No              | ❌ No                   | Enable manually         |
| Azure AD Logs       | Sign-ins and user activity (security)      | ❌ No              | ❌ No                   | Link manually to Log Analytics |

---

## 2. 🔸 以下のサービスも使ってるので、Log習得した方が良い

| Service             | Reason to Log                              | Action Required      |
|---------------------|---------------------------------------------|----------------------|
| Cosmos DB           | Query stats, latency, throttling            | Need to enable       |
| Data Factory        | Pipeline success/failure                    | Need to enable       |
| Synapse             | SQL + pipeline diagnostics                  | Need to enable       |
| API Management      | API requests, backend errors                | Need to enable       |
| App Gateway / WAF   | Web traffic visibility & attacks            | Need to enable       |

---

## 3. 🗃 Retention Plan

- Keep logs in **Log Analytics for 2–3 months**
- After that, send to **Datadog** for long-term use

---

## 4. 🧠 Summary – What We Must Do

- ✅ Activity Logs: Already enabled, but we must redirect to Log Analytics
- ✅ Firewall / NSG / KV : We must **manually enable logging**
- ⚠️ Only log other services (Cosmos, DFactory, etc.) **if we use them**
- 🔄 Final logs will go to **Datadog** for long-term monitoring

---

