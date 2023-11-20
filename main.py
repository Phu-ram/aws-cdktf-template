from constructs import Construct
from cdktf import App, TerraformStack, S3Backend
from cdktf_cdktf_provider_aws.provider import AwsProvider
from cdktf_cdktf_provider_aws.s3_bucket import S3Bucket
from cdktf_cdktf_provider_aws.dynamodb_table import DynamodbTable

BACKEND_BUCKET = "pramm-cdktf-states-bucket"


class MyStack(TerraformStack):
    def __init__(self, scope: Construct, ns: str):
        super().__init__(scope, ns)

        AwsProvider(self, "AWS", region="ap-southeast-1", profile="CDKTF")

        # S3 Remote Backend
        # DynamoDB should be added if multiple people working on the same project.
        S3Backend(self,
                  bucket=BACKEND_BUCKET,
                  key="terraform_aws_states/terraform.tfstate",
                  encrypt=True,
                  region="ap-southeast-1",
                  profile="CDKTF",
                  )


app = App()
MyStack(app, "terraform-state-template")

app.synth()
