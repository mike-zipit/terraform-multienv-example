# Introduction

After reviewing the Makefile used here by [the Rancher team](https://github.com/rancher/terraform-modules/blob/master/example_ha/aws/Makefile), I realized this was how I wanted to segregate my setups, rather than using something like terragrunt.  At a high level, I wanted:

* Different environments (staging, production) with the ability to use different classes of machines
* Shared setup of the *.tf files
* Ability to use different AWS acccounts (potentially) for each environment

This is that system.  Here's the effective directory setup:

NOTE:  At various times, I refer to Components and Modules.  Heres' how I see the different:

* Component -- This is a group of terraform files you run together.  For instance, the [the Rancher team](https://github.com/rancher/terraform-modules) broke their setup into 3 stages/components:  network, database, compute (mgmt)
* Modules -- These are 3rd party modules you use in each component

Within each environment (staging, production, etc), the only static files are typically `terraform.tfstate` (and backup).  Everything else is a simlink.

### Setup / Updating

* All your global variables end go in `common/variables.tf` that will be used throughout your application.  These will be instantiated in 2 different places
  * Global variables across all environments will be at `environment/terraform.tf`
  * Enter the environment specific variables in each environment-specific tfvars file.  For instance, you may have something like this:
    * `environment/staging/staging.tfvars`: `aws_instance_type = "t2.small"`
    * `environment/production/production.tfvars`: `aws_instance_type = "c4.2xlarge"`
* If you add new terraform.tf files to the common/* directory, they will automatically be included during your make commands

### Make targets

    plan:           Run terraform plan
    plan-output:    Run terraform plan and save output to a plan file
    plan-landscape: Run terraform plan and route the output thru landscape
    plan-destroy:   Run terraform plan -destroy and create a plan destroying your infrastructure 
    apply-plan:     Run terraform apply with using the PLAN environment variable


* landscape:  [Nice formatter for terraform output](https://github.com/coinbase/terraform-landscape)

### Running

    cd environment/staging/network
    make plan-output
    // (If all goes well, then run)
    PLAN=network-####### make apply-plan

OR, if you're crazy confident:

    rm -f *.plan; make plan-output; PLAN=$(ls -1 *.plan) make apply-plan

### Destroying

The first time I started playing with this makefile, I didn't get how to destroy things.  Turns out, it follows the same patter:

    cd environment/staging/network
    make plan-destroy
    // (If all goes well, then run)
    PLAN=network-####### make apply-plan
    
OR, if you're crazy confident:

    rm -f *.plan; make plan-destroy; PLAN=$(ls -1 *.plan) make apply-plan
  

### Example Directory Struccture

First time `update.sh` is run, I answered the with the following:

* Environments (one line, space separated): __staging production__
* Components (one line, space separated): __network database compute__

At the end, you can see the full directory structure

    .
    ├── common
    │   ├── compute
    │   │   └── main.tf
    │   ├── data.aws-ami-rancheros.tf
    │   ├── data.aws-ami-ubuntu.tf
    │   ├── database
    │   │   └── main.tf
    │   ├── network
    │   │   └── main.tf
    │   └── variables.tf
    ├── environment
    │   ├── production
    │   │   ├── compute
    │   │   │   ├── data.aws-ami-rancheros.tf -> ../../../common/data.aws-ami-rancheros.tf
    │   │   │   ├── data.aws-ami-ubuntu.tf -> ../../../common/data.aws-ami-ubuntu.tf
    │   │   │   ├── main.tf -> ../../../common/compute/main.tf
    │   │   │   ├── Makefile -> ../../../Makefile
    │   │   │   ├── modules -> ../../../modules
    │   │   │   ├── provider.tf -> ../provider.tf
    │   │   │   └── variables.tf -> ../../../common/variables.tf
    │   │   ├── database
    │   │   │   ├── data.aws-ami-rancheros.tf -> ../../../common/data.aws-ami-rancheros.tf
    │   │   │   ├── data.aws-ami-ubuntu.tf -> ../../../common/data.aws-ami-ubuntu.tf
    │   │   │   ├── main.tf -> ../../../common/database/main.tf
    │   │   │   ├── Makefile -> ../../../Makefile
    │   │   │   ├── modules -> ../../../modules
    │   │   │   ├── provider.tf -> ../provider.tf
    │   │   │   └── variables.tf -> ../../../common/variables.tf
    │   │   ├── network
    │   │   │   ├── data.aws-ami-rancheros.tf -> ../../../common/data.aws-ami-rancheros.tf
    │   │   │   ├── data.aws-ami-ubuntu.tf -> ../../../common/data.aws-ami-ubuntu.tf
    │   │   │   ├── main.tf -> ../../../common/network/main.tf
    │   │   │   ├── Makefile -> ../../../Makefile
    │   │   │   ├── modules -> ../../../modules
    │   │   │   ├── provider.tf -> ../provider.tf
    │   │   │   └── variables.tf -> ../../../common/variables.tf
    │   │   ├── production.tfvars
    │   │   └── provider.tf
    │   ├── staging
    │   │   ├── compute
    │   │   │   ├── data.aws-ami-rancheros.tf -> ../../../common/data.aws-ami-rancheros.tf
    │   │   │   ├── data.aws-ami-ubuntu.tf -> ../../../common/data.aws-ami-ubuntu.tf
    │   │   │   ├── main.tf -> ../../../common/compute/main.tf
    │   │   │   ├── Makefile -> ../../../Makefile
    │   │   │   ├── modules -> ../../../modules
    │   │   │   ├── provider.tf -> ../provider.tf
    │   │   │   └── variables.tf -> ../../../common/variables.tf
    │   │   ├── database
    │   │   │   ├── data.aws-ami-rancheros.tf -> ../../../common/data.aws-ami-rancheros.tf
    │   │   │   ├── data.aws-ami-ubuntu.tf -> ../../../common/data.aws-ami-ubuntu.tf
    │   │   │   ├── main.tf -> ../../../common/database/main.tf
    │   │   │   ├── Makefile -> ../../../Makefile
    │   │   │   ├── modules -> ../../../modules
    │   │   │   ├── provider.tf -> ../provider.tf
    │   │   │   └── variables.tf -> ../../../common/variables.tf
    │   │   ├── network
    │   │   │   ├── data.aws-ami-rancheros.tf -> ../../../common/data.aws-ami-rancheros.tf
    │   │   │   ├── data.aws-ami-ubuntu.tf -> ../../../common/data.aws-ami-ubuntu.tf
    │   │   │   ├── main.tf -> ../../../common/network/main.tf
    │   │   │   ├── Makefile -> ../../../Makefile
    │   │   │   ├── modules -> ../../../modules
    │   │   │   ├── provider.tf -> ../provider.tf
    │   │   │   └── variables.tf -> ../../../common/variables.tf
    │   │   ├── provider.tf
    │   │   └── staging.tfvars
    │   └── terraform.tfvars
    ├── Makefile
    ├── modules
    │   └── example_module_you_will_remove
    ├── README.md
    ├── setup.sh
    └── update.sh
    

