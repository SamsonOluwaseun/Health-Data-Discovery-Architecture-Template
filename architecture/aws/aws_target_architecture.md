# AWS Target Architecture Design
## Gov Health Data Platform
### [Organisation Name] | Version 0.1 | [Date]

---

## 1. Architecture Overview

The target data platform runs entirely on **AWS (eu-west-2 — London region)** to satisfy NHS data residency requirements. It implements a **Medallion Architecture** (Bronze → Silver → Gold) with governance enforced at every layer via AWS Lake Formation, KMS encryption, and CloudTrail audit logging.

---

## 2. AWS Account Structure

```
Management Account (Root)
├── Security Account         ← CloudTrail, GuardDuty, Security Hub aggregation
├── Log Archive Account      ← Centralised CloudWatch + S3 access logs
├── Network Account          ← Transit Gateway, Direct Connect, VPN
└── Workload Accounts
    ├── govhealth-dev        ← Development and testing
    ├── govhealth-staging    ← Pre-production / UAT
    └── govhealth-prod       ← Production workloads
```

> Use **AWS Control Tower** to manage the account factory and guardrails.

---

## 3. Network Architecture

### 3.1 Connectivity to Source Systems (On-Prem)

| Option | Recommended For | Bandwidth | Latency |
|--------|----------------|-----------|---------|
| **AWS Direct Connect** | Production patient data, ongoing CDC | 1 Gbps | Low |
| **AWS Site-to-Site VPN** | Development, low-volume transfers | Variable | Medium |
| **AWS DataSync over internet** | One-time historical loads (encrypted) | Variable | Higher |

**Recommended:** Direct Connect (1Gbps) for production; VPN for dev/staging.

### 3.2 VPC Design

```
VPC: 10.0.0.0/16 (govhealth-prod)
├── Private Subnet A (eu-west-2a): 10.0.1.0/24  ← RDS, Glue, Lambda
├── Private Subnet B (eu-west-2b): 10.0.2.0/24  ← RDS standby, Redshift
├── Private Subnet C (eu-west-2c): 10.0.3.0/24  ← DMS replication instance
└── (No public subnets — all access via VPN / Direct Connect / PrivateLink)
```

---

## 4. S3 Bucket Design

| Bucket | Purpose | Encryption | Lifecycle | Versioning |
|--------|---------|-----------|---------|-----------|
| `govhealth-raw-[account-id]` | Bronze — raw ingested data | SSE-KMS | 90d → Glacier → Delete at retention | Enabled |
| `govhealth-silver-[account-id]` | Silver — conformed data archive | SSE-KMS | Per retention policy | Enabled |
| `govhealth-gold-[account-id]` | Gold — aggregated exports | SSE-KMS | 365d | Enabled |
| `govhealth-glue-assets-[account-id]` | Glue scripts, temp storage | SSE-KMS | 30d temp purge | Disabled |
| `govhealth-logs-[account-id]` | CloudTrail, S3 access logs | SSE-S3 | 365d → Glacier → 7yr delete | Enabled |
| `govhealth-dms-staging-[account-id]` | DMS replication staging | SSE-KMS | 7d auto-delete | Disabled |

### S3 Bucket Policy — Block All Public Access
```json
{
  "BlockPublicAcls": true,
  "IgnorePublicAcls": true,
  "BlockPublicPolicy": true,
  "RestrictPublicBuckets": true
}
```

---

## 5. AWS RDS Configuration (Silver Layer)

```
Engine: PostgreSQL 15.x
Instance class: db.r6g.xlarge (adjust based on volume)
Multi-AZ: Yes (eu-west-2a primary, eu-west-2b standby)
Storage: gp3 SSD — 500GB initial (auto-scaling to 2TB)
Encryption: AWS KMS (customer-managed key)
Backup retention: 35 days automated backups
Maintenance window: Sunday 02:00-03:00 UTC
Parameter group: govhealth-postgres15 (custom — performance tuned)
Security group: Inbound port 5432 from Glue, DMS, Lambda SGs only
```

### Database Schemas
```sql
CREATE SCHEMA silver;       -- Conformed health data (from DDL file)
CREATE SCHEMA gold;         -- Aggregated marts
CREATE SCHEMA governance;   -- Data catalogue, audit, DQ log
```

---

## 6. Amazon Redshift Serverless (Gold Layer)

```
Namespace: govhealth-analytics
Workgroup: govhealth-prod
Base RPU capacity: 8 RPUs (auto-scaling 8-32)
Encryption: AWS KMS
VPC: Same VPC as RDS — private subnets only
Snapshot retention: 35 days
IAM roles: Redshift → S3 read (for COPY command)
```

---

## 7. AWS Glue Configuration

### Glue Data Catalog
- One Glue Database per S3 layer: `raw_db`, `silver_db`, `gold_db`
- Crawlers scheduled daily to update table schemas
- Schema registry for FHIR JSON schemas

### Glue ETL Jobs

| Job Name | Source | Target | Schedule | Worker Type |
|---------|--------|--------|---------|------------|
| `raw-to-silver-patient` | S3 raw (patient JSON) | RDS silver.patient | Daily 02:00 | G.1X × 5 |
| `raw-to-silver-clinical-event` | S3 raw (episodes) | RDS silver.clinical_event | Daily 02:30 | G.1X × 10 |
| `raw-to-silver-lab-result` | S3 raw (LIMS) | RDS silver.lab_result | Daily 03:00 | G.1X × 8 |
| `silver-to-gold-activity-mart` | RDS silver | Redshift gold | Daily 05:00 | G.2X × 5 |
| `dq-checker` | RDS silver | governance.data_quality_log | Daily 06:00 | G.1X × 2 |

---

## 8. AWS DMS Configuration

### Replication Instance
```
Class: dms.r5.xlarge
Engine version: 3.5.x
Multi-AZ: Yes
VPC: govhealth-prod VPC
Subnet group: Private subnets
```

### Migration Tasks

| Task | Source | Target | Method |
|------|--------|--------|--------|
| `pas-patient-full-load` | SQL Server PAS | S3 raw (JSON) | Full load |
| `pas-patient-cdc` | SQL Server PAS | S3 raw (JSON) | Ongoing CDC |
| `epr-episodes-full-load` | Oracle EPR | S3 raw | Full load |
| `epr-episodes-cdc` | Oracle EPR | S3 raw | Ongoing CDC |
| `lims-full-load` | PostgreSQL LIMS | S3 raw | Full load |
| `lims-cdc` | PostgreSQL LIMS | S3 raw | Ongoing CDC |

---

## 9. IAM Roles

| Role Name | Principal | Permissions | Purpose |
|-----------|-----------|------------|---------|
| `GovHealthGlueRole` | Glue | S3 read/write, RDS, CloudWatch logs | ETL job execution |
| `GovHealthDMSRole` | DMS | S3 write, CloudWatch logs | Migration tasks |
| `GovHealthLambdaRole` | Lambda | S3 read, API GW invoke, CloudWatch | Validation functions |
| `GovHealthRedshiftRole` | Redshift | S3 read (gold bucket), Glue | COPY commands |
| `GovHealthAnalystRole` | IAM users (analyst group) | Redshift read, QuickSight | Data consumers |
| `GovHealthEngineerRole` | IAM users (engineer group) | S3 raw+silver, RDS, Glue | Data Engineers |
| `GovHealthAdminRole` | IAM users (admin group) | All platform resources | Data Architects |
| `GovHealthAuditRole` | IAM users (IG team) | CloudTrail read, governance schema | Audit and IG |

---

## 10. Security Controls Summary

| Control | Service | Setting |
|---------|---------|---------|
| Encryption at rest | KMS | Customer-managed CMK per environment |
| Encryption in transit | ACM / TLS | TLS 1.2 minimum enforced |
| Network isolation | VPC | No public subnets; PrivateLink for AWS services |
| Access control | Lake Formation + IAM | Column-level security on sensitive tables |
| PII detection | Amazon Macie | Daily scan of raw S3 bucket |
| Audit logging | CloudTrail | All API calls logged to central log bucket |
| Threat detection | GuardDuty | Enabled across all accounts |
| Vulnerability scanning | Inspector | EC2 / Lambda automated scanning |
| Secrets management | Secrets Manager | All DB credentials; rotated every 90 days |
| SIEM integration | Security Hub | Aggregated across all accounts |

---

## 11. Cost Estimate (Indicative)

| Service | Monthly Estimate (£) | Notes |
|---------|---------------------|-------|
| AWS Direct Connect (1Gbps) | £500-800 | Location-dependent |
| RDS PostgreSQL (r6g.xlarge, Multi-AZ) | £400-600 | |
| Redshift Serverless (8 RPUs baseline) | £200-500 | Scales with query volume |
| S3 Storage (1TB raw + 500GB silver) | £30-60 | |
| AWS Glue (ETL jobs, daily) | £100-200 | |
| AWS DMS (r5.xlarge, Multi-AZ) | £300-400 | Migration period only |
| CloudTrail, GuardDuty, Macie | £50-100 | |
| **Total (migration period)** | **~£1,600-2,600/month** | |
| **Total (steady state, post-migration)** | **~£1,200-1,800/month** | DMS removed |

> Costs are indicative. Run **AWS Pricing Calculator** with actual data volumes for accurate estimates.

---

*[Organisation] | AWS Target Architecture | Version 0.1 | [Date]*
