# 📘 Project Notes & Interview Preparation

## ⚠️ Root Cause Analysis

### 1. Overly Permissive IAM Policy
The initial IAM user was assigned a policy granting `iam:CreateUser`, `iam:AttachUserPolicy`, and `iam:CreateAccessKey` with a `*` resource wildcard. 
* **Business Context:** This often happens when developers are granted temporary broad permissions to troubleshoot a deployment and the permissions are never revoked.
* **Impact:** A classic Privilege Escalation vulnerability allowing full account takeover.

### 2. Public S3 Bucket Exposure
The S3 bucket lacked Account-Level Public Access Blocks and utilized a wildcard Principal (`"Principal": "*"`) for `s3:GetObject`.
* **Impact:** Unauthenticated data exfiltration.

---

## 💼 Advanced Interview Q&A

**Q1: How would you prevent this misconfiguration from happening across 100 different AWS accounts in an enterprise?**
**A:** I would utilize AWS Organizations and implement Service Control Policies (SCPs). An SCP can be applied at the Root or Organizational Unit (OU) level to set a maximum permission boundary, completely denying actions like `iam:CreateUser` or disabling S3 public access, even if a local administrator tries to allow it.

**Q2: During your Incident Response, why is it important to use the CLI rather than just clicking through the AWS Management Console?**
**A:** Speed and precision. In a live breach, every second counts. Executing pre-written CLI commands or scripts allows a responder to revoke keys, delete users, and lock down buckets much faster than navigating multiple pages in the web interface. It also creates a reproducible command history for the post-incident report.

**Q3: How can you ensure the attacker didn't alter or delete the CloudTrail logs to cover their tracks during the breach?**
**A:** By enabling CloudTrail Log File Validation. This feature uses SHA-256 hashing and digital signatures. It creates a verifiable chain, allowing the security team to mathematically prove that the log files were not modified or deleted after AWS delivered them.