
DEBUG_VERSION=7
DEMO_APP_PORT=30000
CERT_MANAGER_VERSION=v1.10.1
#########################################################
# 1/3: Installing Cert Manager                          #
#########################################################
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version ${CERT_MANAGER_VERSION} \
  --set installCRDs=true \
  --wait

#########################################################
# 2/3 Installing OpenFeature Operator                   #
#########################################################
helm repo add openfeature https://open-feature.github.io/open-feature-operator/
helm install ofo openfeature/open-feature-operator --wait

#########################################################
# 3/3: Deploying OpenFeature CRDS and Demo Application  #
#########################################################
kubectl apply -f ~/end-to-end.yaml
sleep 10
kubectl wait pods -n open-feature-demo -l app=open-feature-demo --for condition=Ready --timeout=30s

#########################################################
# 3/3: Exposing demo application                        #
#########################################################
nohup kubectl -n open-feature-demo port-forward --address 0.0.0.0 service/open-feature-demo-service ${DEMO_APP_PORT} &

# ---------------------------------------------#
#       🎉 Installation Complete 🎉             #
#           Please proceed now...              #
# ---------------------------------------------#
