#!/bin/bash

# Environment variables
ENVIRONMENT=$1

check_num_of_args() {
# Checking the number of arguments
if [ "$#" -ne 0 ]; then
    echo "Usage: $0 <environment>"
    exit 1
fi
}

activate_infra_environment() {
# Acting based on the argument value
if [ "$ENVIRONMENT" == "local" ]; then
  echo "Running script for Local Environment..."
elif [ "$ENVIRONMENT" == "testing" ]; then
  echo "Running script for Testing Environment..."
elif [ "$ENVIRONMENT" == "production" ]; then
  echo "Running script for Production Environment..."
else
  echo "Invalid environment specified. Please use 'local', 'testing', or 'production'."
  exit 2
fi
}

# Function to check if AWS CLI is installed
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI is not installed. Please install it before proceeding."
        return 1
    fi
}

# Function to check if AWS profile is set
check_aws_profile() {
    if [ -z "$AWS_PROFILE" ]; then
        echo "AWS profile environment variable is not set."
        return 1
    fi
}

create_keypair () {

    keyname="testkey"

    aws ec2 create-key-pair --key-name "$keyname"
    
    if [ $? -eq 0 ]; then
        echo "'$keyname' created successfully."
    else
        echo "Failed to create '$keyname'"
    fi

}

# Function to create EC2 Instances
create_ec2_instances() {

    # Specify the parameters for the EC2 instances
    instance_type="t3.micro"
    ami_id="ami-011e54f70c1c91e17"  
    count=1  # Number of instances to create
    region="eu-north-1" # Region to create cloud resources

    # Create the EC2 instances
    aws ec2 run-instances \
        --image-id "$ami_id" \
        --instance-type "$instance_type" \
        --key-name webserver \
        --count $count \
        --subnet-id subnet-0e0574c63101013c5
        
        
    # Check if the EC2 instances were created successfully
    if [ $? -eq 0 ]; then
        echo "EC2 instances created successfully."
    else
        echo "Failed to create EC2 instances."
    fi
}

# Function to create S3 buckets for different departments
create_s3_buckets() {
    # Define a company name as prefix
    company="tatti"
    # Array of department names
    departments=("marketing" "sales" "hr" "operations" "media")
    
    # Loop through the array and create S3 buckets for each department
    for department in "${departments[@]}"; do
        bucket_name="${company}-${department}-data-bucket"
        # Create S3 bucket using AWS CLI
        aws s3 mb s3://$bucket_name
        if [ $? -eq 0 ]; then
            echo "S3 bucket '$bucket_name' created successfully."
        else
            echo "Failed to create S3 bucket '$bucket_name'."
        fi
    done
}

create_IAM_users() {
    #Array of user names
    names=("Tom" "Bob" "John" "Sam" "Jack")
    
    #Loop through the array and create IAM user for each employee
    for name in "${names[@]}"; do
        aws iam create-user --user-name "$name"
        #check if the exit code is 0
        if [ $? -eq 0 ]; then
        #prints success if exit code is 0
           echo "IAM user for '$name' created successfully."
        else
        #prints unsuccessfull if the code is 1
            echo "Failed to create IAM user for '$bucket_name'."
        fi
    done
}

create_IAM_group() {

    groupname="Admins"
    #creates an IAM group with whatever name is set for $groupname
    aws iam create-group --group-name "$groupname"
    #check if the exit code is 0
    if [ $? -eq 0 ]; then
    #prints success if exit code is 0
        echo "IAM group '$groupname' created successfully."
    else
    #prints unsuccessfull if the code is 1
        echo "Failed to create IAM group '$groupname'."
    fi

    #sets the arn for "AdministratorAccess" to policyarn variable
    policyarn="arn:aws:iam::aws:policy/AdministratorAccess"

    #uses the policy arn to attach policy to groupname
    aws iam attach-group-policy --policy-arn "$policyarn"  --group-name "$groupname"
    #check if the exit code is 0
    if [ $? -eq 0 ]; then
    #prints success if exit code is 0
        echo "Administrative policy sucessfully attached to Admins group."
    else
    #prints unsuccessfull if the code is 1
        echo "Administrative policy couln't be attached to Admins group."
    fi

}

add_user_to_group () {

    names=("Tom" "Bob" "John" "Sam" "Jack")
    groupname="Admins"

    #Loops through the array and adds each IAM user to the specified groupname
    for name in "${names[@]}"; do
        aws iam add-user-to-group --user-name "$name" --group-name "$groupname"
        #check if the exit code is 0
        if [ $? -eq 0 ]; then
        #prints success if exit code is 0
            echo "'$name' has been sucessfully added to the '$groupname' group."
        else
        #prints unsuccessfull if the code is 1
            echo "'$name' could not be sucessfully added to the '$groupname' group."
        fi
    done
}

check_num_of_args
activate_infra_environment
check_aws_cli
check_aws_profile
create_ec2_instances
create_s3_buckets
create_IAM_users
create_IAM_group
add_user_to_group