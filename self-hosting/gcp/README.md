# Hatchet GCP -- Production-Ready Deployment

This guide walks you through deploying a production-ready instance of Hatchet. It provisions a new VPC, GKE, CloudSQL instance, and Hatchet helm chart and exposes a Hatchet instance on a domain of your choosing.

## Read the following before deploying

**This guide makes the following assumptions:**

1. You do not have an existing GKE cluster, this guide will provision a new one. This guide is also designed to be provisioned in an entirely new GCP project to minimize the amount of setup required.

2. You would like to expose Hatchet on an external domain. If you would not like to do this:

- Change the NGINX configuration [here](./modules/kube-mgmt/nginx_ingress.tf)
- Change the Hatchet configuration [here](./modules/hatchet/hatchet.tf)

3. You are using DNS managed by Cloudflare. This guide automatically provisions certificates using a Cloudflare API token which you provide. If you would not like to expose Hatchet externally, or you have a different certificate provisioning mechanism, you should modify the following files:

- Change the certificate provisioning mechanism in [`cert-manager`](./modules/kube-mgmt/cert_manager.tf)
- Change the certificate reference in [`hatchet`](./modules/hatchet/hatchet.tf)

**This guide costs money on GCP**

The instance will cost money to deploy. If you are finished with the instance, you can tear it down by following the instructions in [Destroying Resources](#destroying-resources).

## Prerequisites

This guide requires the following tools to be installed and available in your path:

- [`terraform`](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/)
- [`task`](https://taskfile.dev/installation/)

Additionally, you should have [created a GCP project](https://developers.google.com/workspace/guides/create-project).

## Provisioning Resources

### Step 1 - Infrastructure

The first step is to provision the VPC, GKE cluster, and CloudSQL database. This is done in the [infra module](./infra/main.tf). To start, run `task gcp-login` or make sure you have existing `gcloud` credentials to provision resources in your GCP account.

Next, export the following as env vars:

```sh
export TF_VAR_project="TODO" # your GCP project ID
export TF_VAR_region="us-west1" # your desired GCP region
export TF_VAR_env_name="hatchet" # the prefix your resources will inherit
```

Then, run `task provision-infra`, which will create all required infrastructure. After the creation process is complete, you can run `task gen-k8s-creds` to generate cluster credentials and connect to the cluster. You will also see two IP addresses logged after creating the infrastructure - these will be used later.

### Step 2 - Kubernetes Manifests

After the infrastructure has been set up, the next step is to create Kubernetes manifests that are required to expose Hatchet on a URL. To do this, simply run `task provision-kube` (making sure you have the same env variables as you set above).

### Step 3 - Install Hatchet

Finally, we'll get Hatchet up and running. To expose Hatchet on a domain, we'll need to generate a Cloudflare API token in order to sign certificates using DNS challenges. Navigate to the Cloudflare dashboard, click on the user icon in the top right, and click `My Profile > API Tokens > Create Token`. Create a token with the following settings:

**Permissions:**

- `Zone - DNS - Edit`
- `Zone - Zone - Read`

**Zone Resources:**

- `<my-domain>`

After creating the API token, export the following env vars:

```sh
# these were set previously
export TF_VAR_project="TODO" # your GCP project ID
export TF_VAR_region="us-west1" # your desired GCP region
export TF_VAR_env_name="hatchet" # the prefix your resources will inherit

# these are new
export TF_VAR_certificate_email="TODO" # an email address where certificate expiration emails will be sent
export TF_VAR_cloudflare_api_token_secret="TODO" # your token from above
export TF_VAR_hatchet_server_url=api.<mydomain> # your domain here
export TF_VAR_hatchet_engine_url=engine.<mydomain> # your domain here
```

Next, run `task provision-hatchet`. While that's running, you can update your DNS records in Cloudflare. Using the IP addresses from above (which you can retrieve using `task show-ips`), set the following DNS records:

- `api.<mydomain>` - create an `A` record that points to the `api_ip_address`. You can use Cloudflare proxying for this IP address.
- `engine.<mydomain>` - create an `A` record that points to the `engine_ip_address`. You **should not** use Cloudflare proxying for this IP address, **make sure you disable the proxy**. The reason is that Cloudflare does not have great support for gRPC using proxies, and this will break the SDKs.

## Destroying Resources

You can run `task destroy` in order to remove all infrastructure. This is basically equivalent to calling `terraform destroy` from within [`infra`](./infra/main.tf), with some small modifications to prevent resources from blocking the destruction process.
