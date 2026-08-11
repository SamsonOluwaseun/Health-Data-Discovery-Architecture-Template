# Migration Risk Register
## [Organisation Name] | Data Platform Migration
### Version 0.1 | [Date] | Owner: [Data Architect Name]

> **Rating:** Likelihood 1-5 (1=Rare, 5=Almost Certain) × Impact 1-5 (1=Negligible, 5=Critical)
> **Score:** L × I | **RAG:** 🔴 15-25 | 🟡 8-14 | 🟢 1-7

---

| Ref | Risk Description | Category | Likelihood (1-5) | Impact (1-5) | Score | RAG | Mitigation | Contingency | Owner | Status |
|-----|----------------|---------|-----------------|-------------|-------|-----|-----------|------------|-------|-------|
| MR-01 | NHS Number completeness below 98% threshold prevents safe patient linkage across systems | Data Quality | 4 | 5 | 20 | 🔴 | Data quality sprint before migration; NHS Number validation at source | Delay migration for that entity until remediated | PAS System Owner | Open |
| MR-02 | AWS DMS fails to handle Oracle-specific data types (CLOB, XMLTYPE) during full load | Technical | 3 | 4 | 12 | 🟡 | AWS Schema Conversion Tool assessment; manual conversion for complex types | Custom AWS Glue job for affected tables | Data Engineer | Open |
| MR-03 | Direct Connect / VPN throughput insufficient for full historical load within agreed window | Infrastructure | 2 | 4 | 8 | 🟡 | Throughput testing before migration; schedule off-peak transfer | AWS DataSync with bandwidth throttling | IT Lead | Open |
| MR-04 | Caldicott Guardian / DPO approval for patient data migration delayed beyond programme timeline | Governance | 3 | 5 | 15 | 🔴 | Engage DPO and Caldicott Guardian immediately; provide DPIA documentation | Migrate non-patient data first; defer patient data until IG approved | Programme Manager | Open |
| MR-05 | Source system owners refuse access for DMS read-only user creation | People | 2 | 4 | 8 | 🟡 | Senior sponsor engagement; read-only DMS user requires minimal permissions | Manual extract-and-load as fallback | SIRO | Open |
| MR-06 | Undocumented DB links cause cascading failures when source system is modified during parallel run | Technical | 3 | 4 | 12 | 🟡 | Document all DB links before migration starts; change freeze on source systems during cutover | Rollback procedure: revert reporting to source immediately | Data Architect | Open |
| MR-07 | PII data exposed in DMS replication logs or Glue job logs | Security / IG | 2 | 5 | 10 | 🟡 | Enable DMS log masking; review Glue job logging settings; CloudTrail audit | Immediate incident report; suspend migration; IG investigation | IG Lead | Open |
| MR-08 | Row count discrepancy > 0.01% after full load fails validation | Data Quality | 3 | 4 | 12 | 🟡 | Pre-migration row count baseline; automated reconciliation after each table load | Do not proceed to Silver transformation until Bronze count validated | Data Engineer | Open |
| MR-09 | Staff capacity to support migration alongside BAU operations insufficient | People | 3 | 3 | 9 | 🟡 | Agree dedicated migration sprint capacity; backfill BAU where possible | Extend migration timeline; phase in smaller batches | Programme Manager | Open |
| MR-10 | Referential integrity violations in source data (orphan records) cause Silver load failures | Data Quality | 4 | 3 | 12 | 🟡 | Source data profiling to identify orphans; create exception table in Bronze for review | Load parent before child entities; log exceptions rather than fail | Data Engineer | Open |
| MR-11 | ICD-10 / OPCS-4 codes not validated at source; dirty codes fail FHIR mapping | Data Quality | 3 | 3 | 9 | 🟡 | Coding completeness report before migration; reject invalid codes to DQ log | Load with NULL coding and flag for clinical coding team remediation | Data Steward | Open |
| MR-12 | KMS key misconfiguration causes S3 encryption failure; data lands unencrypted | Security | 1 | 5 | 5 | 🟢 | KMS key policy reviewed by Cloud Security; default encryption set at bucket level | Auto-detect unencrypted objects via Macie; encrypt in place | Cloud Engineer | Open |
| MR-13 | Migration runs over-schedule; source system freeze extended beyond agreed window, impacting operations | Programme | 2 | 4 | 8 | 🟡 | Detailed cutover run-book with time buffers; dry-run cutover 1 week before | Immediate rollback; source systems remain primary; reschedule | Programme Manager | Open |
| MR-14 | Data mapping document incomplete or incorrect for a critical entity; incorrect data loaded to Silver | Data Quality | 2 | 4 | 8 | 🟡 | Data mapping peer-reviewed by a second architect; Data Owner sign-off before migration | Purge and reload affected entity from Bronze | Data Architect | Open |
| MR-15 | Add new risks as discovered | | | | | | | | | |

---

## Risk Summary

| RAG | Count |
|-----|-------|
| 🔴 Critical (15+) | 2 |
| 🟡 High (8-14) | 10 |
| 🟢 Low (1-7) | 1 |
| **Total** | **13** |

---

## Top 3 Risks Requiring Immediate Action

1. **MR-01 — NHS Number completeness** — data quality sprint must start immediately
2. **MR-04 — IG approval delay** — Caldicott Guardian + DPO engagement this week
3. **MR-07 — PII in DMS logs** — security configuration review before any patient data is migrated

---

*[Organisation] | Migration Risk Register | Version 0.1 | [Date]*
