#!/bin/bash

# setup_project.sh
# This script sets up the project directory structure and creates base Terraform and script files.
# Usage: ./setup_project.sh [project-root-directory]

# Check if a project root directory is provided as an argument
if [ -n "$1" ]; then
  PROJECT_ROOT="$1"
else
  PROJECT_ROOT="project-root"
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
variable "powershell_script_path" {
  description = "Path to the PowerShell script"
  default     = "\${path.module}/../scripts/powershell/my_powershell_script.ps1"
}

variable "shell_script_path" {
  description = "Path to the shell script"
  default     = "\${path.module}/../scripts/shell/my_shell_script.sh"
}
EOL

# Create Terraform main file
cat <<'EOL' > "$PROJECT_ROOT/terraform/main.tf"
provider "aws" {
  region = "us-east-1"  # Replace with your desired AWS region
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
EOL

# Create an empty outputs.tf file
touch "$PROJECT_ROOT/terraform/outputs.tf"

echo "Project structure created successfully in '$PROJECT_ROOT'."