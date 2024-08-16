#!/bin/bash

# Create benchmark namespace if it doesn't exist
if [ -z "$(kubectl get namespace osu)" ]; then
    echo "Setting up benchmark namespace for osu tests..."
    kubectl create namespace osu
fi

# Check if the input benchmark file is provided
if [ -z $1 ]; then
		echo "ERROR: Please provide the job yaml file for the benchmark"
		exit 1
fi

# Check if the input benchmark file exists
if [ ! -f $1 ]; then
    echo "ERROR: File $1 not found"
    exit 1
fi

export INPUT_FILE=$1
export RESULTS_FILE=results.txt
      4194304               719.11            677.69            858.90           1675.58
echo "----------------------------------------------------------------------------------" > $RESULTS_FILE
echo "JOB: $INPUT_FILE" >> $RESULTS_FILE

kubectl apply -f $INPUT_FILE --namespace osu

export STATUS=""
while [ "$STATUS" != "Completed" ]; do
    STATUS=$(kubectl get pod -n osu | grep launcher | awk '{print $3}')
    echo "Running benchmark... | Status: $STATUS"
    sleep 5
done

export POD_NAME=$(kubectl get pods -n osu | grep launcher | awk '{print $1}')
kubectl logs $POD_NAME -n osu >> $RESULTS_FILE
echo "Benchmark completed"
echo "Results written in $RESULTS_FILE"

# Clean up the resources
kubectl delete -f $INPUT_FILE --namespace osu
