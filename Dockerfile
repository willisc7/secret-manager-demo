FROM google/cloud-sdk:365.0.1

WORKDIR /app

COPY secret-manager-demo-credentials.json ./
RUN export GOOGLE_APPLICATION_CREDENTIALS="$PWD/secret-manager-demo-credentials.json"

CMD [ "gcloud secrets versions access latest --secret="my-secret" && sleep infinity" ]