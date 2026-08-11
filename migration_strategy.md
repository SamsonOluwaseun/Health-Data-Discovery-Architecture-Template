# Data Migration Strategy
## Gov Health Data Platform — Discovery to Alpha
### [Organisation Name] | Version 0.1 | [Date]

---

## 1. Executive Summary

This document defines the migration strategy for moving [Organisation]'s health data from legacy on-premises systems to the target AWS cloud data platform. The strategy covers approach, tooling, phasing, validation, cutover, and rollback.

---

## 2. Migration Scope

### 2.1 In Scope

| Source System | Data Type | Volume (est.) | Target Layer |
|--------------|-----------|-------------|-------------|
| PAS (Patient Administration) | Patient demographics, admissions | [X] million rows | Silver — patient, clinical_event |
| EPR (Electronic Patient Record) | Clinical episodes, diagnoses | [X] million rows | Silver — clinical_event |
| LIMS (Lab System) | Specimens, lab results | [X] million rows | Silver — specimen, lab_result |
| Finance System | Activity costs, contracts | [X] million rows | Gold — finance_mart |
| Network file shares (CSV/Excel) | Ad-hoc reports, extracts | [X] GB | Bronze — archive |

### 2.2 Out of Scope (Phase 1)
- Real-time streaming data (Phase 2)
- Imaging data / PACS (separate workstream)
- GP system data (requires IM1/GP Connect integration — separate)
- Archive data >8 years old (legal hold — separate process)

---

## 3. Migration Approach

### Selected Approach: **Phased Migration with Parallel Run**

```
Phase 1 — Foundation (Weeks 1-3)
  └── AWS infrastructure provisioned
  └── Bronze layer schemas deployed
  └── Network connectivity established (Direct Connect / VPN)

Phase 2 — Historical Load (Weeks 3-5)
  └── Full historical data load: PAS, EPR, LIMS
  └── Data quality validation against source
  └── Silver layer transformation runs

Phase 3 — Parallel Run (Weeks 5-6)
  └── Source systems still live
  └── Daily incremental loads to AWS
  └── Reconciliation reports: source vs target row counts, key metrics
  └── Stakeholder sign-off on data accuracy

Phase 4 — Cutover (Week 7)
  └── Final incremental sync
  └── Source system freeze (agreed window)
  └── Final validation
  └── Go-live: reporting from AWS
  └── Source system read-only access for 30 days
```

---

## 4. AWS Migration Tooling

| Migration Task | AWS Service | Notes |
|--------------|-------------|-------|
| Database migration (on-prem DB → RDS) | **AWS DMS** | Full load + ongoing CDC replication |
| Bulk file transfer (CSV/Excel → S3) | **AWS DataSync** | Scheduled, encrypted transfer |
| Schema conversion (SQL Server → PostgreSQL) | **AWS SCT** | Schema Conversion Tool — review and fix warnings |
| Data transformation (raw → silver) | **AWS Glue** | Python/Spark ETL jobs |
| Incremental load orchestration | **AWS Step Functions** | Daily pipeline scheduler |
| Sensitive data discovery | **Amazon Macie** | PII scanning on S3 raw bucket |
| Network connectivity | **AWS Direct Connect / Site-to-Site VPN** | Encrypted in transit |

---

## 5. AWS DMS Configuration

### 5.1 Replication Instance
```
Instance class: dms.r5.xlarge (adjust based on data volume)
Engine: 3.5.x
Multi-AZ: Yes (for production)
VPC: Same VPC as target RDS
Subnet group: Private subnets only
```

### 5.2 Source Endpoint Configuration (SQL Server example)
```
Engine: sqlserver
Server: [on-prem server hostname / IP]
Port: 1433
Database: [source_db_name]
Username: dms_readonly_user   ← read-only account
SSL mode: verify-full
Extra connection attributes: readBackupOnly=true
```

### 5.3 Target Endpoint Configuration (PostgreSQL RDS)
```
Engine: postgres
Server: [rds-endpoint.rds.amazonaws.com]
Port: 5432
Database: govhealth_silver
Schema: silver
Username: dms_writer_user
SSL mode: verify-full
```

### 5.4 Task Configuration
```
Migration type: Full load + CDC (Change Data Capture)
LOB settings: Limited LOB mode (64KB max)
Table mappings: Include specific schemas/tables only
Logging: CloudWatch — enable all task logging
Stop on error: Yes (investigate before resuming)
```

---

## 6. Pre-Migration Checklist

### Infrastructure
- [ ] AWS Direct Connect or VPN tunnel established and tested
- [ ] DMS replication instance provisioned
- [ ] Source endpoints validated (test connection)
- [ ] Target RDS endpoint validated
- [ ] DDL deployed to target RDS (`03_physical_data_model.sql`)
- [ ] S3 buckets created with SSE-KMS encryption
- [ ] IAM roles for DMS and Glue created with minimum permissions
- [ ] CloudWatch logging enabled on DMS tasks

### Data Readiness
- [ ] Source data profiled (row counts, null rates, key distributions)
- [ ] Data quality baseline established
- [ ] PII inventory complete — all PII fields identified
- [ ] Data mapping document signed off by Data Owner
- [ ] NHS Number validation: all patient records have valid NHS Number
- [ ] Referential integrity checked: no orphan records in source

### Governance
- [ ] Data Sharing Agreement in place (if migrating from external system)
- [ ] IG sign-off from Caldicott Guardian for patient data migration
- [ ] DPIA completed and approved
- [ ] Migration window agreed with operations team
- [ ] Rollback plan reviewed by technical lead
- [ ] Comms sent to affected stakeholders

---

## 7. Data Validation Framework

Run after every load phase:

### 7.1 Row Count Reconciliation
```sql
-- Run on source (SQL Server)
SELECT 'PATIENT' AS entity, COUNT(*) AS source_count FROM [source_db].[dbo].[patients]
UNION ALL
SELECT 'CLINICAL_EVENT', COUNT(*) FROM [source_db].[dbo].[hospital_episodes];

-- Run on target (PostgreSQL)
SELECT 'PATIENT' AS entity, COUNT(*) AS target_count FROM silver.patient
UNION ALL
SELECT 'CLINICAL_EVENT', COUNT(*) FROM silver.clinical_event;
```
✅ **Pass criteria:** Target count = Source count ± 0.01%

### 7.2 Key Field Validation
```sql
-- Check all NHS Numbers transferred
SELECT COUNT(*) AS missing_nhs
FROM silver.patient
WHERE nhs_number IS NULL OR LENGTH(nhs_number) != 10;

-- Check referential integrity: every event has a valid patient
SELECT COUNT(*) AS orphan_events
FROM silver.clinical_event ce
LEFT JOIN silver.patient p ON ce.patient_sk = p.patient_sk
WHERE p.patient_sk IS NULL;
```
✅ **Pass criteria:** All counts = 0

### 7.3 Business Metric Reconciliation
```sql
-- Compare key metrics between source reports and target
-- e.g. Total admissions this month
SELECT
    TO_CHAR(admission_date, 'YYYY-MM') AS month,
    COUNT(*) AS admissions
FROM silver.clinical_event
WHERE event_type = 'INPATIENT'
GROUP BY 1 ORDER BY 1;
```
✅ **Pass criteria:** Metrics match source operational reports within 0.5%

---

## 8. Cutover Plan

| Step | Action | Owner | Duration | Validation |
|------|--------|-------|----------|-----------|
| T-48h | Final comms to stakeholders | PM | 30 min | Acknowledgement received |
| T-24h | Final full-load DMS task run | Data Engineer | 2-4 hrs | Row counts match |
| T-4h | Pause source system writes (freeze window) | Operations | 30 min | Confirmed by source team |
| T-2h | Final incremental CDC sync | Data Engineer | 1-2 hrs | Zero lag on DMS task |
| T-1h | Final validation queries | Data Architect | 1 hr | All checks pass |
| T-0 | Switch reporting to AWS target | BI Lead | 30 min | Dashboards loading |
| T+1h | Stakeholder sign-off | Programme Manager | 30 min | Sign-off email |
| T+24h | Monitor for issues | Data Engineer | Ongoing | CloudWatch alarms |

---

## 9. Rollback Plan

**Trigger:** Validation failure rate > 1% on critical fields, or stakeholder rejection

**Rollback Steps:**
1. Revert reporting tools to source system connection (< 30 min)
2. Stop DMS CDC replication task
3. Notify stakeholders: cutover reversed, investigating issue
4. Root cause analysis within 24 hours
5. Fix identified issue in staging environment
6. Re-test and re-schedule cutover

**Rollback window:** Source systems kept in read-write mode for 5 working days after cutover. After 5 days, source systems move to read-only (30-day archive access).

---

## 10. Post-Migration Monitoring

Set up **CloudWatch Alarms** for:
- DMS task latency > 10 minutes (CDC lag)
- RDS CPU > 80% for 5+ minutes
- S3 failed put events > 10 in 1 hour
- Glue job failure rate > 0

Review daily for the first 2 weeks post-cutover:
- Row counts vs source operational system
- Data quality scores (completeness, accuracy)
- User-reported data discrepancies

---

*[Organisation] | Data Migration Strategy | Version 0.1 | [Date]*
