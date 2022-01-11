#!/bin/bash
export KUBECONFIG=/Users/mmazepa/kubeconfig-child
exec 2> error.log

node_list=$(kubectl get node -l=stacklight -o custom-columns=NAME:.status.addresses[1].address,IP:.status.addresses[0].address | grep -v IP)

printf "%-51s %-16s %-50s %-10s\n" "NODE NAME" "IP" "LOCATION" "SIZE"

for node_name in $(echo "$node_list" | awk '{print $1}')
do
	node_ip=$(echo "$node_list" | grep "$node_name" | awk '{print $2}')
	printf "%-51s %-16s\n" "$node_name" "$node_ip"
	for vol_path in $(kubectl get pv -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,PATH:.spec.local.path,NODE:.spec.nodeAffinity.required.nodeSelectorTerms[0].matchExpressions[0].values[0] | grep -i bound | grep "$node_name" | grep "stacklight" | awk '{print $3}' | awk -F '/vol' '{print $1}')
		do
		size=$(ssh -q -i /Users/mmazepa/ssh_keys/eu-production-child mcc-user@"$node_ip" "du -d 0 -h "$vol_path"" | awk '{print $1}')
		printf "%-68s %-50s %-10s\n" " " "$vol_path" "$size"
	done
done
