# Gov Health Data Discovery & Architecture Template

> An end-to-end consultant-grade template for leading Data Architecture Discovery projects in Government Healthcare environments — from Discovery through to Alpha readiness.

[![GDS Phases](https://img.shields.io/badge/GDS-Discovery%20%E2%86%92%20Alpha-blue)](https://www.gov.uk/service-manual/agile-delivery) [![Cloud: AWS](https://img.shields.io/badge/Cloud-AWS-orange)](https://aws.amazon.com) [![Draw.io](https://img.shields.io/badge/Diagrams-Draw.io-blue)](https://app.diagrams.net) [![Erwin](https://img.shields.io/badge/Modelling-Erwin%20Data%20Modeler-green)](https://erwin.com) [![Licence: MIT](https://img.shields.io/badge/Licence-MIT-lightgrey.svg)](LICENSE)

[View the current repository structure](FILES.md)

---

## Project Overview

This repository is designed to support a Government Healthcare data architecture discovery engagement from initial assessment through to Alpha readiness. It provides a practical starter pack for documenting the current state, designing the target state, modelling core entities and flows, and preparing the governance and migration artefacts needed for delivery.

The project is organised into structured sections for architecture, modelling, governance, migration, templates, and outputs. For the full directory map, see [FILES.md](FILES.md).

---

## What This Template Is

This repository provides a reusable, consultant-grade framework for delivering a **Data Architecture Discovery** engagement in a Government Healthcare setting. It covers the full scope typically required from Discovery through to Alpha readiness:

- Documenting the current data landscape
- Defining the target data architecture
- Data mapping and migration planning
- Data governance framework
- Integration pattern design
- AWS cloud architecture
- Alpha readiness assessment

It is tool-specific: architecture diagrams are in **Draw.io** (`.drawio` XML), data models use **Erwin Data Modeler** DDL conventions, and cloud infrastructure is designed for **AWS**.

## Visual Architecture Overview

These diagrams help readers understand the design direction before diving into the templates and models.

![Current State Architecture](architecture/images/Current%20State%20Architecture.png)

*Figure 1: Current state architecture showing the existing healthcare systems, data sources, and the broader operating landscape before target-state design.*

![Target State Data Architecture](architecture/images/Target%20state%20Data%20Architecture.png)

*Figure 2: Target state data architecture illustrating the future, cloud-aligned design for data ingestion, transformation, storage, and reporting.*

![Data Flow Diagram](architecture/images/Data%20Flow%20Diagram.png)

*Figure 3: Data flow diagram covering the three core health data journeys: patient demographics, lab results, and referral pathways.*

![Integration Patterns](architecture/images/Integration%20Patterns.png)

*Figure 4: Integration patterns showing how systems exchange data, trigger events, and connect operational and analytical services across the architecture.*

---

## Who This Is For

- Data Architects leading Gov/NHS discovery engagements
- Senior consultants onboarding to a new public sector client
- Data Engineering teams preparing for Alpha delivery
- Anyone building a portfolio of public sector data architecture work

---

## GDS Phase Alignment

This template follows the [GDS Service Manual](https://www.gov.uk/service-manual/agile-delivery) phases:

```
Discovery ──► Alpha Readiness
   │
   ├── Phase 1: Landscape Assessment (Weeks 1-2)
   ├── Phase 2: Current State Architecture (Weeks 2-3)
   ├── Phase 3: Target Architecture Design (Weeks 3-4)
   ├── Phase 4: Data Governance & Compliance (Weeks 4-5)
   ├── Phase 5: Migration Strategy (Weeks 5-6)
   └── Phase 6: Alpha Readiness Pack (Week 7)
```

---

## Repository Structure

```
govhealth-discovery-template/
│
├── README.md                          ← You are here
├── PROCESS.md                         ← Step-by-step delivery guide
├── .gitignore
│
├── templates/                         ← Blank templates to fill in per engagement
│   ├── 01_discovery_questionnaire.md
│   ├── 02_data_inventory_register.md
│   ├── 03_stakeholder_register.md
│   ├── 04_data_flow_interview_guide.md
│   └── 05_alpha_readiness_checklist.md
│
├── architecture/
│   ├── drawio/
│   │   ├── 01_current_state_architecture.drawio    ← Open in Draw.io
│   │   ├── 02_target_state_architecture.drawio
│   │   ├── 03_data_flow_diagram.drawio
│   │   └── 04_integration_patterns.drawio
│   └── aws/
│       ├── aws_target_architecture.md              ← AWS service design
│       └── aws_services_map.md
│
├── data-modelling/
│   ├── erwin/
│   │   ├── ERWIN_GUIDE.md                          ← How to use Erwin for this project
│   │   ├── conceptual_model_guide.md
│   │   └── physical_model_ddl_guide.md
│   └── ddl/
│       ├── 01_conceptual_entities.sql              ← Reverse-engineer into Erwin
│       ├── 02_logical_data_model.sql
│       └── 03_physical_data_model.sql
│
├── governance/
│   ├── data_governance_framework.md
│   ├── data_quality_assessment.md
│   ├── ropa_template.md                            ← Record of Processing Activities
│   └── data_classification_policy.md
│
├── migration/
│   ├── migration_strategy.md
│   ├── data_mapping_template.md
│   └── migration_risk_register.md
│
├── docs/
│   ├── discovery_report_template.md                ← Final deliverable template
│   └── glossary.md
└── outputs/                                        ← Completed sample outputs
    ├── sample_discovery_report.md
    └── sample_data_inventory.md
```

---

## Tools Required

| Tool | Purpose | How to Get |
|------|---------|-----------|
| Draw.io (diagrams.net) | Architecture diagrams | [diagrams.net](https://app.diagrams.net) — free, browser-based |
| Erwin Data Modeler | Conceptual, Logical, Physical data models | [erwin.com](https://erwin.com) |
| AWS Console / CLI | Cloud architecture | [aws.amazon.com](https://aws.amazon.com) |
| PostgreSQL / DBeaver | Run DDL scripts locally | [dbeaver.io](https://dbeaver.io) — free |
| Git / GitHub | Version control | [github.com](https://github.com) |

---

## Quick Start

1. **Clone the repo**

```bash
git clone https://github.com/SamsonOluwaseun/Health-Data-Discovery-Architecture-Template.git
cd Health-Data-Discovery-Architecture-Template
```

2. **Read the process guide first** — open `PROCESS.md`.
3. **Use templates** in `templates/` to structure stakeholder sessions.
4. **Open Draw.io diagrams** in app.diagrams.net → File → Open from → Device.
5. **Import DDL into Erwin**: Erwin → File → Reverse Engineer → select a DDL file from `/data-modelling/ddl/`.

---

## About This Template

Built by a Senior Enterprise Data Architect with experience delivering discovery and architecture engagements across Government Healthcare, Finance, and Insurance environments. The patterns, templates, and tooling here reflect real-world engagement delivery — not theory.

---

*Contributions welcome. Open an issue or PR if you'd like to improve a template.*