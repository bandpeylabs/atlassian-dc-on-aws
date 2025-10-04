# Enterprise-Scale Jira & Confluence Deployment on AWS

## Why This Solution Accelerator?

> **Important**: Atlassian has ended support for the AWS Quick Start template. The template is no longer maintained or updated, and AWS launch configurations used by the template are being deprecated in favor of launch templates.

**Atlassian now recommends deploying Data Center products on Kubernetes using their official Helm charts** for a more efficient, robust, and maintainable infrastructure setup.

This solution accelerator provides a **production-ready template** that fills this gap by offering:

- **Complete Infrastructure as Code**: Terraform modules for AWS infrastructure (EKS, RDS, EFS, VPC)
- **Helm-based Deployment**: Leverages official Atlassian Helm charts for Jira and Confluence
- **Ready-to-Deploy**: Pre-configured templates with enterprise-grade settings
- **AWS Best Practices**: Implements current AWS services and deployment patterns
- **Maintained & Modern**: Uses actively supported technologies and deployment methods

## Solution Accelerator Overview

This solution accelerator provides enterprise-grade deployment patterns for Atlassian Data Center products on AWS infrastructure. Many enterprises require Atlassian tools like Jira and Confluence to be hosted on their own infrastructure for compliance, security, and control requirements.

Atlassian Data Center is the self-managed edition designed for enterprise environments, offering enhanced deployment flexibility and administrative control for mission-critical instances.

## Recommended Architecture

### Technology Stack

| Component                  | Atlassian Recommendation                | Our Specific Choice            | Rationale                                                                           |
| -------------------------- | --------------------------------------- | ------------------------------ | ----------------------------------------------------------------------------------- |
| **Container Platform**     | Kubernetes                              | Amazon EKS                     | EKS provides managed Kubernetes with AWS integration, reducing operational overhead |
| **Application Deployment** | Helm Charts                             | Official Atlassian Helm Charts | Atlassian maintains these charts with best practices and security updates           |
| **Infrastructure**         | Infrastructure as Code                  | Terraform                      | Terraform provides state management and AWS provider maturity                       |
| **Database**               | PostgreSQL, MySQL, Oracle, SQL Server   | Amazon Aurora PostgreSQL       | Aurora provides automatic scaling, backups, and multi-AZ deployment                 |
| **Shared Storage**         | NFS, SMB/CIFS                           | Amazon EFS                     | EFS integrates seamlessly with EKS and provides automatic scaling                   |
| **Load Balancing**         | Any load balancer with session affinity | AWS Application Load Balancer  | ALB provides native AWS integration and advanced routing capabilities               |

### Architecture Components

```
┌─────────────────────────────────────────────────────────────┐
│                         AWS Cloud                            │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                    VPC (Multi-AZ)                      │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │              Amazon EKS Cluster                  │ │ │
│  │  │  ┌────────────────────────────────────────────┐  │ │ │
│  │  │  │   Jira DC Pods    │  Confluence DC Pods   │  │ │ │
│  │  │  └────────────────────────────────────────────┘  │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  │                                                        │ │
│  │  Application Load Balancer (ALB)                      │ │
│  │  Amazon Aurora PostgreSQL Multi-AZ                    │ │
│  │  Amazon EFS (Shared Storage)                          │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### High Availability Design

- **EKS Multi-AZ**: Kubernetes control plane spans multiple availability zones
- **Aurora Multi-AZ**: Automatic failover for database layer with read replicas
- **EFS Multi-AZ**: Distributed file system across multiple availability zones
- **ALB Health Checks**: Automatic traffic routing with session affinity

## Deployment Architecture Options

### Non-clustered (Single Node)

Atlassian supports running Jira Data Center on a single node, similar to a Server installation. This option requires minimal infrastructure changes while providing access to Data Center-only features.

**We recommend this approach only for development or small pilot environments** because it lacks the high availability and scalability benefits that enterprises typically require.

### Clustered (Recommended)

Atlassian recommends clustering for large-scale, mission-critical Jira instances, providing high availability and performance scalability.

**We specifically recommend Kubernetes-based clustering** because it provides:

- **Automatic scaling**: Horizontal pod autoscaling based on demand
- **Self-healing**: Kubernetes automatically restarts failed pods
- **Rolling updates**: Zero-downtime deployments
- **Resource management**: Better resource utilization and isolation

## Clustered Deployment Requirements

### Infrastructure Guidelines

Atlassian recommends that cluster nodes be located in the same data center or region, with consistent performance characteristics.

**We implement these guidelines using AWS best practices:**

- **Dedicated EKS Node Groups**: Separate node groups for Jira and Confluence workloads
- **Consistent Instance Types**: Use the same instance family across all nodes for predictable performance
- **Multi-AZ Deployment**: Distribute nodes across multiple availability zones within the same region

### Node Sizing

Atlassian states that the Data Center license does not restrict the number of nodes in the cluster, and the optimal number depends on your instance size and node specifications.

**We recommend starting with a minimum viable cluster configuration** and scaling based on:

- **CPU and Memory Metrics**: Monitor pod resource utilization
- **Response Times**: Track application performance metrics
- **User Load**: Scale based on concurrent user patterns

### Instance Sizing Guidelines

Use the following table to determine which size profile your metrics fit into:

| Metric                 | Small         | Medium               | Large                  |
| ---------------------- | ------------- | -------------------- | ---------------------- |
| Issues                 | up to 150,000 | 150,000 to 600,000   | 600,000 to 2,000,000   |
| Projects               | up to 200     | 200 to 800           | 800 to 2,500           |
| Users                  | up to 1,000   | 1,000 to 10,000      | 10,000 to 100,000      |
| Custom Fields          | up to 250     | 250 to 800           | 800 to 1,800           |
| Workflows              | up to 80      | 80 to 200            | 200 to 600             |
| Groups                 | up to 2,000   | 2,000 to 10,000      | 10,000 to 50,000       |
| Comments               | up to 250,000 | 250,000 to 1,000,000 | 1,000,000 to 4,000,000 |
| Permission Schemes     | up to 25      | 25 to 100            | 100 to 400             |
| Issue Security Schemes | up to 50      | 50 to 200            | 200 to 800             |

> **Note**: Any metric above the Large range is considered XLarge (e.g., over 2,000,000 Issues or over 2,500 Projects).

### Memory Requirements

Atlassian specifies that each Jira node requires a minimum of 8GB RAM for a single Server instance with up to 100 projects, 1,000 to 5,000 issues total, and about 100-200 users.

**We recommend higher memory allocation for Kubernetes deployments** because:

- **Container Overhead**: Kubernetes and container runtime require additional memory
- **JVM Tuning**: Larger heap sizes improve garbage collection performance
- **Buffer for Growth**: Additional memory provides headroom for scaling

## Database Requirements

### Supported Database Versions

Atlassian supports multiple database platforms for Data Center deployments:

| Database          | Supported Versions | Notes                                           |
| ----------------- | ------------------ | ----------------------------------------------- |
| **PostgreSQL**    | 9.6, 10, 11        | Bundled with JDBC 42.2.6 driver                 |
| **MySQL**         | 5.7, 8.0           | Not compatible with MariaDB or PerconaDB        |
| **Oracle**        | 12c R2, 18c, 19c   | Use JDBC 19.3 (ojdbc8) driver                   |
| **SQL Server**    | 2016, 2017         | Not compatible with Express Editions            |
| **Azure SQL**     | Current versions   | Supported for both Server and Data Center       |
| **Amazon Aurora** | PostgreSQL 9.6, 11 | Data Center only; PostgreSQL-compatible cluster |

**We specifically recommend Amazon Aurora PostgreSQL** because it provides:

- **Automatic Scaling**: Storage and compute scale independently
- **Multi-AZ Deployment**: Built-in high availability and automatic failover
- **Backup and Recovery**: Point-in-time recovery and automated backups
- **Performance**: Up to 3x better performance than standard PostgreSQL

### Database Configuration Notes

Atlassian provides specific configuration requirements for each database platform:

- **PostgreSQL**: Do not reduce blocksize parameter below default
- **MySQL**: Run in strict mode; do not reduce innodb_page_size below default
- **Oracle**: Do not use Advanced Compression Option (ACO); do not reduce DB_BLOCK_SIZE below default
- **SQL Server**: Use Microsoft JDBC 7.2.1 Driver
- **Amazon Aurora**: Only supports one writer with zero or more readers configuration

## Deployment Approach

This solution accelerator focuses on **Jira Data Center** deployment first, as it typically has more complex infrastructure requirements. Once Jira is successfully deployed and configured, Confluence can be deployed using similar patterns but may require different infrastructure specifications based on your organization's needs.

### Database High Availability

Atlassian recommends removing the database as a single point of failure through clustering. **We implement this using AWS managed services:**

- **Amazon RDS Multi-AZ**: Primary database with synchronous replication to standby in different availability zone
- **Amazon Aurora PostgreSQL**: Cluster with one writer and multiple readers across AZs with automatic failover

### Shared Storage Requirements

Atlassian requires all cluster nodes to have access to a shared directory containing attachments, plugins, and configuration data.

**We use Amazon EFS** because it provides:

- **NFS Compatibility**: Works seamlessly with Atlassian's shared home requirements
- **Automatic Scaling**: Storage grows and shrinks based on usage
- **Multi-AZ**: Data replicated across multiple availability zones
- **Performance**: Provisioned throughput for consistent performance

### Load Balancing

Atlassian recommends using a load balancer that supports session affinity, suggesting the load balancer you are most familiar with.

**We specifically use AWS Application Load Balancer** because it provides:

- **Native Session Affinity**: Built-in sticky sessions support
- **Health Checks**: Automatic backend health monitoring and traffic routing
- **SSL/TLS Termination**: Centralized certificate management
- **Advanced Routing**: Path-based and host-based routing capabilities

### Load Balancer Configuration

Atlassian provides specific recommendations for load balancer configuration:

- **Queue Management**: Ensure maximum requests per node don't exceed Tomcat's maxThreads
- **Error Handling**: Don't replay failed idempotent requests on other nodes
- **Load Balancing Method**: Use least connections rather than round robin
- **Health Check Endpoint**: Use a stable, lightweight URL for health monitoring

**We implement these recommendations through ALB target group configuration and Kubernetes service definitions.**
