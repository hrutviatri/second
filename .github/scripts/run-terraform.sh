#!/bin/bash
set -e

# 🟢 Inputs (GitHub env variables se aayenge)
WORKDIR=${WORKDIR:-infra}
TFVARS_FILE=${TFVARS_FILE:-"../environments/prod.tfvars"}

RUN_INIT=${RUN_INIT:-false}
RUN_PLAN=${RUN_PLAN:-false}
RUN_APPLY=${RUN_APPLY:-false}
RUN_DESTROY=${RUN_DESTROY:-false}

RGNAME=${RGNAME}
SANAME=${SANAME}
SCNAME=${SCNAME}
KEY=${KEY}

cd $WORKDIR

echo "🚀 Terraform Orchestrator Started"
echo "Selected Steps: init=$RUN_INIT | plan=$RUN_PLAN | apply=$RUN_APPLY | destroy=$RUN_DESTROY"
echo "Working Directory: $WORKDIR"

# ---------- INIT ----------
if [ "$RUN_INIT" = "true" ]; then
  echo "🔹 Running Terraform Init..."
  terraform init -input=false \
    -backend-config="resource_group_name=$RGNAME" \
    -backend-config="storage_account_name=$SANAME" \
    -backend-config="container_name=$SCNAME" \
    -backend-config="key=$KEY"
  terraform fmt -check -recursive
  terraform validate
  INIT_SUCCESS=$?
else
  INIT_SUCCESS=0
fi

# ---------- PLAN ----------
if [ "$RUN_PLAN" = "true" ]; then
  if [ "$INIT_SUCCESS" -ne 0 ]; then
    echo "❌ Init failed — skipping plan"
  else
    echo "🔹 Running Terraform Plan..."
    terraform plan -var-file="$TFVARS_FILE" -out="tf-plan.tfplan"
    PLAN_SUCCESS=$?
  fi
else
  PLAN_SUCCESS=0
fi

# ---------- APPLY ----------
if [ "$RUN_APPLY" = "true" ]; then
  if [ "$PLAN_SUCCESS" -ne 0 ]; then
    echo "❌ Plan failed — skipping apply"
  else
    echo "🔹 Running Terraform Apply..."
    terraform apply -auto-approve "tf-plan.tfplan"
    APPLY_SUCCESS=$?
  fi
else
  APPLY_SUCCESS=0
fi

# ---------- DESTROY ----------
if [ "$RUN_DESTROY" = "true" ]; then
  if [ "$RUN_APPLY" = "true" ] && [ "$APPLY_SUCCESS" -ne 0 ]; then
    echo "❌ Apply failed — skipping destroy"
  elif [ "$RUN_PLAN" = "true" ] && [ "$PLAN_SUCCESS" -ne 0 ]; then
    echo "❌ Plan failed — skipping destroy"
  elif [ "$RUN_INIT" = "true" ] && [ "$INIT_SUCCESS" -ne 0 ]; then
    echo "❌ Init failed — skipping destroy"
  else
    echo "🔹 Running Terraform Destroy..."
    terraform destroy -auto-approve -var-file="$TFVARS_FILE"
  fi
fi

echo "✅ Terraform workflow completed."
