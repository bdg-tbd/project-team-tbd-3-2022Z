# gcloud auth application-default login

export $(cat .env)

export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/.secrets/sa-terraform-key.json

cd gcp_project
terraform init
cd ..

terraform init

cd dataproc
terraform init
cd ..


