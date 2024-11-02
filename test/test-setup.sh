#!/bin/bash

# setup_test_environment.sh
# This script sets up the test environment by creating the necessary directory structure,
# placeholder scripts, and Terraform configuration files for the SSM document execution.

# Usage: ./setup_test_environment.sh [project-root-directory]

# Function to display usage
usage() {
  echo "Usage: $0 [project-root-directory]"
  echo "If no project root directory is specified, 'project-root' will be used by default."
  exit 1
}

# Check for help option
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  usage
fi

# Set project root directory
if [ -n "$1" ]; then
  PROJECT_ROOT="$1"
else
  PROJECT_ROOT="project-root"
fi

# Check if the project root directory already exists
if [ -d "$PROJECT_ROOT" ]; then
  echo "Error: Directory '$PROJECT_ROOT' already exists."
  read -p "Do you want to overwrite it? (y/n): " choice
  case "$choice" in
    y|Y )
      echo "Overwriting '$PROJECT_ROOT'..."
      rm -rf "$PROJECT_ROOT"
      ;;
    * )
      echo "Aborting setup."
      exit 1
      ;;
  esac
fi

# Create the directory structure
mkdir -p "$PROJECT_ROOT/scripts/powershell"
mkdir -p "$PROJECT_ROOT/scripts/shell"
mkdir -p "$PROJECT_ROOT/terraform"

# Create placeholder PowerShell script
cat <<EOL > "$PROJECT_ROOT/scripts/powershell/my_powershell_script.ps1"
# my_powershell_script.ps1
Write-Host "Hello from PowerShell script!"
EOL

# Create placeholder shell script
cat <<EOL > "$PROJECT_ROOT/scripts/shell/my_shell_script.sh"
#!/bin/bash
# my_shell_script.sh
echo "Hello from shell script!"
EOL

# Make the shell script executable
chmod +x "$PROJECT_ROOT/scripts/shell/my_shell_script.sh"

# Create Terraform variables file
cat <<EOL > "$PROJECT_ROOT/terraform/variables.tf"
variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "The AWS CLI profile to use"
  type        = string
  default     = "default"
}

variable "powershell_script_path" {
  description = "Path to the PowerShell script"
  default     = "\${path.module}/../scripts/powershell/my_powershell_script.ps1"
}

variable "shell_script_path" {
  description = "Path to the shell script"
  default     = "\${path.module}/../scripts/shell/my_shell_script.sh"
}

variable "target_tags" {
  description = "Tags to identify target instances"
  type        = map(string)
  default     = {
    Environment = "Test"
  }
}
EOL

# Create Terraform main file
cat <<'EOL' > "$PROJECT_ROOT/terraform/main.tf"
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

locals {
  powershell_script_content = file(var.powershell_script_path)
  shell_script_content      = file(var.shell_script_path)
}

resource "aws_ssm_document" "combined_script" {
  name            = "CombinedScriptDocument"
  document_type   = "Command"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "2.2",
    description   = "SSM Document with both PowerShell and Shell scripts",
    mainSteps     = [
      {
        action       = "aws:runPowerShellScript",
        name         = "RunPowerShellScript",
        precondition = {
          StringEquals = ["platformType", "Windows"]
        },
        inputs       = {
          runCommand = [local.powershell_script_content]
        }
      },
      {
        action       = "aws:runShellScript",
        name         = "RunShellScript",
        precondition = {
          StringEquals = ["platformType", "Linux"]
        },
        inputs       = {
          runCommand = [local.shell_script_content]
        }
      }
    ]
  })
}

resource "null_resource" "run_ssm_document" {
  depends_on = [aws_ssm_document.combined_script]

  provisioner "local-exec" {
    command = <<-EOT
      aws ssm send-command \
        --document-name "${aws_ssm_document.combined_script.name}" \
        --targets '${self.triggers.targets}' \
        --region "${var.aws_region}" \
        --profile "${var.aws_profile}" \
        --comment "Running SSM Document via Terraform"
    EOT
    interpreter = ["bash", "-c"]
  }

  triggers = {
    targets = jsonencode([
      for key, value in var.target_tags : {
        Key    = "tag:${key}"
        Values = [value]
      }
    ])
  }
}
EOL

# Create an empty outputs.tf file
touch "$PROJECT_ROOT/terraform/outputs.tf"

echo "Test environment setup completed successfully in '$PROJECT_ROOT'."