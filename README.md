# Dokumentacja

## Etap 1a

**Jakie sposoby odwoływania się do modułów Terraform są wykorzystane w projekcie?**

Root Module -- główny moduł (projekt) wykorzystujący child modules.

Child Modules:
* Local modules -- znajdują się w `./modules`:
    * `data-generator` -- generuje plik zawierający losowe stringi.
    * `dataproc-pyspark-job` -- tworzy i konfiguruje szablon workflowu Dataprocowego zawierającego job PySparkowy.
    * `gke` -- tworzy i konfiguruje klaster Kubernetesowy oraz jego node'y. Zwraca endpoint, pod którym się znajduje, oraz jego certyfikat CA.
* Git repository:
    * `k8s-spark-operator` -- pozwala na uruchamianie aplikacji Sparkowych na Kubernetesie w łatwy i idiomatyczny sposób.

**Graf dla modułu `data-generator`**
![](./doc/phase1a_figures/data-generator-graph.svg)

**Graf dla modułu `dataproc-pyspark-job`**
![](./doc/phase1a_figures/dataproc-pyspark-job-graph.svg)

**Graf dla modułu `gke`**
![](./doc/phase1a_figures/gke-graph.svg)

**Graf dla modułu `k8s-spark-operator`**
![](./doc/phase1a_figures/k8s-spark-operator-graph.svg)


