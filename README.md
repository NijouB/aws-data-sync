# Transfer data from Amazon S3 to Amazon S3 across AWS accounts 
All of these resources will be created as IaC using Terraform.

- An AWS DataSync task which will transfer data between two buckets.
- The respective AWS DataSync location of both source and destination S3 Buckets. 
- An appropiate access roles to allow access to the buckets.



## How to use this configuration:
- We assume both S3 buckets already exists.

- Update the default values of the variables in `vars.tf` as follows:

  - `Variables:`
    ```
    - source_s3_path: full origin S3 path. Example s3://bucket1/```
    ```
    ```
    - detination_s3_path: full destination S3 path. Example: s3://bucket2/key
    ```
    ```
    - datasync_task_name: A unique name for the transfer task
    ```
    ```
    - destination_account: The destination account where is the S3 bucket that you're transferring data to
    ```
    ```
    - destination_account_profile: Profile of the destination account
    ```
    ```
    - destination_account_role: Role of the destination account
    ```
    ```
    - source_account: The source account where is the S3 bucket that you're transferring data from"
    ```
    ```
    - source_account_profile: Profile of the source account to use DataSync
    ```
    ```
    - source_account_role: Role of the source account to use DataSync
    ```

- Update AWS profiles with source and destination in `test.sh`.

- Apply terraform configuratio by running `./test.sh`

- Verify terraform `Outputs`:

    ```
    output "s3_location" {
      value = aws_datasync_location_s3.destination.arn
    }
    ```
    ```
    output "datasync_task" {
      value = aws_datasync_task.datasync_task_name.arn
    }
    ```

## Required Manual Step: Start DataSync Task
Starting an execution of DataSync Task is performed outside of Terraform.

- Go to your `datasync_task` location generated in Outputs, choose Start with defaults to run the task without modification.

- Wait for the task's Status to be `Success` in the `Task history` section, then check your destination S3 bucket using the `s3_location` generated in `Outputs` to ensure that your data was transferred. 

## FAQ
Q1. I am getting an error when applying terraform config

```Error: creating DataSync Location S3: operation error DataSync: CreateLocationS3, https response error StatusCode: 400, RequestID: 3525c874-db08-42ac-b2ad-a111f8761beb, InvalidRequestException: DataSync location access test failed: could not perform s3:GetObject in bucket spoon-rds-snapshot-storage. Access denied. Ensure bucket access role has s3:GetObject permission.```

A1. This is usally happened because source bucket objects are encrypted with a KMS key. See details here https://docs.aws.amazon.com/datasync/latest/userguide/create-s3-location.html#create-s3-location-encryption. Solution would be update KMS policy to give permission to the particular IAM role created as part of this config

## Clean up 
- After successfully transferring data from the source S3 bucket to the destination, it's crucial to tidy up any unnecessary Terraform resources by running:
    `terraform destroy`
- Delete the source s3 bucket.


