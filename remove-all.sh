# 모든 컨테이너와 볼륨 완전 삭제
docker-compose down -v
docker system prune -a -f
docker volume prune -f