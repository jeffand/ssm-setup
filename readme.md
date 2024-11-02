# Terraform AWS SSM Document Setup and Execution

This repository provides a setup for creating and testing AWS Systems Manager (SSM) Documents using Terraform. It includes scripts and configurations to:

- Create a single SSM Document containing both PowerShell and shell scripts.
- Execute the SSM Document on target instances as a one-time command.
- Use Terraform to manage the infrastructure and AWS CLI to run the SSM Document.

## Table of Contents

- [Description](#description)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
- [Usage Instructions](#usage-instructions)
  - [Editing the Scripts](#editing-the-scripts)
  - [Initializing Terraform](#initializing-terraform)
  - [Planning and Applying Terraform Configuration](#planning-and-applying-terraform-configuration)
- [Testing and Verification](#testing-and-verification)
- [Variables and Customization](#variables-and-customization)
- [Notes and Considerations](#notes-and-considerations)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## Description

This project automates the creation and execution of an AWS SSM Document that contains both PowerShell and shell scripts. The scripts are maintained separately and included in the SSM Document using Terraform. The execution is triggered as a one-time command using the AWS CLI via a Terraform `null_resource`.

## Prerequisites

- **AWS Account**: An active AWS account with necessary permissions.
- **AWS CLI**: Installed and configured on your local machine.
- **Terraform**: Installed on your local machine.
- **AWS Credentials**: Configured AWS credentials with permissions to manage SSM Documents and execute commands.
- **SSM Agent**: Target instances must have the AWS SSM Agent installed and running.
- **IAM Role for Instances**: Target instances must have an IAM role with the `AmazonSSMManagedInstanceCore` policy attached.

## Project Structure

After running the setup script, the project structure will be as follows: