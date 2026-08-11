# Data Discovery Questionnaire
## [Organisation Name] | [Date]
> Send to stakeholders **before** their discovery interview session.
> Adapt questions to the stakeholder's role and system ownership.

---

**Stakeholder Name:**
**Role / Team:**
**Date Sent:**
**Interview Scheduled:**
**Completed by:** (stakeholder fills in)

---

## Section 1 — Your Data Systems

1. **Which system(s) are you responsible for or heavily use?**
   (List each system, its name, and your relationship to it)

2. **What data does each system hold?** (e.g. patient demographics, lab results, referrals, financial data)

3. **What is the underlying technology of each system?**
   (e.g. SQL Server 2019, Oracle 11g, PostgreSQL, cloud SaaS, Excel, custom)

4. **Approximately how many records / rows does the system hold?** (rough estimate is fine)

5. **How old is the data?** (e.g. 3 years of data, going back to 2015)

6. **How frequently is the data updated?** (real-time / hourly / daily / weekly / monthly / ad-hoc)

---

## Section 2 — Data Flows

7. **Where does your system get its data from?** (upstream sources — list all)

8. **Who consumes data from your system?** (downstream users or systems — list all)

9. **How is data transferred between systems?**
   (e.g. direct DB link, SFTP, API, manual extract, ETL job, email)

10. **Is there any documentation of these data flows?** (Y/N — if yes, can you share it?)

11. **Are there any temporary or workaround data flows you are aware of?** (e.g. manual CSV dumps, access database copies)

---

## Section 3 — Data Quality

12. **What data quality issues are you currently aware of in your system?**
    (e.g. missing NHS Numbers, duplicate records, incomplete coding)

13. **Are there any known data gaps or fields that are poorly populated?**

14. **How are data quality issues currently identified and resolved?**

15. **Do you have any existing data quality reports or dashboards you can share?**

---

## Section 4 — Governance & Compliance

16. **Do you know who the Data Owner is for the data your system holds?**

17. **What is the sensitivity of the data in your system?** (tick all that apply)
    - [ ] Identifiable patient data (NHS Number, name, DOB)
    - [ ] Pseudonymised patient data
    - [ ] Anonymised / aggregate data
    - [ ] Staff / workforce data
    - [ ] Financial data
    - [ ] Non-personal operational data

18. **Do you know the retention period for data in your system?**

19. **Are there any data sharing agreements in place governing data flows to/from your system?** (Y/N — if yes, who manages them?)

20. **Are there any known IG risks or incidents associated with your system's data?**

---

## Section 5 — Pain Points & Requirements

21. **What are the biggest data-related frustrations in your current role?**

22. **What data would be most valuable to have easier access to?**

23. **What reporting or analytics capabilities are currently missing that would improve your work?**

24. **Are there any regulatory submissions that depend on your system's data?** (e.g. SUS, NHSE returns, CQC, DSPT)

25. **Are there any planned changes to your system in the next 12 months?** (e.g. upgrades, replacements, decommissions)

---

## Section 6 — Alpha Requirements

26. **What would success look like at the end of the Alpha phase from your perspective?**

27. **What is the single most important data capability you need the new platform to deliver?**

28. **Are there any constraints or dependencies we need to be aware of?** (e.g. procurement cycles, technical freezes, staff changes)

---

**Thank you for completing this questionnaire. Your responses will be used to shape the data architecture discovery and will be shared only with the project team.**

*[Organisation] | Discovery Questionnaire | [Date]*
