kubectl
=========

Set up a [kubectl](http://kubernetes.io/docs/user-guide/kubectl-overview/)

Requirements
------------



Role Variables
--------------
```
kubectl_version: 'v1.2.0'
kubectl_url: "https://storage.googleapis.com/kubernetes-release/release/{{ kubectl_version }}/bin/linux/amd64/kubectl"
kubectl_bin: '/opt/bin/kubectl'
kubectl_certificate_authority: '/etc/kubernetes/ssl/ca.pem'
kubectl_server: "https://{{ ssh_host }}"
kubectl_cluster_name: 'default-cluster'
kubectl_context_cluster: 'default-cluster'
kubectl_context_user: 'default-cluster'
kubectl_context_name: 'default-system'
kubectl_context_current: 'default-system'
kubectl_users_name: 'default-admin'
kubectl_client_certificate: '/etc/kubernetes/ssl/master.pem'
kubectl_client_key: '/etc/kubernetes/ssl/master-key.pem'


```

