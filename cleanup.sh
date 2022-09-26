#!/bin/bash

gcloud iam service-accounts delete application-a@seismic-secret-manager-0.iam.gserviceaccount.com
gcloud secrets delete my-secret
kubectl delete serviceaccount app-a-svc --namespace default
kubectl delete po application-a
gcloud iam service-accounts delete application-b@seismic-secret-manager-0.iam.gserviceaccount.com
gcloud secrets delete another-secret
kubectl delete secret app-b-credentials
kubectl delete po application-b