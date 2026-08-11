-- ============================================================
--  Gov Health Data Discovery Template
--  File: 02_logical_data_model.sql
--  Purpose: Logical Data Model — all entities, attributes,
--           data types, and relationships.
--
--  Level: LOGICAL (not physical)
--    - Data types are logical (VARCHAR, INTEGER, DATE, BOOLEAN)
--    - No physical optimisations (no indexes, no partitioning)
--    - No PostgreSQL-specific syntax
--    - Import into Erwin: Actions → Reverse Engineer → Script File
--
--  NHS Data Dictionary alignment:
--    - Field names follow NHS DD conventions where applicable
--    - Comments reference NHS DD element names
--
--  Author: [Your Name] | [Engagement Name] | [Date]
-- ============================================================

-- ── PATIENT ──────────────────────────────────────────────────
CREATE TABLE PATIENT (
    -- Surrogate Key
    patient_sk          VARCHAR(36)     NOT NULL,   -- UUID surrogate key

    -- Enterprise / Business Keys
    nhs_number          VARCHAR(10)     NOT NULL,   -- NHS DD: NHS_NUMBER (10-digit, Luhn validated)
    local_patient_id    VARCHAR(20),                -- Local MRN — system-specific

    -- Demographics
    date_of_birth       DATE            NOT NULL,   -- NHS DD: PERSON_BIRTH_DATE
    sex                 VARCHAR(1)      NOT NULL,   -- NHS DD: PERSON_STATED_GENDER_CODE (M/F/I/U)
    gender_identity     VARCHAR(50),                -- NHS DD: GENDER_IDENTITY_CODE
    ethnicity_code      VARCHAR(5),                 -- NHS DD: ETHNIC_CATEGORY_CODE (2001 classification)

    -- Geography (partial — IG compliant)
    postcode_sector     VARCHAR(5),                 -- First 5 chars of postcode only; no full postcode stored

    -- Registered Care
    gp_practice_ods     VARCHAR(10),                -- ODS Code of registered GP practice
    registered_gp_ods   VARCHAR(10),                -- ODS Code of responsible GP

    -- Status
    is_deceased         BOOLEAN         NOT NULL,   -- Deceased indicator
    date_of_death       DATE,                       -- NHS DD: PERSON_DEATH_DATE (NULL if alive)

    -- Provenance
    data_source         VARCHAR(50)     NOT NULL,   -- Source system name (e.g. 'PAS', 'SPINE')
    source_patient_id   VARCHAR(50),                -- Original ID in source system
    load_date           DATE            NOT NULL,   -- Date record loaded to platform
    last_updated        DATE            NOT NULL,   -- Date record last modified
    is_current          BOOLEAN         NOT NULL,   -- SCD Type 2 current flag

    CONSTRAINT pk_patient PRIMARY KEY (patient_sk),
    CONSTRAINT uq_patient_nhs UNIQUE (nhs_number),
    CONSTRAINT chk_patient_sex CHECK (sex IN ('M','F','I','U'))
);

COMMENT ON TABLE PATIENT IS 'Central patient entity. NHS Number is the enterprise business key. Full postcode not stored per IG policy.';
COMMENT ON COLUMN PATIENT.nhs_number IS 'NHS DD: NHS_NUMBER. 10-digit national patient identifier. Validated via Luhn checksum.';
COMMENT ON COLUMN PATIENT.sex IS 'NHS DD: PERSON_STATED_GENDER_CODE. M=Male, F=Female, I=Indeterminate, U=Unknown.';
COMMENT ON COLUMN PATIENT.ethnicity_code IS 'NHS DD: ETHNIC_CATEGORY_CODE. 2001 census 5+1 classification.';


-- ── ORGANISATION ─────────────────────────────────────────────
CREATE TABLE ORGANISATION (
    org_sk              VARCHAR(36)     NOT NULL,   -- UUID surrogate key
    ods_code            VARCHAR(10)     NOT NULL,   -- NHS ODS Code (business key)
    org_name            VARCHAR(255)    NOT NULL,
    org_type            VARCHAR(30)     NOT NULL,   -- TRUST / ICB / GP_PRACTICE / NHSE / LA / OTHER
    parent_org_sk       VARCHAR(36),                -- FK → ORGANISATION (hierarchical)
    commissioning_region VARCHAR(10),               -- NHS England regional ODS code
    is_active           BOOLEAN         NOT NULL,

    CONSTRAINT pk_org PRIMARY KEY (org_sk),
    CONSTRAINT uq_org_ods UNIQUE (ods_code),
    CONSTRAINT fk_org_parent FOREIGN KEY (parent_org_sk) REFERENCES ORGANISATION(org_sk),
    CONSTRAINT chk_org_type CHECK (org_type IN ('TRUST','ICB','GP_PRACTICE','NHSE','LOCAL_AUTHORITY','PRIVATE','LAB','OTHER'))
);

COMMENT ON TABLE ORGANISATION IS 'NHS and partner organisations. ODS Code from NHS Digital Organisation Data Service.';


-- ── PRACTITIONER ─────────────────────────────────────────────
CREATE TABLE PRACTITIONER (
    practitioner_sk     VARCHAR(36)     NOT NULL,
    registration_number VARCHAR(20)     NOT NULL,   -- GMC / NMC / HCPC registration number
    registration_body   VARCHAR(10),                -- GMC / NMC / HCPC / GDC / GPhC / OTHER
    forename            VARCHAR(100),               -- First name
    surname             VARCHAR(100),               -- Surname / family name
    primary_specialty   VARCHAR(10),                -- NHS national specialty code
    grade               VARCHAR(50),                -- CONSULTANT / REGISTRAR / SHO / FY1 / NURSE / AHP
    primary_org_sk      VARCHAR(36),                -- FK → ORGANISATION
    is_active           BOOLEAN         NOT NULL,

    CONSTRAINT pk_practitioner PRIMARY KEY (practitioner_sk),
    CONSTRAINT uq_practitioner_reg UNIQUE (registration_number),
    CONSTRAINT fk_practitioner_org FOREIGN KEY (primary_org_sk) REFERENCES ORGANISATION(org_sk),
    CONSTRAINT chk_reg_body CHECK (registration_body IN ('GMC','NMC','HCPC','GDC','GPhC','OTHER'))
);

COMMENT ON TABLE PRACTITIONER IS 'Clinical and healthcare professionals. Registration number (GMC/NMC/HCPC) is the business key.';


-- ── CLINICAL_EVENT ───────────────────────────────────────────
CREATE TABLE CLINICAL_EVENT (
    event_sk            VARCHAR(36)     NOT NULL,
    event_id            VARCHAR(100)    NOT NULL,   -- Source system event ID
    patient_sk          VARCHAR(36)     NOT NULL,   -- FK → PATIENT
    org_sk              VARCHAR(36)     NOT NULL,   -- FK → ORGANISATION (provider)
    practitioner_sk     VARCHAR(36),                -- FK → PRACTITIONER (responsible consultant)

    -- Event Classification
    event_type          VARCHAR(20)     NOT NULL,   -- INPATIENT / DAYCASE / OUTPATIENT / A_AND_E / COMMUNITY
    admission_method    VARCHAR(5),                 -- NHS DD: ADMISSION_METHOD (11=Elect, 21=Emergency)
    discharge_method    VARCHAR(5),                 -- NHS DD: DISCHARGE_METHOD (1=Discharge home, etc.)

    -- Dates
    admission_date      DATE,
    discharge_date      DATE,

    -- Clinical Coding
    specialty_code      VARCHAR(10),                -- NHS national specialty code
    primary_diagnosis   VARCHAR(10),                -- ICD-10 code (4-char)
    secondary_diag_1    VARCHAR(10),                -- ICD-10 secondary diagnosis
    secondary_diag_2    VARCHAR(10),
    secondary_diag_3    VARCHAR(10),
    primary_procedure   VARCHAR(10),                -- OPCS-4 code
    secondary_proc_1    VARCHAR(10),                -- OPCS-4

    -- Grouping
    hrg_code            VARCHAR(10),                -- Healthcare Resource Group (HRG4+)
    spell_number        VARCHAR(50),                -- Hospital spell number (links episodes)

    -- Statutory Reporting
    sus_submission_date DATE,                       -- Date submitted to Secondary Uses Service

    -- Provenance
    source_system       VARCHAR(50)     NOT NULL,
    load_date           DATE            NOT NULL,

    CONSTRAINT pk_clinical_event PRIMARY KEY (event_sk),
    CONSTRAINT uq_event_source UNIQUE (event_id, source_system),
    CONSTRAINT fk_event_patient FOREIGN KEY (patient_sk) REFERENCES PATIENT(patient_sk),
    CONSTRAINT fk_event_org FOREIGN KEY (org_sk) REFERENCES ORGANISATION(org_sk),
    CONSTRAINT fk_event_practitioner FOREIGN KEY (practitioner_sk) REFERENCES PRACTITIONER(practitioner_sk),
    CONSTRAINT chk_event_type CHECK (event_type IN ('INPATIENT','DAYCASE','OUTPATIENT','A_AND_E','COMMUNITY','MENTAL_HEALTH'))
);

COMMENT ON TABLE CLINICAL_EVENT IS 'Hospital episodes and clinical encounters. Aligned to SUS HES schema.';
COMMENT ON COLUMN CLINICAL_EVENT.primary_diagnosis IS 'ICD-10 Chapter IV code, 4-character. NHS DD: PRIMARY_DIAGNOSIS_CODE.';
COMMENT ON COLUMN CLINICAL_EVENT.hrg_code IS 'Healthcare Resource Group code (HRG4+). Used for tariff and payment calculation.';


-- ── REFERRAL ─────────────────────────────────────────────────
CREATE TABLE REFERRAL (
    referral_sk         VARCHAR(36)     NOT NULL,
    referral_id         VARCHAR(100)    NOT NULL,   -- Source system referral ID
    patient_sk          VARCHAR(36)     NOT NULL,   -- FK → PATIENT
    referring_org_sk    VARCHAR(36),                -- FK → ORGANISATION (referrer — e.g. GP)
    receiving_org_sk    VARCHAR(36),                -- FK → ORGANISATION (provider — e.g. Trust)

    -- Referral Detail
    referral_date       DATE            NOT NULL,
    referral_type       VARCHAR(20),                -- ROUTINE / URGENT / TWO_WEEK_WAIT / SELF / INTERNAL
    specialty_code      VARCHAR(10),
    status              VARCHAR(20),                -- RECEIVED / TRIAGED / BOOKED / ATTENDED / DNA / CANCELLED

    -- Appointment
    first_appointment   DATE,

    -- RTT Pathway (Referral to Treatment)
    rtt_start_date      DATE,                       -- RTT clock start
    rtt_stop_date       DATE,                       -- RTT clock stop (treatment or pathway end)

    -- e-Referral Service
    ubrn                VARCHAR(20),                -- Unique Booking Reference Number (NHS e-RS)

    -- Provenance
    source_system       VARCHAR(50)     NOT NULL,
    load_date           DATE            NOT NULL,

    CONSTRAINT pk_referral PRIMARY KEY (referral_sk),
    CONSTRAINT fk_referral_patient FOREIGN KEY (patient_sk) REFERENCES PATIENT(patient_sk),
    CONSTRAINT fk_referral_referring_org FOREIGN KEY (referring_org_sk) REFERENCES ORGANISATION(org_sk),
    CONSTRAINT fk_referral_receiving_org FOREIGN KEY (receiving_org_sk) REFERENCES ORGANISATION(org_sk),
    CONSTRAINT chk_referral_type CHECK (referral_type IN ('ROUTINE','URGENT','TWO_WEEK_WAIT','SELF','INTERNAL','CHOOSE_AND_BOOK')),
    CONSTRAINT chk_referral_status CHECK (status IN ('RECEIVED','TRIAGED','BOOKED','ATTENDED','DNA','CANCELLED','REJECTED'))
);

COMMENT ON TABLE REFERRAL IS 'Patient referrals. RTT start/stop dates support 18-week standard monitoring.';
COMMENT ON COLUMN REFERRAL.ubrn IS 'Unique Booking Reference Number — generated by NHS e-Referral Service (e-RS).';


-- ── SPECIMEN ─────────────────────────────────────────────────
CREATE TABLE SPECIMEN (
    specimen_sk         VARCHAR(36)     NOT NULL,
    specimen_id         VARCHAR(100)    NOT NULL,   -- LIMS specimen barcode / accession number
    patient_sk          VARCHAR(36)     NOT NULL,   -- FK → PATIENT
    event_sk            VARCHAR(36),                -- FK → CLINICAL_EVENT (collection episode)
    specimen_type       VARCHAR(50),                -- e.g. BLOOD / URINE / SWAB / TISSUE / CSF
    snomed_concept      VARCHAR(20),                -- SNOMED CT concept ID for specimen type
    collection_date     DATE            NOT NULL,
    requesting_org_sk   VARCHAR(36),                -- FK → ORGANISATION (requesting)
    processing_lab_sk   VARCHAR(36),                -- FK → ORGANISATION (laboratory)
    disposal_date       DATE,                       -- Planned or actual disposal date
    source_system       VARCHAR(50)     NOT NULL,
    load_date           DATE            NOT NULL,

    CONSTRAINT pk_specimen PRIMARY KEY (specimen_sk),
    CONSTRAINT uq_specimen_source UNIQUE (specimen_id, source_system),
    CONSTRAINT fk_specimen_patient FOREIGN KEY (patient_sk) REFERENCES PATIENT(patient_sk),
    CONSTRAINT fk_specimen_event FOREIGN KEY (event_sk) REFERENCES CLINICAL_EVENT(event_sk),
    CONSTRAINT fk_specimen_req_org FOREIGN KEY (requesting_org_sk) REFERENCES ORGANISATION(org_sk),
    CONSTRAINT fk_specimen_lab FOREIGN KEY (processing_lab_sk) REFERENCES ORGANISATION(org_sk)
);

COMMENT ON TABLE SPECIMEN IS 'Biological specimens collected for laboratory analysis. SNOMED CT coded.';


-- ── LAB_RESULT ───────────────────────────────────────────────
CREATE TABLE LAB_RESULT (
    result_sk           VARCHAR(36)     NOT NULL,
    result_id           VARCHAR(100)    NOT NULL,
    specimen_sk         VARCHAR(36)     NOT NULL,   -- FK → SPECIMEN
    patient_sk          VARCHAR(36)     NOT NULL,   -- FK → PATIENT (denormalised for query performance)
    test_code           VARCHAR(30),                -- SNOMED CT concept / LOINC code
    test_name           VARCHAR(255),
    result_value_text   VARCHAR(500),               -- Free text or coded result
    result_value_num    DECIMAL(12,4),              -- Numeric result (NULL if not numeric)
    result_unit         VARCHAR(50),                -- UCUM unit of measure
    ref_range_low       DECIMAL(10,4),              -- Lower reference range
    ref_range_high      DECIMAL(10,4),              -- Upper reference range
    result_status       VARCHAR(15),                -- PRELIMINARY / FINAL / CORRECTED / CANCELLED
    is_abnormal         BOOLEAN,                    -- Outside reference range
    is_critical_value   BOOLEAN         NOT NULL,   -- Life-threatening result — triggers urgent alert
    reported_date       DATE            NOT NULL,
    requesting_clinician_sk VARCHAR(36),            -- FK → PRACTITIONER
    source_system       VARCHAR(50)     NOT NULL,
    load_date           DATE            NOT NULL,

    CONSTRAINT pk_lab_result PRIMARY KEY (result_sk),
    CONSTRAINT uq_result_source UNIQUE (result_id, source_system),
    CONSTRAINT fk_result_specimen FOREIGN KEY (specimen_sk) REFERENCES SPECIMEN(specimen_sk),
    CONSTRAINT fk_result_patient FOREIGN KEY (patient_sk) REFERENCES PATIENT(patient_sk),
    CONSTRAINT fk_result_clinician FOREIGN KEY (requesting_clinician_sk) REFERENCES PRACTITIONER(practitioner_sk),
    CONSTRAINT chk_result_status CHECK (result_status IN ('PRELIMINARY','FINAL','CORRECTED','CANCELLED','AMENDED'))
);

COMMENT ON TABLE LAB_RESULT IS 'Laboratory test results. SNOMED CT / LOINC test codes. Critical value flag triggers clinical alert.';


-- ── MEDICATION ───────────────────────────────────────────────
CREATE TABLE MEDICATION (
    medication_sk       VARCHAR(36)     NOT NULL,
    medication_id       VARCHAR(100)    NOT NULL,
    patient_sk          VARCHAR(36)     NOT NULL,   -- FK → PATIENT
    event_sk            VARCHAR(36),                -- FK → CLINICAL_EVENT
    prescriber_sk       VARCHAR(36),                -- FK → PRACTITIONER

    -- Drug Identification
    dm_plus_d_code      VARCHAR(20),                -- NHS dm+d VMPP/VMP code (mandatory for EPS)
    medication_name     VARCHAR(255),

    -- Dosage
    dose_text           VARCHAR(200),               -- Free text dose description
    dose_amount         DECIMAL(10,4),
    dose_unit           VARCHAR(30),                -- mg / ml / mcg / units
    route               VARCHAR(30),                -- ORAL / IV / IM / SC / TOPICAL / INHALED
    frequency           VARCHAR(50),                -- e.g. OD / BD / TDS / QDS / PRN

    -- Dates
    start_date          DATE,
    end_date            DATE,

    -- Prescription Type
    prescription_type   VARCHAR(20),                -- ACUTE / REPEAT / REPEAT_DISPENSING / EPS
    eps_prescription_id VARCHAR(50),                -- EPS prescription ID
    dispenser_org_sk    VARCHAR(36),                -- FK → ORGANISATION (dispensing pharmacy)

    source_system       VARCHAR(50)     NOT NULL,
    load_date           DATE            NOT NULL,

    CONSTRAINT pk_medication PRIMARY KEY (medication_sk),
    CONSTRAINT fk_medication_patient FOREIGN KEY (patient_sk) REFERENCES PATIENT(patient_sk),
    CONSTRAINT fk_medication_event FOREIGN KEY (event_sk) REFERENCES CLINICAL_EVENT(event_sk),
    CONSTRAINT fk_medication_prescriber FOREIGN KEY (prescriber_sk) REFERENCES PRACTITIONER(practitioner_sk),
    CONSTRAINT fk_medication_dispenser FOREIGN KEY (dispenser_org_sk) REFERENCES ORGANISATION(org_sk),
    CONSTRAINT chk_medication_route CHECK (route IN ('ORAL','IV','IM','SC','TOPICAL','INHALED','NASAL','OCULAR','OTHER')),
    CONSTRAINT chk_prescription_type CHECK (prescription_type IN ('ACUTE','REPEAT','REPEAT_DISPENSING','EPS','OTC'))
);

COMMENT ON TABLE MEDICATION IS 'Medications and prescriptions. dm+d coded per NHS Electronic Prescribing Service standard.';
COMMENT ON COLUMN MEDICATION.dm_plus_d_code IS 'NHS Dictionary of Medicines and Devices (dm+d) VMPP or VMP code. Mandatory for EPS submissions.';


-- ── DATA_ASSET (Governance / Data Catalogue) ─────────────────
CREATE TABLE DATA_ASSET (
    asset_sk            VARCHAR(36)     NOT NULL,
    asset_name          VARCHAR(255)    NOT NULL,
    asset_type          VARCHAR(30),                -- TABLE / VIEW / FILE / API / REPORT / DATASET / PIPELINE
    description         VARCHAR(2000),
    source_system       VARCHAR(100),
    owner_org_sk        VARCHAR(36),                -- FK → ORGANISATION (data owning org)
    data_steward        VARCHAR(150),               -- Named data steward
    data_owner          VARCHAR(150),               -- Named data owner

    -- Classification
    classification      VARCHAR(30)     NOT NULL,   -- OFFICIAL / OFFICIAL-SENSITIVE / SECRET
    sensitivity         VARCHAR(30),                -- PERSONAL / PSEUDONYMISED / ANONYMISED / NON-PERSONAL
    contains_pii        BOOLEAN         NOT NULL,
    legal_basis         VARCHAR(100),               -- UK GDPR Article 6/9 basis

    -- Retention
    retention_years     INTEGER,                    -- Per NHS Records Management Code of Practice 2021

    -- Technical
    aws_location        VARCHAR(1000),              -- S3 URI / RDS endpoint / table name
    data_standard       VARCHAR(100),               -- FHIR / HL7v2 / SNOMED CT / ICD-10 / OPCS-4 / dm+d
    is_active           BOOLEAN         NOT NULL,
    review_date         DATE,

    CONSTRAINT pk_data_asset PRIMARY KEY (asset_sk),
    CONSTRAINT fk_asset_org FOREIGN KEY (owner_org_sk) REFERENCES ORGANISATION(org_sk),
    CONSTRAINT chk_asset_classification CHECK (classification IN ('OFFICIAL','OFFICIAL-SENSITIVE','SECRET','TOP-SECRET')),
    CONSTRAINT chk_asset_sensitivity CHECK (sensitivity IN ('PERSONAL','PSEUDONYMISED','ANONYMISED','NON-PERSONAL'))
);

COMMENT ON TABLE DATA_ASSET IS 'Data catalogue entry. One row per data asset identified during discovery. Supports IG and Microsoft Purview integration.';
