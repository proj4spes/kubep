IN AWS
========
* Note similiar instructions should work for DigitalOcean

After deploying the cluster in AWS if you run

```kubectl cluster-info```
you get something like
```
Kubernetes master is running at https://kube-master-61628301.eu-west-1.elb.amazonaws.com
KubeDNS is running at https://kube-master-61628301.eu-west-1.elb.amazonaws.com/api/v1/proxy/namespaces/kube-system/services/kube-dns
kubernetes-dashboard is running at https://kube-master-61628301.eu-west-1.elb.amazonaws.com/api/v1/proxy/namespaces/kube-system/services/kubernetes-dashboard
```
you can access to the dashboard through the elb load balancer on https by
```
 https://kube-master-61628301.eu-west-1.elb.amazonaws.com/api/v1/proxy/namespaces/kube-system/services/kubernetes-dashboard
```
or
```
 https://kube-master-61628301.eu-west-1.elb.amazonaws.com/ui
```
it will ask you for the credentials so If you ssh into any of the masters you will find the default credentials here ``` /etc/kubernetes/users/known_users.csv ```
user: kube
pass: changeme
should just work.

Also as we are binding the insecure address to 0.0.0.0 on 8080 at the moment 
https://github.com/Capgemini/kubeform/blob/master/roles/kube-master/templates/kube-apiserver.yaml.j2#L17
you could also access on http by: 
``` http://master-ip:8080/ui ```

In the .kube/config we handle the user and credentials for interacting to with cluster via api using Client certificate authentication.

In a real env you will probably want to create a cname record to route queries from your domain name into the elb
http://docs.aws.amazon.com/ElasticLoadBalancing/latest/DeveloperGuide/using-domain-names-with-elb.html 
