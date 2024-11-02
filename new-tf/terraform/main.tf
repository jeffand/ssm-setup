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
