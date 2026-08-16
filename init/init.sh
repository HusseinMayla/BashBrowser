#!/bin/bash


echo "app started"
url="https://example.com"
search=""
title=""
command=''

process(){
    echo $1
}

clear
cat <<EOF
┌──────────────────────────────────────────────────────┐
│ Bash Browser                                
├──────────────────────────────────────────────────────┤
│ Search: $search                              
├──────────────────────────────────────────────────────┤
│ URL: $url                                    
├──────────────────────────────────────────────────────┤
│ Title: $title                                  
├──────────────────────────────────────────────────────┤
│  
│          
|                                  
│                                  
├──────────────────────────────────────────────────────┤
│ Commands: open <url> | Search <keyword> | back | forward | quit  
└──────────────────────────────────────────────────────┘
EOF
echo "enter command:"
read command
process $command
