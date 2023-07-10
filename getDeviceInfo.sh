# name, cpu, memory, 
node_info=$(echo "$(kubectl describe nodes)" | grep -E -A 8 '^Name:|^Allocatable:' | grep -E '^Name:|^  cpu:|^  memory:|^  ephemeral-storage:')

count=0
output="{"
while IFS= read -r line; do
    if (( count % 4 == 0 )); then
        # node name
        name=$(echo "$line" | sed 's/^Name://' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//') # remove leading and trailing whitespace  
        
        # latency
        podsOfCurNode=$( kubectl get pods -l app=m-device-info --field-selector=spec.nodeName==$name --template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
        podsOfOtherNode=$( kubectl get pods -l app=m-device-info --field-selector=spec.nodeName!=$name -o=jsonpath='{range .items[*]}{.status.podIP} {.metadata.name}{"\n"}{end}')
        # podsIPOfOtherNode=$( kubectl get pods -l app=m-device-info --field-selector=spec.nodeName!=$name -o jsonpath='{range .items[*]}{.status.podIP}{"\n"}{end}')
        latency="{"
        if [ -n "$podsOfCurNode" ]; then
            while IFS= read -r otherPods; do
                read -r otherPodsIP otherPodsName <<< "$otherPods"
                otherNodeName=$(kubectl get pod "$otherPodsName" -o=jsonpath='{.spec.nodeName}')
                latencyRaw=$(kubectl exec $podsOfCurNode -- sh -c "ping -c 5 $otherPodsIP")
                latencyTemp=$(echo "$latencyRaw" | grep -E '^round-trip' | awk -F'/' '{print $(NF-1)}')
                latency+="\"$otherNodeName\":\"$latencyTemp\","
            done <<< "$podsOfOtherNode"
            latency=${latency%,}
            latency+="}"
        fi

    elif (( count % 4 == 1 )); then
        # cpu
        cpu=$(echo "$line" | sed 's/cpu://' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//') # remove leading and trailing whitespace
    elif (( count % 4 == 2 )); then
        # storage
        storage=$(echo "$line" | sed 's/ephemeral-storage://' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'  | sed -e 's/..$//') # remove last two character "Ki"
        storage=$(echo "scale=2; "$storage" / 1024" | bc) #convert Ki to MB
    elif (( count % 4 == 3 )); then
        # ram
        ram=$(echo "$line" | sed 's/memory://' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'  | sed -e 's/..$//') # remove last two character "Ki"
        ram=$(echo "scale=2; "$ram" / 1024" | bc) #convert Ki to MB
        output+="\n\"$name\":{\n\"cpu\":\"$cpu\", \"ram\":\"$ram\", \"storage\":\"$storage\", \"latency\":\"$latency\"\n},"
    fi
    (( count++ ))
done <<< "$node_info"

output=${output%,}  # Remove the trailing comma
output+="\n}"
echo "$output" > output_device_info.json