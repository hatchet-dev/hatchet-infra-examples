# Configuring CloudKMS with Hatchet

By default, Hatchet uses public/private keysets for encryption which are generated from a single master key. These keysets can alternatively be generated from CloudKMS via envelope encryption.

This Terraform modules sets up a CloudKMS keyring and key and creates a service account for Hatchet with permissions to use that key for encryption and decryption.

## Step 1 -- Generating CloudKMS Keys

To use this module, first set the variables in either a `tfvars.json` file, calling this module as a child module, or passed via command input:

```
variable "env_name" {
  description = "The environment name"
}

variable "gcp_project_id" {
  description = "The GCP project ID"
}
```

After running `terraform init` and `terraform apply`, generate a `JSON` key file for the created service account and download it to your machine.

## Step 2 -- Generate public/private keysets

**Note:** these examples require a `hatchet-admin` binary to be present on the machine. This binary can be built from source by running `go build -o ./bin/hatchet-admin ./cmd/hatchet-admin` from the [Hatchet repository](https://github.com/hatchet-dev/hatchet), or can be run within a docker container via `docker run -it ghcr.io/hatchet-dev/hatchet/hatchet-admin:latest sh`.

Next, set the following environment variables:

```sh
export GCP_PROJECT_ID=<gcp_project_id>
export ENV_NAME=<env_name>
export CREDENTIALS_PATH=<path-to-credentials-json>
```

Finally, run `sh generate-keys.sh` to generate the keysets. They can be found at `./<env_name>/private_ec256.key` and `./<env_name>/public_ec256.key`.

## Step 3 -- Configure Hatchet to use the keysets

Then, pass the following environment variables to the Hatchet instance:

```sh
SERVER_ENCRYPTION_CLOUDKMS_ENABLED=t
SERVER_ENCRYPTION_CLOUDKMS_KEY_URI=gcp-kms://projects/<gcp_project_id>/locations/global/keyRings/<env_name>/cryptoKeys/<env_name> # TODO: replace gcp_project_id and env_name
SERVER_ENCRYPTION_CLOUDKMS_CREDENTIALS_JSON="<json file contents>"
SERVER_ENCRYPTION_JWT_PUBLIC_KEYSET="<public-keyset>"
SERVER_ENCRYPTION_JWT_PRIVATE_KEYSET="<private-keyset>"
```

You can alternatively specify file locations via:

```sh
SERVER_ENCRYPTION_JWT_PUBLIC_KEYSET_FILE
SERVER_ENCRYPTION_JWT_PRIVATE_KEYSET_FILE
```
