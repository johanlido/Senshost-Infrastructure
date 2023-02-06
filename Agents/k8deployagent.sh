#! /bin/bash

# Controlling the input parameters
if [ $# -ne 2 ]; then
  echo "Usage: $0 <parameter_file> <deployment_name>"
  exit 1
fi

# Read parameters from a parameter file
while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ $line =~ ^[A-Z]+ ]]; then
    declare "$line"
  fi
done < $1

echo -e "\n\n$(date +%Y-%m-%d_%T) \033[1mStarting deployment of script: ${2}\033[0m" 

IMAGE_PATH=$IMAGE_REGISTRY"/"$CONTAINER_NAME

curr_dir=$PWD
cd $DEPLOY_FILE_FOLDER
mkdir -p $BACKUP_DIR

aws ecr get-login-password --region ap-south-1 | \
 docker login --username AWS --password-stdin \
 $IMAGE_REGISTRY

image_version=$(aws ecr describe-images --repository-name $REPO_NAME \
  --query 'sort_by(imageDetails,& imagePushedAt)[*].imageTags[*]' --output text | \
  awk "/$IMAGE_TAG/ {print \$0}" | tr -d ' ' | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')

if [ -z $image_version ]; then
    echo 'Cannot find image version in image registry for tag: '$IMAGE_TAG
    exit 1
fi

# This is a temporary fix for the issue with the image version being empty, need to do a proper more bullet proof solution later

deployment_image_line=$(grep -o 'image: .*' "$DEPLOY_FILE_NAME")
deployment_image_version=$(echo "$deployment_image_line" | awk -F ':' '{print $3}')
if [ $image_version == $deployment_image_version ]; then
    echo 'Image version already up to date'
    echo 'Image version in ecr= '$image_version ' Image version in deployment file= '$deployment_image_version    
    echo 'exit'
    exit 1
fi

echo 'Image version= '$image_version

backupextension=-Ver$(grep -oE 'image: $CONTAINER_NAME:[^ ]+' $DEPLOY_FILE_NAME | cut -d ':' -f 3)-T-$(date +%Y%m%d-%H%M%S).bak
backpufile=$DEPLOY_FILE_NAME$backupextension

sed -i$backupextension "s#image: $IMAGE_PATH:.*#image: $IMAGE_PATH:$image_version#" $DEPLOY_FILE_NAME

mv $backpufile $BACKUP_DIR

echo 'Deployment file updated with new image version ' $image_version

# kubectl apply -f $DEPLOY_FILE_NAME --record
# kubectl replace -f $DEPLOY_FILE_NAME

echo 'Deployment started'

cd $curr_dir

message='Deployment '$IMAGE_PATH':'$image_version', tag:'$IMAGE_TAG ' started'

curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"$message\"}" $DISCORD_WEBHOOK_URL

# run every 5 minutes
#crontab -e
#*/5 * * * * /home/ec2-user/k8script/script.sh deploytest &>> /home/ec2-user/k8script/log/logile.log

 kubectl apply -f dd.yaml
 kubectl replace -f dd.yaml
 kubectl rollout status dd ams-senshost-api-deployment

 kubectl rollout history deployment ams-senshost-api-deployment
 kubectl rollout undo deployment ams-senshost-api-deployment --to-revision=1

