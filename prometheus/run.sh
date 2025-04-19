# Prometheus 실행
docker run -d --name prometheus \
  -p 9090:9090 \
  -v $(pwd)/config:/etc/prometheus \
  prom/prometheus