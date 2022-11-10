# Dokumentacja

## Etap 1a

### Sposoby odwoływania się do modułów Terraform wykorzystane w projekcie

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



### Moduł monitorujący budżet

Moduł znajduje się w folderze `./modules/budget-monitoring`.

Wszelkie czynności związane z `google_billing_budget` muszą być dokonywane przy użyciu *service account*. W przypadku *end user credentials* dostaniemy `403` z informacją `"reason": "SERVICE_DISABLED"` dla `"service": "billingbudgets.googleapis.com"`, który w rzeczywistości jest włączony.

`google_billing_budget` można skonfigurować podając wiele `threshold_rules` dla jednego resource'a, jednak nie jest możliwe użycie w takim wypadku `for_each`, a co za tym idzie, nie można poziomów dla alertów trzymać w liście.

Postanowiliśmy wykorzystać `for_each`, a także umożliwić konfigurowanie poziomów dla alertów poprzez zmienną (z domyślnymi wartościami). Skutek jest jednak taki, że w konsoli widnieją 3 różne budżety zamiast jednego z kilkoma poziomami, jednak nie powinien być to raczej problem, ponieważ cała konfiguracja jest zarządzana i modyfikowana przez Terraforma.

**Lista budżetów**

![](./doc/phase1a_figures/budget-list.png)

**Szczegóły budżetu**

![](./doc/phase1a_figures/budget-details.png)

**Wykorzystanie budżetu na koniec etapu 1a**

![](./doc/phase1a_figures/budget-usage.png)



### Klaster dataproc

Projekt znajduje się w folderze `./dataproc`.

W poleceniu jest mowa na zmianę o jobie sparkowym i pysparkowym, jednak przykładowy job pysparkowy jest typowym *hello worldem*, który praktycznie nic nie robi, a zatem w celu przetestowania polityki autoscalowania wybrany został przykładowy job sparkowy, który oblicza wartość liczby pi. Na zrzucie ekranu widoczne są 3 scale upy, ponieważ job sparkowy został uruchomiony 3 razy z kolejno argumentami: 100000, 200000 i 400000, które oznaczają liczbę równoległych tasków zwanych *slice* / *partition*.

Można zauważyć, że gdy zaczynało brakować dostępnej pamięci, dodawany był kolejny (trzeci) node, a po zakończeniu obliczeń był on usuwany.

**Działanie polityki autoscalowania**

![](./doc/phase1a_figures/dataproc-asp.png)


