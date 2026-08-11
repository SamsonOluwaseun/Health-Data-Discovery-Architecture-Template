# Data Governance Framework
## Gov Health Data Discovery Engagement
### [Organisation Name] | Version 0.1 | [Date]

---

## 1. Purpose

This document defines the data governance framework applicable to the [Organisation] data platform. It covers data ownership, stewardship, classification, quality management, and compliance obligations under UK GDPR, NHS Data Security and Protection Toolkit (DSPT), and the NHS Records Management Code of Practice 2021.

---

## 2. Governance Structure

### 2.1 Roles and Responsibilities

| Role | Responsibility | Who Holds It |
|------|---------------|-------------|
| **Senior Information Risk Owner (SIRO)** | Accountable for all information risk across the organisation | [Executive Director] |
| **Caldicott Guardian** | Protects patient information; approves uses of patient data | [Clinical Lead] |
| **Data Protection Officer (DPO)** | UK GDPR compliance; oversees RoPA; advises on lawful processing | [IG Lead] |
| **Data Owner** | Accountable for a specific data domain; sets policy | [Department Head] |
| **Data Steward** | Day-to-day data quality and governance for a dataset | [Named Individual] |
| **Data Architect** | Designs data structures, flows, and standards | [Architecture Lead] |
| **Data Engineer** | Implements pipelines; enforces governance in code | [Engineering Lead] |

### 2.2 Governance Bodies

| Body | Frequency | Purpose |
|------|-----------|---------|
| Data Governance Board | Monthly | Strategic decisions on data policy, classification changes |
| Data Architecture Review | Bi-weekly | Review proposed data designs and integration patterns |
| IG Steering Group | Monthly | UK GDPR, DSPT, Caldicott compliance |
| Data Quality Working Group | Monthly | Data quality KPIs, remediation prioritisation |

---

## 3. Data Classification Policy

All data assets must be classified using TWO dimensions:

### 3.1 Government Security Classification (GSC)

| Classification | Definition | Example |
|---------------|-----------|---------|
| **OFFICIAL** | Routine public sector data | Aggregated activity stats, non-personal operational data |
| **OFFICIAL-SENSITIVE** | Sensitive but not top-tier; limited distribution | Patient data, staff HR data, commercial contracts |
| **SECRET** | Serious damage to national security if disclosed | Not applicable to most health data |

### 3.2 Personal Data Sensitivity (UK GDPR / Caldicott)

| Sensitivity | Definition | Handling |
|------------|-----------|---------|
| **PERSONAL** | Directly identifies an individual | NHS Number, name, DOB, full postcode — encrypt at rest and in transit |
| **PSEUDONYMISED** | Indirect identification risk with key | Replace NHS Number with token; key held separately |
| **ANONYMISED** | Cannot re-identify with reasonable effort | ICO standard anonymisation test must be applied |
| **NON-PERSONAL** | No individual identifiable | Aggregate counts, coded lookups |

### 3.3 Classification Decision Tree

```
Does the data contain NHS Number, Name, DOB, or Full Postcode?
  YES → PERSONAL → OFFICIAL-SENSITIVE minimum
  NO  → Can a combination of fields re-identify a patient?
          YES → PSEUDONYMISED → OFFICIAL-SENSITIVE minimum
          NO  → ANONYMISED or NON-PERSONAL → OFFICIAL
```

---

## 4. Legal Basis for Processing (UK GDPR)

All processing activities must have a documented legal basis. For health data:

| Processing Activity | Legal Basis | Special Category Basis |
|--------------------|------------|----------------------|
| Direct care of patients | Art. 6(1)(e) — Public Task | Art. 9(2)(h) — Healthcare provision |
| Secondary use — research | Art. 6(1)(e) — Public Task | Art. 9(2)(j) — Research |
| Quality improvement | Art. 6(1)(e) — Public Task | Art. 9(2)(h) — Healthcare provision |
| Statutory reporting (NHSE) | Art. 6(1)(c) — Legal Obligation | Art. 9(2)(h) |
| Staff HR records | Art. 6(1)(b) — Contract | Not applicable (non-clinical) |

> **Note:** Health data is Special Category under Art. 9 UK GDPR. Every processing activity involving patient data requires both an Art. 6 **AND** an Art. 9 basis.

---

## 5. Data Retention Policy

Per **NHS Records Management Code of Practice 2021**:

| Data Type | Minimum Retention | Maximum Retention |
|-----------|-----------------|-----------------|
| Adult patient health records | 8 years after last entry | 8 years after death |
| Children's records | Until age 25 or 8 years after death | Until age 25 |
| Mental health records | 20 years after last entry | 20 years |
| Cancer records | Indefinite (per NCRAS guidance) | — |
| Research data | Per ethics approval | — |
| Financial records | 7 years (HMRC) | 7 years |
| Staff HR records | 6 years after employment ends | 6 years |
| Audit / access logs | 6 years | 10 years |

**AWS Implementation:** Retention enforced via:
- S3 Object Lifecycle Rules → automated deletion after retention period
- RDS automated backups → 35-day rolling backup (configurable)
- AWS Glacier → long-term archive for retention-required data

---

## 6. Data Quality Framework

Six dimensions measured and reported monthly:

| Dimension | Definition | Measurement Method | Minimum Threshold |
|-----------|-----------|-------------------|------------------|
| **Completeness** | Required fields populated | NULL count / total rows | ≥ 95% |
| **Accuracy** | Correct values (validated against reference) | Failed validation rules | ≥ 98% |
| **Consistency** | Consistent across systems | Cross-system reconciliation | ≥ 97% |
| **Timeliness** | Data available when needed | SLA breach rate | ≤ 5% breach |
| **Uniqueness** | No duplicate records | Duplicate key check | 100% unique PKs |
| **Validity** | Conforms to defined format/range | Failed format checks | ≥ 99% |

Quality results are written to `governance.data_quality_log` table in the AWS RDS database.

---

## 7. Access Control

### 7.1 Principles
- **Minimum necessary access** — staff access only the data their role requires
- **Role-based access** — AWS IAM roles aligned to job function, not individual
- **No standing access** to production patient data — request and time-limited via approved process
- **Audit all access** — CloudTrail logs every data access event

### 7.2 AWS IAM Role Definitions

| Role | Access Level | Example Groups |
|------|-------------|---------------|
| `data-platform-admin` | Full platform access | Data Architecture team |
| `data-engineer` | Read/write to bronze + silver | Data Engineering team |
| `data-analyst` | Read-only to gold layer | Analytics team |
| `researcher` | Read-only to anonymised data only | Research team |
| `bi-report-user` | QuickSight/Power BI read only | Business users |
| `audit-read-only` | Governance schema read + CloudTrail | IG team |

### 7.3 Data Access Request Process
1. Staff submits request via [ticketing system]
2. Data Steward approves within 5 working days
3. Data Owner countersigns for OFFICIAL-SENSITIVE+
4. AWS IAM role assigned with expiry (max 90 days for sensitive data)
5. Access logged in access register

---

## 8. Incident Response

| Incident Type | Response Time | Escalation |
|--------------|--------------|-----------|
| Suspected personal data breach | Within 1 hour | SIRO + DPO immediately |
| ICO notification (72-hour rule) | Within 72 hours of becoming aware | DPO leads |
| System unavailability affecting patient care | Within 30 minutes | IT + Clinical Lead |
| Data quality failure affecting reporting | Within 24 hours | Data Steward + Owner |

---

## 9. Compliance Checklist

- [ ] All data assets recorded in Data Asset Register (`governance.data_asset` table)
- [ ] RoPA completed and reviewed by DPO
- [ ] DSPT submission evidence pack updated
- [ ] Data Sharing Agreements in place for all external data sources
- [ ] Privacy Notices updated if new data uses introduced
- [ ] DPIA (Data Protection Impact Assessment) completed for any high-risk processing
- [ ] AWS CloudTrail enabled across all accounts
- [ ] S3 bucket policies reviewed — no public access
- [ ] Encryption at rest: SSE-KMS enabled on all S3 buckets and RDS instances
- [ ] Encryption in transit: TLS 1.2+ enforced on all endpoints

---

*[Organisation Name] | Data Governance Framework | Version 0.1 | [Date] | Author: [Name]*
