#!/usr/bin/env bash

if [ ! -f setup.sh ]; then
    cat << EOS
OK, this is your first time running this.  Let's get some basics (you can edit setup.sh later if these change)

What environments would you like?  Examples:
    dev test prod
  or
    staging production

EOS
    echo -n "Environments (one line, space separated): "
    read ENVIRONMENTS

    cat << EOS
We break this up into components (e.g. network, database, compute) to allow you to focus on that specific section.
If you have a simple project with a single or small number of terraform files, simply enter "main".

Each component you enter becomes a subdirectory in your environment.
EOS
    echo -n "Components (one line, space separated): "
    read COMPONENTS
    cat << EOS > setup.sh
ENVIRONMENTS="$ENVIRONMENTS"
COMPONENTS="$COMPONENTS"
EOS
fi

source setup.sh

if [ -z "$ENVIRONMENTS" -o -z "$COMPONENTS" ]; then
    echo "You need to define your ENVIRONMENTS and COMPONENTS"
    exit 1
fi

TOP=$(pwd)
REL_TOP="../../.."
COMMON_DIR="$REL_TOP/common"
COMPONENT_DIR="$REL_TOP/modules"

if [ ! -d modules ]; then
    echo -n "I'm now ready to create your initial directory structure.  Press ENTER to begin: "
    read a
    echo " "
    for MOD in $COMPONENTS; do
        mkdir -p "$TOP/common/$MOD"
        touch "$TOP/common/$MOD/main.tf"
    done
    mkdir -p "$TOP/modules/example_module_you_will_remove"
    mkdir -p "$TOP/environment"
    touch "$TOP/environment/terraform.tfvars"
fi


for ENV in $ENVIRONMENTS; do
    for MOD in $COMPONENTS; do

        mkdir -p "$TOP/environment/$ENV/$MOD"
        touch "$TOP/environment/$ENV/$ENV.tfvars"

        if [ ! -f "$TOP/environment/$ENV/provider.tf" ]; then
            cat <<EOS > "$TOP/environment/$ENV/provider.tf"
# Setup AWS provider
provider "aws" {
  profile = "\${var.aws_profile}"
  region  = "\${var.aws_region}"
}
EOS
        fi

        pushd "$TOP/environment/$ENV/$MOD" > /dev/null
        [ "$1" == "quiet" ] || echo "Directory: environment/$ENV/$MOD"

        find . -name '*.tf' | while read FILE; do
            if [ ! -L $FILE ]; then
                echo " "
                echo "** WARNING: environment/$ENV/$MOD/${FILE:2:255} is only in $ENV environment --- If you want it to be across all environments, move to your common ($COMMON_DIR) directory"
                echo " "
            fi
        done

        find $REL_TOP/common/ -maxdepth 1 -type f | while read FILE; do
            rm -f $(basename "$FILE")
            ln -s "$FILE"
        done

        find $REL_TOP/common/$MOD/ -maxdepth 1 -type f | while read FILE; do
            rm -f $(basename "$FILE")
            ln -s "$FILE"
        done

        ln -sf $REL_TOP/Makefile .
        ln -sf $COMPONENT_DIR .
        if [ ! -L provider.tf ]; then
            rm -f provider.tf
            ln -s ../provider.tf .
        fi

        if [ ! -f .gitignore ]; then echo '*.tf' >> .gitignore; fi

        popd > /dev/null
    done
done

if [ `which tree` ]; then
    [ "$1" == "quiet" ] || echo " "
    [ "$1" == "quiet" ] || echo "If you want to see the results, run: tree -C"
fi