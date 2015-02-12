# deploy.sh
#!/bin/bash

SHA1=$1

# Deploy image to Docker Hub

echo thedpd | docker push thedpd/api-peer

# Create new Elastic Beanstalk version
EB_BUCKET=peerbelt
DOCKERRUN_FILE=Dockerrun.aws.json
#sed "s/<TAG>/$SHA1/" < Dockerrun.aws.json.template > $DOCKERRUN_FILE
aws s3 cp $DOCKERRUN_FILE s3://$EB_BUCKET/$DOCKERRUN_FILE
aws elasticbeanstalk create-environment  --application-name peerbelt-api --environment-name TEST-$CIRCLE_BUILD_NUM --template-name peerbelt-config
aws elasticbeanstalk create-application-version --application-name peerbelt-api --version-label $SHA1 --source-bundle S3Bucket=peerbelt,S3Key=Dockerrun.aws.json
sleep 300;
# Update Elastic Beanstalk environment to new version
aws elasticbeanstalk update-environment --environment-name TEST-$CIRCLE_BUILD_NUM --version-label $SHA1
