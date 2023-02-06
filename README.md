# Senshost-Infrastructure
Infrastructure for hosting and release deployments

## K8 cluster
EC2-instance type t2.large, 8 gb memory, 128 gb disk \
All security groups has full access to each others \
All instances can get access via SSH, with key wep-api-key 


- Control plane = K8-SH-CP-&lt;Environment&gt; // ex: Prod 
  - Security group = SG-SH-CP-&lt;Environment&gt; sg-0152d76e08ec83788
  - Installation file Senshost-Infrastructure/&lt;Environment&gt;/Hosting/k8install-amazon.sh
- Worker node 1 = K8-SH-W1-&lt;Environment&gt;
  - Security group = SG-SH-W1-&lt;Environment&gt; sg-01507ff598f974ac0 
  - Installation file Senshost-Infrastructure/&lt;Environment&gt;/Hosting/k8install-wn-amazon.sh  
- Worker node 2 = K8-SH-W2-&lt;Environment&gt;
  - Security group = SG-SH-W2-&lt;Environment&gt; sg-030f11a79b37dd83e
  - Installation file Senshost-Infrastructure/&lt;Environment&gt;/Hosting/k8install-wn-amazon.sh    

Plan is to setup hosting with help of Terraform

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
### Setting up k8deployment agent to run every 5 minutes
On the control plane node, run: crontab -e \
Insert the following line: \
*/5 * * * * /home/ec2-user/k8script/script.sh deploytest &>> /home/ec2-user/k8script/log/logile.log

### Tree structure
├── k8deploy // Here is where all deployment files should be stored \
│   ├── backup // Backup directory when a new deployment is rolled out \
│   │   ├── deploymentXXX.yaml-Ver-T-20230202-081003.bak \
│   │   ├── deploymentXXX.yaml-Ver-T-20230202-121003.bak \
│   └── deploymentXXX.yaml // Actual deployment yaml \
├── k8script // Here is where all agent scripts should be stored \
│   ├── ams-senshost-api.para // parameter file for service deployment-agent \
│   ├── k8deployagent.sh // Actuall deployment agent \
│   ├── log // output log from agent scripts \
│   │   ├── logfile.log \
│   │   └── logfile.log.bak \
│   └── recyclelog.sh // recycle agent to make sure log files doesn't fill the disk
