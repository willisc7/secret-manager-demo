This repo will demonstrate two things:
* Create a secret in the GUI and allow an app running on GKE to access the secret
* Create a secret in the GUI and allow a service account used externally to access the secret

### Before Demo
0. Create a GKE autopilot cluster and get the credentials
    ```
    gcloud services enable container.googleapis.com
    gcloud compute networks create default --subnet-mode=auto --mtu=1460 --bgp-routing-mode=regional
    gcloud container clusters create-auto cluster-1 --region us-central1
    gcloud container clusters get-credentials cluster-1 --region us-central1 --project ${GOOGLE_CLOUD_PROJECT}
    ```
0. Make sure to disable conflicting org policies (including iam.disableServiceAccountKeyCreation)

### Demo: Create Secret in GUI and Give Dev Access via Workload Idenitity
0. Create GCP service account called `application-a`
0. Create a secret in Secret Manager called `my-secret` with contents `hello` and give the `application-a` service account `Secret Manager Secret Accessor` role
0. Create the k8s service account and allow it to impersonate the GCP service account created earlier
    ```
    kubectl create serviceaccount app-a-svc \
        --namespace default
    gcloud iam service-accounts add-iam-policy-binding application-a@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com \
        --role roles/iam.workloadIdentityUser \
        --member "serviceAccount:${GOOGLE_CLOUD_PROJECT}.svc.id.goog[default/app-a-svc]"
    kubectl annotate serviceaccount app-a-svc \
        --namespace default \
        iam.gke.io/gcp-service-account=application-a@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com
    ```
0. Run the pod
    ```
    kubectl apply -f application-a.yaml && kubectl get pods -w
    ```
0. Once the container status is Running
    ```
    kubectl logs -f application-a
    ```

### Demo: Create Secret in GUI and Give Dev Access via App on Other Cloud
**Warning: this is for demo purposes only and not a recommended security best practice. When using service accounts outside Google Cloud you should use [Workload Identity federation](https://cloud.google.com/iam/docs/workload-identity-federation)**

0. Create GCP service account called `application-b`
0. Create a secret in Secret Manager called `another-secret` with contents `hello again` and give the `application-b` service account `Secret Manager Secret Accessor` role
0. Get credentials for the service account
    ```
    gcloud iam service-accounts keys create application-b-credentials.json \
        --iam-account=application-b@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com
    ```
0. Create secret from credentials file
    ```
    kubectl create secret generic app-b-credentials --from-file=./application-b-credentials.json
    ```
0. Run the pod
    ```
    kubectl apply -f application-b.yaml && kubectl get pods -w
    ```
0. Once the container status is Running
    ```
    kubectl logs -f application-b
    ```