#!/bin/bash

kubectl create secret generic -n nextcloud nextcloud-secret \
  --from-literal=username=admin \
  --from-literal=password=123456 \
  --from-literal=token=vVjGFYXE14

kubectl create secret generic -n nextcloud postgresql-secret \
  --from-literal=postgresql-username=nextcloud \
  --from-literal=postgresql-password=changeme \
  --from-literal=postgresql-root-password=changeme \
  --from-literal=database=nextcloud 

kubectl create secret generic -n nextcloud redis-secret \
  --from-literal=redis-password=changeme
