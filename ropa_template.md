# Record of Processing Activities (RoPA)
## [Organisation Name]
### UK GDPR Article 30 Compliance | Version 0.1 | [Date]
> **Owner:** Data Protection Officer | **Review frequency:** Annual or when processing changes

---

| Ref | Processing Activity | Controller | Data Categories | Special Categories | Data Subjects | Purpose | Legal Basis (Art 6) | Special Cat Basis (Art 9) | Recipients | Transfers Outside UK | Retention | Security Measures | DPIA Required? | Review Date |
|-----|-------------------|-----------|----------------|-------------------|--------------|---------|-------------------|------------------------|-----------|---------------------|---------|------------------|--------------|------------|
| P-01 | Migration of patient demographics from PAS to AWS data platform | [Organisation] | Name, DOB, NHS Number, postcode sector, GP practice | Health data — patient identifiers | Patients | Providing and improving healthcare services | Art 6(1)(e) — Public Task | Art 9(2)(h) — Healthcare provision | Internal data platform team only | No — AWS eu-west-2 (UK) | 8 years (NHS RMCOP) | Encryption at rest (KMS), TLS in transit, IAM RBAC, CloudTrail audit | Yes — complete before migration | [Date] |
| P-02 | Processing hospital episode data for operational analytics | [Organisation] | NHS Number (pseudonymised), diagnoses (ICD-10), procedures (OPCS-4), dates | Health data | Patients | Service planning, resource allocation, operational performance | Art 6(1)(e) — Public Task | Art 9(2)(h) — Healthcare provision | Internal analytics team, NHSE (aggregate only) | No | 8 years | As above + pseudonymisation applied | No | [Date] |
| P-03 | Processing lab results for clinical performance monitoring | [Organisation] | NHS Number (pseudonymised), test codes, results | Health data | Patients | Clinical quality improvement, patient safety monitoring | Art 6(1)(e) — Public Task | Art 9(2)(h) — Healthcare provision | Internal clinical governance team | No | 8 years | As above | No | [Date] |
| P-04 | Statutory data submission to NHS England (SUS / HES) | [Organisation] | Pseudonymised patient data per SUS spec | Health data | Patients | Legal obligation — NHS activity return | Art 6(1)(c) — Legal Obligation | Art 9(2)(h) | NHS England (statutory recipient) | No (UK body) | Per NHSE retention policy | Encrypted transmission; NHSE DUA in place | No | [Date] |
| P-05 | Staff access audit logging (CloudTrail) | [Organisation] | Staff name, user ID, IP address, data accessed | N/A (staff data) | Staff | Security monitoring; accountability | Art 6(1)(f) — Legitimate Interests | N/A | Information Governance team | No | 6 years | S3 with restricted access; KMS encrypted | No | [Date] |
| P-06 | Research / secondary use of anonymised data | [Organisation] | Anonymised aggregate data (no individual identified) | Anonymised — not personal data per ICO | Former patients | Service improvement research | Not applicable — anonymised data | Not applicable | Research team; potentially external researchers via DSA | No | Per research ethics approval | Anonymisation standard documented and verified | No | [Date] |
| P-07 | [Add further processing activities] | | | | | | | | | | | | | |

---

## Notes on Legal Bases Used

| Basis | When Used | Evidence Required |
|-------|----------|-----------------|
| **Art 6(1)(c) — Legal Obligation** | Statutory NHS reporting (SUS, DSPT, CQC) | Cite the specific legislation / direction |
| **Art 6(1)(e) — Public Task** | Most NHS analytical and operational processing | Refer to NHS Act 2006 / Health and Care Act 2022 |
| **Art 6(1)(f) — Legitimate Interests** | Security monitoring of staff | LIA (Legitimate Interests Assessment) must be completed |
| **Art 9(2)(h) — Healthcare** | All processing of patient health data | Must also have Art 6 basis |
| **Art 9(2)(j) — Research** | Secondary research use | Must also have Art 6 basis; EAG / ethics approval recommended |

---

## Data Sharing Agreements in Place

| Ref | Data Source / Recipient | Agreement Type | Date Signed | Review Date | Contact |
|-----|------------------------|---------------|------------|------------|---------|
| DSA-01 | NHS England | NHS Standard DSA | [Date] | [Date] | [Name] |
| DSA-02 | NHS Digital (now NHSE) | Data Access Agreement | [Date] | [Date] | [Name] |
| DSA-03 | [Other external partner] | Data Sharing Agreement | [Date] | [Date] | [Name] |

---

## DPO Review Sign-off

| Version | Date | Reviewed By | Notes |
|---------|------|------------|-------|
| 0.1 | [Date] | [DPO Name] | Initial draft for Discovery phase |

---

*[Organisation] | Record of Processing Activities | Version 0.1 | [Date]*
*Prepared by: [Data Architect] | Reviewed by: [DPO]*
