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

type OutMsg struct{
    cmd string
    err error
    out string
    errout string
}

func CreateCluster(cluster Cluster, c chan OutMsg) {

    var err_out error
    cmd_tpl := `gcloud beta container --project "%v" clusters create "%v" --zone "%v" \
    --no-enable-basic-auth --cluster-version "1.11.8-gke.6" --machine-type "%v" \
    --image-type "COS" --disk-type "pd-standard" --disk-size "100" \
    --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
    --preemptible --num-nodes "%v" --no-enable-cloud-logging --no-enable-cloud-monitoring \
    --no-enable-ip-alias --network "%v" --subnetwork "%v" \
    --enable-autoscaling --min-nodes "%v" --max-nodes "%v" \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing --enable-autoupgrade --enable-autorepair`

    cmd := fmt.Sprintf(cmd_tpl, cluster.project, cluster.name, cluster.zone, cluster.machine_type,
        cluster.num_nodes, cluster.network, cluster.subnetwork, cluster.min_nodes,
        cluster.max_nodes)

    err, out, errout := Shellout(cmd)
    if err != nil {
        err_msg := fmt.Sprintf("error creating %v: %v\n", cluster.name, err)
        err_out = errors.New(err_msg)
    }

    outmsg := OutMsg{
        cmd: cmd,
        err: err_out,
        out: out,
        errout: errout}

    c <- outmsg
}

func CreateClusters(clusters []Cluster) (error) {
    // var err_msgs string
    var err_out error

    log.Printf("Create %v clusters", len(clusters))
    chans := make([]chan OutMsg, 0)
    for _, cluster := range clusters {
        c := make(chan OutMsg)
        chans = append(chans, c)
        go CreateCluster(cluster, c)
        // err := CreateCluster(c)
        // if err != nil {
        //     err_msgs = fmt.Sprintf("%v %v", err_msgs, err)    
        // }   
    }
    for _,c := range chans {
        outmsg := <-c
        log.Println(outmsg.cmd)
        log.Println(outmsg.out)
        if outmsg.err != nil {
            log.Println(outmsg.err)
            log.Println(outmsg.errout)
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

type RegionZone struct{
    region string
    zone string
}

func appendRegionZones(rzs []RegionZone, prefix string, idxs []int, zones []rune) []RegionZone {
    for i, idx := range idxs {
        region := fmt.Sprintf("%v%v", prefix, idx)
        zone := fmt.Sprintf("%v-%v", region, string(zones[i]))
        r := RegionZone{
            region: region,
            zone: zone}
        rzs = append(rzs, r)
    }
    return rzs
}

func main() {

    project := "coastal-sunspot-206412"

    nb_clusters := 2

    clusters :=  make([]Cluster, 0)
    regionzones :=  make([]RegionZone, 0)

    prefix := "europe-west"
    idxs := []int{1, 2, 3, 4, 6}
    zones := []rune{'c', 'c', 'c', 'c', 'c'}
    regionzones = appendRegionZones(regionzones, prefix, idxs, zones)

    prefix = "us-west"
    idxs = []int{1, 2}
    zones = []rune{'a', 'a'}
    regionzones = appendRegionZones(regionzones, prefix, idxs, zones)

    for i, rz := range regionzones[0:nb_clusters] {
        name := fmt.Sprintf("cluster-%v", i)
        region := rz.region
        zone := rz.zone
        machine_type := "n1-standard-2"
        num_nodes := 2
        network := fmt.Sprintf("projects/%v/global/networks/default", project)
        subnetwork := fmt.Sprintf("projects/%v/regions/%v/subnetworks/default", project, region)
        min_nodes := 2
        max_nodes := 4

        c := Cluster{
            project: project,
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