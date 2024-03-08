## Simple Notification Service (SNS) -> ECS Example

This is a guide explaining how to spin up an ECS cluster which responds to events from SNS, routed through Hatchet. All AWS resources are created in Terraform for reproducibility.

### Prerequisites

Make sure you have a Hatchet instance up and running (or you're using Hatchet cloud). You will need to have generated a token, you can see the docs [here](https://docs.hatchet.run/home/quickstart/installation) for more information.

### Step 1 - Create an ECR repository

The first step is to create a new ECR repository (or use an existing one). To do this, navigate to the `./ecr` folder and call the following:

```sh
terraform init
terraform apply
```

You will be prompted to input a name for your ECR repository - here you can put `sns-demo`.

This will give you output resembling the following:

```sh
1234567890.dkr.ecr.us-west-1.amazonaws.com/sns-demo
```

### Step 2 - Build the demo app

Next step is to build the demo application that gets run on Hatchet. This can be built by navigating to the `./demo-app` folder and calling:

```
docker build --platform linux/amd64 -t sns-demo .
```

After a few minutes, your image should be built, you can now call:

```sh
docker tag sns-demo <your-repository-url>:latest # note: replace with your image URL
docker push <your-repository-url>:latest # note: replace with your image URL
```

Copy this value, as you will need it in the next step.

### Step 3 - Start the ECS service

Next we build the ECS cluster and service using this image. To do this, navigate to `./ecs` and run the following:

```sh
terraform init
terraform apply
```

You will be prompted to input a Hatchet API token, which you should have grabbed in the Prerequisites section. You will also be prompted for the **full container url** that you pushed above, for example:

```sh
1234567890.dkr.ecr.us-west-1.amazonaws.com/sns-demo:latest
```

After running `terraform apply`, wait for a few minutes. If everything is spun up successfully, you will see the workers registered in the Hatchet UI under the **Workers** tab.

### Step 4 - Create the SNS topic

Navigate to `./sns-topic` and run the following:

```sh
terraform init
terraform apply
```

Make note of this topic ARN as you will need it below.

### Step 5 - Create an Ingestor URL in Hatchet

You will next create an ingestion endpoint which SNS can call. Navigate to your **Settings** tab in Hatchet, and scroll down to **SNS Integrations**. Click on **Create integration** and input the topic ARN that you created above. You will see an ingestor URL to copy which you will need below.

### Step 6 - Create the SNS Subscription

Finally, navigate to `./sns-subscription` and run:

```
terraform init
terraform apply
```

You will be prompted for the topic ARN from above along with the ingest URL.

### Smoke Test

Navigate to the AWS console and verify this subscription has been verified (in the SNS tab under **Subscriptions**). If it is failing, make sure you have input the ingest URL and topic ARN properly. You can also view the failure logs for the verification in Cloudwatch.

Next, navigate to the SNS topic in the AWS console and post a new message to the topic. After posting this message, you should see it show up in Hatchet, and you should see a new workflow triggered in Hatchet. It should look something like the following:

<img width="1728" alt="Screen Shot 2024-03-07 at 6 52 55 PM" src="https://github.com/hatchet-dev/hatchet-infra-examples/assets/25448214/9bbc3ffb-fd14-4875-b58f-8e826c18532e">
