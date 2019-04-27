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

    project := "coastal-sunspot-206412"
    cluster := "cluster-1"
    region := "us-central1"
    zone := "us-central1-a"
    num_nodes := 2
    network := fmt.Sprintf("projects/%v/global/networks/default", project)
    subnetwork := fmt.Sprintf("projects/%v/regions/%v/subnetworks/default", project, region)
    min_nodes := 2
    max_nodes := 4

    cmd_tpl := `gcloud beta container --project "%v" clusters create "%v" --zone "%v" \
    --no-enable-basic-auth --cluster-version "1.11.8-gke.6" --machine-type "n1-standard-2" \
    --image-type "COS" --disk-type "pd-standard" --disk-size "100" \
    --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
    --preemptible --num-nodes "%v" --no-enable-cloud-logging --no-enable-cloud-monitoring \
    --no-enable-ip-alias --network "%v" --subnetwork "%v" \
    --enable-autoscaling --min-nodes "%v" --max-nodes "%v" \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing --enable-autoupgrade --enable-autorepair`

    cmd := fmt.Sprintf(cmd_tpl, project, cluster, zone, num_nodes, network, subnetwork, min_nodes, max_nodes)

    fmt.Println(cmd)
    err, out, errout := Shellout(cmd)
    if err != nil {
        log.Printf("error: %v\n", err)
    }
    fmt.Println("--- stdout ---")
    fmt.Println(out)
    fmt.Println("--- stderr ---")
    fmt.Println(errout)
}