# Physical Data Model DDL Guide
## Gov Health Data Discovery Template
### Version 0.1 | [Date]

> **Purpose:** This guide explains the DDL files in `/data-modelling/ddl/`, how they relate to each other, how to use them with Erwin, and how to deploy them to AWS RDS.

---

## The Three DDL Files Explained

| File | Level | Purpose | Run Against |
|------|-------|---------|------------|
| `01_conceptual_entities.sql` | Conceptual | Business entity definitions — import into Erwin to build the CDM. No physical detail. | Erwin reverse engineer only — not for direct deployment |
| `02_logical_data_model.sql` | Logical | All attributes, data types, relationships — the full data model without physical optimisations | Erwin review and validation |
| `03_physical_data_model.sql` | Physical | Production-ready PostgreSQL DDL — schemas, indexes, constraints, generated columns | AWS RDS PostgreSQL 15+ |

---

## File 1 — Conceptual Entities (`01_conceptual_entities.sql`)

**What it is:** Simplified CREATE TABLE statements representing business entities with basic column names and NHS commentary. No production data types, no indexes, no constraints.

**How to use:**
1. Open Erwin → **Actions → Reverse Engineer → Script File**
2. Select this file
3. Erwin generates entity boxes from the `CREATE TABLE` statements
4. Use as your starting point for the CDM

**What you get in Erwin:** 9 entity boxes — PATIENT, ORGANISATION, CLINICAL_EVENT, REFERRAL, SPECIMEN, LAB_RESULT, PRACTITIONER, MEDICATION, DATA_ASSET

---

## File 2 — Logical Data Model (`02_logical_data_model.sql`)

**What it is:** Full attribute-level definitions with NHS Data Dictionary column names, data types aligned to logical standards (no physical PostgreSQL-specific features), foreign key relationships, and comments.

**How to use:**
1. Open Erwin → **Actions → Reverse Engineer → Script File**
2. Select this file
3. Review the generated logical model
4. Add business definitions to each attribute in Erwin (double-click → Definition tab)
5. Export logical model diagram: **File → Export → Image → PNG**
6. Save as: `outputs/ldm_diagram.png`

**How to get from Logical to Physical in Erwin:**
1. In Erwin, right-click the model → **Model Properties**
2. Set target database: **PostgreSQL 15**
3. **Actions → Transform → Logical to Physical**
4. Erwin generates the physical model with PostgreSQL-specific data types
5. Review and adjust (add indexes, partitioning, compression)
6. **Actions → Generate Database Schema** → save as `03_physical_data_model.sql`

---

## File 3 — Physical Data Model (`03_physical_data_model.sql`)

**What it is:** Production-ready PostgreSQL DDL. This is the definitive deployable script for the AWS RDS Silver layer. It includes:

- `silver`, `gold`, and `governance` schemas
- UUID primary keys (`uuid_generate_v4()`)
- Generated columns (age_band, length_of_stay_days, rtt_weeks_elapsed, breach_flag)
- NHS-specific CHECK constraints (sex values, event types, result statuses)
- Foreign key relationships across all entities
- Optimised indexes for analytics query patterns
- `governance.data_quality_log` and `governance.audit_log` tables

### Deployment Instructions

#### Step 1 — Connect to AWS RDS
```bash
# Using psql (install psql locally or use AWS Cloud Shell)
psql \
  --host=[your-rds-endpoint].rds.amazonaws.com \
  --port=5432 \
  --username=govhealth_admin \
  --dbname=govhealth
```

#### Step 2 — Run Extensions First
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
```

#### Step 3 — Run the Full DDL Script
```bash
psql \
  --host=[rds-endpoint] \
  --port=5432 \
  --username=govhealth_admin \
  --dbname=govhealth \
  --file=data-modelling/ddl/03_physical_data_model.sql
```

#### Step 4 — Verify Deployment
```sql
-- Check all tables created
SELECT schemaname, tablename
FROM pg_tables
WHERE schemaname IN ('silver','gold','governance')
ORDER BY schemaname, tablename;

-- Check indexes
SELECT schemaname, tablename, indexname
FROM pg_indexes
WHERE schemaname = 'silver'
ORDER BY tablename;

-- Check foreign keys
SELECT
    tc.table_schema,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_schema = 'silver';
```

---

## Generated Columns — How They Work

The physical DDL uses PostgreSQL GENERATED ALWAYS AS STORED columns. These compute automatically and are stored on disk:

| Column | Table | Formula | Business Use |
|--------|-------|---------|-------------|
| `age_band` | `silver.patient` | 10-year age bands from DOB | Epidemiology / population analytics |
| `length_of_stay_days` | `silver.clinical_event` | `discharge_date - admission_date` | Operational efficiency KPI |
| `rtt_weeks_elapsed` | `silver.referral` | Weeks from RTT start to stop (or today) | RTT monitoring dashboard |
| `breach_flag` | `silver.referral` | TRUE if > 18 weeks elapsed | NHSE 18-week standard monitoring |

These columns update automatically when underlying source columns are updated — no ETL needed to maintain them.

---

## Index Strategy

Indexes are built for the most common analytical query patterns:

| Index | Column | Query Pattern Served |
|-------|--------|---------------------|
| `idx_patient_nhs` | `nhs_number` | Patient lookup by NHS Number |
| `idx_patient_dob` | `date_of_birth` | Age-band filtering |
| `idx_event_admission` | `admission_date` | Date range queries on episodes |
| `idx_event_specialty` | `specialty_code` | Specialty-level reporting |
| `idx_referral_rtt_start` | `rtt_start_date` | RTT pathway analysis |
| `idx_referral_breach` | `breach_flag` WHERE TRUE | Fast breach-only queries |
| `idx_result_critical` | `is_critical_value` WHERE TRUE | Critical result monitoring |
| `idx_result_reported` | `reported_date` | Time-series lab analytics |

**Partial indexes** (WHERE clause) are used for `breach_flag` and `is_critical_value` because most records will be FALSE — indexing only TRUE values keeps the index tiny and fast.

---

## Adding New Entities

When discovery reveals additional data sources:

1. Add a `CREATE TABLE` to `01_conceptual_entities.sql` (entity definition)
2. Add the full attribute definition to `02_logical_data_model.sql`
3. Add the production DDL to `03_physical_data_model.sql`
4. Re-import into Erwin and update the model
5. Commit all three files together with a message: `feat: add [entity] table — [system] source`

---

## Naming Convention Quick Reference

| Object | Convention | Example |
|--------|-----------|---------|
| Schema | Lowercase | `silver`, `gold`, `governance` |
| Table | Singular noun, `snake_case` | `clinical_event`, `lab_result` |
| Surrogate key | `[table]_sk` | `patient_sk`, `event_sk` |
| Business key | Meaningful name | `nhs_number`, `ods_code` |
| Foreign key | `[referenced_table]_sk` | `patient_sk` (in clinical_event) |
| Index | `idx_[table]_[column]` | `idx_event_admission` |
| Check constraint | `chk_[table]_[rule]` | `chk_patient_sex` |
| Unique constraint | `uq_[table]_[column]` | `uq_patient_nhs_number` |

---

*Gov Health Discovery Template | Physical DDL Guide | v0.1*
