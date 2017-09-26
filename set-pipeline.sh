#!/bin/bash -e

cd $(dirname $0)

target=flintstone

fly -t ${target} login -c https://flintstone.ci.cf-app.com -u admin -p $(lpass show "Shared-Flintstone/Flintstone Concourse" --password)

# use brew install lastpass-cli
lpass show "Shared-Flintstone"/ci-config --notes > config.yml
github_ssh_key=$(lpass show "Shared-Flintstone"/Github --notes)
github_access_token=$(lpass show "Shared-Flintstone/Github Access Token" --password)
rubygems_api_key=$(lpass show "Shared-Flintstone"/flintstone@rubygems.org --notes)
bluemix_cloudfoundry_username=$(lpass show "Shared-Flintstone"/"Bluemix Cloud Foundry User" --username)
bluemix_cloudfoundry_password=$(lpass show "Shared-Flintstone"/"Bluemix Cloud Foundry User" --password)
slack_webhook=$(lpass show "Shared-Flintstone"/"Flintstone Slack Webhook" --password)

fly \
  -t ${target} \
  set-pipeline \
  -p bits-service \
  -c pipeline.yml \
  -l config.yml \
  -v github-private-key="${github_ssh_key}" \
  -v github-access-token="${github_access_token}" \
  -v rubygems-api-key="${rubygems_api_key}" \
  -v bluemix_cloudfoundry_username="${bluemix_cloudfoundry_username}" \
  -v bluemix_cloudfoundry_password="${bluemix_cloudfoundry_password}" \
  -v sl-bosh-ca-cert="$(bosh int ~/workspace/bits-service-private-config/environments/softlayer/director/vars.yml --path /director_ssl/ca)" \
  -v bosh-ca-cert="$(<~/workspace/bosh-lite/ca/certs/ca.crt)" \
  -v slack-webhook="${slack_webhook}"

rm -f config.yml

fly -t ${target} expose-pipeline --pipeline bits-service
