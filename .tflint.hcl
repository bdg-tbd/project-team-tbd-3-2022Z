plugin "google" {
    enabled = true
    version = "0.16.1"
    source  = "github.com/terraform-linters/tflint-ruleset-google"
    deep_check = true
}

rule "terraform_unused_declarations" {
    enabled = true
}
