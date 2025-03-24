# Home Server

This README covers setting up the Walton Home Server on any number of Raspberry Pi's running Ubuntu Server.

## Building Nodes

- Ensure that the IP of the Raspberry Pi to be used has been added to the `hosts` file inside the `ansible` directory.
- From the `ansible` directory, run `make build`.

## Managing Kubernetes

- From the `ansible` directory, run `make k8s`.

## Current Domains

| Domain           | Description              |
|------------------|--------------------------|
| prometheus.local | The Prometheus UI        |
| grafana.local    | The Grafana UI           |

## Current Kubernetes Namespaces and Workloads

### Storage

The storage namespace includes the NFS server used for persistence throughout the kubernetes cluster.

### Monitoring

The monitoring namespace includes all workloads related to monitoring the health of the kubernetes cluster.

#### Prometheus

The Prometheus deployments are responsible for collecting metrics from the various workloads via endpoint scraping. These include:

- prometheus-prometheus-pushgateway
- prometheus-kube-state-metrics
- prometheus-server

#### Node Exporter

The Node Exporter deamonset is responsible for getting metrics dealing with the Raspberry Pi's being used as nodes in the kubernetes cluster.

#### MySQL Exporter

The MySQL Exporter deployment is responsible for getting metrics from the MySQL database.

#### Redis Exporter

The Redis Exporter deployment is responsible for getting metrics from the Redis cache.

#### Grafana

The Grafana deployment handles the visualization of the metrics via dashboards.

### Database

The database namespace includes the MySQL database for the cluster. A single instance of MySQL is used for all workloads within the cluster. Separation is made via individual databases and limited user access.

### Caching

The caching namespace includes the Redis cache. A single cache is used for the kubernetes cluster as a need for more is not currently expected.
