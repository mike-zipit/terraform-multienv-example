# Courtesy of https://github.com/rancher/terraform-modules/blob/master/example_ha/aws/Makefile
COMPONENT := $(shell basename $$PWD)
ENVIRONMENT := $(shell basename $(dir $(abspath $(dir $$PWD))))
TIMESTAMP := $(shell date +%Y-%m-%d-%H%M%S)

.PHONY: get plan plan-destroy plan-output apply

state-pull:
	@terraform remote pull

update:
	cd ../../../ && bash update.sh quiet

get: update
	@terraform get

plan: get
	@terraform plan $(RESOURCES) -var-file ../../terraform.tfvars -var-file ../$(ENVIRONMENT).tfvars -var-file ./$(COMPONENT).tfvars

plan-output: get
	@terraform plan $(RESOURCES) -var-file ../../terraform.tfvars -var-file ../$(ENVIRONMENT).tfvars -var-file ./$(COMPONENT).tfvars -out $(COMPONENT)-$(TIMESTAMP).plan

plan-landscape: get
	if [ -n `which landscapex` ]; then echo "\n\nInstall landscape from https://github.com/coinbase/terraform-landscape\n\n"; exit 1; fi
	@terraform plan $(RESOURCES) -var-file ../../terraform.tfvars -var-file ../$(ENVIRONMENT).tfvars -var-file ./$(COMPONENT).tfvars -out $(COMPONENT)-$(TIMESTAMP).plan | landscape

plan-destroy: get
	@terraform plan $(RESOURCES) -var-file ../../terraform.tfvars -var-file ../$(ENVIRONMENT).tfvars -var-file ./$(COMPONENT).tfvars -destroy -out $(COMPONENT)-$(TIMESTAMP).plan

apply: get
	@terraform apply -var-file ../../terraform.tfvars -var-file ../$(ENVIRONMENT).tfvars -var-file ./$(COMPONENT).tfvars

apply-plan:
	@terraform apply $(PLAN)

clean:
	@rm *.plan