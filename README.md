# Senshost-Infrastructure
Infrastructure for hosting and release deployments

## K8 cluster
EC2-instance type t2.large, 8 gb memory, 128 gb disk
All security groups has full access to each others
All instances can get access via SSH, with key wep-api-key

- Control plane = K8-SH-CP-Prod 
  - Security group = SG-SH-CP-PROD sg-0152d76e08ec83788
- Worker node 1 = K8-SH-W1-Prod
  - Security group = SG-SH-W1-PROD sg-01507ff598f974ac0 
- Worker node 2 = K8-SH-W2-Prod 
  - Securoty group = SG-SH-W2-PROD sg-030f11a79b37dd83e



### Code tree
  - Prod  
    - Hosting
    - Deployment
  - Stage
    - Hosting
    - Deployment
  - Development
    - Hosting
    - Deployment

### Deployment file templates
Here are the K8S yaml files

### Github actions templates
Here are the github actions yaml files

## Git flow strategy
Using the Gitlab flow strategy https://www.flagship.io/git-branching-strategies/

## Deployment agent
