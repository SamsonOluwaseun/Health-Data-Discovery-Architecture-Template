# Glossary
## Gov Health Data Discovery Template
### Health Data, Governance, Architecture & AWS Terms

---

## A

**A&E** — Accident and Emergency. Unplanned urgent care setting. Data submitted via ECDS (Emergency Care Data Set) to NHSE.

**ADR** — Architecture Decision Record. A document recording a significant architectural decision, its context, and the rationale.

**Alpha (GDS Phase)** — The second phase of GDS delivery. Builds and tests prototypes. Follows Discovery. Precedes Beta.

**Anonymisation** — Process of removing or transforming data so individuals cannot be re-identified. ICO "motivated intruder" test applies. Anonymised data is not personal data under UK GDPR.

**API Gateway (AWS)** — Managed AWS service for creating, publishing, and securing APIs. Used in this template to expose FHIR R4 endpoints.

**AWS** — Amazon Web Services. Cloud platform used for the target data architecture in this template.

---

## B

**Bronze Layer** — First tier of the Medallion architecture. Holds raw, unprocessed data as ingested from source systems. No transformations applied. Data is immutable.

**BYOID** — Bring Your Own Identity. Pattern where existing NHS login credentials (NHS Login, NHS Staff Identity) are used for platform access.

---

## C

**Caldicott Guardian** — A senior NHS professional responsible for protecting patient information and enabling appropriate information sharing. A statutory role.

**Caldicott Principles** — Seven (now eight) principles governing the use of patient-identifiable data in health and social care. The eighth principle: duty to share information can be as important as the duty to protect it.

**CDC** — Change Data Capture. Technique for tracking row-level changes (inserts, updates, deletes) in a source database. Used by AWS DMS for ongoing replication.

**CDM** — Conceptual Data Model. The highest-level data model showing key business entities and relationships only. No technical detail.

**CDS** — Commissioning Data Set. The set of data items collected at point of care and submitted to the NHS for planning and payment purposes.

**Clinical Event** — Any healthcare encounter between a patient and a healthcare provider (inpatient, outpatient, A&E, community).

**CloudTrail (AWS)** — AWS service that logs every API call made in an AWS account. Used for security auditing and compliance evidence (DSPT).

**CloudWatch (AWS)** — AWS monitoring service for metrics, logs, alarms. Used to monitor DMS replication lag, Glue job failures, RDS performance.

---

## D

**Data Asset** — Any data source, dataset, table, file, report, or API that holds or produces data. Catalogued in the Data Asset Register.

**Data Catalogue** — A directory of all data assets, their metadata, classifications, owners, and quality scores. Implemented via AWS Glue Data Catalog.

**Data Owner** — The senior individual accountable for a data domain. Sets policy; approves access; accountable for quality.

**Data Steward** — The individual responsible for day-to-day data quality, governance, and cataloguing for a specific dataset.

**Discovery (GDS Phase)** — The first phase of GDS delivery. Focuses on understanding the problem space, user needs, and data landscape. Precedes Alpha.

**dm+d** — Dictionary of Medicines and Devices. NHS coding system for medicines and medical devices. Used for prescribing and dispensing. Mandatory for Electronic Prescribing Service (EPS).

**DMS (AWS Database Migration Service)** — AWS managed service for database migration and ongoing replication. Supports full load + CDC from SQL Server, Oracle, PostgreSQL, MySQL.

**DPA 2018** — Data Protection Act 2018. UK legislation that implements and supplements UK GDPR.

**DPIA** — Data Protection Impact Assessment. Mandatory under UK GDPR for high-risk processing activities involving personal data.

**DPO** — Data Protection Officer. Statutory role under UK GDPR. Advises on compliance; supervises the RoPA; handles ICO enquiries.

**DSPT** — Data Security and Protection Toolkit. NHS self-assessment framework for data security standards. Annual submission required.

---

## E

**ECDS** — Emergency Care Data Set. The national dataset for unscheduled (A&E) care.

**EPR** — Electronic Patient Record. Clinical system holding patient clinical information (diagnoses, medications, notes). Distinct from PAS.

**e-RS** — Electronic Referral Service. NHS national system (previously Choose and Book) for managing GP-to-specialist referrals. Generates UBRN.

**ETL** — Extract, Transform, Load. The process of extracting data from source systems, transforming it to the target format, and loading it to the destination.

---

## F

**FHIR** — Fast Healthcare Interoperability Resources. HL7 standard for exchanging healthcare information electronically. FHIR R4 is the current NHS England-mandated version.

**FK** — Foreign Key. A field in one table that references the primary key of another, enforcing referential integrity.

---

## G

**GDS** — Government Digital Service. UK government body that sets digital service standards. GDS Service Manual defines Discovery, Alpha, Beta, Live phases.

**Glue (AWS)** — Serverless ETL service. Used for data transformation between Bronze, Silver, and Gold layers.

**Gold Layer** — Third tier of the Medallion architecture. Analytics-ready, aggregated, business-rule-applied data. Served to dashboards and reporting tools.

**GP Connect** — NHS API standard for accessing GP system data (appointments, records) via FHIR.

**GSC** — Government Security Classification. UK government data classification: OFFICIAL, OFFICIAL-SENSITIVE, SECRET, TOP SECRET.

**GuardDuty (AWS)** — AWS threat detection service. Detects malicious activity and unauthorised behaviour based on CloudTrail, VPC flow logs, and DNS logs.

---

## H

**HES** — Hospital Episode Statistics. The national collection of inpatient and outpatient hospital activity data in England.

**HL7** — Health Level Seven. International standards organisation for healthcare data exchange. HL7 v2 (legacy) and HL7 FHIR R4 (modern).

**HRG** — Healthcare Resource Group. NHS activity classification used for costing and payment (NHS tariff). HRG4+ is the current version.

---

## I

**IAM (AWS)** — Identity and Access Management. AWS service for managing users, roles, and permissions.

**ICD-10** — International Classification of Diseases, 10th Revision. Standard coding for diagnoses. Used in clinical coding and HES submissions.

**ICO** — Information Commissioner's Office. UK data protection regulator.

**IG** — Information Governance. The policies, processes, and standards governing how information is handled.

---

## K

**KMS (AWS)** — Key Management Service. AWS service for creating and managing encryption keys. Used for SSE-KMS encryption on S3 and RDS.

---

## L

**Lake Formation (AWS)** — AWS service providing fine-grained access control (row and column level) on data stored in S3 / Glue Data Catalog.

**LDM** — Logical Data Model. Second level of data modelling. Contains all entities, attributes, data types, and relationships. No physical optimisations.

**LIMS** — Laboratory Information Management System. Clinical system managing specimens and lab test results.

**LOINC** — Logical Observation Identifiers Names and Codes. International standard for laboratory test codes. Used alongside SNOMED CT.

**Luhn Algorithm** — Checksum formula used to validate NHS Numbers (10-digit patient identifier).

---

## M

**Macie (AWS)** — Amazon Macie. Service that uses machine learning to discover and protect sensitive data (PII) in S3 buckets.

**MDM** — Master Data Management. Processes and tools to ensure consistent, accurate, and unified key data (e.g. patient, organisation) across systems.

**Medallion Architecture** — Layered data architecture pattern: Bronze (raw) → Silver (conformed) → Gold (analytics-ready).

**MPI** — Master Patient Index. A single trusted record of all patients, used to link records across systems. NHS Number is the enterprise MPI key.

---

## N

**NHS Number** — 10-digit national patient identifier. The enterprise patient key across all NHS systems. Must be Luhn-validated.

**NHSE** — NHS England. National body responsible for overseeing NHS commissioning, data standards, and national collections.

**NHSD** — NHS Digital (now part of NHS England). Previously responsible for national IT and data standards.

**NMDS** — National Minimum Data Set. Minimum data requirements for national submissions.

---

## O

**ODS** — Organisation Data Service. NHS service that maintains the reference list of NHS organisations with their ODS codes.

**ODS Code** — Unique identifier for an NHS organisation. The enterprise key for ORGANISATION entities.

**OPCS-4** — Office of Population Censuses and Surveys Classification of Surgical Operations and Procedures. Coding for surgical and non-surgical procedures in NHS clinical coding.

---

## P

**PAS** — Patient Administration System. System managing patient registration, admissions, and administrative clinical data. Distinct from EPR.

**PDS** — Personal Demographics Service. NHS national master index of patient demographics. Authoritative source of NHS Number, name, DOB, address.

**PDM** — Physical Data Model. Third level of data modelling. Contains database-specific DDL, indexes, constraints, physical storage details.

**PII** — Personally Identifiable Information. Any data that can identify a living individual.

**Pseudonymisation** — Replacement of direct identifiers with a token (pseudonym). Data remains personal under UK GDPR as re-identification is possible with the key.

---

## R

**RDS (AWS)** — Relational Database Service. Managed relational database. Used for Silver layer storage (PostgreSQL 15).

**Redshift (AWS)** — AWS cloud data warehouse. Used for Gold layer analytics-ready data marts.

**RMCOP** — Records Management Code of Practice (2021). NHS guidance on retention and disposal of health records.

**RoPA** — Record of Processing Activities. UK GDPR Article 30 requirement. Documents all personal data processing activities.

**RPO** — Recovery Point Objective. Maximum acceptable amount of data loss in a disaster scenario (time-based).

**RTO** — Recovery Time Objective. Maximum acceptable downtime in a disaster scenario.

**RTT** — Referral to Treatment. The NHS 18-week standard from referral to first definitive treatment.

---

## S

**Secrets Manager (AWS)** — AWS service for storing and automatically rotating secrets (database passwords, API keys).

**Silver Layer** — Second tier of the Medallion architecture. Cleansed, conformed, and standardised data. NHS coding applied (ICD-10, SNOMED, dm+d).

**SIRO** — Senior Information Risk Owner. Executive accountable for information risk across the organisation.

**SNOMED CT** — Systematized Nomenclature of Medicine — Clinical Terms. Comprehensive clinical terminology for clinical records. Used in EPR coding and FHIR resources.

**SSE-KMS** — Server-Side Encryption with AWS KMS. Encrypts S3 objects using KMS-managed customer keys.

**Step Functions (AWS)** — AWS workflow orchestration service. Used to sequence ETL pipeline steps with error handling and retry logic.

**SUS** — Secondary Uses Service. The central NHS repository for health and care activity data. Source of HES.

---

## T

**TLS** — Transport Layer Security. Encryption protocol for data in transit. TLS 1.2+ required for all NHS data connections.

---

## U

**UBRN** — Unique Booking Reference Number. Generated by NHS e-Referral Service for each referral.

**UK GDPR** — UK General Data Protection Regulation. UK data protection law (retained EU GDPR, amended post-Brexit). Enforced by ICO.

**UCUM** — Unified Code for Units of Measure. Standard for measurement units in healthcare (lab results).

---

## V

**VPC** — Virtual Private Cloud. Isolated network within AWS. All data platform resources run in private subnets with no public internet exposure.

---

*Gov Health Discovery Template | Glossary | v0.1 | [Date]*
