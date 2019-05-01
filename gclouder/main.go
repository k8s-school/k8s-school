package main

import (
	"log"
)

func main() {

	project := "coastal-sunspot-206412"

	// Number of GKE cluster
	nbCluster := 0

	// Number of instances cluster to create
	nbInstances := 2
	nbInstance := 3

	regionzones := make([]RegionZone, 0)

	prefix := "europe-west"
	idxs := []int{1, 2, 3, 4, 6}
	zones := []rune{'c', 'c', 'c', 'c', 'c'}
	regionzones = appendRegionZones(regionzones, prefix, idxs, zones)

	prefix = "us-west"
	idxs = []int{1, 2}
	zones = []rune{'a', 'a'}
	regionzones = appendRegionZones(regionzones, prefix, idxs, zones)

	if nbCluster != 0 {
		clusters := BuildClusterList(nbCluster, project, regionzones)

		err := CreateClusters(clusters)
		if err != nil {
			log.Printf("Error(s) while creating cluster(s): %v", err)

		}
	}
	if nbInstances != 0 {
		instanceClusters := BuildInstanceClusterList(nbInstances, nbInstance, project, regionzones)
		err := CreateInstanceClusters(instanceClusters)
		if err != nil {
			log.Printf("Error(s) while creating instance cluster(s): %v", err)

		}
	}
}
