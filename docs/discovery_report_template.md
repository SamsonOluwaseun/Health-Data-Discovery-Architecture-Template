# Data Architecture Discovery Report
## [Organisation Name]
### Version 1.0 | [Date] | Prepared by: [Senior Data Architect Name]

---

> **Document Status:** DRAFT / FOR REVIEW / APPROVED
> **Classification:** OFFICIAL-SENSITIVE
> **Distribution:** [Programme Board, SIRO, Caldicott Guardian, IG Lead]

---

## Table of Contents

1. Executive Summary
2. Engagement Overview
3. Current State Assessment
4. Target Architecture
5. Data Governance Framework
6. Data Quality Assessment
7. Migration Strategy Summary
8. Gap Analysis
9. Risks and Issues
10. Alpha Readiness Recommendation
11. Appendices

---

## 1. Executive Summary

### Purpose
This report presents the findings of a [X]-week data architecture discovery engagement for [Organisation Name]. The engagement was commissioned to assess the current state of the organisation's data landscape, define a target architecture for the planned digital health data platform, and develop a roadmap for migration and governance.

### Key Findings

| Finding | Impact | Recommendation |
|---------|--------|---------------|
| [X] source systems identified with no central data catalogue | High | Implement AWS Glue Data Catalog as immediate priority |
| Patient data distributed across [X] separate databases with no MPI | High | Implement Master Patient Index using NHS Number as enterprise key |
| Legacy ETL processes undocumented; [X] direct DB links between systems | Medium | Replace with API-first integration via AWS API Gateway |
| NHS Number completeness at [X]% across PAS | High | Data quality remediation before migration |
| No data governance structure; no Data Owners assigned | High | Establish Data Governance Board within 4 weeks |

### Alpha Readiness Summary
Based on the assessment, [Organisation] is **[Ready / Conditionally Ready / Not Ready]** to proceed to Alpha, subject to resolution of the [X] blockers identified in Section 10.

**Recommended Alpha start date:** [Date]

---

## 2. Engagement Overview

### 2.1 Scope
This discovery engagement covered:
- Current state data landscape assessment across [X] source systems
- Stakeholder interviews with [X] teams over [X] weeks
- Target architecture design on AWS
- Data governance framework definition
- Migration strategy for Bronze → Silver → Gold transition
- Alpha readiness assessment

### 2.2 Out of Scope
- GP / primary care data integration (requires IM1/GP Connect programme)
- PACS / imaging data
- Real-time streaming (Phase 2)

### 2.3 Stakeholders Engaged

| Name | Role | Organisation | Sessions |
|------|------|-------------|---------|
| [Name] | SIRO | [Org] | 1 |
| [Name] | Caldicott Guardian | [Org] | 1 |
| [Name] | IT Director | [Org] | 2 |
| [Name] | Head of Analytics | [Org] | 3 |
| [Name] | PAS System Owner | [Org] | 2 |
| [Name] | IG Lead / DPO | [Org] | 2 |
| [Name] | Clinical Lead | [Org] | 1 |

### 2.4 Methodology
The discovery followed the GDS Discovery phase methodology, with additional data architecture discovery frameworks applied:
- Stakeholder interviews (structured questionnaire)
- System documentation review
- Data profiling and quality assessment
- Architecture workshops
- GDS Service Manual phase gates applied throughout

---

## 3. Current State Assessment

### 3.1 Data Landscape Summary

**[X] source systems identified:**

| System | Type | Data | Volume | Technology | Owner | Risk |
|--------|------|------|--------|-----------|-------|------|
| PAS | Patient Admin | Demographics, admissions | [X]M rows | SQL Server 2016 | [Team] | High — out of support |
| EPR | Clinical | Episodes, diagnoses | [X]M rows | Oracle 11g | [Team] | High — out of support |
| LIMS | Pathology | Specimens, results | [X]M rows | PostgreSQL 12 | [Team] | Medium |
| Finance | Finance | Activity costs | [X]M rows | SQL Server 2019 | [Team] | Low |
| File Shares | Ad-hoc | Reports, extracts | [X] GB | CSV / Excel | Various | High — uncontrolled PII |

### 3.2 Current State Architecture
*[Insert PNG of Draw.io current state diagram here]*
> File: `outputs/current_state_architecture.png`

### 3.3 Critical Issues Identified

#### 3.3.1 No Master Patient Index
There is no enterprise master patient index linking patient records across PAS, EPR, and LIMS. This results in:
- Duplicate patient records across systems
- Inability to produce a complete patient journey view
- Inconsistent NHS Number usage (completeness: [X]%)

**Recommendation:** Implement NHS Number as the enterprise patient key across all systems. NHS Number validation rules must be enforced at every ingestion point.

#### 3.3.2 Uncontrolled PII on Network File Shares
[X] GB of files containing patient-identifiable information reside on shared network drives with no access controls, no audit logging, and no retention enforcement.

**Recommendation:** Immediate IG risk assessment. Migrate controlled data to AWS S3 with Lake Formation access controls. Delete uncontrolled files under IG team direction.

#### 3.3.3 Legacy Integration Debt
[X] direct database links exist between operational systems with no documentation. These create:
- Undocumented data dependencies
- Risk of data corruption if any system is modified
- Inability to move any system independently

**Recommendation:** Document all DB links via data flow workshops. Replace with API-first integrations in target architecture.

---

## 4. Target Architecture

### 4.1 Architecture Principles

1. **Cloud-first:** AWS as the primary data platform (eu-west-2 — London)
2. **API-first integration:** No direct DB links; all integration via documented APIs or DMS
3. **NHS Number as enterprise key:** Verified NHS Number used across all patient data
4. **NHS Data Standards:** FHIR R4, SNOMED CT, ICD-10, OPCS-4, dm+d enforced at ingestion
5. **Governance by design:** No pipeline without a data owner, classification, and retention policy
6. **Encryption everywhere:** SSE-KMS at rest; TLS 1.2+ in transit
7. **Minimum necessary access:** Role-based access; no standing access to patient data

### 4.2 Target Architecture Overview
*[Insert PNG of Draw.io target state diagram here]*
> File: `outputs/target_state_architecture.png`

### 4.3 Medallion Architecture

| Layer | Storage | Purpose | Access |
|-------|---------|---------|--------|
| **Bronze** | S3 — Raw Bucket | Raw ingested data; no transformation | Data Engineers only |
| **Silver** | AWS RDS PostgreSQL | Cleansed, conformed, NHS-standard coded data | Data Engineers + Analysts (read) |
| **Gold** | Amazon Redshift | Analytics-ready aggregated data marts | Analysts + BI tools |

### 4.4 AWS Services Selected

| Service | Purpose |
|---------|---------|
| AWS S3 | Data lake storage — all layers |
| AWS RDS (PostgreSQL) | Silver layer structured storage |
| Amazon Redshift Serverless | Gold layer analytics warehouse |
| AWS Glue | ETL, data catalogue, schema registry |
| AWS DMS | Database migration (on-prem → RDS) |
| AWS API Gateway | FHIR R4 ingest endpoint |
| AWS Lambda | Event-driven validation and processing |
| AWS Step Functions | Pipeline orchestration |
| AWS Lake Formation | Fine-grained data access control |
| Amazon Macie | PII detection on S3 |
| AWS CloudTrail | Audit logging |
| AWS KMS | Encryption key management |
| Amazon GuardDuty | Threat detection |
| Amazon QuickSight | Operational dashboards |

### 4.5 Integration Patterns
*[Insert PNG of integration patterns diagram here]*
> File: `outputs/integration_patterns.png`

---

## 5. Data Governance Framework

See full framework: `governance/data_governance_framework.md`

### 5.1 Summary

- **Data Governance Board** to be established within 4 weeks of Discovery sign-off
- **Data Owners** must be assigned for: Patient, Clinical, Pathology, Finance domains
- **All data assets** to be catalogued in AWS Glue Data Catalog
- **UK GDPR compliance** requires RoPA completion and DPO review before Alpha
- **DSPT** — [X] Mandatory Assertions require data architecture evidence

---

## 6. Data Quality Assessment

### 6.1 Quality Scores by System

| System | Completeness | Accuracy | Consistency | Timeliness | Uniqueness | Validity | Overall |
|--------|------------|---------|------------|-----------|-----------|---------|---------|
| PAS | [X]% | [X]% | [X]% | [X]% | [X]% | [X]% | [RAG] |
| EPR | [X]% | [X]% | [X]% | [X]% | [X]% | [X]% | [RAG] |
| LIMS | [X]% | [X]% | [X]% | [X]% | [X]% | [X]% | [RAG] |

### 6.2 Critical Quality Issues

| Issue | System | Impact | Remediation | Owner | Target Date |
|-------|--------|--------|------------|-------|------------|
| NHS Number null rate [X]% | PAS | High | [Action] | [Name] | [Date] |
| Duplicate patient records ([X] identified) | PAS + EPR | High | [Action] | [Name] | [Date] |
| ICD-10 coding gaps [X]% | EPR | Medium | [Action] | [Name] | [Date] |

---

## 7. Migration Strategy Summary

**Approach:** Phased migration with parallel run
**Duration:** [X] weeks from Discovery sign-off
**Key milestones:**

| Milestone | Target Date |
|-----------|------------|
| AWS infrastructure provisioned | [Date] |
| Historical load — PAS complete | [Date] |
| Historical load — EPR complete | [Date] |
| Parallel run start | [Date] |
| Cutover | [Date] |

See full strategy: `migration/migration_strategy.md`

---

## 8. Gap Analysis

| # | Gap | Current State | Target State | Priority | Owner |
|---|-----|--------------|-------------|---------|-------|
| G1 | No data catalogue | Manual spreadsheet | AWS Glue Catalog | High | Data Architect |
| G2 | No master patient index | 4 separate patient tables | Unified NHS Number key | High | Data Architect |
| G3 | No cloud data platform | On-prem SQL Server / Oracle | AWS Medallion Architecture | High | Cloud Engineer |
| G4 | No data governance | Ad-hoc data ownership | Formal governance board + owners | High | Programme Manager |
| G5 | No data quality monitoring | Manual spot checks | Automated DQ checks + CloudWatch | Medium | Data Engineer |
| G6 | Uncontrolled PII on file shares | Shared drives | S3 with Lake Formation controls | High | IG + Data Engineer |
| G7 | Legacy ETL undocumented | [X] undocumented processes | Documented, version-controlled Glue jobs | Medium | Data Engineer |

---

## 9. Risks and Issues

| # | Risk | Likelihood | Impact | Mitigation | Owner |
|---|------|-----------|--------|-----------|-------|
| R1 | NHS Number completeness below 98% blocks migration | Medium | High | Data quality sprint before migration | Data Steward |
| R2 | PAS system unavailability during DMS migration window | Low | High | Direct Connect + DMS parallel run | IT Lead |
| R3 | IG approval delays for patient data migration | Medium | High | Engage DPO and Caldicott Guardian immediately | Programme Manager |
| R4 | Legacy Oracle DB schema not supported by AWS SCT | Medium | Medium | Manual schema conversion for complex objects | Data Architect |
| R5 | Resistance from system owners to share data flows | Low | Medium | Executive sponsor engagement | SIRO |

---

## 10. Alpha Readiness Recommendation

**Overall Assessment:** [Conditionally Ready to Proceed to Alpha]

**Conditions to be met before Alpha start:**

| # | Condition | Owner | Resolution Date |
|---|-----------|-------|----------------|
| C1 | Data Governance Board established with Data Owners assigned | Programme Manager | [Date] |
| C2 | NHS Number completeness raised to ≥ 98% on PAS | PAS System Owner | [Date] |
| C3 | RoPA completed and reviewed by DPO | IG Lead | [Date] |
| C4 | AWS infrastructure provisioned and security baseline verified | Cloud Engineer | [Date] |
| C5 | Caldicott Guardian sign-off for patient data migration | Caldicott Guardian | [Date] |

**Recommended Alpha Start Date:** [Date]

---

## 11. Appendices

- **Appendix A:** Stakeholder Register — `outputs/stakeholder_register.md`
- **Appendix B:** Data Inventory — `outputs/data_inventory.md`
- **Appendix C:** Current State Architecture — `outputs/current_state_architecture.png`
- **Appendix D:** Target Architecture — `outputs/target_state_architecture.png`
- **Appendix E:** Integration Patterns — `outputs/integration_patterns.png`
- **Appendix F:** Conceptual Data Model — `outputs/cdm_diagram.png`
- **Appendix G:** Physical Data Model (DDL) — `data-modelling/ddl/03_physical_data_model.sql`
- **Appendix H:** Data Governance Framework — `governance/data_governance_framework.md`
- **Appendix I:** Migration Risk Register — `migration/migration_risk_register.md`
- **Appendix J:** Alpha Readiness Checklist — `templates/05_alpha_readiness_checklist.md`

---

*[Organisation] | Data Architecture Discovery Report | Version 1.0 | [Date]*
*Prepared by: [Senior Data Architect] | Reviewed by: [Technical Architect] | Approved by: [Programme Manager]*
