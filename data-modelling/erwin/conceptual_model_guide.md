# Conceptual Data Model Guide
## Gov Health Data Discovery Template — Erwin Data Modeler
### Version 0.1 | [Date]

> **Purpose:** This guide explains what to build at the Conceptual level in Erwin, what it should look like when done, and how to use it in stakeholder conversations during Discovery.

---

## What Is a Conceptual Data Model?

The Conceptual Data Model (CDM) is the **highest-level view** of the data landscape. It answers the question: **"What major things does the organisation need to keep data about?"**

At this level:
- There are **no data types** — only entity names
- There are **no column details** — only relationships
- It should be readable by **clinical, IG, and executive stakeholders** — not just technical teams
- It fits on **one page** (A3 or a projector slide)

---

## Core Health Entities to Include

For a Gov Health engagement, the CDM should contain these 9 core entities as a minimum:

```
┌─────────────┐       ┌──────────────────┐       ┌──────────────┐
│   PATIENT   │──────<│  CLINICAL EVENT  │>──────│ ORGANISATION │
└─────────────┘       └──────────────────┘       └──────────────┘
       │                       │
       │                       │
       ▼                       ▼
┌─────────────┐       ┌──────────────────┐
│   REFERRAL  │       │    MEDICATION    │
└─────────────┘       └──────────────────┘
       │
       ▼
┌─────────────┐       ┌──────────────────┐       ┌──────────────┐
│   SPECIMEN  │──────<│   LAB RESULT     │       │ PRACTITIONER │
└─────────────┘       └──────────────────┘       └──────────────┘
                                                         │
                                                         ▼
                                               ┌──────────────────┐
                                               │   DATA ASSET     │
                                               │  (Governance)    │
                                               └──────────────────┘
```

---

## Relationship Summary for CDM

| Entity A | Cardinality | Entity B | Business Meaning |
|----------|------------|----------|-----------------|
| PATIENT | 1 : Many | CLINICAL EVENT | One patient can have many hospital episodes |
| PATIENT | 1 : Many | REFERRAL | One patient can have many referrals |
| PATIENT | 1 : Many | SPECIMEN | One patient can provide many specimens |
| SPECIMEN | 1 : Many | LAB RESULT | One specimen produces many test results |
| CLINICAL EVENT | 1 : Many | MEDICATION | One episode can have many prescribed medications |
| ORGANISATION | 1 : Many | CLINICAL EVENT | One organisation hosts many episodes |
| PRACTITIONER | 1 : Many | CLINICAL EVENT | One practitioner leads many episodes |
| PRACTITIONER | 1 : Many | LAB RESULT | One clinician requests many lab tests |
| ORGANISATION | 1 : Many | DATA ASSET | One org owns many data assets |

---

## Step-by-Step: Building the CDM in Erwin

### Step 1 — Create the Model
1. Open Erwin Data Modeler
2. **File → New Model**
3. Type: **Logical** (CDM is logical-level only)
4. Notation: **IE (Information Engineering)**
5. Save as: `govhealth_cdm_v0.1.erwin`

### Step 2 — Add Entities
1. Select the **Entity** tool from the toolbar (rectangle icon)
2. Click on the canvas to place 9 entity boxes
3. Name them:
   - `PATIENT`
   - `ORGANISATION`
   - `CLINICAL_EVENT`
   - `REFERRAL`
   - `SPECIMEN`
   - `LAB_RESULT`
   - `PRACTITIONER`
   - `MEDICATION`
   - `DATA_ASSET`

4. **Do not add any attributes at CDM level** — entities only

### Step 3 — Add Relationships
1. Select the **Relationship** tool
2. Click on the parent entity first, then drag to the child
3. Set cardinality: right-click the relationship → Properties → Cardinality
4. Use **One-to-Many (1:M)** for all relationships in this model

### Step 4 — Add Business Definitions
For each entity, double-click → Properties → Definition tab:

| Entity | Business Definition |
|--------|-------------------|
| PATIENT | An individual who is or has been the subject of health or care services delivered by the organisation. Identified by NHS Number. |
| CLINICAL EVENT | A healthcare encounter between a patient and the organisation. Includes inpatient admissions, day cases, outpatient appointments, and A&E attendances. |
| ORGANISATION | An NHS or partner organisation that provides, commissions, or receives health data. Identified by ODS Code. |
| REFERRAL | A formal request for a patient to receive assessment or treatment from a clinical team. The RTT (Referral to Treatment) pathway starts from this point. |
| SPECIMEN | A biological sample collected from a patient for laboratory analysis. |
| LAB RESULT | The result of a laboratory test performed on a specimen. May include a numeric value, free text, or coded result. |
| PRACTITIONER | A registered clinical or healthcare professional who delivers or oversees patient care. Identified by GMC/NMC/HCPC registration number. |
| MEDICATION | A medicine prescribed to a patient, either during a clinical event or in the community. Coded using NHS dm+d (Dictionary of Medicines and Devices). |
| DATA ASSET | Any data source, dataset, table, file, or report identified during discovery. Used for the data catalogue. |

### Step 5 — Arrange and Export
1. Arrange entities so the diagram reads top-to-bottom, primary flows left-to-right
2. **File → Export → Image → PNG** (300 DPI)
3. Save as: `outputs/cdm_diagram.png`
4. Save Erwin file: `data-modelling/erwin/govhealth_cdm_v0.1.erwin`

---

## How to Use the CDM in Stakeholder Conversations

**With Executives / Programme Board:**
> *"This diagram shows the 9 key things we need to keep data about. PATIENT is at the centre — everything links back to the patient. This is what the new platform is built around."*

**With IG / Caldicott Guardian:**
> *"Each box that connects to PATIENT is a category of patient data. This helps us identify which processing activities need a legal basis under UK GDPR Article 9."*

**With Clinical Leads:**
> *"The CLINICAL EVENT is any time a patient is seen. It links to REFERRAL — the start of the RTT clock — and to LAB RESULT through the specimen. Does this match how you think about the patient journey?"*

**With System Owners:**
> *"Your [PAS / EPR / LIMS] system holds data about [these entities]. Does anything look missing? Any data you manage that isn't captured here?"*

---

## CDM Sign-Off Checklist

- [ ] All 9 core entities present
- [ ] Business definitions completed for every entity
- [ ] Relationships drawn with correct cardinality
- [ ] Clinical lead has reviewed and agreed
- [ ] IG / DPO has reviewed — confirms all patient-linked entities identified
- [ ] Exported as PNG and committed to `outputs/`
- [ ] Erwin file committed to `data-modelling/erwin/`

---

*Gov Health Discovery Template | Conceptual Model Guide | v0.1*
