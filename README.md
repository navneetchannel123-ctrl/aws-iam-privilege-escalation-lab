# AWS Identity Privilege Escalation & Incident Response Lab

## Overview
This project simulates a real-world AWS cloud security breach initiated by a misconfigured Identity and Access Management (IAM) policy. It demonstrates the complete attack lifecycle-from privilege escalation to data exfiltration-and showcases a DevSecOps-aligned detection pipeline using CloudTrail and CloudWatch, followed by manual Incident Response (IR) containment.

---

## Architecture & Attack Flow

![Architecture Diagram](architecture-diagram.png)

---

## The Attack Lifecycle (Offense)

### 1. Privilege Escalation
**Objective:** Exploit `iam:CreateUser` and `iam:AttachUserPolicy` to establish a rogue administrative backdoor.

Using the compromised `proj2-attacker` credentials, I bypassed intended restrictions by creating a secondary administrative identity, `hacked-admin`.

<details>
<summary><b>[Click to view proof of privilege escalation]</b></summary>
<br>

**Step A: The Exploit (CLI)**
![CLI Proof](screenshots/13_hacked_admin_user_created.png)
*Figure 13: Terminal output showing the successful creation of 'hacked-admin' via AWS CLI.*

**Step B: Verification (Console)**
![Console Proof](screenshots/18_hacked_admin_user.png)
*Figure 18: AWS Management Console confirming the existence of the unauthorized 'hacked-admin' identity.*

**The Root Cause: Toxic Policy**
![Toxic Policy](screenshots/02_attach_weak_policy.png)
*Figure 02: The misconfigured IAM policy that allowed the 'proj2-attacker' to escalate privileges.*
</details>

**Impact:** Complete account takeover achieved via a newly minted admin identity.

---

### 2. Data Exfiltration
**Objective:** Access and download sensitive credentials from a restricted S3 bucket using the `hacked-admin` backdoor.

Targeting the `proj2-data-leak` bucket, I used the AWS CLI to bypass intended security boundaries and retrieve the sensitive `passwords.txt` file.

<details>
<summary><b>[Click to view definitive proof of exfiltration]</b></summary>
<br>

**Step A: Identifying the Target**
![S3 Overview](screenshots/04_s3_bucket_overview.png)
*Figure 04: Locating the sensitive data-leak bucket in the S3 console.*

**Step B: The Breach (Terminal)**
![Data Retrieval](screenshots/16_s3_data_retrieved.png)
*Figure 16: Terminal output confirming the successful sync and unauthorized viewing of 'passwords.txt'.*
</details>

**Impact:** **CRITICAL.** Unauthorized access to plaintext credentials, leading to potential lateral movement across the infrastructure.

## 3. Detection & Alerting (Defense)

### Intercepting Anomalies
**Objective:** Detect unauthorized identity creation using CloudWatch Metric Filters.

AWS CloudTrail logged the malicious `CreateUser` API call, which was intercepted by a pre-configured CloudWatch Metric Filter scanning for identity-based anomalies.

<details>
<summary><b>[Click to view detection logic]</b></summary>
<br>

![Metric Filter](screenshots/08_metric_filter_created.png)
*Figure 5: CloudWatch filter intercepting unauthorized user creation (`{ $.eventName = "CreateUser" }`).*
</details>
### Real-Time Alerting
**Objective:** Notify the security team instantly via Amazon SNS.

The Metric Filter triggered a CloudWatch Alarm, which immediately dispatched an incident notification via email.

<details>
<summary><b>[Click to view triggered alerts]</b></summary>
<br>

![CloudWatch Alarm](screenshots/10_cloudwatch_alarm.png)
*Figure 6: The triggered CloudWatch Alarm.*

![Email Alert](screenshots/14_email_alert.png)
*Figure 7: Real-time Incident Response alert delivered to the security team.*
</details>

---

### 4. Incident Response & Remediation
**Objective:** Contain the threat, eradicate compromised assets, and restore secure access.

Upon receiving the real-time SNS alert, I initiated emergency containment protocols via the **AWS Management Console** to neutralize the threat and restore a secure baseline.

<details>
<summary><b>[Click to view full remediation & hardening proof]</b></summary>
<br>

**Step A: Severing Rogue Identity Access**
I manually revoked the compromised access keys and deleted the `hacked-admin` identity to ensure the attacker could not maintain persistence.
![Key Removal](screenshots/19_hacked_admin_key_removal.png)
*Figure 19: Revoking the active Access Keys for the rogue user.*
![User Deleted](screenshots/20_hacked_admin_removed.png)
*Figure 20: Deleting the 'hacked-admin' IAM user from the console.*

**Step B: Hardening the Data Perimeter**
![S3 Public Block](screenshots/22_blocked_public_access.png)
*Figure 22: Enforcing 'Block Public Access' via the S3 Console to permanently close the exfiltration vector.*

**Step C: Restoring Secure Access (Least Privilege)**
Finally, I restored access to the bucket using a **ReadOnly** policy, ensuring that legitimate users could access data without the risk of unauthorized modification or public exposure.
![S3 ReadOnly](screenshots/21_s3_read_only_access.png)
*Figure 21: Re-configuring the bucket with S3ReadOnlyAccess to follow the principle of Least Privilege.*
</details>

**Impact:** **Threat Neutralized.** Rogue identities were purged, and the S3 data perimeter was hardened and restored to a secure, "Read-Only" baseline.

## Tech Stack & Services Used
* **Identity & Security:** AWS IAM, AWS STS
* **Storage:** Amazon S3
* **Monitoring & Auditing:** AWS CloudTrail, Amazon CloudWatch
* **Notification:** Amazon SNS
* **Operations:** AWS CLI, Bash
