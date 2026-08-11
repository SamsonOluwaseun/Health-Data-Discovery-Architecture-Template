# Step-by-Step Delivery Process
## Gov Health Data Discovery → Alpha Readiness

> **Engagement duration:** 7 weeks | **Tools:** AWS · Draw.io · Erwin Data Modeler
> Follow this guide week by week. Each step produces a tangible deliverable.

---

## WEEK 1 — Mobilisation & Stakeholder Discovery

### Step 1.1 — Engagement Setup
**What to do:**
1. Set up your GitHub repository (fork this template)
2. Create a shared project folder (SharePoint or S3 bucket) for working documents
3. Agree a governance log location with the client

**Output:** Blank repository with folder structure, shared drive access confirmed

---

### Step 1.2 — Stakeholder Mapping
**What to do:**
1. Open `templates/03_stakeholder_register.md`
2. Identify all data-producing and data-consuming teams:
   - Clinical systems teams (PAS, EPR, LIMS)
   - IG / Data Protection team
   - IT Infrastructure / Cloud team
   - Analytics / BI team
   - Programme / Project owners
3. Book 30–45 min discovery sessions with each stakeholder group

**Output:** Completed `stakeholder_register.md` — committed to your repo

**Tool:** Draw.io → open `architecture/drawio/01_current_state_architecture.drawio` and add stakeholder system owners as annotations

---

### Step 1.3 — Discovery Questionnaire Dispatch
**What to do:**
1. Open `templates/01_discovery_questionnaire.md`
2. Customise the questions for your client context
3. Send to all stakeholders **before** their interview slot

**Output:** Completed questionnaires returned — store responses in `/outputs/`

---

## WEEK 2 — Current State Landscape Assessment

### Step 2.1 — Conduct Discovery Interviews
**What to do:**
1. Use `templates/04_data_flow_interview_guide.md` to run each session
2. For each system discussed, capture:
   - System name and owner
   - Data it produces (tables, files, APIs)
   - Data it consumes (upstream dependencies)
   - Volume and frequency
   - Current storage location (on-prem / cloud / hybrid)
   - Known data quality issues

**Output:** Interview notes per stakeholder — add to `/outputs/`

---

### Step 2.2 — Build the Data Inventory
**What to do:**
1. Open `templates/02_data_inventory_register.md`
2. Populate one row per data source/system
3. Flag: data sensitivity classification, retention period, owner, format

**Output:** `outputs/sample_data_inventory.md` — your master list of all data assets

---

### Step 2.3 — Draw the Current State Architecture (Draw.io)
**What to do:**
1. Open Draw.io → [app.diagrams.net](https://app.diagrams.net)
2. File → Open from Device → select `architecture/drawio/01_current_state_architecture.drawio`
3. Populate with your discovered systems:
   - Add each source system as a box (use the Healthcare shape library)
   - Draw data flows between systems with directional arrows
   - Annotate flows with: data type, frequency, protocol (HL7 / API / SFTP / DB link)
   - Add a legend: On-Prem / Cloud / Legacy / Decommission-planned
4. Export as PNG: File → Export As → PNG → save to `/outputs/`
5. Save the `.drawio` file back to `/architecture/drawio/`

**Draw.io Tips for Healthcare:**
- Use `Extras → Edit Diagram` to paste the XML from the template directly
- Healthcare shapes: Shape Libraries → Healthcare (if available) or use standard server/database icons
- Colour code: Red = legacy risk, Amber = integration risk, Green = stable

**Output:** Completed `01_current_state_architecture.drawio` + PNG export

---

### Step 2.4 — Data Flow Diagram (Draw.io)
**What to do:**
1. Open `architecture/drawio/03_data_flow_diagram.drawio`
2. Trace end-to-end data flows for 2-3 critical health data journeys:
   - Patient demographics (PDS → Clinical system → Analytics)
   - Lab results (LIMS → Clinical portal → Reporting)
   - Referral pathway (GP system → Acute → Reporting)
3. Label each arrow with: data type, volume, frequency, protocol

**Output:** Completed `03_data_flow_diagram.drawio` + PNG export

---

## WEEK 3 — Target Architecture Design

### Step 3.1 — Define Target Architecture Principles
**What to do:**
Open `docs/discovery_report_template.md` and populate Section 4 — Architecture Principles:
- Data must flow through a single ingest layer (no direct source-to-report connections)
- All PII must be classified and masked at the landing zone
- NHS Data Standards (FHIR R4, SNOMED CT, ICD-10) to be enforced at ingestion
- Cloud-first: AWS as the primary platform
- Data governance by design — no pipeline without a data owner and classification

**Output:** Section 4 of the discovery report drafted

---

### Step 3.2 — Design the Target Architecture (Draw.io)
**What to do:**
1. Open `architecture/drawio/02_target_state_architecture.drawio`
2. Design the AWS medallion architecture:

```
Source Systems (Clinical, Admin, Lab)
        │
        ▼
[AWS Landing Zone — S3 Raw Bucket]
        │  (AWS Glue / Lambda — Validation & Classification)
        ▼
[Bronze Layer — S3 / RDS — Raw Validated Data]
        │  (AWS Glue — Transformation & Standardisation)
        ▼
[Silver Layer — AWS RDS / Redshift — Cleansed, Conformed Data]
        │  (dbt / AWS Glue — Aggregation & Business Rules]
        ▼
[Gold Layer — Redshift — Analytics-Ready Data Mart]
        │
        ▼
[Reporting / Consumption — QuickSight / Power BI / API]
```

3. Add: governance overlay (AWS Lake Formation), security layer (IAM, KMS), monitoring (CloudWatch)
4. Export PNG

**Output:** Completed `02_target_state_architecture.drawio` + PNG export

---

### Step 3.3 — AWS Services Design
**What to do:**
1. Open `architecture/aws/aws_target_architecture.md`
2. Map each architecture layer to specific AWS services
3. Add IAM roles, VPC configuration, and encryption requirements

**Output:** Completed `aws_target_architecture.md`

---

### Step 3.4 — Integration Patterns (Draw.io)
**What to do:**
1. Open `architecture/drawio/04_integration_patterns.drawio`
2. Document the 3-4 integration patterns in use or planned:
   - Batch file transfer (SFTP → S3)
   - API integration (REST/HL7 FHIR → API Gateway → Lambda → S3)
   - Database replication (RDS → DMS → Redshift)
   - Event-driven (SNS/SQS for real-time clinical alerts)

**Output:** Completed `04_integration_patterns.drawio`

---

## WEEK 4 — Data Modelling with Erwin

### Step 4.1 — Conceptual Data Model (Erwin)
**What to do:**
1. Read `data-modelling/erwin/ERWIN_GUIDE.md` first
2. Open Erwin Data Modeler
3. Create a new Logical/Physical model
4. Build the Conceptual Model — high-level entities only:
   - PATIENT, ORGANISATION, CLINICAL_EVENT, REFERRAL, SAMPLE, RESULT, PRACTITIONER
5. Draw relationships between entities
6. Export as image: File → Export → Image → save to `/outputs/`
7. Save the `.erwin` file to `/data-modelling/erwin/`

---

### Step 4.2 — Reverse Engineer DDL into Erwin
**What to do:**
1. Open `data-modelling/ddl/01_conceptual_entities.sql`
2. In Erwin: Actions → Reverse Engineer → Database → Select SQL Server or PostgreSQL
3. Paste or point to the DDL file
4. Review generated model — add relationships and cardinality
5. Promote to Logical model in Erwin (right-click → Go To Logical)

**Output:** Logical model in Erwin with all entities, attributes, and relationships

---

### Step 4.3 — Physical Data Model (Erwin → DDL)
**What to do:**
1. In Erwin, switch to Physical Model view
2. Map logical entities to physical tables:
   - Add data types (VARCHAR, INT, TIMESTAMP, UUID)
   - Add primary keys, foreign keys, indexes
   - Apply naming conventions: `tbl_`, `fk_`, `idx_`
3. Generate DDL: Actions → Generate Database Schema → PostgreSQL
4. Save output to `data-modelling/ddl/03_physical_data_model.sql`

**Output:** Physical DDL script ready to deploy to AWS RDS

---

## WEEK 5 — Data Governance Framework

### Step 5.1 — Data Classification Assessment
**What to do:**
1. Open `governance/data_classification_policy.md`
2. For every data asset in your inventory, assign:
   - Classification: OFFICIAL / OFFICIAL-SENSITIVE / SECRET
   - Sensitivity: PII / Pseudonymised / Anonymised / Non-personal
   - Retention period (per NHS Records Management Code of Practice)
   - Data owner (team, not individual)

**Output:** Completed `data_classification_policy.md`

---

### Step 5.2 — Record of Processing Activities (RoPA)
**What to do:**
1. Open `governance/ropa_template.md`
2. Complete one row per data processing activity
3. For each: processing purpose, legal basis (UK GDPR Article 6/9), data types, recipients, retention, security measures

**Output:** Draft RoPA for IG review

---

### Step 5.3 — Data Quality Assessment
**What to do:**
1. Open `governance/data_quality_assessment.md`
2. For each source system, score against 6 dimensions:
   - Completeness, Accuracy, Consistency, Timeliness, Uniqueness, Validity
3. Flag critical quality issues that block Alpha
4. Define remediation actions and owners

**Output:** Data quality scorecard per system

---

## WEEK 6 — Migration Strategy

### Step 6.1 — Data Mapping
**What to do:**
1. Open `migration/data_mapping_template.md`
2. For each source system → target table, document:
   - Source field name → Target field name
   - Data type transformation
   - Transformation rule (direct copy / lookup / derived / drop)
   - Null handling
   - Validation rule

**Output:** Completed data mapping document per source system

---

### Step 6.2 — Migration Strategy Document
**What to do:**
1. Open `migration/migration_strategy.md`
2. Decide and document:
   - Migration approach: Big Bang / Phased / Parallel Run
   - AWS migration services: AWS DMS, AWS Glue, S3 Transfer
   - Cutover plan: freeze point, validation, go-live
   - Rollback plan

**Output:** Completed `migration_strategy.md`

---

### Step 6.3 — Risk Register
**What to do:**
1. Open `migration/migration_risk_register.md`
2. Log every identified risk:
   - Data loss during migration
   - Legacy system unavailability
   - Schema mismatches
   - PII exposure during transit
3. Assign: Likelihood (1-5), Impact (1-5), Mitigation, Owner

**Output:** Completed risk register

---

## WEEK 7 — Alpha Readiness

### Step 7.1 — Complete the Discovery Report
**What to do:**
1. Open `docs/discovery_report_template.md`
2. Populate all sections using outputs from weeks 1-6
3. Key sections:
   - Executive Summary
   - Current State Assessment
   - Target Architecture
   - Gap Analysis
   - Governance Framework
   - Migration Approach
   - Alpha Readiness Recommendations

**Output:** Draft discovery report (Word/PDF) — share for stakeholder review

---

### Step 7.2 — Alpha Readiness Checklist
**What to do:**
1. Open `templates/05_alpha_readiness_checklist.md`
2. Complete every item — mark: ✅ Ready / ⚠️ In Progress / ❌ Blocker
3. For each blocker, define: Owner, Resolution date, Dependency

**Output:** Alpha readiness assessment — presented to programme board

---

### Step 7.3 — Commit Everything to GitHub
**What to do:**
```bash
git add .
git commit -m "feat: complete discovery phase deliverables — [client/engagement name]"
git push origin main
```

**Optional — tag the release:**
```bash
git tag -a v1.0-discovery -m "Discovery phase complete — Alpha ready"
git push origin v1.0-discovery
```

---

## Deliverables Summary

| Week | Deliverable | File Location |
|------|------------|---------------|
| 1 | Stakeholder Register | `outputs/stakeholder_register.md` |
| 1 | Discovery Questionnaire (completed) | `outputs/discovery_questionnaires/` |
| 2 | Data Inventory Register | `outputs/data_inventory.md` |
| 2 | Current State Architecture Diagram | `outputs/current_state_architecture.png` |
| 2 | Data Flow Diagram | `outputs/data_flow_diagram.png` |
| 3 | Target Architecture Diagram | `outputs/target_state_architecture.png` |
| 3 | AWS Services Map | `architecture/aws/aws_target_architecture.md` |
| 3 | Integration Patterns Diagram | `outputs/integration_patterns.png` |
| 4 | Conceptual Data Model (Erwin) | `data-modelling/erwin/conceptual_model.erwin` |
| 4 | Physical DDL Script | `data-modelling/ddl/03_physical_data_model.sql` |
| 5 | Data Classification Policy | `governance/data_classification_policy.md` |
| 5 | Record of Processing Activities | `governance/ropa_template.md` |
| 5 | Data Quality Assessment | `governance/data_quality_assessment.md` |
| 6 | Data Mapping Document | `migration/data_mapping_template.md` |
| 6 | Migration Strategy | `migration/migration_strategy.md` |
| 6 | Risk Register | `migration/migration_risk_register.md` |
| 7 | Discovery Report | `docs/discovery_report_template.md` |
| 7 | Alpha Readiness Checklist | `outputs/alpha_readiness_checklist.md` |
