# Data Quality Assessment
## [Organisation Name] | Discovery Phase
### Version 0.1 | [Date] | Author: [Name]

> **Purpose:** Establish a data quality baseline for each source system before migration. Findings inform the migration risk register and the remediation plan.

---

## 1. Assessment Methodology

Each source system is assessed against **six data quality dimensions**:

| Dimension | Definition | Measurement |
|-----------|-----------|------------|
| **Completeness** | Required fields are populated | % of non-null values in mandatory fields |
| **Accuracy** | Values are correct and reflect reality | % passing reference data validation |
| **Consistency** | Same data is consistent across systems | Cross-system reconciliation match rate |
| **Timeliness** | Data is available when needed | Hours/days from event to data availability |
| **Uniqueness** | No duplicate records | % unique on primary key |
| **Validity** | Values conform to defined format/coding | % passing format and coding checks |

**Thresholds:**
- 🟢 **Good:** ≥ 95%
- 🟡 **Acceptable:** 85–94%
- 🔴 **Poor / Blocker:** < 85%

---

## 2. System-Level Quality Scorecard

| System | Completeness | Accuracy | Consistency | Timeliness | Uniqueness | Validity | Overall RAG |
|--------|------------|---------|------------|-----------|-----------|---------|------------|
| PAS | [X]% | [X]% | [X]% | [X] hrs | [X]% | [X]% | 🟡 |
| EPR | [X]% | [X]% | [X]% | [X] hrs | [X]% | [X]% | 🔴 |
| LIMS | [X]% | [X]% | [X]% | [X] hrs | [X]% | [X]% | 🟢 |
| Finance | [X]% | [X]% | [X]% | [X] hrs | [X]% | [X]% | 🟢 |

---

## 3. Detailed Findings by System

### 3.1 PAS — Patient Administration System

**NHS Number Completeness**
```sql
-- Run against source PAS
SELECT
    COUNT(*) AS total_patients,
    COUNT(nhs_number) AS has_nhs_number,
    COUNT(*) - COUNT(nhs_number) AS missing_nhs_number,
    ROUND(100.0 * COUNT(nhs_number) / COUNT(*), 2) AS completeness_pct
FROM [source_db].[dbo].[patients];
```
| Metric | Result | Threshold | RAG |
|--------|-------|---------|-----|
| NHS Number completeness | [X]% | ≥ 98% | 🟡 |
| NHS Number validity (Luhn) | [X]% | 100% | 🔴 |
| Date of Birth populated | [X]% | ≥ 99% | |
| Sex code valid | [X]% | 100% | |
| Duplicate NHS Numbers | [X] records | 0 | 🔴 |

**Issues Found:**
- [ ] [X]% of patients missing NHS Number — requires data quality sprint before migration
- [ ] [X] records with duplicate NHS Numbers — deduplication logic needed
- [ ] [X]% sex code uses legacy values ('Male'/'Female') — transformation rule required

**Remediation:**
- Run NHS Number trace via NHS Spine (SMSP) for patients with missing numbers
- Deduplicate using probabilistic matching on DOB + postcode sector
- Add transformation rule: legacy sex codes → NHS DD 1-character codes

---

**Admission Date Completeness (Clinical Events)**
```sql
SELECT
    event_type,
    COUNT(*) AS total,
    COUNT(admission_date) AS has_date,
    ROUND(100.0 * COUNT(admission_date) / COUNT(*), 2) AS completeness_pct
FROM [source_db].[dbo].[hospital_episodes]
GROUP BY event_type;
```
| Metric | Inpatient | Outpatient | A&E | RAG |
|--------|----------|-----------|-----|-----|
| Admission date populated | [X]% | N/A | [X]% | |
| Discharge date populated | [X]% | N/A | [X]% | |

---

### 3.2 EPR — Electronic Patient Record

**ICD-10 Coding Completeness**
```sql
SELECT
    specialty_code,
    COUNT(*) AS total_episodes,
    COUNT(primary_diagnosis) AS coded,
    ROUND(100.0 * COUNT(primary_diagnosis) / COUNT(*), 2) AS coding_pct
FROM [epr_db].[owner].[hospital_episodes]
WHERE discharge_date >= DATEADD(YEAR, -2, GETDATE())
GROUP BY specialty_code
ORDER BY coding_pct ASC;
```
| Metric | Result | Threshold | RAG |
|--------|-------|---------|-----|
| Primary ICD-10 completeness | [X]% | ≥ 95% | |
| Valid ICD-10 format | [X]% | ≥ 99% | |
| OPCS-4 procedure code completeness | [X]% | ≥ 90% | |
| HRG code populated | [X]% | ≥ 95% | |

**Issues Found:**
- [ ] Specialty [X] has only [X]% coding completeness — clinical coder capacity issue
- [ ] [X] records with ICD-10 codes in free-text fields — not structured codes

---

**Patient Linkage to PAS**
```sql
-- Cross-system consistency: EPR patient ID matches PAS
SELECT
    COUNT(*) AS epr_total,
    COUNT(p.nhs_number) AS matched_to_pas,
    COUNT(*) - COUNT(p.nhs_number) AS unmatched
FROM [epr_db].[owner].[patients] e
LEFT JOIN [source_db].[dbo].[patients] p ON e.nhs_number = p.nhs_number;
```
| Metric | Result | Threshold | RAG |
|--------|-------|---------|-----|
| EPR patients matched to PAS | [X]% | ≥ 98% | |
| Unmatched (no NHS Number link) | [X] records | < 2% | |

---

### 3.3 LIMS — Laboratory Information Management System

**Result Completeness**
| Metric | Result | Threshold | RAG |
|--------|-------|---------|-----|
| Result value populated | [X]% | ≥ 99% | |
| Result status = FINAL | [X]% | > 95% | |
| SNOMED CT test code populated | [X]% | ≥ 90% | |
| Reference range populated | [X]% | ≥ 85% | |
| Patient NHS Number on result | [X]% | ≥ 98% | |
| Critical value flag populated | [X]% | 100% | 🔴 |

**Issues Found:**
- [ ] Critical value flag not consistently applied — patient safety risk
- [ ] [X]% of SNOMED codes pre-2018 — superseded concepts in use

---

## 4. Cross-System Consistency

**Patient Count Reconciliation**
| System | Patient Count | NHS Number Match Rate | Notes |
|--------|-------------|---------------------|-------|
| PAS | [X] | — | Master |
| EPR | [X] | [X]% to PAS | [X] unmatched |
| LIMS | [X] | [X]% to PAS | Historic non-NHS patients in scope |

**Activity Reconciliation — Inpatient Spells (last 12 months)**
| Source | Count | Matches PAS | Discrepancy |
|--------|-------|------------|------------|
| PAS episodes | [X] | — | — |
| EPR episodes | [X] | [X]% | [X] unmatched |
| SUS submission | [X] | [X]% | [X] unmatched |

---

## 5. Critical Quality Issues — Prioritised

| # | Issue | System | Impact | Pre-migration Blocker? | Owner | Target Date |
|---|-------|--------|--------|----------------------|-------|------------|
| DQ-01 | NHS Number completeness [X]% — below 98% threshold | PAS | HIGH — blocks patient linkage | ✅ YES | PAS System Owner | [Date] |
| DQ-02 | Duplicate NHS Numbers: [X] records | PAS | HIGH — creates duplicate patients in Silver | ✅ YES | Data Steward | [Date] |
| DQ-03 | Critical value flag inconsistently applied in LIMS | LIMS | HIGH — patient safety | ✅ YES | LIMS Manager | [Date] |
| DQ-04 | ICD-10 completeness [X]% in specialty [X] | EPR | MEDIUM — impacts coding analytics | ❌ NO (remediate in Alpha) | Clinical Coding Lead | [Date] |
| DQ-05 | Superseded SNOMED concepts in LIMS | LIMS | MEDIUM — coding accuracy | ❌ NO | LIMS Manager | [Date] |
| DQ-06 | EPR patients not linkable to PAS: [X] records | EPR/PAS | MEDIUM — orphan clinical data | ❌ NO | Both system owners | [Date] |

---

## 6. Data Quality Monitoring Plan (Post-Migration)

Once on the AWS platform, these checks run automatically via **AWS Glue Data Quality** and write results to `governance.data_quality_log`:

```python
# Glue Data Quality ruleset — patient table
ruleset = """
  Rules = [
    Completeness "nhs_number" >= 0.98,
    IsComplete "date_of_birth",
    ColumnValues "sex" in ["M","F","I","U"],
    IsUnique "nhs_number",
    ColumnLength "nhs_number" = 10
  ]
"""
```

**CloudWatch Dashboard:** Data quality scores by dimension, by table, by day — reviewed by Data Steward weekly.

---

## 7. Sign-Off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Data Architect | | | |
| Data Steward | | | |
| Data Owner | | | |

---

*[Organisation] | Data Quality Assessment | Version 0.1 | [Date]*
