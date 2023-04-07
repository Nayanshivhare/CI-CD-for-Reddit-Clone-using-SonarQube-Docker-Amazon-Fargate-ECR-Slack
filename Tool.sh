if [ $? -eq 0 ]
then
  sudo apt update && sudo apt install zip unzip -y

fi
#Step 1 Install AWS CLI and Configure
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install


#Step2 Install and Setup Kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.24.11/2023-03-17/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin
kubectl version

# Install git
sudo apt install git-all

#Step 3 Install and setup eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gg
z" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

#step 5 Install Helm Chart
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm version