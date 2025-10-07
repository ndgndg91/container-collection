docker network create elastic-single-node
docker pull docker.elastic.co/elasticsearch/elasticsearch:9.1.5
docker run --name es01 --net elastic-single-node -p 9200:9200 -it -m 1GB docker.elastic.co/elasticsearch/elasticsearch:9.1.5
docker exec -it es01 /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic
export ELASTIC_PASSWORD="sZZ5C=lPdUd*2UZeZvqu"
docker cp es01:/usr/share/elasticsearch/config/certs/http_ca.crt .
curl --cacert http_ca.crt -u elastic:$ELASTIC_PASSWORD https://localhost:9200


docker exec -it es01 /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node
docker run -e ENROLLMENT_TOKEN="<token>" --name es02 --net elastic -it -m 1GB docker.elastic.co/elasticsearch/elasticsearch:9.1.5
curl --cacert http_ca.crt -u elastic:$ELASTIC_PASSWORD https://localhost:9200/_cat/nodes

docker pull docker.elastic.co/kibana/kibana:9.1.5
docker run --name kib01 --net elastic-single-node -p 5601:5601 docker.elastic.co/kibana/kibana:9.1.5
docker exec -it es01 /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic
docker exec -it es01 /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana