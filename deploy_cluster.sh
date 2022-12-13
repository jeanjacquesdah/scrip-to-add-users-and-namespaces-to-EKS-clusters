#!/bin/bash

NAMESPACES=()

set -e

eksctl create cluster -f cluster.yaml 2>&1 | tee cluster_setup.log

kubectl apply -f autoscaler-deployment.yaml

# deploy each user in the following manner:
for eksuser in  (email of user )\( email of the user)
        
        emr-user ; do
  echo "add identiy map: $eksuser"
  eksctl create iamidentitymapping --cluster   --arn arn:/$eksuser --group system:masters --username $eksuser
  sleep 1
done

kubectl create serviceaccount spark 
sleep 2 

kubectl create clusterrolebinding spark-role --clusterrole=edit \
        --serviceaccount=default:spark --namespace=default

for namespace in "${NAMESPACES[@]}" ; do
  echo "Applying namespace configs for $namespace"
  kubectl apply -f namespace_$namespace.json
  sleep 1
  kubectl create serviceaccount spark-$namespace --namespace $namespace
  sleep 1
  kubectl create clusterrolebinding spark-role-$namespace --clusterrole=edit \
          --serviceaccount=$namespace:spark-$namespace --namespace=$namespace
done

echo "Done."
cat errata.txt
