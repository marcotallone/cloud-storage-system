#!/bin/bash

# Wait until the node is in the Ready state
while ! kubectl get nodes | grep -q 'Ready'; do
  echo "Waiting for node to be ready..."
  sleep 10
done

# Remove the taint from all nodes
kubectl taint nodes --all node-role.kubernetes.io/control-plane-