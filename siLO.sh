#!/bin/bash
threshold_temp="70" # Minimum temperature before fan rampage
max_temp="90" # Maximum temperature
default_speed="15" # In percentage
host="Administrator@192.168.86.99" # ssh host for iLO

check_temp() {
        cpu0_temp=$(( $(cat /sys/class/thermal/thermal_zone1/temp) / 1000 ))
        cpu1_temp=$(( $(cat /sys/class/thermal/thermal_zone2/temp) / 1000 ))
        temp=$(((cpu0_temp + cpu1_temp) / 2))
        echo "$temp"
}

calculate_speed() {
        temp=$(check_temp)
        if [ $(( "$temp" )) -gt "$threshold_temp" ]; then
                fan_speed=$(echo "$threshold_temp / max_temp * 255 / 100" | bc)
                echo "$fan_speed"
        else
                fan_speed=$(( "$default_speed * 255 / 100" ))
                echo "$fan_speed"
        fi
}

update_fans() {
        fan_speed=$(calculate_speed)
        # Uncomment for fan speed info
        # echo "Speed is $fan_speed"
        for fan in {0..5}; do
                ssh -o 'KexAlgorithms=diffie-hellman-group14-sha1' "$host" "fan p $fan max $fan_speed" > /dev/null
        done
}

while :; do
        update_fans
done
