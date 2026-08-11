# Sample Data Inventory Register
## Midshire Community Health Trust (MCHT) — Discovery Phase
### Version 0.3 | 8 August 2024 | Author: O. Odeyemi

> ⚠️ **SAMPLE OUTPUT — For Portfolio / Template Demonstration Only**
> All figures, names, and systems are fictional. Demonstrates a completed data inventory using this template.

---

## Data Asset Register — 18 Assets Catalogued

| Asset ID | Asset Name | Asset Type | Source System | Data Domain | Owner Team | Data Steward | Classification | Sensitivity | Contains PII | PII Fields | Retention (Yrs) | Volume (est.) | Format | Current Location | AWS Target | NHS Standard | Status | Issues / Notes |
|---------|-----------|-----------|--------------|------------|-----------|-------------|---------------|------------|-------------|-----------|----------------|-------------|-------|-----------------|-----------|-------------|-------|--------------|
| DA-001 | Patient Master Record | Table | PAS (Systema) | Patient | IT / PAS Team | Angela Torres | OFFICIAL-SENSITIVE | PERSONAL | YES | NHS Number, Name, DOB, Postcode | 8 | 480K rows | SQL Server table | On-Prem SQL Server 2014 | Silver — patient | NHS DD | ✅ Catalogued | NHS No. completeness 93.4% 🔴 |
| DA-002 | Hospital Episodes (Inpatient) | Table | EPR (CareView) | Clinical | Clinical Records | David Liu | OFFICIAL-SENSITIVE | PERSONAL | YES | NHS Number, Diagnoses, Procedures | 8 | 1.2M rows | Oracle table | On-Prem Oracle 11g | Silver — clinical_event | HES / SUS | ✅ Catalogued | ICD-10 completeness 87% 🟡 |
| DA-003 | Outpatient Appointments | Table | EPR (CareView) | Clinical | Clinical Records | David Liu | OFFICIAL-SENSITIVE | PERSONAL | YES | NHS Number, Clinician, Dates | 8 | 840K rows | Oracle table | On-Prem Oracle 11g | Silver — clinical_event | SUS OP | ✅ Catalogued | RTT fields incomplete in 12% |
| DA-004 | Community Nursing Contacts | Table | RiO | Community | Community Division | Angela Torres | OFFICIAL-SENSITIVE | PERSONAL | YES | NHS Number, Care Plan, Diagnoses | 8 | 340K contacts | Cloud SaaS DB | RiO Cloud (AWS-based) | Silver — clinical_event | MHSDS / CDS | ✅ Catalogued | ICD-10 only 78% 🔴 — coding backlog |
| DA-005 | Laboratory Specimens | Table | LIMS (PathMaster) | Pathology | Pathology Dept | Fatima Al-Hassan | OFFICIAL-SENSITIVE | PERSONAL | YES | NHS Number, Specimen type, SNOMED | 8 | 2.8M specimens | PostgreSQL 12 | On-Prem | Silver — specimen | SNOMED CT | ✅ Catalogued | Disposal dates not populated 🟡 |
| DA-006 | Laboratory Results | Table | LIMS (PathMaster) | Pathology | Pathology Dept | Fatima Al-Hassan | OFFICIAL-SENSITIVE | PERSONAL | YES | NHS Number, Test results (SNOMED) | 8 | 9.4M results | PostgreSQL 12 | On-Prem | Silver — lab_result | SNOMED CT / LOINC | ✅ Catalogued | Critical value flag inconsistent 🔴 |
| DA-007 | Referral Data | Table | EPR (CareView) | Clinical | Clinical Records | David Liu | OFFICIAL-SENSITIVE | PERSONAL | YES | NHS Number, Referral details, UBRN | 8 | 180K referrals | Oracle table | On-Prem Oracle 11g | Silver — referral | e-RS / RTT | ✅ Catalogued | UBRN missing in 23% of records |
| DA-008 | Prescribing / Medication | Table | EPR (CareView) | Clinical | Clinical Records | David Liu | OFFICIAL-SENSITIVE | PERSONAL | YES | NHS Number, dm+d codes, Prescriber | 8 | 620K records | Oracle table | On-Prem Oracle 11g | Silver — medication | dm+d / EPS | ✅ Catalogued | dm+d codes: 89% coverage |
| DA-009 | Financial Activity Data | Table | Finance (Agresso) | Finance | Finance Dept | Yemi Adeyemi | OFFICIAL | NON-PERSONAL | NO | — | 7 | 200K rows/yr | SQL Server 2019 | On-Prem | Gold — finance_mart | PLICS | ✅ Catalogued | No patient link — safe |
| DA-010 | RTT Waiting List (Weekly) | Report / File | PAS (Systema) | Clinical | Analytics | Marcus Webb | OFFICIAL-SENSITIVE | PERSONAL | YES | NHS Number, Specialty, Wait times | 8 | ~5K rows/week | Excel | Network Share Z:\Reports | Gold — rtt_mart | RTT | ⚠️ Uncontrolled PII | **IMMEDIATE ACTION: PII on uncontrolled share** |
| DA-011 | Agency Staff Timesheets | File | HR (manual) | Workforce | HR Dept | (Unassigned) | OFFICIAL-SENSITIVE | PERSONAL | YES | Staff name, NI number, Bank details | 6 | Monthly CSV | CSV | Network Share Z:\HR | Out of scope | — | ❌ Not catalogued | IG risk — no owner assigned |
| DA-012 | NHSE Benchmarking Dataset | Dataset | NHS England | Performance | Analytics | Marcus Webb | OFFICIAL | ANONYMISED | NO | — | 5 | Annual release | ZIP/CSV | SFTP from NHSE | Bronze — external | NHSE Model Hospital | ✅ Catalogued | ICO anonymisation standard met |
| DA-013 | ICD-10 Reference File | Reference | NHS Data Dictionary | Reference | IT | Ben Kowalski | OFFICIAL | NON-PERSONAL | NO | — | Indefinite | Annual update | CSV | Network Share (read) | S3 — reference | NHS DD | ✅ Catalogued | Annual update from NHS DD |
| DA-014 | ODS Organisation Reference | Reference | NHS ODS | Reference | IT | Ben Kowalski | OFFICIAL | NON-PERSONAL | NO | — | Indefinite | Quarterly update | CSV | Network Share (read) | S3 — reference | NHS ODS | ✅ Catalogued | |
| DA-015 | Maternity Data | Table | EPR (CareView) | Maternity | Maternity Unit | David Liu | OFFICIAL-SENSITIVE | PERSONAL | YES | NHS Number, Gestation, Birth outcomes | 25 | 12K deliveries/yr | Oracle | On-Prem Oracle 11g | Silver — clinical_event | MSDS | ⚠️ Partial | MSDS compliance review needed |
| DA-016 | Mental Health Referrals | Table | RiO | Mental Health | MH Division | Angela Torres | OFFICIAL-SENSITIVE | PERSONAL | YES | NHS Number, MH diagnosis, CPA status | 20 | 8K referrals/yr | Cloud SaaS | RiO Cloud | Silver — referral | MHSDS | ✅ Catalogued | 20-year retention per RMCOP 2021 |
| DA-017 | A&E Attendances | Table | EPR (CareView) | Urgent Care | Clinical Records | David Liu | OFFICIAL-SENSITIVE | PERSONAL | YES | NHS Number, Chief complaint, Outcome | 8 | 45K/yr | Oracle | On-Prem Oracle 11g | Silver — clinical_event | ECDS | ⚠️ Partial | ECDS data elements not all captured |
| DA-018 | Patient Feedback / PREM | File | Manual survey | Patient Experience | Corporate | (Unassigned) | OFFICIAL-SENSITIVE | PERSONAL | YES | Patient comments, Dept, Date | 8 | Quarterly PDF | PDF | Email + SharePoint | Out of scope | — | ❌ Not catalogued | Requires separate PIA |

---

## Summary Counts

| Classification | Count |
|---------------|-------|
| OFFICIAL | 4 |
| OFFICIAL-SENSITIVE | 14 |
| **Total** | **18** |

| Sensitivity | Count |
|------------|-------|
| PERSONAL | 14 |
| ANONYMISED | 1 |
| NON-PERSONAL | 3 |
| **Total** | **18** |

| Status | Count |
|--------|-------|
| ✅ Catalogued | 13 |
| ⚠️ Partial / Uncontrolled | 4 |
| ❌ Not Catalogued | 1 |
| **Total** | **18** |

---

## Priority Risk Flags

| Priority | Asset ID | Risk | Action Required | Owner | Due |
|---------|---------|------|----------------|-------|-----|
| 🔴 CRITICAL | DA-010 | RTT waiting list with PII on uncontrolled network share | Move to S3 + Lake Formation immediately; IG risk register entry | Priya Sharma + Marcus Webb | Immediately |
| 🔴 CRITICAL | DA-001 | NHS Number completeness 93.4% — blocks patient linkage | NHS Spine tracing sprint | Angela Torres | 15 Sept 2024 |
| 🔴 CRITICAL | DA-006 | Critical value flag inconsistently applied in LIMS | LIMS configuration review — patient safety risk | Fatima Al-Hassan | 1 Sept 2024 |
| 🟡 HIGH | DA-011 | Agency staff bank details on uncontrolled share | Move to secure HR system; immediate IG review | HR + DPO | 1 Sept 2024 |
| 🟡 HIGH | DA-004 | RiO ICD-10 completeness 78% | Community nursing coding backlog sprint | Dr. Rachel Nwosu | 30 Sept 2024 |
| 🟡 HIGH | DA-018 | Patient feedback not catalogued — no owner | Assign data owner; conduct PIA; scope for Phase 2 | Corporate + DPO | 30 Sept 2024 |

---

## Assets by Retention Period

| Retention Period | Count | Assets |
|-----------------|-------|--------|
| 8 years (Adult records) | 11 | DA-001, DA-002, DA-003, DA-004, DA-005, DA-006, DA-007, DA-008, DA-010, DA-017, DA-018 |
| 20 years (Mental health) | 1 | DA-016 |
| 25 years (Maternity) | 1 | DA-015 |
| 7 years (Finance) | 1 | DA-009 |
| 6 years (HR) | 1 | DA-011 |
| 5 years (Benchmarking) | 1 | DA-012 |
| Indefinite (Reference) | 2 | DA-013, DA-014 |

---

*SAMPLE OUTPUT — Midshire Community Health Trust | Data Inventory Register v0.3 | 8 Aug 2024*
*Template: gov-health-discovery-architecture-template | github.com/yourusername/govhealth-discovery-template*
