# Intro

This repo illustrates how I use Terraform with Microsoft Azure to create the necessary resources to run an Nginx webserver. The public IP of the server is output by the script upon completion. When navigating to this IP in a web browser, the Nginx start page should be shown. 

Before we can start automating the deployment of our infrastructure, we must ensure our local machine has the following prerequisites installed:

 1. Terraform
 2. Azure CLI
 3. Ansible

# Installing Prerequisites 

## Terraform 

```
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update && sudo apt install terraform
terraform -install-autocomplete
```

## Azure CLI

```
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az login
```

Running az login will open your browser and authenticate you. 

## Ansible

```
sudo apt update && sudo apt install -y ansible
```

# Running Terraform

Once you have terraform installed and Azure CLI authenticated, you can deploy the infrastructure defined in main.tf by running the following commands inside of this repo:

```
terraform init
terraform apply --auto-approve 2>&1 | tee terraform.log
```

I like to copy the output to a log file for good measure. You may also modify the variable values defined in `variables.tf` with your desired user, region, and key locations.

# More Info

For more detail on the concepts we used in this tutorial:
  * Read about the format of the configuration files in the [Terraform documentation](https://www.terraform.io/docs/language/index.html).
  * Learn more about [Terraform providers](https://www.terraform.io/docs/providers/index.html).
  * Review usage examples of the [Terraform Azure provider](https://github.com/terraform-providers/terraform-provider-azurerm/tree/master/examples) from Terraform provider engineers


