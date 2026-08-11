# Data Mapping Template
## [Organisation Name] | Source: [System Name] → Target: Silver Layer
### Version 0.1 | [Date] | Author: [Name] | Reviewed by: [Name]

---

## Entity: PATIENT
**Source Table:** `[source_db].[dbo].[patients]`
**Target Table:** `silver.patient`
**Migration Method:** AWS DMS Full Load + CDC
**Volume:** ~[X] rows

| Source Field | Source Type | Target Field | Target Type | Transformation Rule | Null Handling | Validation | Notes |
|-------------|------------|-------------|------------|-------------------|--------------|-----------|-------|
| `PatientID` | INT | `source_patient_id` | VARCHAR(50) | CAST to VARCHAR | NOT NULL | Must be unique in source | Source PK |
| `NHSNumber` | VARCHAR(12) | `nhs_number` | CHAR(10) | Strip spaces; validate 10-digit Luhn checksum | Reject row if NULL or invalid | Luhn algorithm check | Enterprise key — reject invalid |
| `Surname` | VARCHAR(100) | *(not mapped)* | — | **DROP** — do not migrate surname | — | — | IG: name not required in analytics layer |
| `Forename` | VARCHAR(100) | *(not mapped)* | — | **DROP** | — | — | IG: name not required |
| `DateOfBirth` | DATETIME | `date_of_birth` | DATE | Extract date part only (no time) | NOT NULL — reject row if NULL | Must be in past; not > today | |
| `SexCode` | CHAR(1) | `sex` | CHAR(1) | Direct copy; map legacy: 'Male'→'M', 'Female'→'F', 'Unknown'→'U', 'Indeterminate'→'I' | Default 'U' if NULL | IN ('M','F','U','I') | NHS DD: SEX |
| `EthnicCategory` | VARCHAR(5) | `ethnicity_code` | VARCHAR(5) | Map to NHS 2001 Ethnic Category Codes if using legacy classification | NULL allowed | Must match NHSDD reference table | |
| `Postcode` | VARCHAR(10) | `postcode_sector` | VARCHAR(5) | Extract first 5 characters ONLY (sector-level) | NULL allowed | — | Full postcode not stored per IG policy |
| `GPPracticeCode` | VARCHAR(10) | `gp_practice_ods` | VARCHAR(10) | Direct copy | NULL allowed | Validate against ODS reference | |
| `DeceasedFlag` | BIT | `is_deceased` | BOOLEAN | BIT→BOOLEAN: 1→TRUE, 0→FALSE | Default FALSE | — | |
| `DateOfDeath` | DATETIME | `date_of_death` | DATE | Extract date part only | NULL if not deceased | Must be > date_of_birth | |
| `RegisteredDate` | DATETIME | *(not mapped)* | — | Not required in target | — | — | |
| `AddressLine1` | VARCHAR(100) | *(not mapped)* | — | **DROP** — IG: address not required | — | — | |
| `AddressLine2` | VARCHAR(100) | *(not mapped)* | — | **DROP** | — | — | |

**Rows expected to reject:** ~[X]% (invalid NHS Numbers, NULL DOB)
**Exception handling:** Rejected rows written to `governance.data_quality_log` with `dimension='VALIDITY'`

---

## Entity: CLINICAL_EVENT (Hospital Episodes)
**Source Table:** `[epr_db].[owner].[HospitalEpisodes]`
**Target Table:** `silver.clinical_event`
**Migration Method:** AWS DMS Full Load + CDC
**Volume:** ~[X] rows

| Source Field | Source Type | Target Field | Target Type | Transformation Rule | Null Handling | Validation | Notes |
|-------------|------------|-------------|------------|-------------------|--------------|-----------|-------|
| `EpisodeID` | BIGINT | `event_id` | VARCHAR(100) | CONCAT('EPR-', CAST(EpisodeID AS VARCHAR)) | NOT NULL | Unique | Prefix to avoid collision with other sources |
| `LocalPatientID` | VARCHAR(20) | `patient_sk` | UUID | Lookup silver.patient via nhs_number join | NOT NULL — reject if no patient match | FK must exist in silver.patient | Requires patient load first |
| `OrgCode` | VARCHAR(10) | `org_sk` | UUID | Lookup silver.organisation via ods_code | NOT NULL | FK must exist | |
| `ConsultantCode` | VARCHAR(10) | `practitioner_sk` | UUID | Lookup silver.practitioner via registration_number | NULL allowed | FK if provided | |
| `EpisodeType` | VARCHAR(20) | `event_type` | VARCHAR(20) | Map: 'IP'→'INPATIENT', 'DC'→'DAYCASE', 'OP'→'OUTPATIENT', 'AE'→'A_AND_E' | Reject if unmappable | IN allowed values | |
| `AdmissionDate` | DATETIME | `admission_date` | DATE | Extract date only | NULL allowed (OP has no admission) | Must be ≤ discharge_date | |
| `DischargeDate` | DATETIME | `discharge_date` | DATE | Extract date only | NULL if still admitted | Must be ≥ admission_date | |
| `AdmissionMethod` | VARCHAR(5) | `admission_method` | VARCHAR(5) | Direct copy — NHS DD code | NULL allowed | Validate against NHS DD ref | |
| `DischargeMethod` | VARCHAR(5) | `discharge_method` | VARCHAR(5) | Direct copy | NULL allowed | Validate against NHS DD ref | |
| `SpecialtyCode` | VARCHAR(10) | `specialty_code` | VARCHAR(10) | Direct copy | NULL allowed | Validate against national list | |
| `PrimaryDiagnosis` | VARCHAR(10) | `primary_diagnosis` | VARCHAR(10) | Strip trailing dots; uppercase; validate ICD-10 format | NULL allowed | Regex: `[A-Z]\d{2}(\.\d{1,2})?` | ICD-10 4-char code |
| `SecondaryDiag1` | VARCHAR(10) | `secondary_diag_1` | VARCHAR(10) | As above | NULL | ICD-10 format | |
| `PrimaryProcedure` | VARCHAR(10) | `primary_procedure` | VARCHAR(10) | Strip trailing dots; uppercase | NULL allowed | OPCS-4 format | |
| `HRGCode` | VARCHAR(10) | `hrg_code` | VARCHAR(10) | Direct copy | NULL allowed | — | |
| `SpellNumber` | VARCHAR(50) | `spell_number` | VARCHAR(50) | Direct copy | NULL allowed | — | |
| `SUSSubmissionDate` | DATE | `sus_submission_date` | DATE | Direct copy | NULL allowed | — | |

---

## Entity: LAB_RESULT
**Source Table:** `[lims_db].[public].[test_results]`
**Target Table:** `silver.lab_result`
**Migration Method:** AWS Glue (PostgreSQL source)
**Volume:** ~[X] rows

| Source Field | Source Type | Target Field | Target Type | Transformation Rule | Null Handling | Validation | Notes |
|-------------|------------|-------------|------------|-------------------|--------------|-----------|-------|
| `ResultUID` | UUID | `result_id` | VARCHAR(100) | CAST to VARCHAR | NOT NULL | Unique | |
| `SpecimenUID` | UUID | `specimen_sk` | UUID | Lookup silver.specimen | NOT NULL | FK must exist | Load specimens first |
| `PatientUID` | UUID | `patient_sk` | UUID | Lookup via NHS Number | NOT NULL | FK must exist | |
| `TestCode` | VARCHAR(30) | `test_code` | VARCHAR(30) | Direct copy — SNOMED / LOINC | NULL allowed | — | |
| `TestName` | VARCHAR(500) | `test_name` | VARCHAR(255) | Truncate at 255 chars | NULL allowed | — | |
| `ResultValue` | TEXT | `result_value_text` | VARCHAR(500) | Direct copy | NULL allowed | — | |
| `ResultValueNum` | DECIMAL | `result_value_num` | NUMERIC(12,4) | Direct copy | NULL if non-numeric | — | |
| `Unit` | VARCHAR(50) | `result_unit` | VARCHAR(50) | Standardise to UCUM units where possible | NULL allowed | — | |
| `RefRangeLow` | DECIMAL | `ref_range_low` | NUMERIC(10,4) | Direct copy | NULL allowed | Must be ≤ ref_range_high | |
| `RefRangeHigh` | DECIMAL | `ref_range_high` | NUMERIC(10,4) | Direct copy | NULL allowed | Must be ≥ ref_range_low | |
| `Status` | VARCHAR(20) | `result_status` | VARCHAR(15) | Map: 'F'→'FINAL', 'P'→'PRELIMINARY', 'C'→'CORRECTED', 'X'→'CANCELLED' | Reject if unmappable | IN allowed values | |
| `Abnormal` | CHAR(1) | `is_abnormal` | BOOLEAN | 'Y'→TRUE, 'N'→FALSE, NULL→NULL | NULL allowed | — | |
| `CriticalValue` | CHAR(1) | `is_critical_value` | BOOLEAN | 'Y'→TRUE, else FALSE | Default FALSE | — | Critical results must be flagged |
| `ReportedDate` | TIMESTAMP | `reported_date` | TIMESTAMP | Direct copy | NOT NULL | Must not be future | |

---

## Mapping Summary

| Entity | Source Rows (est.) | Expected Target Rows | Expected Reject % | Reject Reason |
|--------|-------------------|---------------------|------------------|--------------|
| PATIENT | [X] | [X] | ~[X]% | Invalid NHS Number, NULL DOB |
| CLINICAL_EVENT | [X] | [X] | ~[X]% | No patient match, invalid event type |
| LAB_RESULT | [X] | [X] | ~[X]% | No specimen match |

---

## Sign-off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Data Architect | | | |
| Data Owner | | | |
| Data Steward | | | |
| IG Lead | | | |

---

*[Organisation] | Data Mapping | Version 0.1 | [Date]*
