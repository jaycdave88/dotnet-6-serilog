# Dotnet 6 Serilog

This will outline how to deploy the Datadog Agent on the control plane and
Linux worker nodes, deploy the Dotnet 6 Serilog application and a Service
to access it.  

1) Deploy & Configure the Datadog Agent (and API Key secrete):
- a) Create secrets for agent using keys from [here](https://app.datadoghq.com/organization-settings/users).  
    ```  
    kubectl create secret generic datadog-agent --from-literal api-key=<key>
    ```  

- b) Deploy the Datadog Agent Helm chart:  
    ```  
    helm repo add datadog https://helm.datadoghq.com  
    helm repo update  
    helm install datadog-agent -f values.yaml datadog/datadog  
    ```  

2) Deploy the .NET 6 MVC application:
    ```  
    kubectl create -f web-deployment.yaml  
    ```  

3) Deploy the Web-service:  
    ```  
    kubectl create -f web-service.yaml  
    ```  

4) Retrieve  the external load balancer IP:  
    ```  
    kubectl get svc  
    ```  

5) Using the external load balancer IP, navigate to the URL
    ```
    http://{LoadBalancerIP}:8000  
    ```  
5) See application traces correlated to application logs within[Datadog Traces](https://app.datadoghq.com/apm/traces)  