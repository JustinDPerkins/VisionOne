# Vision One Endpoint Security Agent Deployment

This guide explains how to use an AWS Systems Manager (SSM) Document to deploy the Vision One Endpoint Security Agent on Linux and Windows systems.

## Prerequisites

Before you begin, make sure you have the following:

- AWS account with appropriate permissions to use SSM.
- AWS CLI and SSM Agent installed and configured on the target instances.
- S3 Bucket with Vision One Endpoint Security Agent Software Packages uploaded.

---

## SSM Document

To deploy the Vision One Endpoint Security Agent using this SSM Document, you'll need to provide the following parameters:

- `LinuxBucketURI` (String): The S3 URI for the Linux Tar Package. Example: `s3://your-bucket/linux/TM-Linux-Agent.tar`
- `WindowsBucketURI` (String): The S3 URI for the Windows Zip Package. Example: `s3://your-bucket/windows/TM-Windows-Agent.zip`

### This Document is currently made available in the AWS US-EAST-1 region.
[See here](https://us-east-1.console.aws.amazon.com/systems-manager/documents/VisionOneAgentDeployment/description?region=us-east-1)

### Need to deploy in another AWS Region?

Deploy the CloudFormation Template [here](https://github.com/JustinDPerkins/VisionOne/blob/main/EndpointSecurity/Deployments/AWS/SSM/v1es.ssm.template.yaml) in any region.

---

### Contents

The SSM Document that will be run is defined as follows:

```yaml
schemaVersion: "2.2"
description: "Deploy Vision One Endpoint Security Agent."
parameters:
  LinuxBucketURI:
    type: "String"
    description: "The S3 URI for Linux Tar Package."
  WindowsBucketURI:
    type: "String"
    description: "The S3 URI for Windows Zip Package."
mainSteps:
  - precondition:
      StringEquals:
        - "platformType"
        - "Linux"
    action: "aws:runShellScript"
    name: "runLinuxDeployment"
    inputs:
      runCommand:
        - 'if [ -e /tmp/TM-Linux-Agent.tar ]; then'
        - '    echo "Trend V1 Linux Agent package already exists in path."'
        - 'else'
        - '    aws s3 cp {{ LinuxBucketURI }} /tmp/TM-Linux-Agent.tar'
        - '    tar -xvf /tmp/TM-Linux-Agent.tar'
        - '    ./tmxbc install'
        - 'fi'
  - precondition:
      StringEquals:
        - "platformType"
        - "Windows"
    action: "aws:runPowerShellScript"
    name: "runWindowsDeployment"
    inputs:
      runCommand:
        - 'if (Test-Path -Path "C:\Temp\TM-Windows-Agent.zip") {'
        - '    Write-Host "Trend V1 Windows Agent package already exists in path."'
        - '} else {'
        - '    aws s3 cp {{ WindowsBucketURI }} C:\\Temp\\TM-Windows-Agent.zip'
        - '    Expand-Archive -Path "C:\Temp\TM-Windows-Agent.zip" -DestinationPath "C:\Temp\\"'
        - '    C:\\Temp\\TM-Windows-Agent\\EndpointBasecamp.exe'
        - '}'
