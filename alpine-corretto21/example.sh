echo "<PAT>" | docker login ghcr.io -u ndgndg91 --password-stdin

docker buildx build \
    --platform linux/amd64,linux/arm64 \
    -t ghcr.io/ndgndg91/giri-alpine-corretto21:latest \
    --push .