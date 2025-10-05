# AWS Access Control - VPC Core

Possible role assignments and permissions for **AWS VPC Core Resources**.

## Available Roles for VPC Core

| Role Name                       | Description                                                     |
|---------------------------------|-----------------------------------------------------------------|
| **VPC Administrator**           | Full access to manage VPC resources.                           |
| **Network Administrator**       | Can manage networking components.                              |
| **VPC Core Administrator**      | Can manage VPC core configurations.                            |

## Required Permissions

### VPC Management
- `ec2:CreateVpc`
- `ec2:DeleteVpc`
- `ec2:ModifyVpcAttribute`
- `ec2:DescribeVpcs`

## Common VPC Configurations

### Basic VPC
```hcl
vpc_core = {
  project_short = "myapp"
  region        = "us-west-2"
  context       = "networking"
  stage         = "prod"
  
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
}
```

## Security Best Practices

1. **DNS Resolution**: Enable DNS hostnames and support for service discovery
2. **CIDR Planning**: Plan CIDR blocks carefully to avoid conflicts
3. **Tagging**: Use consistent tagging for resource identification
