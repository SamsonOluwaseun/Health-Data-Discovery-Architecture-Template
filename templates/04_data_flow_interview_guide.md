# Data Flow Interview Guide
## Gov Health Data Discovery Template
### Structured Interview Scripts for Data Architecture Discovery

> **Purpose:** Use these scripts to run structured 45-minute discovery sessions with each stakeholder group. Record answers in the `outputs/` folder per stakeholder. Follow up with the `01_discovery_questionnaire.md` responses the stakeholder pre-completed.

---

## Before Every Interview

**Checklist:**
- [ ] Pre-read the completed questionnaire for this stakeholder
- [ ] Review any existing system documentation you have
- [ ] Have the data inventory register open to fill in live
- [ ] Set up recording (with consent) or have a note-taker
- [ ] Open Draw.io current state diagram to annotate live

**Standard Opening (use for ALL sessions):**
> *"Thank you for your time. I'm the lead Data Architect for this discovery engagement. The goal of today's session is to understand the data your team works with — what systems hold it, how it moves, who uses it, and any quality or governance concerns. Everything you share helps us design a platform that actually works for you. There are no wrong answers. Ready to start?"*

---

## Interview Script A — IT / Systems / DBA Teams

**Duration:** 45 minutes | **Audience:** System Administrators, DBAs, Infrastructure leads
**Goal:** Technical system detail — schemas, volumes, connectivity, dependencies

### Section 1 — System Inventory (10 mins)

**Q1:** Walk me through the main systems your team manages that hold health or operational data.
> *Probe: For each system — what's the name, the underlying technology, the version, and how long has it been running?*

**Q2:** Which of these systems are on-premises, which are cloud-hosted, and which are a mix?
> *Note: Flag any AWS, Azure, or cloud-adjacent systems already in use*

**Q3:** What is the database engine and version for each system?
> *Record: SQL Server / Oracle / PostgreSQL / MySQL / other + version number*

**Q4:** How many tables are in each database? Any idea of the largest tables by row count?
> *Probe: Any tables with > 10 million rows? Any with particularly complex structures — nested JSON, XML columns, BLOBs?*

**Q5:** Is there existing schema documentation (ERDs, data dictionaries) for any of these systems? Can you share it?

---

### Section 2 — Data Flows and Integrations (15 mins)

**Q6:** For each system — what data does it receive from other systems, and what does it send out?
> *Draw on the diagram live as they answer*

**Q7:** How are those data flows implemented?
> *Options to listen for: direct DB link / SQL Server linked server / SSIS / SFTP / REST API / manual export / ETL tool / stored procedure*

**Q8:** Are any of these integrations documented? Do you have a data flow diagram or an integration register?

**Q9:** Are there any direct database-to-database links (SQL linked servers, Oracle DBLinks) between systems?
> *Critical — these are often undocumented and create hidden dependencies*

**Q10:** Are there any ad-hoc or workaround data flows you're aware of? Things like: someone running a SQL extract and emailing it, a shared spreadsheet used as a data bridge, a scheduled task no one set up officially?
> *Listen carefully — these reveal shadow IT and uncontrolled PII*

**Q11:** What network infrastructure connects these systems? Is there a firewall between them? Any VPN or dedicated network segment?

---

### Section 3 — Performance and Constraints (10 mins)

**Q12:** Which systems are under the most performance pressure? Any that are slow, frequently failing, or struggling with capacity?

**Q13:** Are any systems approaching end of life, out of support, or scheduled for replacement?

**Q14:** What are the backup and recovery arrangements for each system? RPO / RTO if known?

**Q15:** Do you have any network bandwidth constraints that might affect a migration from on-prem to AWS?
> *Record: Available bandwidth to internet / to AWS Direct Connect / to partner networks*

---

### Section 4 — Access and Security (5 mins)

**Q16:** Who currently has access to each database? Is access role-based or individual?

**Q17:** Are database credentials shared between applications? Are they stored in config files or a secrets management tool?

**Q18:** Is there any encryption of data at rest on the current systems? TLS for connections?

---

### Section 5 — Wrap-Up (5 mins)

**Q19:** What are the biggest technical risks you see with migrating this data to a cloud platform?

**Q20:** Is there anything we haven't asked about that you think we should know?

---

## Interview Script B — Information Governance / IG / Caldicott

**Duration:** 45 minutes | **Audience:** DPO, IG Lead, Caldicott Guardian, Data Protection team
**Goal:** Legal basis, classification, consent, compliance obligations, IG risks

### Section 1 — Governance Overview (10 mins)

**Q1:** Walk me through the current IG governance structure. Who are the key roles — SIRO, Caldicott Guardian, DPO, data owners?

**Q2:** Is there a current RoPA (Record of Processing Activities)? Is it complete and up to date?

**Q3:** What is the organisation's current DSPT (Data Security and Protection Toolkit) rating? Are there any mandatory assertions that are failing or at risk?

**Q4:** What NHS data sharing agreements are currently in place? Who manages them?

---

### Section 2 — Patient Data (15 mins)

**Q5:** For each source system holding patient data — what is the legal basis for processing?
> *Listen for: Art 6(1)(c) legal obligation, Art 6(1)(e) public task, Art 9(2)(h) healthcare*

**Q6:** Are patients informed about how their data is used? Are privacy notices up to date?

**Q7:** Does any processing of patient data require a DPIA (Data Protection Impact Assessment)? Has one been done? Can we see it?

**Q8:** What patient data flows outside the organisation? To NHSE, ICBs, CCGs, researchers?
> *For each: is there a DSA? Is it current? Who holds it?*

**Q9:** Has the Caldicott Guardian been engaged on the planned data platform? What approvals will be required?

**Q10:** Is there any patient data currently stored in uncontrolled locations — shared drives, personal devices, email attachments?

---

### Section 3 — Classification and Retention (10 mins)

**Q11:** Has data classification been applied across all data assets? What classification framework is used — GSC (OFFICIAL / OFFICIAL-SENSITIVE)?

**Q12:** Are retention periods defined and enforced for each data type? Are they aligned to the NHS Records Management Code of Practice 2021?

**Q13:** How is data deletion currently managed? Is there automated deletion or manual?

---

### Section 4 — Incidents and Risk (5 mins)

**Q14:** Have there been any personal data breaches or near-misses in the past 12 months? What were the causes?

**Q15:** What are the biggest IG risks you see with the planned data platform project?

---

### Section 5 — Wrap-Up (5 mins)

**Q16:** What IG conditions must be met before patient data can be migrated to the new platform?

**Q17:** What would your sign-off process look like for the migration to proceed?

---

## Interview Script C — Clinical Informatics / Clinical Leads

**Duration:** 45 minutes | **Audience:** Clinical leads, clinical informaticists, coding teams
**Goal:** Clinical data quality, coding standards, clinical requirements for analytics

### Section 1 — Clinical Data Overview (10 mins)

**Q1:** What clinical data is most critical to the organisation's analytical and reporting needs?

**Q2:** What coding standards are used today — ICD-10, OPCS-4, SNOMED CT, dm+d, LOINC?
> *Probe: Are they coded at point of care or coded retrospectively? Who codes? What's the turnaround time?*

**Q3:** What is the current quality of clinical coding? Are there known gaps or inconsistencies?

**Q4:** What clinical data flows to NHSE, NICE, or other national bodies as statutory returns?

---

### Section 2 — Clinical Requirements for the New Platform (15 mins)

**Q5:** What clinical analytics or reporting capabilities are currently missing that the new platform should deliver?

**Q6:** Are there specific clinical pathways where data quality or fragmentation causes problems today?
> *Examples: RTT pathway, cancer 2WW, mental health, maternity, urgent care*

**Q7:** Are there any patient safety concerns related to data quality or data availability today?

**Q8:** What clinical reference datasets does the organisation use — NHSE reference files, national tariff, specialty codes, HRG grouper?

**Q9:** How should the new platform support clinical decision-making vs back-office reporting?

---

### Section 3 — NHS Data Standards (10 mins)

**Q10:** Is FHIR (HL7 FHIR R4) in use or planned in any systems today?

**Q11:** Are there any planned system upgrades that will change clinical data formats or coding?

**Q12:** Are NHS Number completeness rates monitored? What is the current rate across PAS?

---

### Section 4 — Wrap-Up (5 mins)

**Q13:** What would a clinically trustworthy data platform look like to you?

**Q14:** Who should we involve in validating that clinical data has migrated correctly?

---

## Interview Script D — Analytics / BI Teams

**Duration:** 45 minutes | **Audience:** Head of Analytics, BI developers, data analysts
**Goal:** Current reporting landscape, consumption requirements, Gold layer design

### Section 1 — Current Reporting Landscape (10 mins)

**Q1:** What are the main reports and dashboards used by the organisation today? Who uses them?

**Q2:** Where does your team currently get data from? Which systems do you query directly?

**Q3:** What tools do you use for reporting — Power BI, Excel, SQL, Python, Tableau?

**Q4:** Are there any reports that regularly fail, produce incorrect figures, or require manual correction before distribution?

---

### Section 2 — Data Access Pain Points (15 mins)

**Q5:** What data is hardest to access today? What requests do you regularly have to push back on?

**Q6:** How long does it typically take from a data request to delivery? What causes delays?

**Q7:** Are analysts querying production operational databases directly? If so, what are the risks?

**Q8:** Is there a data warehouse or analytical database in use today? If yes, how current is it and how is it maintained?

---

### Section 3 — Gold Layer Requirements (10 mins)

**Q9:** If we were building an analytics-ready Gold layer from scratch, what are the top 5 reporting use cases you need it to support?

**Q10:** What are the key metrics and KPIs the organisation reports on — both internally and externally?

**Q11:** Are there mandatory NHSE / NHSD submissions that must be supported?
> *Record: SUS, MSDS, IAPT, Mental Health, Cancer Waiting Times, Urgent Care, etc.*

**Q12:** What granularity of data is needed — patient-level, episode-level, aggregate?

---

### Section 4 — Wrap-Up (5 mins)

**Q13:** What would make the biggest difference to your team's productivity if the new platform delivered it?

**Q14:** Are there any current reports that must not be disrupted during the migration?

---

## Post-Interview Output Template

Fill in immediately after each session:

```
INTERVIEW RECORD
================
Date:
Stakeholder:
Role:
Duration:
Note-taker:

KEY SYSTEMS DISCUSSED:
- System 1: [name, tech, volume, owner]
- System 2:

DATA FLOWS IDENTIFIED:
- [System A] → [System B] via [method] — [frequency] — [data type]

DATA QUALITY ISSUES NOTED:
-

GOVERNANCE / IG POINTS:
-

RISKS FLAGGED BY STAKEHOLDER:
-

FOLLOW-UP ACTIONS:
- [ ] [Action] — Owner: [Name] — Due: [Date]

DOCUMENTS REQUESTED / TO RECEIVE:
-

DIAGRAM UPDATES MADE:
-
```

---

*Gov Health Data Discovery Template | Interview Guide | v0.1*
