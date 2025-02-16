# Reference
- [참고 README](https://github.com/yasasdy/mongodb-sharding/blob/main/README.md)

# start config server
```
docker-compose -f config_server/docker-compose.yml up -d
```
# connect config server
```
mongosh mongodb://localhost:10001
```

# config server replica
```
rs.initiate(
  {
    _id: "config_rs",
    configsvr: true,
    members: [
      { _id : 0, host : "configsvr1:27017" },
      { _id : 1, host : "configsvr2:27017" },
      { _id : 2, host : "configsvr3:27017" }
    ]
  }
)
```

# check replica set status
```
rs.status()
```

# Shard Server
```
docker-compose -f shard_server1/docker-compose.yml up -d
docker-compose -f shard_server2/docker-compose.yml up -d
```

# connect container
```
mongosh mongodb://localhost:20001
mongosh mongodb://localhost:20004
```

# initialize replica sets in shard 1
```
rs.initiate(
  {
    _id: "shard1_rs",
    members: [
      { _id : 0, host : "shardsvr1_1:27017" },
      { _id : 1, host : "shardsvr1_2:27017" },
      { _id : 2, host : "shardsvr1_3:27017" }
    ]
  }
)
```

# initialize replica sets in shard 2
```
rs.initiate(
  {
    _id: "shard2_rs",
    members: [
      { _id : 0, host : "shardsvr2_1:27017" },
      { _id : 1, host : "shardsvr2_2:27017" },
      { _id : 2, host : "shardsvr2_3:27017" }
    ]
  }
)
```

# start router
```
docker-compose -f router/docker-compose.yml up -d
docker exec -it mongos mongosh
mongosh mongodb://localhost:30000
```

# add shard to cluster
```
sh.addShard("shard1_rs/shardsvr1_1:27017,shardsvr1_2:27017,shardsvr1_3:27017")
sh.addShard("shard2_rs/shardsvr2_1:27017,shardsvr2_2:27017,shardsvr2_3:27017")
```


# connect router 
```
use <database>
sh.enableSharding("<database>")
sh.shardCollection("<database>.<collection>", { <shard key field> : "hashed" , ... } )
```

# docker volume 삭제 Cheat sheet
```
docker volume ls --filter driver=local --format "{{.Name}}" | grep "sharding_mongodb" | xargs -r docker volume rm
```