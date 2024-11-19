gcloud projects add-iam-policy-binding hatchet-benchmarks \
  --member="serviceAccount:benchmarks-cloudsql-proxy@hatchet-benchmarks.iam.gserviceaccount.com" \
  --role="roles/cloudsql.admin"

gcloud projects add-iam-policy-binding hatchet-benchmarks \
  --member="serviceAccount:benchmarks-cloudsql-proxy@hatchet-benchmarks.iam.gserviceaccount.com" \
  --role="roles/cloudsql.client"


gcloud services enable sqladmin.googleapis.com --project=hatchet-benchmarks



create the relevant google secrets for 

benchmarks-google-client-id
benchmarks-google-client-secret
benchmarks-cloudkms-key
benchmarks-jwt-private-keyset
benchmarks-jwt-public-keyset
benchmarks-postmark-api-token

benchmarks-cert-manager-cloudflare-token
benchmarks-logdna-ingestion-key
metabase-benchmarks-database-password


task gen-benchmarks
task use-benchmarks


in gcp,gcp-services,cloudkms,kube-mgmt,benchmarks 


terraform init
terraform apply

Debugging

kubectl describe pod hatchet-api -n benchmarks

kubectl logs hatchet-api-79b87d78c9-k6n45 -n benchmarks --previous



need to get a build of hatchet-admin

then login to gcp
task gcp-login
cd keys

create benchmarks/credentials.json
sh generate-keys.sh

copy the two keys into the secrets

maybe go to

https://console.cloud.google.com/security/kms/key/manage/global/benchmarks/benchmarks?project=hatchet-benchmarks

and grab that key and put it in secrets




________

apply gcp_services
apply gcp

add secretes for

benchmarks-cert-manager-cloudflare-token
benchmarks-logdna-ingestion-key
metabase-benchmarks-database-password
benchmarks-tailscale-auth-key


apply kube_mgmt