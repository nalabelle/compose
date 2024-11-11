scrape_configs:
  - job_name: push-monitor
    static_configs:
      - targets:
        - {{ op://Applications/PUSH_MONITOR__${COMPOSE_PROJECT_NAME}/password }}
  - job_name: docker
    docker_sd_configs:
      -  host: unix:///var/run/docker.sock
    relabel_configs:
      # Change metrics_path to labeled value
      - source_labels: [__meta_docker_container_label_scrape_path]
        regex: (.+)
        target_label: __metrics_path__
      # Change port
      - source_labels: [__address__, __meta_docker_container_label_scrape_port]
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        target_label: __address__
      # Only keep containers that have a `metrics-job` label.
      - source_labels: [__meta_docker_container_label_metrics_job]
        regex: .+
        action: keep
      # Use the task labels that are prefixed by `metrics-`.
      - regex: __meta_docker_container_label_metrics_(.+)
        action: labelmap
        replacement: $1
