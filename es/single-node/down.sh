# Remove the Kibana container
docker stop kib01
docker rm kib01

# Remove Elasticsearch containers
docker stop es02
docker stop es01
docker rm es02
docker rm es01

# Remove the Elastic network
docker network rm elastic-single-node

