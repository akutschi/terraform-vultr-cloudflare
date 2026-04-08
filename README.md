# Terraform Vultr Cloudflare Instance

This module allows you to easily create and manage **Vultr servers** while automatically updating your **Cloudflare DNS records**. It also generates an **Ansible inventory file** for the deployed servers, making it easier to manage them with Ansible.

> For simplicity, the module uses a `secrets.tfvars` file to store sensitive information like API keys and tokens. The better approach is to use environment variables or a secure secrets manager, but for the sake of this example, we will use the `secrets.tfvars` file.

## How to Use

### As a Module in Another Terraform Project

1. Add the module and the required providers to your Terraform configuration:
   ```hcl
    provider "vultr" {
    api_key = var.vultr_api_key
    }

    provider "cloudflare" {
    api_token = var.cloudflare_api_token
    }

    module "vultr_server" {
    source = "github.com/akutschi/terraform-vultr-cloudflare-instance"

    # Pass necessary variables here
    vultr_api_key = var.vultr_api_key
    cloudflare_api_token = var.cloudflare_api_token
    #cloudflare_api_key = var.cloudflare_api_key
    #cloudflare_email = var.cloudflare_email

    servers = {
    us = { region = "ewr", plan = "vhp-1c-1gb" }
    # uk = { region = "lhr", plan = "vhp-1c-1gb" }
    }

    ssh_key_name = "your_vultr_key_name"
    os_name = "Debian 13 x64 (trixie)"
    subdomain = "subdomain"
    domain = "tld.com"
    label = "vultr server"
    }
    ```

2. Initialize Terraform:
    
    ```bash
    terraform init
    ```

3. Plan the deployment:
    ```bash
    terraform plan -var-file="secrets.tfvars" -var-file="servers.tfvars"
    ```

4. Apply the deployment:
    ```bash
    terraform apply -var-file="secrets.tfvars" -var-file="servers.tfvars" 
    ```

5. After the deployment is complete, you can find the generated Ansible inventory file at `inventory.ini`.

6. To destroy the infrastructure when you no longer need it:
    ```bash
    terraform destroy -var-file="secrets.tfvars" -var-file="servers.tfvars"
    ```

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

> Important: Comment out what you are not using. Make sure to replace the placeholder values with your actual API keys and tokens.

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
    terraform init
    ```

7. Plan the deployment:
    ```bash
    terraform plan -var-file="secrets.tfvars" -var-file="servers.tfvars"
    ```

8. Apply the deployment:
    ```bash
    terraform apply -var-file="secrets.tfvars" -var-file="servers.tfvars" 
    ```

9. After the deployment is complete, you can find the generated Ansible inventory file at `inventory.ini`.

10. To destroy the infrastructure when you no longer need it:
    ```bash
    terraform destroy -var-file="secrets.tfvars" -var-file="servers.tfvars"
    ```

## Notes

- Ensure that you have the necessary permissions and API keys for both Vultr and Cloudflare.
- The `servers.tfvars` file allows you to easily configure the server settings, such as region, plan, SSH key, OS, and domain information.
- The generated Ansible inventory file can be used to manage the deployed servers with Ansible for further configuration and automation.
- Always **review the Terraform plan output before applying changes** to ensure that the expected resources will be created or modified.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
