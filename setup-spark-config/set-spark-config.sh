#!/usr/bin/env bash

input_dir=$1
output_dir=$2
for CONFIG_FILE in $input_dir/*; do
    echo "Append $CONFIG_FILE"
    cat $CONFIG_FILE >> $output_dir/spark-defaults.conf;
    echo $'\n' >> $output_dir/spark-defaults.conf
done