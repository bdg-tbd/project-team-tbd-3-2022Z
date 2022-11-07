gcloud auth application-default login

export $(cat .env)

cd gcp_project
terraform init
cd ..

terraform init -backend-config=env/dev/backend.tfvars -reconfigure

export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/.secrets/sa-terraform-key.json


