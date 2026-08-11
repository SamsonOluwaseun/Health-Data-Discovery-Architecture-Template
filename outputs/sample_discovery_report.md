# Data Architecture Discovery Report
## Midshire Community Health Trust (MCHT)
### Version 1.0 | 15 August 2024 | Prepared by: O. Odeyemi, Senior Data Architect

> **Document Status:** APPROVED
> **Classification:** OFFICIAL-SENSITIVE
> **Distribution:** Programme Board, SIRO, Caldicott Guardian, IG Lead

---

> ⚠️ **SAMPLE OUTPUT — For Portfolio / Template Demonstration Only**
> All organisation names, figures, and individuals are fictional. Created to demonstrate what a completed Discovery Report looks like using this template.

---

## 1. Executive Summary

### Purpose
This report presents the findings of a 7-week data architecture discovery engagement for **Midshire Community Health Trust (MCHT)**. The engagement was commissioned to assess the current state of the Trust's data landscape, define a target architecture for the planned Digital Health Data Platform, and develop a roadmap for migration and governance.

### Strategic Context
MCHT is a mid-sized NHS community trust serving approximately 280,000 patients across three locality hubs. The Trust's existing data infrastructure is predominantly on-premises, legacy, and fragmented — limiting its ability to meet NHS England performance reporting requirements, support clinical governance, or enable population health analytics.

The organisation has committed to an AWS-first cloud strategy and is seeking to establish a unified data platform that will serve as the foundation for all analytical, reporting, and research activities.

### Key Findings

| Finding | Impact | Recommendation |
|---------|--------|---------------|
| 6 source systems identified; no central data catalogue | High | Implement AWS Glue Data Catalog immediately |
| NHS Number completeness: 93.4% on PAS | High | Data quality sprint before migration |
| Patient records fragmented across PAS, EPR, and LIMS with no MPI | High | NHS Number as enterprise key; cross-system deduplication |
| SFTP file transfers unencrypted between PAS and finance | High | Replace with AWS Transfer Family (encrypted SFTP) |
| No formal data governance structure; no data owners assigned | High | Establish Data Governance Board within 4 weeks |
| ICD-10 coding completeness: 87% in community nursing specialty | Medium | Clinical coding capacity review |

### Alpha Readiness Summary
Based on this assessment, MCHT is **conditionally ready** to proceed to Alpha, subject to resolution of 3 pre-migration blockers identified in Section 10.

**Recommended Alpha start date:** 30 September 2024

---

## 2. Engagement Overview

### Scope
This discovery covered:
- Current state assessment of 6 source systems
- Stakeholder interviews with 11 teams over 7 weeks
- Target architecture design on AWS (eu-west-2)
- Data governance framework
- Migration strategy for Bronze → Silver → Gold transition
- Alpha readiness assessment

### Stakeholders Engaged

| Name | Role | Sessions |
|------|------|---------|
| Sarah Chen | IT Director | 2 |
| Dr. James Okafor | Caldicott Guardian | 1 |
| Priya Sharma | DPO / IG Lead | 3 |
| Marcus Webb | Head of Analytics | 4 |
| Angela Torres | PAS System Owner | 2 |
| David Liu | EPR System Owner | 2 |
| Fatima Al-Hassan | LIMS Manager | 2 |
| Dr. Rachel Nwosu | Community Nursing Lead | 1 |
| Ben Kowalski | Cloud / Network Engineer | 3 |
| Yemi Adeyemi | Finance Manager | 1 |
| Sandra McBride | Programme Manager | Weekly stand-up |

---

## 3. Current State Assessment

### 3.1 Data Landscape — 6 Source Systems

| System | Type | Technology | Data | Volume | Owner | Risk |
|--------|------|-----------|------|--------|-------|------|
| PAS (Systema) | Patient Admin | SQL Server 2014 ⚠️ | Demographics, episodes | 480K patients, 1.2M episodes | Angela Torres | HIGH — out of support |
| EPR (CareView) | Clinical | Oracle 11g ⚠️ | Diagnoses, care plans, medications | 2.8M records | David Liu | HIGH — out of support |
| LIMS (PathMaster) | Pathology | PostgreSQL 12 | Specimens, results | 9.4M results | Fatima Al-Hassan | MEDIUM |
| RiO (Community) | Community care | Cloud SaaS | Community nursing | 340K contacts | Angela Torres | LOW |
| Finance (Agresso) | Finance | SQL Server 2019 | Activity costs, contracts | 200K rows/yr | Yemi Adeyemi | LOW |
| Network Shares | Ad-hoc | CSV / Excel | Reports, extracts | ~45 GB | Various | HIGH — uncontrolled PII |

### 3.2 Critical Issues Found

**Issue 1 — NHS Number Completeness: 93.4%**
PAS holds 480,000 patient records. 31,680 records have missing or invalid NHS Numbers. Without a valid NHS Number, patient records cannot be safely linked across PAS, EPR, LIMS, and RiO — creating a fragmented view of the patient journey.

**Remediation:** NHS Number tracing via NHS Spine SMSP service. Marcus Webb confirmed his team has tracing access but has not run it in 2 years.

**Issue 2 — SQL Server 2014 and Oracle 11g: End of Support**
Both PAS and EPR run on database engines that are no longer receiving security patches from their vendors. This represents a security and IG risk that the migration will resolve.

**Issue 3 — 45GB of Patient Data on Uncontrolled Network Shares**
Discovery interviews revealed 45GB of CSV and Excel files on shared network drives containing patient-identifiable data (NHS Number, name, DOB). These files have no access audit trail, no retention enforcement, and are accessible to all clinical staff on the network.

Priya Sharma (DPO) confirmed this is a known IG risk but has not been formally risk-assessed. **Immediate action required before migration proceeds.**

**Issue 4 — 7 Undocumented Direct DB Links**
Database interview with Angela Torres revealed 7 SQL Server linked server connections between PAS and other systems (EPR, Finance). These are undocumented, blocking independent migration of any single system.

---

## 4. Target Architecture

### 4.1 Architecture Principles Agreed

1. AWS eu-west-2 (London) — UK data residency; NHS DSPT compliance
2. NHS Number as the enterprise patient identifier across all systems
3. FHIR R4 as the target integration standard for all new connections
4. Medallion Architecture (Bronze → Silver → Gold) for all data flows
5. Governance by design — no pipeline without data owner, classification, and retention
6. No direct DB links — all integration via documented APIs or DMS

### 4.2 Medallion Architecture Design

| Layer | AWS Service | Content | Access |
|-------|------------|---------|--------|
| **Bronze** | S3 (govhealth-raw) | Raw ingested data; immutable; partitioned by source/date | Data Engineers only |
| **Silver** | RDS PostgreSQL 15 | Conformed, NHS-coded, standardised data (silver schema) | Data Engineers + read-only Analysts |
| **Gold** | Redshift Serverless | Analytics-ready data marts; aggregated KPIs | Analysts, Power BI, QuickSight |

*[See: `outputs/target_state_architecture.png`]*

### 4.3 Integration Patterns Agreed

| Source System | Pattern | AWS Services | Frequency |
|-------------|---------|------------|---------|
| PAS (SQL Server) | Database replication | AWS DMS (CDC) | Real-time CDC |
| EPR (Oracle) | Database replication | AWS DMS + SCT | Daily batch |
| LIMS (PostgreSQL) | JDBC incremental | AWS Glue | 4-hourly |
| RiO (SaaS) | REST API | API Gateway + Lambda | Event-driven |
| Finance (SQL Server) | Database replication | AWS DMS | Daily |
| SFTP files | Encrypted batch | AWS Transfer Family | Daily |

*[See: `outputs/integration_patterns.png`]*

---

## 5. Data Governance Framework

### 5.1 Governance Structure — To Be Established

| Role | Assigned To | Status |
|------|------------|-------|
| SIRO | Sarah Chen (IT Director) | ✅ Confirmed |
| Caldicott Guardian | Dr. James Okafor | ✅ Confirmed |
| DPO | Priya Sharma | ✅ Confirmed |
| Data Governance Board | Chaired by Sarah Chen | ⚠️ To be set up within 4 weeks |
| Data Owner — Patient Domain | Dr. James Okafor | ⚠️ To be confirmed |
| Data Owner — Clinical Domain | Dr. Rachel Nwosu | ⚠️ To be confirmed |
| Data Owner — Finance Domain | Yemi Adeyemi | ✅ Agreed |

### 5.2 Classification Summary

All 6 source systems classified during discovery:

| System | GSC | Sensitivity |
|--------|-----|------------|
| PAS | OFFICIAL-SENSITIVE | PERSONAL |
| EPR | OFFICIAL-SENSITIVE | PERSONAL |
| LIMS | OFFICIAL-SENSITIVE | PERSONAL |
| RiO | OFFICIAL-SENSITIVE | PERSONAL |
| Finance | OFFICIAL | NON-PERSONAL |
| Network Shares | OFFICIAL-SENSITIVE | PERSONAL ⚠️ Uncontrolled |

---

## 6. Data Quality Assessment

| System | NHS No. Completeness | ICD-10 Completeness | Uniqueness | Overall |
|--------|---------------------|-------------------|-----------|---------|
| PAS | 93.4% 🔴 | N/A | 99.1% 🟢 | 🟡 |
| EPR | 97.2% 🟡 | 87.0% 🔴 | 99.8% 🟢 | 🟡 |
| LIMS | 98.6% 🟢 | N/A | 100% 🟢 | 🟢 |
| RiO | 95.1% 🟡 | 78.2% 🔴 | 98.9% 🟢 | 🔴 |

**Blockers:**
- PAS NHS Number completeness 93.4% — must reach 98% before migration
- RiO ICD-10 completeness 78.2% — community nursing coding backlog

---

## 7. Migration Strategy Summary

**Approach:** Phased migration with 4-week parallel run

| Phase | Weeks | Activity |
|-------|-------|---------|
| Phase 0 | 1-2 | AWS infrastructure provisioning |
| Phase 1 | 3-5 | PAS historical load; NHS Number remediation |
| Phase 2 | 5-6 | EPR, LIMS historical loads |
| Phase 3 | 6-7 | Parallel run; reconciliation |
| Phase 4 | 7 | Cutover; source systems read-only |

**Key AWS DMS detail:**
- PAS → RDS Silver: DMS r5.xlarge, Multi-AZ, CDC enabled
- EPR (Oracle 11g): AWS SCT used — 23 objects require manual conversion
- Cutover window: agreed Sunday 02:00–06:00 UTC

---

## 8. Gap Analysis

| # | Gap | Current | Target | Priority |
|---|-----|---------|--------|---------|
| G1 | No data catalogue | Manual spreadsheet | AWS Glue Catalog | HIGH |
| G2 | No master patient index | 4 separate patient tables | NHS Number-unified patient record | HIGH |
| G3 | No cloud platform | On-prem SQL Server 2014 / Oracle 11g | AWS Medallion Architecture | HIGH |
| G4 | No data governance structure | Ad-hoc | Governance Board + data owners | HIGH |
| G5 | Uncontrolled PII on shares | 45GB uncontrolled | S3 + Lake Formation controlled access | HIGH |
| G6 | Undocumented DB links | 7 cross-system SQL links | Documented API integrations | MEDIUM |
| G7 | No automated DQ monitoring | Manual spot checks | Glue DQ + CloudWatch alarms | MEDIUM |
| G8 | Legacy SFTP unencrypted | Plain SFTP | AWS Transfer Family (SFTP over TLS) | HIGH |

---

## 9. Risks and Issues

| Ref | Risk | RAG | Mitigation |
|-----|------|-----|-----------|
| MR-01 | NHS Number completeness below 98% | 🔴 | Spine tracing sprint — 3 weeks |
| MR-04 | IG approval delay | 🟡 | DPO and Caldicott engaged; DPIA in draft |
| MR-02 | Oracle 11g → PostgreSQL: 23 manual conversions | 🟡 | SCT review; 2 Data Engineers allocated |
| MR-08 | Row count reconciliation failure after full load | 🟡 | Automated reconciliation scripts; stop/fix before Silver |
| MR-07 | PII in DMS replication logs | 🟡 | Log masking enabled; Macie configured |

---

## 10. Alpha Readiness Recommendation

**Overall Score:** 51 / 66 (77%) — **Conditionally Ready**

**3 Blockers to resolve before Alpha:**

| # | Blocker | Owner | Resolution Date |
|---|---------|-------|----------------|
| C1 | PAS NHS Number completeness must reach ≥ 98% | Angela Torres / Data Steward | 15 Sept 2024 |
| C2 | Network share PII — IG risk assessment and secure migration | Priya Sharma | 22 Sept 2024 |
| C3 | Data Governance Board established with Data Owners assigned | Sarah Chen | 1 Sept 2024 |

**Recommended Alpha Start Date: 30 September 2024**

### Sign-Off

| Role | Name | Date |
|------|------|------|
| Data Architect | O. Odeyemi | 15 Aug 2024 |
| Programme Manager | Sandra McBride | 15 Aug 2024 |
| SIRO | Sarah Chen | Pending |
| Caldicott Guardian | Dr. J. Okafor | Pending |

---

*SAMPLE OUTPUT — Midshire Community Health Trust | Discovery Report v1.0 | 15 Aug 2024*
*Template: gov-health-discovery-architecture-template | github.com/yourusername/govhealth-discovery-template*
