package main

import (
    "bytes"
    "fmt"
    "log"
    "os/exec"
)

const ShellToUse = "bash"

func Shellout(command string) (error, string, string) {
    var stdout bytes.Buffer
    var stderr bytes.Buffer
    cmd := exec.Command(ShellToUse, "-c", command)
    cmd.Stdout = &stdout
    cmd.Stderr = &stderr
    err := cmd.Run()
    return err, stdout.String(), stderr.String()
}

func main() {

    command = 'gcloud beta container --project "$PROJECT" clusters create "$CLUSTER" --zone "$REGION" \
    --no-enable-basic-auth --cluster-version "1.11.8-gke.6" --machine-type "n1-standard-2" \
    --image-type "COS" --disk-type "pd-standard" --disk-size "100" \
    --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
    --preemptible --num-nodes "2" --no-enable-cloud-logging --no-enable-cloud-monitoring \
    --no-enable-ip-alias --network "projects/coastal-sunspot-206412/global/networks/default" \
    --subnetwork "projects/coastal-sunspot-206412/regions/us-central1/subnetworks/default" \
    --enable-autoscaling --min-nodes "2" --max-nodes "4" \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing --enable-autoupgrade --enable-autorepair'

    err, out, errout := Shellout("ls -ltr")
    if err != nil {
        log.Printf("error: %v\n", err)
    }
    fmt.Println("--- stdout ---")
    fmt.Println(out)
    fmt.Println("--- stderr ---")
    fmt.Println(errout)
}