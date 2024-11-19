# Terraform Quickstart for deploying Hatchet on your own Infra

## Google Cloud Project

This example uses a project called

hatchet-benchmarks

Create this project in your own google cloud account.

## Namespace

This deploys into the "benchmarks" kubernetes namespace. If you wish to use a different kubernetes namespace find and replace all instances of benchmarks in the folders below this.

## Google Cloud

This example deploys into google cloud. 

## Cloud SQL

This provisions a postgres cloud SQL DB defaulting to a db-custom-16-15360 (16 core DB with 15360 MB memory)

## Terraform 

### Setup

You will need terraform installed locally. (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
You will need kubectl installed locally. (https://kubernetes.io/docs/tasks/tools/)
You will need task installed locally (https://taskfile.dev/installation/)

### Login to GCP

In the root directory run i.e. this one run

```bash
task gcp-login
```
and log in to your GCP. You will need re-login every day or so when deploying or making changes.

You may also need to run

```bash
gcloud auth login
```

to log in to your gcloud account in the terminal.

```bash
task gen-benchmarks
task use-benchmarks
```

### Setup GCP 

```bash
cd deploy/gcp
terraform init
terraform apply
cd ../../
```

```bash
cd deploy/gcp-services
terraform init
terraform apply
cd ../../
```

You may need to run

```bash
gcloud services enable sqladmin.googleapis.com --project=hatchet-benchmarks
```

depending on what services you have enabled for your account.

```bash
cd deploy/kube-mgmt
terraform init
terraform apply
cd ../../
```

and finally
### Deploy the Stack

```bash
cd deploy/benchmarks
terraform init
terraform apply
cd ../../
```


### Connect to the Dashboard

```bash
export POD_NAME=$(kubectl get pods --namespace $NAMESPACE -l "app=caddy" -o jsonpath="{.items[0].metadata.name}")
export CONTAINER_PORT=$(kubectl get pod --namespace $NAMESPACE $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
kubectl --namespace $NAMESPACE port-forward $POD_NAME 8080:$CONTAINER_PORT
```

Now navigate in your browser to 

http://localhost:8080/


### Troubleshooting

List any pods

```bash
kubectl get pods -n benchmarks
```


view the logs from a pod (replace the name of the pod)
```bash
 kubectl logs hatchet-engine-fbcfdd967-gk7hk -n benchmarks
 ```

describe a pod

```bash
kubectl describe pod hatchet-engine-7578cb58cd-d6w2c -n benchmarks
```