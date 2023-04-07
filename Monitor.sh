
## Step 7
if [ $? -eq 0 ]
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
then
    kubectl get deployment metrics-server -n kube-system
else
    echo "metrics server deployment failed"
fi

## Step 8  Install Prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
if [ $? -eq 0 ]
then
    #Step 8.1 update helm char repo
    helm repo update
    helm repo list
else
    echo "error in prometheus"
fi


## Step 8.2-8.3 Create prometheus namespace
kubectl create namespace prometheus
helm install prometheus prometheus-community/prometheus --namespace prometheus --set alertmanager.persistentVolume.storageClass="gp2" --set server.persistentVolume.storageClass="gp2"
  

#STep 9
oidc_id=$(aws eks describe-cluster --name eks-cluster --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" - f4
eksctl utils associate-iam-oidc-provider --cluster eks-cluster --approve --region us-east-2


#Step 10 Create IAMserviceaccount with role
if [ $? -eq 0 ]
then
        eksctl create iamserviceaccount \
                --name ebs-csi-controller-sa \
                --namespace kube-system \
                --cluster eks-cluster \
                --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
                --approve \
                --role-only \
                --role-name AmazonEKS_EBS_CSI_DriverRole \
                --region us-east-2
        
        eksctl create addon --name aws-ebs-csi-driver --cluster eks-cluster --service-account-role-arn arn:aws:iam::334671708617:role/AmazonEKS_EBS_CSI_DriverRole --force --region us-east-2
        
else
  echo "Failed to create IAM Service account"

fi

#Step 10.2 to get pods name
kubectl get pods -n prometheus

#Step 10.3 view Promethus dashboard
# it will run in background
kubectl port-forward deployment/prometheus-server 9090:9090 -n prometheus > /dev/null 2>&1 &


#step 11 Install Grafana
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

#Step 11.1 Create yaml
cat <<EOF > prometheus-datasource.yaml
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        url: http://prometheus-server.prometheus.svc.cluster.local
        access: proxy
        isDefault: true

EOF

#Step11.2 and step 11.3
if [ $? -eq 0 ]
then
  kubectl create namespace grafana
  helm install grafana grafana/grafana \
 --namespace grafana \
 --set persistence.storageClassName="gp2" \
 --set persistence.enabled=true \
 --set adminPassword='EKS!sAWSome' \
 --values prometheus-datasource.yaml \
 --set service.type=LoadBalancer

else
  echo "Failed to create namespace"


fi

