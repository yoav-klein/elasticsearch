sudo iptables -P INPUT ACCEPT
sudo sysctl -w vm.max_map_count=262144

export ES_HOME=$PWD/elasticsearch-8.6.2



