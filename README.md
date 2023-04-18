# DeployVMWithTerraform

This repository contains a Terraform configuration for deploying an Ubuntu virtual machine on Azure with an existing virtual network and a GitHub Actions workflow to automate the deployment process.

## Prerequisites

1. An Azure account with an active subscription.
2. A configured [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) or [Azure PowerShell](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps) on your local machine.
3. [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
4. A GitHub account and an existing GitHub repository.

## Repository structure

The repository is organized as follows:
`|- .github
|- Workflows
    |- terraform_deploy.yml
|- src
    |- main.tf
    |- terraform.tfvars
    |- variables.tf
|- util
    |- tree.ps1
    |- DirectoryStructure.txt
|- README.md`

## Files

- `main.tf`: Contains the Terraform configuration to deploy an Ubuntu VM on Azure with an existing virtual network.
- `variables.tf`: Defines the input variables used in the Terraform configuration.
- `outputs.tf`: Defines the output values generated by the Terraform configuration.
- `terraform.tfvars`: Contains values for the input variables.
- `.github/workflows/terraform.yml`: The GitHub Actions workflow to automate the deployment process.

## Setup

1. Clone the repository: `git clone https://github.com/emrgcl/DeployVMWithTerraform.git`
1. Replace the placeholder values in the `terraform.tfvars` file with your desired values. Make sure to use a strong and unique password for the `admin_password` variable. Also, update the existing virtual network name, resource group name, and subnet name to match your existing resources.
1. Configure your Azure CLI or Azure PowerShell by running `az login` or `Connect-AzAccount`, respectively.
1. run the powershell script in the util folder to prepare azure and set github secrets.
   ```PowerShell
   .\CreateGitHubSecrets.ps1 -tenantId "<TENANT_ID>" -subscriptionId "<SUBSCRIPTION_ID>" -githubToken "<GITHUB_TOKEN>" -githubOwner "<GITHUB_OWNER>" -githubRepo "<GITHUB_REPO>"
   ```
1. Initialize Terraform: `terraform init`
1. Apply the Terraform configuration: `terraform apply`
1. Add a GitHub Personal Access Token with the `repo` scope as a secret named `GH_TOKEN` in your GitHub repository settings.
1. Update the `<your-github-username>` and `<your-repo-name>` placeholders in the `.github/workflows/terraform.yml` file with your GitHub username and repository name.
1. Create a new environment in your GitHub repository with the same name specified in the `terraform.yml` file (e.g., "production"). Add required reviewers for approving deployments in the environment settings.
1. Push your changes to the `main` branch:
   ```
   git add .
   git commit -m "Initial setup"
   git push origin main
   ```
1. The GitHub Actions workflow will run automatically when changes are pushed to the `main` branch.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
