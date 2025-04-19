# Grafana 컨테이너 실행
docker run -d --name grafana \
  -p 3000:3000 \
  --link prometheus:prometheus \
  grafana/grafana