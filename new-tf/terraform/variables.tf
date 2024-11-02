variable "powershell_script_path" {
  description = "Path to the PowerShell script"
  default     = "${path.module}/../scripts/powershell/my_powershell_script.ps1"
}

variable "shell_script_path" {
  description = "Path to the shell script"
  default     = "${path.module}/../scripts/shell/my_shell_script.sh"
}
