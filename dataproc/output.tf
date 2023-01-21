output "spark_status" {
  value = google_dataproc_job.tbd-spark-job.status[0].state
}
