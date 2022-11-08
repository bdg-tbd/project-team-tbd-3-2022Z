resource "google_project_service" "dataproc-service" {
  for_each                   = toset(["dataproc.googleapis.com"])
  project                    = var.project_name
  service                    = each.value
  disable_dependent_services = true
}

resource "google_dataproc_cluster" "tbd-cluster" {
  depends_on = [google_project_service.dataproc-service]

  name    = "tbd-cluster"
  project = var.project_name
  region  = var.region

  cluster_config {
    autoscaling_config {
      policy_uri = google_dataproc_autoscaling_policy.tbd-asp.name
    }
  }
}

resource "google_dataproc_autoscaling_policy" "tbd-asp" {
  policy_id = "tbd-asp"
  project   = var.project_name
  location  = var.region

  worker_config {
    max_instances = 3
  }

  basic_algorithm {
    yarn_config {
      graceful_decommission_timeout = "30s"

      scale_up_factor   = 0.5
      scale_down_factor = 0.5
    }
  }
}

resource "google_dataproc_job" "tbd-spark-job" {
  project      = var.project_name
  region       = google_dataproc_cluster.tbd-cluster.region
  force_delete = true

  placement {
    cluster_name = google_dataproc_cluster.tbd-cluster.name
  }

  spark_config {
    main_class    = "org.apache.spark.examples.SparkPi"
    jar_file_uris = ["file:///usr/lib/spark/examples/jars/spark-examples.jar"]
    args          = ["400000"]

    properties = {
      "spark.logConf" = "true"
    }

    logging_config {
      driver_log_levels = {
        "root" = "INFO"
      }
    }
  }
}
