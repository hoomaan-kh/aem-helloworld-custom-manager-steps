#!/usr/bin/env bash
set -o nounset
set -o errexit
BASE_DIR=$(dirname "$0")
data_bucket_name=${AWS_LIBRARY_S3_BUCKET}
stack_prefix=${STACK_PREFIX}
jenkins_build_name=${JOB_BASE_NAME}
jenkins_url=${BUILD_URL}

if [[ $jenkins_url =~ "jenkins.prod" ]]
then
  echo "Jenkins is running in production environment."
  deployment_domain_type="prod"
elif [[ $jenkins_url =~ "jenkins.npe" ]]
then
  echo "Jenkins is running in non-prod environement ."
  deployment_domain_type="npe"
else
  echo "Jenkins hostname should include 'npe' or 'prod' "
  exit 1
fi

if [[ $jenkins_build_name = "deploy-artifacts-full-set" ]]
then
  echo "This is going to be Full-set deployment."
  deployment_target_scale="full-set"
elif [[ $jenkins_build_name = "deploy-artifacts-consolidated" ]]
then
  echo "This is going to be Consolidated deployment."
  deployment_target_scale="consolidated"
fi


if [ $jenkins_build_name = "deploy-artifacts-full-set" ] || [ $jenkins_build_name = "deploy-artifacts-consolidated" ]
then
echo "puppet servlet validate module is started"

set +o errexit
aem_password=$(aws s3 cp s3://${data_bucket_name}/${stack_prefix}/system-users-credentials.json - | jq --raw-output .orchestrator)
echo ${aem_password}

FACTER_deployment_target_scale="$deployment_target_scale" \
FACTER_deployment_domain_type="$deployment_domain_type" \
FACTER_stack_prefix="$stack_prefix" \
FACTER_aem_password="$aem_password" \
puppet apply \
  --detailed-exitcodes \
  --modulepath "$BASE_DIR"/modules \
  "$BASE_DIR"/manifests/post_common.pp


echo "puppet servlet validate module is finished"
else
echo "Deployment step had been skipped"
fi
