# Erwin Data Modeler — Guide for This Engagement
## Gov Health Data Discovery Template

---

## Overview

This guide explains how to use **Erwin Data Modeler** to build and maintain the three levels of data model required for a Gov Health discovery engagement:

1. **Conceptual Data Model (CDM)** — business entities and relationships, no technical detail
2. **Logical Data Model (LDM)** — all attributes, data types, relationships, keys
3. **Physical Data Model (PDM)** — database-specific DDL, indexes, constraints, partitioning

All three models are maintained in Erwin and flow from one level to the next via the **Model Transformation** feature.

---

## Step 1 — Set Up Your Erwin Project

1. Open **Erwin Data Modeler** (r9.x or later)
2. **File → New Model**
3. Choose: **Logical/Physical**
4. Target Database: **PostgreSQL 15**
5. Notation: **IE (Information Engineering)** — standard for NHS/Gov environments
6. Save as: `govhealth_[engagement_name]_v[version].erwin`
   - e.g. `govhealth_discovery_v0.1.erwin`
6. Store in: `/data-modelling/erwin/`

---

## Step 2 — Build the Conceptual Model

**Option A — Import from DDL (recommended):**

1. In Erwin: **Actions → Reverse Engineer**
2. Select: **Script File**
3. Browse to: `data-modelling/ddl/01_conceptual_entities.sql`
4. Database: **PostgreSQL**
5. Click **Reverse Engineer**
6. Erwin will generate entities from the `CREATE TABLE` statements

**Option B — Draw manually:**

1. From the toolbar, select the **Entity** tool
2. Click on the canvas to place entities: PATIENT, ORGANISATION, CLINICAL_EVENT, REFERRAL, SPECIMEN, LAB_RESULT, PRACTITIONER, MEDICATION, DATA_ASSET
3. Use the **Relationship** tool to draw lines between entities
4. Set relationship cardinality (one-to-many, many-to-many)

**Conceptual Relationships to draw:**

```
PATIENT ──< CLINICAL_EVENT    (one patient : many events)
PATIENT ──< REFERRAL           (one patient : many referrals)
PATIENT ──< SPECIMEN           (one patient : many specimens)
SPECIMEN ──< LAB_RESULT        (one specimen : many results)
ORGANISATION ──< CLINICAL_EVENT (one org : many events)
PRACTITIONER ──< CLINICAL_EVENT (one practitioner : many events)
CLINICAL_EVENT ──< MEDICATION  (one event : many medications)
```

---

## Step 3 — Add Logical Detail

1. Switch to **Logical View**: View → Logical
2. For each entity, double-click to open properties
3. Add attributes with:
   - **Attribute name** (business name — e.g. "NHS Number")
   - **Domain** (set up domains for NHS codes: NHS_NUMBER, ODS_CODE, ICD10_CODE, SNOMED_CODE)
   - **Data type** (Logical types: String, Integer, Date, Boolean)
   - **Nullability** (Is this mandatory?)
   - **Primary Key** flag
   - **Definition** (business definition — what this field means)

**NHS-specific Domains to create in Erwin:**

| Domain Name | Logical Type | Definition |
|------------|-------------|-----------|
| NHS_NUMBER | VARCHAR(10) | 10-digit NHS Number per NHS DD |
| ODS_CODE | VARCHAR(10) | NHS ODS Organisation Code |
| ICD10_CODE | VARCHAR(10) | ICD-10 diagnosis code (4 chars) |
| OPCS4_CODE | VARCHAR(10) | OPCS-4 procedure code |
| SNOMED_CONCEPT | VARCHAR(20) | SNOMED CT concept identifier |
| ETHNIC_CODE | VARCHAR(5) | NHS 2001 Ethnic Category Code |
| SPECIALTY_CODE | VARCHAR(10) | National specialty code |

**To create a Domain:**
Edit → Domains → New Domain → fill in name, parent type, default length

---

## Step 4 — Generate Physical Model

1. Switch to **Physical View**: View → Physical
2. Erwin auto-maps logical types to PostgreSQL physical types
3. Review and adjust:
   - VARCHAR lengths
   - NOT NULL constraints
   - Check constraints
   - Index definitions
4. Add indexes: right-click on entity → Indexes → Add Index
5. Name convention: `idx_[table]_[column]`

---

## Step 5 — Generate DDL from Erwin

1. **Actions → Generate Database Schema**
2. Database type: **PostgreSQL 15**
3. Schema: `silver`
4. Options: ✅ Include DROP IF EXISTS, ✅ Include Comments, ✅ Include Indexes
5. Output to: `data-modelling/ddl/03_physical_data_model.sql`
6. Review generated DDL — compare with the template file in this repo

---

## Step 6 — Export Diagrams

For each model level, export as an image to include in the Discovery Report:

1. **File → Export → Image**
2. Format: **PNG** (high resolution, 150+ DPI)
3. Save to: `outputs/`
   - `outputs/cdm_diagram.png` — conceptual
   - `outputs/ldm_diagram.png` — logical
   - `outputs/pdm_diagram.png` — physical

---

## Step 7 — Reverse Engineer from Existing Database

If the client has an existing database you can connect to:

1. **Actions → Reverse Engineer**
2. Select: **Database (Live Connection)**
3. Connection type: **PostgreSQL / SQL Server / Oracle**
4. Enter connection string (use read-only credentials)
5. Select schemas/tables to include
6. Click **Reverse Engineer**

This generates a physical model from the existing schema — useful for documenting the current state.

---

## Naming Conventions for This Engagement

| Object Type | Convention | Example |
|------------|-----------|---------|
| Tables | Singular noun, UPPER_SNAKE_CASE | `PATIENT`, `CLINICAL_EVENT` |
| Columns | Lower_snake_case | `nhs_number`, `admission_date` |
| Primary Keys | `[table]_sk` (surrogate) | `patient_sk` |
| Business Keys | `[attribute]_bk` or named | `nhs_number` |
| Foreign Keys | `fk_[table]_[ref_table]` | `fk_event_patient` |
| Indexes | `idx_[table]_[column]` | `idx_patient_nhs` |
| Surrogate Keys | UUID (uuid_generate_v4()) | Standard across all entities |

---

## Tips for Gov Health Modelling in Erwin

- **Always define business definitions** on every attribute — this is your data dictionary
- **Use NHS Data Dictionary names** where they exist — makes NHSE/NHSD reporting alignment easier
- **Tag sensitive attributes** using Erwin's property tags: add a custom property `Sensitivity` with values PERSONAL / PSEUDONYMISED / ANONYMISED
- **Version your Erwin file** in Git using meaningful commit messages: `feat: add REFERRAL entity with RTT attributes`
- **Do not store the .erwin binary alone** — always export DDL and PNG alongside it so the model is readable without Erwin installed
