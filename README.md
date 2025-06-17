# Juicebox Software Realm

This project contains all the software necessary to run a Juicebox Software Realm on the hosting provider of your choice.

We recommend adding at least one software backed realm to your configuration alongside Juicebox's hardware backed realms. Utilizing realms hosted in different cloud providers and maintained by different authorities – in addition to Juicebox's hardware backed realms – can increase the security of your user secrets. With this diversity in your configuration, you would have to compromise at least `recover_threshold` different realm providers before you could even attempt to recover a secret (and you'd _still_ have to gain access to their PIN in order to decrypt the secret).

## Usage

```
Usage of jb-sw-realm:
  -id string
    	A 16-byte hex string identifying this realm. (default random)

    	Note: Changing this id for an existing realm will result in data loss.
  -port int
    	The port to run the server on. (default 8080)
  -provider string
        The provider to use. [gcp|aws|mongo|memory] (default "memory")

    	Some providers take additional configuration via environment variables.

    	gcp:
    	    BIGTABLE_INSTANCE_ID = The id of your Bigtable instance in GCP
    	    GCP_PROJECT_ID       = The id of your project in GCP
    	aws:
    	    AWS_REGION_NAME      = The name of the region your AWS instance is in

    	    Note: AWS uses DynamoDB and assumes you have a table created with a name
    	          matching your realm id and a partitionKey named recordID.
    	mongo:
    	    MONGO_URL = The url to acess your MongoDB instance in the form of:
    	                mongodb://username:password@host:port/database


    	    Note: User records are stored in a collection named "userRecords".
    	    Tenant signing keys are stored in a collection named "tenantSecrets".
    	memory:
    	    TENANT_SECRETS = The versioned tenant secrets, in JSON format.
    	                     For example: {"tenantName":{"1":"tenantSecretKey"}}
```

Compile the Juicebox Software Realm with `go build ./cmd/jb-sw-realm` or compile and run with `go run ./cmd/jb-sw-realm/`.

To quickly spin up a local realm for testing, you can run:

 ```sh
TENANT_SECRETS='{"test":{"1":"an-auth-token-key"}}' jb-sw-realm -port 8080
 ```

## Running a Realm

This software is setup to be portable to the cloud provider of your choice.

In order to run a realm you will generally need to:
1. Clone this repo
2. Choose a provider to manage your data
3. Initialize the provider environment with Terraform
4. Upload the realm software you to your provider

## Tenant Auth Secrets

Realm software is structured to operate in a multi-tenant environment. In order to validate access from different tenants, your realm will need access to the JWT signing key for each tenant you plan to support. You may add support for additional tenants at any time in the future.

In general, regardless of provider, tenant secrets are stored in the following fashion:

```json
{
	"jb-sw-tenant-{{yourTenantName}}" : {"{{keyVersion}}" : "{{yourSigningKey}}"},
	"jb-sw-tenant-acme" : {"1" : "acme-tenant-secret"},
}
```

Note: Tenant names should be unique alphanumeric strings. Key versions should be non-negative integer values, which are generally incremented when you upload a new key for a tenant.

The realm software will determine which tenant key to validate on a request by accessing the "kid" header field on a received JWT auth token. This field will be provided in the format of `tenantName:1`.

## GCP

The `gcp/` directory is now a Terraform module which can be leveraged in your own Terraform codebase. For example:

```terraform
module "juicebox-software-realm" {
  source = "github.com/rpcpool/juicebox-software-realm.git//gcp"

  project_id             = "your-project-id"
  realm_id               = "99b2da84b7076203dc35804bbbcb8cba"
  region                 = "europe-west3"
  zone                   = "c"
  tenant_secrets         = {"acme":"acme-tenant-key","anotherTenant":"another-tenant-key"}
  juicebox_image_url     = "path/to/juicebox/container/image"
  juicebox_image_version = "latest"
  otelcol_image_url      = "path/to/otel/collector/container/image"
  otelcol_image_version  = "latest"
  otelcol_config_b64     = filebase64("otel-collector-config.yaml")
}
```

This will deploy an instance of Juicebox Software Realm along with the necessary infrastructure that supports it. Please note that you will either need to deploy the Juicebox and OpenTelemetry Collector containers to a repository in GCP, or else use a remote repository which caches them from GitHub.

## AWS

The following instructions will help you quickly deploy a realm to Amazon's Elastic Beanstalk.

To begin, initialize your environment with terraform as follows:
```sh
cd aws
terraform init
terraform plan -var='tenant_secrets={"acme":"acme-tenant-key","anotherTenant":"another-tenant-key"}'
terraform apply -var='tenant_secrets={"acme":"acme-tenant-key","anotherTenant":"another-tenant-key"}'
```

Note: you should update the tenant secrets `var` to reflect the actual secrets you wish to support.

After terraform has finished configuring your project environment, you should see an output like follows:
```sh
CLOUDFRONT_DOMAIN = "https://d1oivazt933sey.cloudfront.net"
```

You can view your newly deploy Elastic Beanstalk environment at the returned URL, but for now it's just going to render an example application.

To deploy the realm software and replace the example site, you'll need to install the `eb` command line tools. You can find instructions on how to install these [here](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install.html).

Once installed, from the root of the repo run the command:
```sh
eb init
```

You will be presented with a number of prompts. In general, you can select the default options *except* for the following questions:
1. Use the region you selected in Terraform
2. Choose the existing "jb-sw-realm" as the application to use
3. Choose the existing "jb-sw-realm" as the environment to use

Once initialized, you can now deploy the realm software by running the following command from the root of the repo:
```sh
eb deploy jb-sw-realm
```

This may take a few minutes, but upon success you should be able to access your realm using the URL returned by terraform earlier.

If all was successful, you'll see a page render that looks something like:
```json
{"realmID":"99b2da84-b707-6203-dc35-804bbbcb8cba"}
```

To finish setup and start using your realm, you will want to configure your CloudFront distribution with a custom domain. You can do so by visiting:
https://console.aws.amazon.com/cloudfront

## Other Providers

If you'd like to host a realm on another provider, or with a configuration other than the ones described above, you will need to choose a provider and manually configure your environment.

For your convenience, a Dockerfile is provided that can run a realm on most hosting platforms once properly configured.

The available configuration variables, beyond the args on the `jb-sw-realm` binary are as follows:

* **REALM_ID**: A unique ID representing your realm. This is ignored if the `-id` flag is specified.
* **PROVIDER**: The provider you wish to use [gcp|aws|mongo|memory]. This is ignored if the `-provider` flag is specified.
* **BIGTABLE_INSTANCE_ID**: The id of your bigtable instance in GCP. This is only read when using the `GCP` provider.
* **GCP_PROJECT_ID**: The id of your project in GCP. This is only read when using the `GCP` provider.
* **AWS_REGION_NAME**: The name of your region in AWS. This is only read when using the `AWS` provider.
* **MONGO_URL**: The fully qualified URL to your mongo database, such as `mongodb://username:password@host:port/database`. This is only read when using the `Mongo` provider.
* **TENANT_SECRETS**: A list of versioned tenant secrets in the form of `'{"test":{"1":"an-auth-token-key"}}'`. This is only used if the `memory` provider is specified.
* **OPENTELEMETRY_ENDPOINT**: The URL to an OpenTelemetry gRPC service where tracing data should be sent.

## Metrics and Tracing

If you want to gather metrics and tracing information from your realm, it is configured to report to a GRPC server at `OPENTELEMETRY_ENDPOINT`. The `Dockerfile` in this repo is configured to launch `jb-sw-realm` alongside an Open Telemetry Collector, which is one way you can gather this info. You can edit the `otel-collector-config.yml` to customize the export settings to your liking – by default, it expects a `DD_API_KEY` and `DD_SITE` environment variable to export to Datadog.

If you are using the Dockerized version in AWS ensure that the "Disable IMDSv1"
option is checked in the configuration. Otherwise the process inside the docker
container does not have access to IMDSv2 and renewing access tokens will be slow
while it times out IMDSv2 and falls back to IMDSv1. Checking the "Disable IMDSv1"
option will cause EC2 instance to have the metadata hop limit set to 2, allowing
access to the metadata service from within the docker container.

### GCP

To deploy to App Engine Flex with tracing enabled, you can deploy a docker image instead of allowing Google to build an image for you. You will need to set up a repository in Artifact Registry to push your image to.

This looks something like the following:
```sh
docker build --platform=linux/amd64 -t jb-sw-realm .
docker tag jb-sw-realm us-west1-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REPOSITORY_NAME}/jb-sw-realm
docker push us-west1-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REPOSITORY_NAME}/jb-sw-realm
gcloud app deploy --appyaml=app.yaml --image-url=us-west1-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REPOSITORY_NAME}/jb-sw-realm
```

Note: Make sure to configure `OPENTELEMETRY_ENDPOINT` to `localhost:4317` in your `app.yaml` as well as adding any other environment parameters you need, such as `DD_API_KEY`.

### AWS

To deploy to Elastic Beanstalk with tracing enabled, you can update your environment to use the Docker solution stack instead of the Go solution stack. Additionally, you will need to define the appropriate additional environment properties on your configuration.
