aws lambda delete-function --function-name lambda
aws lambda create-function \
--region us-west-2 \
--function-name lambda \
--zip-file fileb://./lambda.zip \
--role arn:aws:iam::149602047535:role/lambda_basic_execution \
--handler lambda.handler \
--runtime nodejs  
