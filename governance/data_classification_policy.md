# Data Classification Policy
## [Organisation Name]
### Version 0.1 | [Date] | Owner: Data Protection Officer

---

## 1. Purpose

This policy defines how data assets at [Organisation] are classified for security, sensitivity, and handling. All data assets identified during the Discovery phase must be classified before migration to the AWS data platform.

Classification determines: storage controls, access permissions, encryption requirements, retention periods, and sharing restrictions.

---

## 2. Classification Framework

Two dimensions apply to every data asset:

### Dimension 1 — Government Security Classification (GSC)
*(UK Government framework — applies to all public sector data)*

| Classification | Description | Example |
|---------------|------------|---------|
| **OFFICIAL** | Routine public sector business. Most health data falls here. | Aggregate activity statistics, non-personal operational data, anonymised datasets |
| **OFFICIAL-SENSITIVE** | Sensitive data where disclosure could cause harm. Requires additional handling controls. | Patient-identifiable records, staff HR data, commercial contracts, financial details |
| **SECRET** | Very sensitive information — serious damage if disclosed. | Not typically applicable to health analytics environments |

### Dimension 2 — Personal Data Sensitivity
*(UK GDPR / Data Protection Act 2018 / Caldicott Principles)*

| Sensitivity | Description | UK GDPR Status | Handling |
|------------|------------|---------------|---------|
| **PERSONAL** | Directly identifies a living individual | Personal data — full UK GDPR obligations | Encrypt at rest and in transit; minimum necessary access; audit all access |
| **PSEUDONYMISED** | Cannot identify without a separate key (key held securely) | Still personal data — reduced risk | Encrypt; key held separately; restricted access |
| **ANONYMISED** | Cannot re-identify with reasonable effort (ICO standard test passed) | Not personal data — UK GDPR does not apply | Standard controls; document anonymisation method |
| **NON-PERSONAL** | Never related to an individual | Not personal data | Standard controls |

---

## 3. Classification Matrix — Combined

| GSC \ Sensitivity | PERSONAL | PSEUDONYMISED | ANONYMISED | NON-PERSONAL |
|-------------------|---------|--------------|-----------|-------------|
| **OFFICIAL-SENSITIVE** | Patient records, staff records | Pseudonymised research data | — | — |
| **OFFICIAL** | — | — | Published aggregate stats | Operational data, lookup tables |

> Patient health data is **always minimum OFFICIAL-SENSITIVE + PERSONAL** until anonymisation is proven to ICO standard.

---

## 4. Classification Requirements by Asset Type

| Data Type | GSC | Sensitivity | Encryption | Access | Retention |
|-----------|-----|------------|-----------|--------|---------|
| Patient identifiable records (name, DOB, NHS Number) | OFFICIAL-SENSITIVE | PERSONAL | SSE-KMS + TLS | Role-based; no standing access | 8 years |
| Pseudonymised patient data (token instead of NHS Number) | OFFICIAL-SENSITIVE | PSEUDONYMISED | SSE-KMS + TLS | Analysts (read-only); key holder separate | 8 years |
| Anonymised aggregate stats (counts, rates) | OFFICIAL | ANONYMISED | SSE-S3 | Wider access permitted | 5 years |
| Staff HR records | OFFICIAL-SENSITIVE | PERSONAL | SSE-KMS + TLS | HR team only | 6 years post-employment |
| Clinical coding reference data (ICD-10, SNOMED) | OFFICIAL | NON-PERSONAL | SSE-S3 | Read for all | Indefinite (updated annually) |
| Financial / activity data (no patient link) | OFFICIAL | NON-PERSONAL | SSE-S3 | Finance team + analysts | 7 years |
| Audit logs | OFFICIAL-SENSITIVE | PERSONAL (access records) | SSE-KMS | IG team + SIRO | 6 years |

---

## 5. Classification Decision Flowchart

```
STEP 1: Does the data relate to a living individual who can be identified?
  ├── YES → Is the identifier direct (NHS Number, name, full DOB)?
  │           ├── YES → PERSONAL + OFFICIAL-SENSITIVE
  │           └── NO  → Could they be re-identified with other available data?
  │                        ├── YES → PSEUDONYMISED + OFFICIAL-SENSITIVE
  │                        └── NO  → Apply ICO anonymisation test →
  │                                    PASS → ANONYMISED + OFFICIAL
  │                                    FAIL → PSEUDONYMISED + OFFICIAL-SENSITIVE
  └── NO  → Is this commercially sensitive / contractual?
               ├── YES → OFFICIAL-SENSITIVE + NON-PERSONAL
               └── NO  → OFFICIAL + NON-PERSONAL
```

---

## 6. AWS Implementation of Classification

### Storage Controls by Classification

| Classification | S3 Config | RDS Config | Access |
|---------------|----------|-----------|--------|
| OFFICIAL-SENSITIVE + PERSONAL | SSE-KMS CMK, versioning, Object Lock | Encrypted, Multi-AZ, Private subnet | Lake Formation column-level; restricted roles |
| OFFICIAL-SENSITIVE + PSEUDONYMISED | SSE-KMS CMK | Encrypted | Restricted roles; token key held separately |
| OFFICIAL + ANONYMISED | SSE-KMS or SSE-S3 | Encrypted | Analyst roles; broader access |
| OFFICIAL + NON-PERSONAL | SSE-S3 | Standard | Wider read access |

### AWS Lake Formation — Column-Level Security

Apply column-level security for sensitive fields in Silver layer:

```sql
-- Example: Analysts can read all columns EXCEPT direct identifiers
-- Configure in AWS Lake Formation → Data Filters → Column Exclusion

-- Sensitive columns to restrict for analyst role:
-- silver.patient: nhs_number, date_of_birth (restrict to data engineer role)
-- silver.patient: age_band, postcode_sector (allow for analyst role)
```

### Amazon Macie — Automated PII Detection

Configure Macie to scan S3 raw bucket daily:
- Alert if files contain NHS Numbers outside the `/patient/` prefix
- Alert if name patterns detected in non-patient data paths
- Alert if unexpected PII sensitivity spike on any bucket

---

## 7. Classification Labelling in AWS

Apply classification as S3 object tags and RDS table comments:

**S3 Object Tags:**
```json
{
  "classification": "OFFICIAL-SENSITIVE",
  "sensitivity": "PERSONAL",
  "data-domain": "patient",
  "retention-years": "8",
  "data-owner": "clinical-governance-team"
}
```

**RDS Table Comment** (set during DDL deployment):
```sql
COMMENT ON TABLE silver.patient IS
  'Classification: OFFICIAL-SENSITIVE | Sensitivity: PERSONAL | Retention: 8 years | Owner: Clinical Governance';
```

---

## 8. Data Asset Classification Register

Complete one row per data asset during Discovery:

| Asset ID | Asset Name | Source System | GSC | Sensitivity | Contains PII | PII Field List | Retention (Yrs) | Classified By | Review Date |
|---------|-----------|--------------|-----|------------|-------------|--------------|----------------|--------------|------------|
| DA-001 | Patient Demographics | PAS | OFFICIAL-SENSITIVE | PERSONAL | Yes | NHS Number, DOB, Postcode | 8 | [Name] | [Date] |
| DA-002 | Hospital Episodes | EPR | OFFICIAL-SENSITIVE | PERSONAL | Yes | NHS Number, Diagnoses | 8 | [Name] | [Date] |
| DA-003 | Lab Results | LIMS | OFFICIAL-SENSITIVE | PERSONAL | Yes | NHS Number, Results | 8 | [Name] | [Date] |
| DA-004 | Aggregate Activity Stats | Analytics | OFFICIAL | ANONYMISED | No | — | 5 | [Name] | [Date] |
| DA-005 | Specialty Code Reference | Reference | OFFICIAL | NON-PERSONAL | No | — | Indefinite | [Name] | [Date] |
| DA-006 | [Add further assets] | | | | | | | | |

---

## 9. Roles and Responsibilities

| Role | Responsibility |
|------|--------------|
| **Data Owner** | Accountable for correct classification of their domain; approves reclassification |
| **Data Steward** | Applies and maintains classification labels; annual review |
| **Data Architect** | Implements classification controls in AWS (tags, Lake Formation, Macie) |
| **DPO / IG Lead** | Advises on UK GDPR requirements; approves anonymisation claims |
| **Caldicott Guardian** | Approves uses of patient data; advises on Caldicott Principles |

---

## 10. Review and Change

- Classification is reviewed **annually** or when processing activities change
- Reclassification requests go to the Data Owner + DPO for approval
- All changes logged in the Data Asset register with reason and date

---

*[Organisation] | Data Classification Policy | Version 0.1 | [Date]*
*Owner: Data Protection Officer | Approved by: SIRO*
