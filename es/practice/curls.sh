curl -i -X GET "https://localhost:9200/_cat/indices?v" -u elastic:ndgndg91 -k
curl -i -X GET "https://localhost:9200/my_index?pretty" -u elastic:ndgndg91 -k
curl -i -X GET "https://localhost:9200/my_index/_mapping?pretty" -u elastic:ndgndg91 -k
curl -i -X PUT "https://localhost:9200/my_index?pretty" \
  -u elastic:ndgndg91 \
  -k \
  -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1
  },
  "mappings": {
    "properties": {
      "title": {
        "type": "text"
      },
      "author": {
        "type": "keyword"
      },
      "created_at": {
        "type": "date"
      },
      "views": {
        "type": "integer"
      }
    }
  }
}'
curl -i -X DELETE "https://localhost:9200/my_index?pretty" -u elastic:ndgndg91 -k

# 문서 추가
curl -i -X POST "https://localhost:9200/my_index/_doc?pretty" \
  -u elastic:ndgndg91 -k \
  -H 'Content-Type: application/json' -d '
{
  "title": "Elasticsearch 시작하기",
  "author": "남동길",
  "created_at": "2025-10-07",
  "views": 42
}
'

# 검색해보기
curl -i -X GET "https://localhost:9200/my_index/_search?pretty" \
  -u elastic:ndgndg91 -k \
  -H 'Content-Type: application/json'  -d '
{
  "query": {
    "match_all": {}
  }
}
'