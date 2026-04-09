# Terraform Vultr Cloudflare Instance

This module allows you to easily create and manage **Vultr servers** while automatically updating your **Cloudflare DNS records**. It also generates an **Ansible inventory file** for the deployed servers, making it easier to manage them with Ansible.

> For simplicity, the module uses a `secrets.tfvars` file to store sensitive information like API keys and tokens. The better approach is to use environment variables or a secure secrets manager, but for the sake of this example, we will use the `secrets.tfvars` file.

## How to Use

### As a Module in Another Terraform Project

1. Add the module and the required providers to your Terraform configuration:
   ```hcl
    terraform {
    required_providers {
        vultr = {
        source  = "vultr/vultr"
        version = "~> 2"
        }
        cloudflare = {
        source  = "cloudflare/cloudflare"
        version = "~> 5"
        }
        local = {
        source  = "hashicorp/local"
        version = "~> 2"
        }
    }
    }

    # ===============================================
    # Providers
    # ===============================================

    provider "vultr" {
    api_key = var.vultr_api_key
    }

    provider "cloudflare" {
    api_token = var.cloudflare_api_token
    }

    # ===============================================
    # Module
    # ===============================================

    module "wireguard_server" {
    source = "github.com/akutschi/terraform-vultr-cloudflare?ref=v0.1.1"

    vultr_api_key        = var.vultr_api_key
    cloudflare_api_token = var.cloudflare_api_token
    ssh_key_name         = var.ssh_key_name
    os_name              = var.os_name
    servers              = var.servers
    firewall_group_rules = var.firewall_group_rules
    domain               = var.domain
    subdomain            = var.subdomain
    label                = var.label
    inventory_dir        = path.root
    }
    ```

> Reference to the correct version (here v0.1.1) of the module is important to ensure compatibility. You can check the available versions on the [GitHub repository](https://github.com/akutschi/terraform-vultr-cloudflare/releases).

2. Copy over the variables.tf file from the module to your project. 

3. Go to the standalone project instructions and start at step 4 to create the `secrets.tfvars` and `servers.tfvars` files, initialize Terraform, and apply the configuration.


### As a Standalone Project

1. Clone the repository:
   ```bash
    git clone https://github.com/akutschi/terraform-vultr-cloudflare-instance.git
    ```

2. Navigate to the project directory:
   ```bash   
    cd terraform-vultr-cloudflare-instance
    ```

3. Add provider to the `main.tf` file:
   ```hcl
    provider "vultr" {
    api_key = var.vultr_api_key
    }

    provider "cloudflare" {
    api_token = var.cloudflare_api_token
    }
    ```

4. Create a `secrets.tfvars` file in the project root and add your Vultr API key and Cloudflare API token. Instead using the Cloudflare API token the Cloudflare API key and the email can be used, but the API token is recommended for better security and granular permissions:
    ```hcl
    vultr_api_key = "your_vultr_api_key"

    cloudflare_api_token = "your_cloudflare_api_token"
    #cloudflare_api_key = "your_cloudflare_api_key"
    #cloudflare_email = "your_cloudflare_email"
    ``` 

> Important: Comment out what you are not using. Make sure to replace the placeholder values with your actual API keys and tokens. See notes for more details on using API keys vs API tokens for Cloudflare.

5. Create a `servers.tfvars` file in the project root and define your server configurations:
    ```hcl
    # ====================
    # Servers
    # ====================

    servers = {
    us = { region = "ewr", plan = "vhp-1c-1gb" }
    # uk = { region = "lhr", plan = "vhp-1c-1gb" }
    }

    # ====================
    # Firewall Group Rules
    # ====================

    firewall_group_rules = {
    ssh       = { protocol = "tcp", port = "22" }
    }

    # ====================
    # Settings
    # ====================

    ssh_key_name = "your_vultr_key_name"
    os_name = "Debian 13 x64 (trixie)"
    subdomain = "subdomain"
    domain = "tld.com"
    label = "vultr server"
    ```

>  Keep `secrets.tfvars` and `servers.tfvars` secure and do not commit them to version control.

6. Initialize Terraform:
    
    ```bash
    tofu init
    ```

7. Plan the deployment:
    ```bash
    tofu plan -var-file="secrets.tfvars" -var-file="servers.tfvars"
    ```

8. Apply the deployment:
    ```bash
    tofu apply -var-file="secrets.tfvars" -var-file="servers.tfvars" 
    ```

9. After the deployment is complete, you can find the generated Ansible inventory file at `inventory.ini`.

10. To destroy the infrastructure when you no longer need it:
    ```bash
    tofu destroy -var-file="secrets.tfvars" -var-file="servers.tfvars"
    ```

## Notes

- **The shell command uses `tofu` from OpenTofu, which is a replacement for Terraform. You can replace `tofu` with `terraform` if you prefer to use Terraform directly.**
- Ensure that you have the necessary permissions and API keys for both Vultr and Cloudflare.
- The `servers.tfvars` file allows you to easily configure the server settings, such as region, plan, SSH key, OS, and domain information.
- The generated Ansible inventory file can be used to manage the deployed servers with Ansible for further configuration and automation.
- Always **review the Terraform plan output before applying changes** to ensure that the expected resources will be created or modified.
- If you want to use your Cloudflare API key and email instead of an API token, make sure to update the `main.tf` file accordingly and provide the necessary values in the `secrets.tfvars` file. However, using an API token with the least privileges necessary is recommended for better security.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
