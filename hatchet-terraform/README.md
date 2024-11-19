# Terraform quickstart for deploying Hatchet in your own GCP cloud

## Google Cloud Project

Set the variable TF_VAR_project and the region TF_VAR_region for your project and region in google cloud.

Make sure and create this project in your own google cloud account in the chosen region.


```bash
export TF_VAR_project="hatchet"
export TF_VAR_region="us-west1"
export NAMESPACE="hatchet"
```

## Namespace

This deploys into the "hatchet" kubernetes namespace. 

## Google Cloud

This example deploys into google cloud. 

## Cloud SQL

This provisions a postgres cloud SQL DB defaulting to a db-custom-16-15360 (16 core DB with 15360 MB memory)

Modify 
```
TF_VAR_database_instance_type
```
to change this instance type.

## Terraform 

### Setup

- You will need terraform installed locally. (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- You will need kubectl installed locally. (https://kubernetes.io/docs/tasks/tools/)
- You will need task installed locally (https://taskfile.dev/installation/)

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

> **Note**
>  You may need to run the following to enable certain services in your GCP project if they have not been used before
> ```bash
> gcloud services enable sqladmin.googleapis.com compute.googleapis.com container.googleapis.com servicenetworking.googleapis.com secretmanager.googleapis.com --project=$TF_VAR_project
> ```
> If you do enable services it can take 5 - 10 minutes for the change to propagate. 

### Setup GCP 

```bash
cd gcp-services
terraform init
terraform apply
cd ../
```

```bash
cd deploy/environments/hatchet/gcp
terraform init
terraform apply
cd ../
```





You may need to run

```bash
gcloud services enable sqladmin.googleapis.com --project=$TF_VAR_project
```

depending on what services you have enabled for your account.

```bash
cd kube-mgmt
terraform init
terraform apply
cd ../
```

In the root.

Set up kubernetes
```bash
task gen-hatchet
task use-hatchet
```

and finally
### Deploy the Stack

```bash
cd hatchet
terraform init
terraform apply
cd ../
```


### Connect to the Dashboard

```bash
export POD_NAME=$(kubectl get pods --namespace $NAMESPACE -l "app=caddy" -o jsonpath="{.items[0].metadata.name}")
export CONTAINER_PORT=$(kubectl get pod --namespace $NAMESPACE $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
kubectl --namespace $NAMESPACE port-forward $POD_NAME 8080:$CONTAINER_PORT
```

Now navigate in your browser to 

http://localhost:8080/

And log in with the default demo user (change for production)


> User: admin@example.com
> Pass: Admin123!!

### Run a Workflow

A default worker will be running and workflows will have been executed. You can view them on the workflow run page and the Workers page.

Visit
http://localhost:8080/workflows?tenant=707d0855-80ab-4e1f-a156-f1c4546cbf52

to see the workflows. 

Select the 

```
ha-loadtester-v3
```

Workflow and click "Trigger Worfklow" 

Leaving everything blank hit "Trigger Workflow"

This will spawn 10 children and should complete. 

Navigate to 
http://localhost:8080/workflow-runs?tenant=707d0855-80ab-4e1f-a156-f1c4546cbf52&pageIndex=0&pageSize=50

and you should be able to see these workflows that have just been run.




### Troubleshooting

List any pods

```bash
kubectl get pods -n $NAMESPACE
```


view the logs from a pod (replace the name of the pod)
```bash
 kubectl logs hatchet-engine-fbcfdd967-gk7hk -n $NAMESPACE
 ```

describe a pod

```bash
kubectl describe pod hatchet-engine-7578cb58cd-d6w2c -n $NAMESPACE
```