route:
  receiver: pagerduty
  group_by: [alertname]
  routes:
    - receiver: push_monitor
      repeat_interval: 5m
      matchers:
        - alertname = PushMonitor
receivers:
  - name: pagerduty
    pagerduty_configs:
      - routing_key: "{{ op://Applications/ALERTMANAGER/pagerduty-routing-key }}"
  - name: push_monitor
    webhook_configs:
      - url: "{{ op://Applications/ALERTMANAGER/apps-webhook-url }}"
