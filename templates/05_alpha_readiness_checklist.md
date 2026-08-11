# Alpha Readiness Checklist
## Gov Health Data Platform
### [Organisation Name] | Assessment Date: [Date] | Assessed by: [Name]

> **Rating key:**
> ✅ **Ready** — complete and verified
> ⚠️ **In Progress** — partially complete; on track
> ❌ **Blocker** — not started or blocked; must resolve before Alpha

---

## 1. Data Architecture & Design

| # | Criterion | Status | Owner | Notes |
|---|-----------|--------|-------|-------|
| 1.1 | Conceptual data model documented and signed off | ⬜ | | |
| 1.2 | Logical data model complete in Erwin | ⬜ | | |
| 1.3 | Physical DDL deployed to AWS RDS staging environment | ⬜ | | |
| 1.4 | Target architecture diagram approved by Technical Architect | ⬜ | | |
| 1.5 | All 4 integration patterns documented and agreed | ⬜ | | |
| 1.6 | AWS landing zone provisioned (S3 buckets, VPC, IAM roles) | ⬜ | | |
| 1.7 | Medallion architecture (Bronze/Silver/Gold) implemented in staging | ⬜ | | |
| 1.8 | dbt or Glue transformation jobs deployed and tested | ⬜ | | |
| 1.9 | Network connectivity to source systems established and tested | ⬜ | | |
| 1.10 | Architecture design reviewed and approved by Architecture Board | ⬜ | | |

**Section score:** __ / 10 complete

---

## 2. Data Inventory & Landscape

| # | Criterion | Status | Owner | Notes |
|---|-----------|--------|-------|-------|
| 2.1 | All source systems identified and documented | ⬜ | | |
| 2.2 | Data inventory register complete (all data assets catalogued) | ⬜ | | |
| 2.3 | Data owners assigned for every data domain | ⬜ | | |
| 2.4 | Current state architecture diagram complete and accurate | ⬜ | | |
| 2.5 | Data flow diagrams complete for all critical pathways | ⬜ | | |
| 2.6 | Gap analysis between current and target state documented | ⬜ | | |
| 2.7 | Technical debt register created with prioritised items | ⬜ | | |

**Section score:** __ / 7 complete

---

## 3. Data Governance & Compliance

| # | Criterion | Status | Owner | Notes |
|---|-----------|--------|-------|-------|
| 3.1 | All data assets classified (OFFICIAL / OFFICIAL-SENSITIVE) | ⬜ | | |
| 3.2 | Personal data sensitivity labelled (PERSONAL / PSEUDONYMISED / ANONYMISED) | ⬜ | | |
| 3.3 | Record of Processing Activities (RoPA) drafted and reviewed by DPO | ⬜ | | |
| 3.4 | Legal basis for processing documented for every data use | ⬜ | | |
| 3.5 | DPIA completed for high-risk processing activities | ⬜ | | |
| 3.6 | Data Sharing Agreements in place for all external data sources | ⬜ | | |
| 3.7 | Caldicott Guardian sign-off for patient data uses | ⬜ | | |
| 3.8 | NHS DSPT (Data Security and Protection Toolkit) requirements mapped | ⬜ | | |
| 3.9 | Retention periods defined and AWS lifecycle rules configured | ⬜ | | |
| 3.10 | Data access roles defined and IAM policies implemented | ⬜ | | |
| 3.11 | Privacy notices reviewed / updated | ⬜ | | |

**Section score:** __ / 11 complete

---

## 4. Data Quality

| # | Criterion | Status | Owner | Notes |
|---|-----------|--------|-------|-------|
| 4.1 | Data quality assessment completed for all source systems | ⬜ | | |
| 4.2 | Critical data quality issues documented with remediation plan | ⬜ | | |
| 4.3 | NHS Number completeness ≥ 98% on patient records | ⬜ | | |
| 4.4 | ICD-10 coding completeness ≥ 95% on clinical events | ⬜ | | |
| 4.5 | Data quality monitoring implemented (DQ log table, CloudWatch) | ⬜ | | |
| 4.6 | Data quality thresholds agreed with Data Owner | ⬜ | | |

**Section score:** __ / 6 complete

---

## 5. Migration Readiness

| # | Criterion | Status | Owner | Notes |
|---|-----------|--------|-------|-------|
| 5.1 | Migration strategy document signed off by Data Owner | ⬜ | | |
| 5.2 | Data mapping complete for all source → target fields | ⬜ | | |
| 5.3 | Migration risk register reviewed and risks accepted | ⬜ | | |
| 5.4 | AWS DMS tasks configured and tested in staging | ⬜ | | |
| 5.5 | Full-load validation successful (row counts match within 0.01%) | ⬜ | | |
| 5.6 | Business metric reconciliation passed | ⬜ | | |
| 5.7 | Rollback plan documented and rehearsed | ⬜ | | |
| 5.8 | Cutover window agreed with operations | ⬜ | | |

**Section score:** __ / 8 complete

---

## 6. Security & Infrastructure

| # | Criterion | Status | Owner | Notes |
|---|-----------|--------|-------|-------|
| 6.1 | All S3 buckets: public access blocked | ⬜ | | |
| 6.2 | All S3 buckets: SSE-KMS encryption enabled | ⬜ | | |
| 6.3 | RDS instances: encryption at rest enabled | ⬜ | | |
| 6.4 | All endpoints: TLS 1.2+ enforced | ⬜ | | |
| 6.5 | AWS CloudTrail enabled across all accounts and regions | ⬜ | | |
| 6.6 | AWS GuardDuty enabled | ⬜ | | |
| 6.7 | Amazon Macie configured on raw S3 bucket | ⬜ | | |
| 6.8 | VPC flow logs enabled | ⬜ | | |
| 6.9 | No hardcoded credentials — all via AWS Secrets Manager | ⬜ | | |
| 6.10 | Penetration test / security review scheduled for Alpha | ⬜ | | |
| 6.11 | Multi-AZ configured for RDS production | ⬜ | | |
| 6.12 | RDS automated backups configured (≥ 7 days) | ⬜ | | |

**Section score:** __ / 12 complete

---

## 7. Team & Stakeholder Readiness

| # | Criterion | Status | Owner | Notes |
|---|-----------|--------|-------|-------|
| 7.1 | Data Owner and Stewards identified for all domains | ⬜ | | |
| 7.2 | Data Governance Board established with agreed ToR | ⬜ | | |
| 7.3 | Programme team briefed on Alpha scope and timeline | ⬜ | | |
| 7.4 | Clinical stakeholders engaged and supportive | ⬜ | | |
| 7.5 | IG / DPO formally engaged and supportive | ⬜ | | |
| 7.6 | Alpha user stories defined and prioritised | ⬜ | | |

**Section score:** __ / 6 complete

---

## 8. Documentation

| # | Criterion | Status | Owner | Notes |
|---|-----------|--------|-------|-------|
| 8.1 | Discovery report complete and signed off | ⬜ | | |
| 8.2 | Data dictionary complete and published | ⬜ | | |
| 8.3 | Architecture diagrams in Draw.io, PNG exported | ⬜ | | |
| 8.4 | All Erwin models saved and DDL exported | ⬜ | | |
| 8.5 | All code (SQL, Python, Glue) committed to GitHub | ⬜ | | |
| 8.6 | README and repo structure clear and navigable | ⬜ | | |

**Section score:** __ / 6 complete

---

## Overall Alpha Readiness Summary

| Section | Max Score | Your Score | % |
|---------|-----------|------------|---|
| 1. Architecture & Design | 10 | | |
| 2. Data Inventory | 7 | | |
| 3. Governance & Compliance | 11 | | |
| 4. Data Quality | 6 | | |
| 5. Migration Readiness | 8 | | |
| 6. Security & Infrastructure | 12 | | |
| 7. Team & Stakeholder | 6 | | |
| 8. Documentation | 6 | | |
| **TOTAL** | **66** | | |

### Alpha Readiness Decision

| Score | Decision |
|-------|---------|
| 60-66 (90%+) | ✅ **Proceed to Alpha** |
| 50-59 (75-89%) | ⚠️ **Conditional — resolve blockers first** |
| Below 50 | ❌ **Not ready — extend Discovery** |

**Blockers preventing Alpha start:**
1. [List any ❌ items that are critical path]
2.
3.

**Recommended Alpha start date:** [Date]

**Sign-off:**

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Data Architect | | | |
| Programme Manager | | | |
| Senior Information Risk Owner | | | |
| Caldicott Guardian | | | |

---

*[Organisation] | Alpha Readiness Checklist | [Date]*
