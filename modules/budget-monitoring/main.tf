resource "google_project_service" "billing-budgets-service" {
  for_each                   = toset(["billingbudgets.googleapis.com"])
  project                    = var.project_name
  service                    = each.value
  disable_dependent_services = true
}

data "google_billing_account" "account" {
  billing_account = var.billing_account
}

resource "google_billing_budget" "budget" {
  depends_on = [google_project_service.billing-budgets-service]
  for_each   = toset(var.notification_thresholds)

  billing_account = data.google_billing_account.account.id
  display_name    = "TBD Billing Budget"

  amount {
    specified_amount {
      currency_code = "USD"
      units         = var.monthly_budget
    }
  }
  threshold_rules {
    threshold_percent = each.value
  }
}
