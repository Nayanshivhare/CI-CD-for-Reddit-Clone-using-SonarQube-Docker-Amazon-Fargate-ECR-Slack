##########STEP 6 Creating an Amazon EKS cluster using eksctl ########
if [ $? -eq 0 ]
then
  echo "Creating Cluster."

  # Creation of EKS cluster
  eksctl create cluster \
  --name eks-cluster \
  --region us-east-2 \
  --nodegroup-name worker-node \
  --node-type t2.large \
  --nodes 2 \
  --nodes-min 2 \
  --nodes-max 3 \

  if [ $? -eq 0 ]
  then
    echo "Cluster Setup Completed with eksctl command."
  else
    echo "Cluster Setup Failed while running eksctl command."
  fi
else
  echo "Cluster setup failed."
fi

##Step 6.1
sudo aws eks update-kubeconfig --region us-east-2 --name eks-cluster
