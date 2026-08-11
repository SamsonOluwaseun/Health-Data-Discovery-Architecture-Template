# AWS Services Map
## Gov Health Data Platform — Complete Service Reference
### [Organisation Name] | Version 0.1 | [Date]

> **Quick-reference:** Every AWS service used in this engagement, what it does, where it sits in the architecture, and why it was chosen over alternatives.

---

## Architecture Layer → AWS Service Mapping

| Layer | AWS Service | Role | Why Chosen | Alternative Considered |
|-------|------------|------|-----------|----------------------|
| **Ingestion** | AWS API Gateway | FHIR R4 REST endpoint for clinical system feeds | Managed, scalable; native FHIR support | Azure API Management |
| **Ingestion** | AWS DMS (Database Migration Service) | On-prem database replication (full load + CDC) | Native support for SQL Server, Oracle, PostgreSQL; minimal source impact | Striim, Debezium |
| **Ingestion** | AWS Transfer Family (SFTP) | Secure managed SFTP for batch file exchange | Replaces on-prem SFTP servers; S3-backed | Self-hosted SFTP on EC2 |
| **Ingestion** | AWS DataSync | Bulk file transfer from on-prem file shares | Scheduled, encrypted, monitoring built-in | AWS CLI S3 sync |
| **Processing** | AWS Glue (ETL) | Data transformation: raw → silver → gold | Serverless Spark; native S3/RDS/Redshift connectors | AWS EMR, Databricks |
| **Processing** | AWS Glue Data Catalog | Schema registry and metadata store | Integrates with Glue, Athena, Lake Formation | Apache Hive Metastore |
| **Processing** | AWS Lambda | Event-driven validation, critical value alerts, small transforms | Serverless; triggered by S3 events; cost-effective | ECS Fargate for long tasks |
| **Processing** | AWS Step Functions | Pipeline orchestration (daily ETL workflow) | Visual workflow; retry logic; error handling | Apache Airflow on MWAA |
| **Storage — Bronze** | Amazon S3 | Raw data landing zone; archive; data lake foundation | Durable, cheap, serverless; S3 lifecycle for cost | Azure Data Lake Gen2 |
| **Storage — Silver** | Amazon RDS (PostgreSQL 15) | Conformed, structured clinical data store | Managed PostgreSQL; Multi-AZ; native Glue integration | Aurora PostgreSQL |
| **Storage — Gold** | Amazon Redshift Serverless | Analytics-ready data mart | Pay-per-query; auto-scaling; BI tool integration | Snowflake, BigQuery |
| **Governance** | AWS Lake Formation | Fine-grained access control on S3 data (row/column-level) | Integrates with Glue Catalog; supports NHS data classification tiers | IAM policies alone |
| **Governance** | Amazon Macie | Automated PII detection on S3 buckets | Detects unexpected PII; alerts IG team | Custom Lambda scanner |
| **Governance** | AWS Glue Data Quality | Automated DQ rules on Glue jobs | Native integration; writes to CloudWatch | Great Expectations |
| **Security** | AWS KMS | Customer-managed encryption keys (CMK) | Full key control; audit via CloudTrail | SSE-S3 (less control) |
| **Security** | AWS Secrets Manager | Database credentials; API keys; rotation | Auto-rotation; IAM-integrated; no hardcoded creds | AWS Parameter Store |
| **Security** | AWS IAM | Identity and access management; role-based access | Foundational AWS identity; integrates with everything | — |
| **Security** | Amazon GuardDuty | Threat detection: malicious IPs, unusual API calls | Automated; no agents; CloudTrail-based | Custom SIEM rules |
| **Security** | AWS CloudTrail | API-level audit logging; compliance evidence | Mandatory for NHS IG; immutable log archive | — |
| **Security** | AWS Config | Resource configuration tracking; compliance rules | Detect config drift; DSPT evidence | — |
| **Security** | AWS Security Hub | Aggregated security posture across accounts | Single view; CIS benchmark checks | — |
| **Monitoring** | Amazon CloudWatch | Metrics, alarms, logs for all services | Native AWS; DMS lag, Glue failures, RDS CPU | Datadog |
| **Monitoring** | CloudWatch Dashboards | Operational health view for Data Engineering team | No extra cost; real-time | Grafana |
| **Networking** | AWS Direct Connect | Dedicated 1Gbps connection from on-prem to AWS | Low latency; high bandwidth for migration | Site-to-Site VPN |
| **Networking** | AWS VPC | Network isolation for all data platform resources | Foundational; private subnets; no public exposure | — |
| **Networking** | AWS PrivateLink | Private connectivity to AWS services (no internet) | S3, Glue, RDS accessed privately | VPC Endpoints (Gateway) |
| **Consumption** | Amazon QuickSight | Operational dashboards; internal analytics | Native Redshift integration; Okta SSO | Power BI Embedded |
| **Migration** | AWS Schema Conversion Tool (SCT) | Convert Oracle/SQL Server schemas to PostgreSQL DDL | Automated first-pass; flags incompatible objects | Manual conversion |
| **Compliance** | AWS Artifact | Compliance reports (ISO 27001, SOC 2, Cyber Essentials+) | Download for IG/DSPT evidence pack | — |
| **Costs** | AWS Cost Explorer | Monitor and alert on cloud spend | Right-size; identify waste | — |

---

## Service Configuration Quick Reference

### S3 — Standard Bucket Configuration
```bash
# Create raw data bucket with encryption and versioning
aws s3api create-bucket \
  --bucket govhealth-raw-${ACCOUNT_ID} \
  --region eu-west-2 \
  --create-bucket-configuration LocationConstraint=eu-west-2

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket govhealth-raw-${ACCOUNT_ID} \
  --versioning-configuration Status=Enabled

# Block all public access
aws s3api put-public-access-block \
  --bucket govhealth-raw-${ACCOUNT_ID} \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,\
    BlockPublicPolicy=true,RestrictPublicBuckets=true

# Enable default encryption (KMS)
aws s3api put-bucket-encryption \
  --bucket govhealth-raw-${ACCOUNT_ID} \
  --server-side-encryption-configuration '{
    "Rules": [{"ApplyServerSideEncryptionByDefault": {
      "SSEAlgorithm": "aws:kms",
      "KMSMasterKeyID": "arn:aws:kms:eu-west-2:ACCOUNT_ID:key/KEY_ID"
    }}]}'
```

### AWS Glue — Standard Job Skeleton
```python
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ['JOB_NAME', 'SOURCE_BUCKET', 'TARGET_DB'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Read from S3 raw
source_df = glueContext.create_dynamic_frame.from_options(
    connection_type="s3",
    connection_options={"paths": [f"s3://{args['SOURCE_BUCKET']}/patient/"]},
    format="json"
)

# Transform here ...

# Write to RDS
glueContext.write_dynamic_frame.from_jdbc_conf(
    frame=source_df,
    catalog_connection="govhealth-rds-connection",
    connection_options={"dbtable": "silver.patient", "database": "govhealth"},
    redshift_tmp_dir=f"s3://govhealth-glue-assets-{ACCOUNT_ID}/tmp/"
)

job.commit()
```

### CloudWatch — Key Alarms to Set Up
```bash
# DMS task lag > 10 minutes
aws cloudwatch put-metric-alarm \
  --alarm-name "DMS-CDCLatency-High" \
  --metric-name CDCLatencySource \
  --namespace AWS/DMS \
  --statistic Average \
  --period 300 \
  --threshold 600 \
  --comparison-operator GreaterThanThreshold \
  --alarm-actions arn:aws:sns:eu-west-2:ACCOUNT_ID:govhealth-alerts

# RDS CPU > 80%
aws cloudwatch put-metric-alarm \
  --alarm-name "RDS-CPUUtilization-High" \
  --metric-name CPUUtilization \
  --namespace AWS/RDS \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --alarm-actions arn:aws:sns:eu-west-2:ACCOUNT_ID:govhealth-alerts

# Glue job failure
aws cloudwatch put-metric-alarm \
  --alarm-name "Glue-JobFailure" \
  --metric-name glue.driver.aggregate.numFailedTasks \
  --namespace Glue \
  --statistic Sum \
  --period 300 \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --alarm-actions arn:aws:sns:eu-west-2:ACCOUNT_ID:govhealth-alerts
```

---

## AWS Region Decision: eu-west-2 (London)

**Why eu-west-2 (London)?**
- NHS data residency requirement: all patient data must remain in the UK
- AWS eu-west-2 is the only UK AWS region
- Compliance: NHS DSPT, UK GDPR, Caldicott Principles all satisfied
- Low latency to NHS on-prem systems (most in England)

**Do NOT use:** eu-west-1 (Ireland) for patient data — outside UK jurisdiction post-Brexit.

---

## Cost Optimisation Recommendations

| Area | Recommendation | Estimated Saving |
|------|---------------|-----------------|
| S3 lifecycle | Move raw data >90 days to S3 Glacier Instant Retrieval | 30-40% on storage |
| RDS | Use Reserved Instance (1-year) for production | 30-35% vs on-demand |
| Redshift | Serverless RPUs — scale to zero on weekends | 20-30% on compute |
| Glue | Use G.025X worker type for light jobs | 75% cheaper than G.1X |
| DMS | Remove replication instance after migration; switch to Glue incremental | £300-400/month saving |

---

*[Organisation] | AWS Services Map | Version 0.1 | [Date]*
