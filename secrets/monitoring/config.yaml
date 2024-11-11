route:
  receiver: pagerduty
  group_by: [alertname]
receivers:
  - name: pagerduty
    pagerduty_configs:
      - routing_key: "{{ op://Applications/ALERTMANAGER/pagerduty-routing-key }}"
