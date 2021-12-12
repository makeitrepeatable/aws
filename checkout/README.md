# Scalable web application on AWS

## Description
This repo will deploy a scalable web application AWS



## Deployment

Infrastructure is deployed to AWS using github actions.

**Github Actions**

The configuration for the Actions pipeline lives in the root of this repo (`.github/workflows/checkout-deploy.yml`). To use:
1. Clone the repo
2. Log into github and upload `AWS_ACCESS_KEY` & `AWS_SECRET_KEY` as github secrets
3. Run deploy-checkout-aws workflow

The pipeline contains a deploy stage. This culd be enhanced by running the tests as part of the pipeline prior to the build stage, to be sure that the confoguration will be applied as expected. a PR pipeline could also be created to protect against breaking changes before the PR is merged.

The AWS secrets mentioned in step 2 above are passed as environment variables.

```
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.aws_access_key }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.aws_secret_key }}
jobs:
  deploy:
    name: Deploy
    runs-on: ubuntu-latest
    needs: test
    steps:
```


## Terraform

Terraform creates the following infrastructure in this repo

**Security groups**
<br />
Security groups define the ingress & egress for the web application:

```
  dynamic "ingress" {
    iterator = port
    for_each = var.ingress_ports
    content {
        ...
    }
  }
```
Terraform dynamic resources allow the user to simplify their code by iterating through the values passed in a variable with a complex data type. A `foreach` loop iterates through these values and uses an iterator to defined each configuration value.

**S3**
<br />
An S3 bucket stores the image displayed on the web page. Currently the bucket is public, but could easily be converted to a private bucket.

**Cloudfront**
<br />
Cloudfront is a CDN that sits in front of the S3 bucket and aims to reduce latency by caching images and serving them from closest endpoint to the request origin.

**EC2 Autoscale Group**
<br />
The autoscale group will launch a number of EC2 instances that host the web application based on load. 

**EC2 Launch Configuration**
<br />
The launch configuration defines how the new instances created within the ASG will be configured. In this use case, the launch configuration runs an inline bash script passed as `user_data` that removes the default apache index.html page and replaces it with a custom page with a header and an image.

```
  user_data       = <<-EOF
                        #!/bin/bash
                        # Do stuff
                      EOF
```

**Elastic load balancer**
<br />
The ELB distributes the traffic across the nodes in the ASG. It currently listens on port 80, but improvements could be made to offload SSL and secure the traffic to the web application behind it, along with a custom DNS entry.

## Terratest
A basic Terratest has been created that deploys the infrastructure and validates the hostname of the ELB. To use:
1. You'll need to install golang on the host operating system
2. cd into the tests directory and run `go test -v -timeout 30m`

## WIP
* Terratests throwing false negative because of padding on output, when run during pipeline on Ubuntu agent
* Implement private VPC with WAF as single entry point
* Implement remote state
* Add Cloudwatch config to monitor instances created and send alerts when an autoscale even occurs
* Look into action composition to avoid code duplication and promote reusable patterns
