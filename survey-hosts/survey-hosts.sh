#!/bin/bash

#Get $filepath
#Get Contents from $list (config file)

for file in $list
do
    sha256sum $file >> $filepath/hashes/hashes.sha256
    md5sum $file >> $filepath/hashes/hashes.md5 
done