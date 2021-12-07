This repo will demonstrate two things:
* Creating a secret using the Go Secret Manager client libraries
* Reading a secret in a kubernetes pod using workload identity

0. Create a GKE autopilot cluster and get the credentials
    ```
    gcloud beta container clusters create-auto cluster-1 --region us-central1
    gcloud container clusters get-credentials cluster-1 --region us-central1 --project ${GOOGLE_CLOUD_PROJECT}
    ```
0. Setup the service account the apps will use to create/read the secret
    ```
    gcloud iam service-accounts create secret-manager-demo
    gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
        --member="serviceAccount:secret-manager-demo@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
        --role="roles/owner"
    gcloud iam service-accounts keys create secret-manager-demo-credentials.json \
        --iam-account=secret-manager-demo@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com
    ```
0. Set the credential file
    ```
    export GOOGLE_APPLICATION_CREDENTIALS="$PWD/secret-manager-demo-credentials.json"
    ```
0. Create the secret within the go app
    ```
    go mod download
    go run .
    ```
0. Create the k8s service account and allow it to impersonate the GCP service account created earlier
    ```
    kubectl create serviceaccount secret-manager-demo-svc \
        --namespace default
    gcloud iam service-accounts add-iam-policy-binding secret-manager-demo@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com \
        --role roles/iam.workloadIdentityUser \
        --member "serviceAccount:${GOOGLE_CLOUD_PROJECT}.svc.id.goog[default/secret-manager-demo-svc]"
    kubectl annotate serviceaccount secret-manager-demo-svc \
        --namespace default \
        iam.gke.io/gcp-service-account=secret-manager-demo@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com
    ```
0. Run the pod
    ```
    kubectl apply -f secret-manager-demo.yaml && kubectl get pods -w
    ```
0. Once the container status is Running
    ```
    kubectl logs -f secret-manager-demo
    ```
