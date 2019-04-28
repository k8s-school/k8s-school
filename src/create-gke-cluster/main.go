package main

import (
    "bytes"
    "errors"
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

func CreateClusters(clusters []Cluster) (error) {

    var err_msgs string
    var err_out error

    for _, c := range clusters {
        cmd_tpl := `gcloud beta container --project "%v" clusters create "%v" --zone "%v" \
        --no-enable-basic-auth --cluster-version "1.11.8-gke.6" --machine-type "%v" \
        --image-type "COS" --disk-type "pd-standard" --disk-size "100" \
        --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
        --preemptible --num-nodes "%v" --no-enable-cloud-logging --no-enable-cloud-monitoring \
        --no-enable-ip-alias --network "%v" --subnetwork "%v" \
        --enable-autoscaling --min-nodes "%v" --max-nodes "%v" \
        --addons HorizontalPodAutoscaling,HttpLoadBalancing --enable-autoupgrade --enable-autorepair`
    
        cmd := fmt.Sprintf(cmd_tpl, c.project, c.name, c.zone, c.machine_type, c.num_nodes,
            c.network, c.subnetwork, c.min_nodes, c.max_nodes)
    
        log.Println(cmd)
        err, out, errout := Shellout(cmd)
        if err != nil {
            err_msg := fmt.Sprintf("error creating %v: %v\n", c.name, err)
            log.Printf(err_msg)
            err_msgs = fmt.Sprintf("%v %v", err_msgs, err_msg)
        }
        log.Println("--- stdout ---")
        log.Println(out)
        log.Println("--- stderr ---")
        log.Println(errout)
        if err_msgs != "" {
            err_out = errors.New(err_msgs)
        }
        
    }
    return err_out
}

type Cluster struct{
    project string
    name string
    region string
    zone string
    machine_type string
    num_nodes int
    network string
    subnetwork string
    min_nodes int
    max_nodes int
}

func main() {

    project := "coastal-sunspot-206412"

    clusters :=  make([]Cluster, 0)

    for i := 1; i <= 6; i++ {
        name := fmt.Sprintf("cluster-%v", i)
        region := fmt.Sprintf("europe-west-%v", i)
        zone := fmt.Sprintf("%v-%v", region, "a")
        machine_type := "n1-standard-2"
        num_nodes := 2
        network := fmt.Sprintf("projects/%v/global/networks/default", project)
        subnetwork := fmt.Sprintf("projects/%v/regions/%v/subnetworks/default", project, region)
        min_nodes := 2
        max_nodes := 4

        c := Cluster{
            project : project,
            name: name,
            region:  region,
            zone:  zone,
            machine_type: machine_type,
            num_nodes: num_nodes,
            network: network,
            subnetwork: subnetwork,
            min_nodes: min_nodes,
            max_nodes: max_nodes}
        clusters = append(clusters, c)
    }
    
    err := CreateClusters(clusters)
    if err != nil {
        log.Printf("Error(s) while creating cluster(s): %v", err)

    }
}