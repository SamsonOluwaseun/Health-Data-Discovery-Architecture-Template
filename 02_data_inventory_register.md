# Data Inventory Register
## [Organisation Name] | Discovery Phase | [Date]
> One row per data source/system/dataset. Populate during stakeholder interviews.

---

| Asset ID | Asset Name | Asset Type | Source System | Data Domain | Owner Team | Data Steward | Classification | Sensitivity | Contains PII | Retention (Years) | Volume (est.) | Format | Location (Current) | AWS Target | NHS Standard | Status | Notes |
|---------|-----------|-----------|--------------|------------|-----------|-------------|---------------|------------|-------------|------------------|-------------|-------|------------------|-----------|-------------|-------|-------|
| DA-001 | Patient Demographics | Table | PAS | Patient | [Team] | [Name] | OFFICIAL-SENSITIVE | PERSONAL | Yes | 8 | 500K rows | SQL Server table | On-Prem | Silver — patient | NHS DD | ✅ Catalogued | NHS Number completeness: 94% |
| DA-002 | Hospital Episodes | Table | EPR | Clinical | [Team] | [Name] | OFFICIAL-SENSITIVE | PERSONAL | Yes | 8 | 4.2M rows | Oracle table | On-Prem | Silver — clinical_event | HES / SUS | ✅ Catalogued | ICD-10 coding gaps identified |
| DA-003 | Lab Results | Table | LIMS | Pathology | [Team] | [Name] | OFFICIAL-SENSITIVE | PERSONAL | Yes | 8 | 12M rows | PostgreSQL | On-Prem | Silver — lab_result | SNOMED CT | ✅ Catalogued | |
| DA-004 | Referral Data | Table | EPR | Clinical | [Team] | [Name] | OFFICIAL-SENSITIVE | PERSONAL | Yes | 8 | 800K rows | Oracle | On-Prem | Silver — referral | RTT / e-RS | ✅ Catalogued | RTT fields incomplete |
| DA-005 | Outpatient Waiting List | Report | PAS | Clinical | [Team] | [Name] | OFFICIAL-SENSITIVE | PERSONAL | Yes | 8 | Weekly extract | Excel | File share | Gold — waiting_list_mart | SUS | ⚠️ Uncontrolled PII | Move to S3 urgently |
| DA-006 | Finance / Activity Data | Table | Finance System | Finance | [Team] | [Name] | OFFICIAL | NON-PERSONAL | No | 7 | 200K rows | SQL Server | On-Prem | Gold — finance_mart | PLICS | ✅ Catalogued | |
| DA-007 | Staff Rota Data | File | HR System | Workforce | [Team] | [Name] | OFFICIAL-SENSITIVE | PERSONAL | Yes | 6 | Monthly CSV | CSV | File share | Out of scope | — | ❌ Not catalogued | |
| DA-008 | NHSE Benchmarking Data | Dataset | NHSE | Performance | [Team] | [Name] | OFFICIAL | ANONYMISED | No | 5 | Annual ZIP | CSV | SFTP | Bronze — external | Model Hospital | ✅ Catalogued | |
| DA-009 | Prescribing Data | Table | EPR / Pharmacy | Clinical | [Team] | [Name] | OFFICIAL-SENSITIVE | PERSONAL | Yes | 8 | 3M rows | Oracle | On-Prem | Silver — medication | dm+d | ⚠️ Partial | dm+d codes incomplete |
| DA-010 | [ADD YOUR ASSETS] | | | | | | | | | | | | | | | | |

---

## Summary Counts

| Classification | Count |
|---------------|-------|
| OFFICIAL | |
| OFFICIAL-SENSITIVE | |
| SECRET | |
| **Total** | |

| Sensitivity | Count |
|------------|-------|
| PERSONAL | |
| PSEUDONYMISED | |
| ANONYMISED | |
| NON-PERSONAL | |
| **Total** | |

| Cataloguing Status | Count |
|-------------------|-------|
| ✅ Catalogued | |
| ⚠️ Partial | |
| ❌ Not catalogued | |
| **Total** | |

---

## Data Asset Risk Flags

| Priority | Asset ID | Risk | Action Required | Owner |
|---------|---------|------|----------------|-------|
| HIGH | DA-005 | PII on uncontrolled file share | Move to S3 immediately | IG + Data Engineer |
| HIGH | DA-001 | NHS Number completeness 94% — below 98% threshold | Data quality sprint | PAS System Owner |
| MEDIUM | DA-009 | dm+d codes incomplete — impacts prescribing analytics | Coding remediation | Pharmacy / Data Steward |

---

*[Organisation] | Data Inventory Register | Version 0.1 | [Date]*
