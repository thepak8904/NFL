#   Azure Logging Plan の下書き

This document explains **what logs we should collect**, **why**, and **what actions we need to take**.


+-------------------+                 +-------------------+                 +--------------------------+
|                   | Diagnostic     |                   | Diagnostic     |                          |
| Azure Resources   +--------------->+ Log Analytics WS  +---------------->+ Azure Monitor Alerts     |
| (Firewall, KV,    | Settings       | (Query + Alert)   | KQL, Alerts    | (email, webhook, etc.)   |
| AKS, API Mgmt...) |                +--------+----------+                 +--------------------------+
|                   |                         |
+--------+----------+                         |
         |                                    |
         |                                    ▼
         |                           +--------+----------+
         |                           | Event Hub         |
         |                           | (Streaming logs)  |
         |                           +--------+----------+
         |                                    |
         |                                    ▼
         |                           +--------+----------+
         |                           | Datadog           |
         |                           | Ingest via Agent  |
         |                           | or Event Hub API  |
         |                           | - Dashboards      |
         |                           | - Alerts          |
         |                           | - Monitors        |
         |                           +-------------------+
         |
         |  (parallel)
         ▼
+--------+----------+
| Azure Storage     |
| (Blob Container)  |
| - Archive Tier    |
| - Lifecycle Mgmt  |
| - Immutability    |
+--------+----------+
         |
         ▼
+--------+----------+
| Long-Term Archive |
| (10 Years)        |
| - Raw JSON logs   |
| - Compliance Use  |
+-------------------+


---

## 1. 必だと思うログ　(セキュリティや監査上、必須ログ)

| Log Type                 | Why We Need It                                   | Enabled by Azure?    | Sent to Log Analytics? | What We Must Do                        |
|--------------------------|--------------------------------------------------|-------------------|------------------------|--------------------------------------------|
| Activity Logs            | Track who created, updated, or deleted resources |Yes                |  No                  | Route manually to Log Analytics             |
| Azure Firewall Logs      | Track allowed/denied/threat traffic              | No                |  No                  | Enable Diagnostic Settings per firewall     |
| NSG Flow Logs 　　　　　  | Subnet-level traffic flow (critical zones)       |  No                |  No                  | Enable only on hub/public-facing subnets    |
| Key Vault Logs           | Monitor secret/key access                        | No                |  No                  | Enable Diagnostic Settings per vault        |
| Azure AD Sign-in Logs    | Track login activity and risky sign-ins          | No                |  No                  | Enable via AAD Diagnostic Settings          |
| Defender for Cloud Alerts| Security alerts, threat detections               | No                |  No                  | Enable plan + route to Log Analytics        |
| AKS Control Plane Logs   | Monitor Kubernetes API, scheduler, etc.          | No                |  No                  | Enable via Azure Monitor for containers     |
| Backup Logs              | Monitor backup job success/failure               | No                |  No                  | Enable Diagnostic Settings on Backup Vault  |

---

## 2. 使用するリソースに応じて有効化

| Resource / Service        | Reason to Log                                 | Recommendation                                        |
|---------------------------|-----------------------------------------------|-------------------------------------------------------|
| NSG Flow Logs             | Subnet traffic detail                         |  Enable only on critical subnets (hub/public)         |
| API Management Logs       | API access tracing and backend error logging  |  Enable if external users or customers are involved   |
| App Gateway /             | Web traffic visibility and WAF threat logging |  Enable if exposed to internet / public traffic       |
| Data Factory Logs         | ETL pipeline execution monitoring             |  Enable for production workloads                      |
| Synapse Analytics Logs    | Big data job diagnostics                      |  Enable if jobs often fail or time out                |
| Cosmos DB Logs            | Query performance and throttling              |  Enable if tuning or debugging DB performance         |

---

## 3. Retention Plan

- Keep logs in **Log Analytics for 2–3 months**
- After that, send to **Datadog** for long-term use
---

## 4. Alert Planning – What Logs Should Trigger Alerts?

| Log Type                | Why Alert Is Needed                              | Example Alert Conditions                          | Where to send alert |
|-------------------------|---------------------------------------------------|---------------------------------------------------|------------------------|
| Azure Firewall Logs     | Detect denied traffic, threat IPs, port scans     | - Multiple denies from 1 IP <br> - Unusual port access ||
| Azure AD Sign-in Logs   | Detect brute force, risky login behavior          | - Multiple failed sign-ins <br> - New country sign-in ||
| Key Vault Logs          | Monitor sensitive access to secrets               | - Secret access outside business hours             ||
| Defender for Cloud      | Respond to security threat alerts                 | - Malware detection <br> - VM misconfig alert     ||
| AKS Logs                | Detect cluster misuse, throttling, or errors      | - Kube API errors <br> - Unauthorized actions     ||
| WAF / App Gateway Logs  | Detect attack patterns or traffic anomalies       | - Spike in 4xx/5xx responses <br> - WAF rule match ||
| NSG Flow Logs (selective)| Detect unexpected subnet access                  | - Traffic to restricted ports                     |

###  Optional Alerts (Enable if the resource is used):

| Log Type          | When to Alert                              |
|-------------------|---------------------------------------------|
| Data Factory Logs | If pipeline fails repeatedly                |
| Synapse Logs      | If critical jobs fail or timeout            |
| Cosmos DB Logs    | If repeated throttling or query failures    |
| Backup Logs       | If backup fails or is delayed               |
