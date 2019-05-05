package main

import (
	"flag"
	"log"
)

func main() {

	projectPtr := flag.String("project", "coastal-sunspot-206412", "Identifier of GCP project")

	machineTypePtr := flag.String("machine-type", "n1-standard-2", "GCE machine type")

	numK8sClusterPtr := flag.Int("k8s", 1, "Number of GKE/K8S clusters")
	numNodePtr := flag.Int("num-nodes", 2, "Number of nodes in each GKE/K8S cluster")

	// Number of instances cluster to create
	numVirtualClusterPtr := flag.Int("vm", 1, "Number of virtual machine clusters")
	numVirtualPtr := flag.Int("num-vms", 3, "Number of instances in each virtual machine cluster")
	flag.Parse()

	regionzones := make([]RegionZone, 0)

	prefix := "europe-west"
	idxs := []int{1, 2, 3, 4, 6}
	zones := []rune{'c', 'c', 'c', 'c', 'c'}
	regionzones = appendRegionZones(regionzones, prefix, idxs, zones)

	prefix = "us-west"
	idxs = []int{1, 2}
	zones = []rune{'a', 'a'}
	regionzones = appendRegionZones(regionzones, prefix, idxs, zones)

	k8sClusters := BuildClusterList(*numK8sClusterPtr, *numNodePtr, *machineTypePtr, *projectPtr, regionzones)
	vmClusters := BuildInstanceClusterList(*numVirtualClusterPtr, *numVirtualPtr, *machineTypePtr, *projectPtr,
		regionzones)

	err := CreateAllClusters(vmClusters, k8sClusters)
	if err != nil {
		log.Printf("Error(s) while creating cluster(s): %v", err)

	}
}
