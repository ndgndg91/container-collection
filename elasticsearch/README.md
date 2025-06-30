# Elasticsearch 로컬 개발환경 구축 가이드

Docker Compose를 사용하여 Elasticsearch 로컬 개발환경을 구축하는 방법을 설명합니다.

## 📋 목차

- [Elasticsearch란?](#elasticsearch란)
- [사전 요구사항](#사전-요구사항)
- [설정 파일](#설정-파일)
- [사용 방법](#사용-방법)
- [설정 상세 설명](#설정-상세-설명)
- [테스트 방법](#테스트-방법)
- [Kibana 사용법](#kibana-사용법)
- [트러블슈팅](#트러블슈팅)

## 🔍 Elasticsearch란?

Elasticsearch는 **분산 검색 및 분석 엔진**으로 다음과 같은 용도로 사용됩니다:

- 📊 로그 분석 (ELK 스택)
- 🔍 실시간 검색 기능
- 📈 데이터 분석 및 시각화
- 📝 전문 검색 (Full-text search)

## 🛠 사전 요구사항

- Docker
- Docker Compose
- 최소 4GB RAM (권장 8GB+)

## 📁 설정 파일

### 1. 기본 단일 노드 설정

개발 초기 단계나 간단한 테스트용으로 적합합니다.

**docker-compose.yml**

```yaml
version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.0
    container_name: es-dev
    environment:
      - node.name=es-dev
      - cluster.name=es-dev-cluster
      - discovery.type=single-node
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - xpack.security.enabled=false
      - xpack.security.enrollment.enabled=false
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - es-data:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"
      - "9300:9300"
    networks:
      - es-net

  kibana:
    image: docker.elastic.co/kibana/kibana:8.11.0
    container_name: kibana-dev
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    networks:
      - es-net
    depends_on:
      - elasticsearch

volumes:
  es-data:
    driver: local

networks:
  es-net:
    driver: bridge
```

### 2. 3노드 클러스터 설정

클러스터 기능을 테스트하고 싶을 때 사용합니다.

**docker-compose-cluster.yml**

```yaml
version: '3.8'

services:
  es01:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.0
    container_name: es01
    environment:
      - node.name=es01
      - cluster.name=es-cluster
      - discovery.seed_hosts=es02,es03
      - cluster.initial_master_nodes=es01,es02,es03
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - xpack.security.enabled=false
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - es01-data:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"
    networks:
      - es-net

  es02:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.0
    container_name: es02
    environment:
      - node.name=es02
      - cluster.name=es-cluster
      - discovery.seed_hosts=es01,es03
      - cluster.initial_master_nodes=es01,es02,es03
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - xpack.security.enabled=false
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - es02-data:/usr/share/elasticsearch/data
    networks:
      - es-net

  es03:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.0
    container_name: es03
    environment:
      - node.name=es03
      - cluster.name=es-cluster
      - discovery.seed_hosts=es01,es02
      - cluster.initial_master_nodes=es01,es02,es03
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - xpack.security.enabled=false
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - es03-data:/usr/share/elasticsearch/data
    networks:
      - es-net

  kibana:
    image: docker.elastic.co/kibana/kibana:8.11.0
    container_name: kibana
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://es01:9200
    networks:
      - es-net
    depends_on:
      - es01

volumes:
  es01-data:
    driver: local
  es02-data:
    driver: local
  es03-data:
    driver: local

networks:
  es-net:
    driver: bridge
```

## 🚀 사용 방법

### 기본 단일 노드 실행

```bash
# 백그라운드에서 실행
docker-compose up -d

# 로그 확인
docker-compose logs -f

# 상태 확인
docker-compose ps
```

### 클러스터 실행

```bash
# 클러스터 설정으로 실행
docker-compose -f docker-compose-cluster.yml up -d

# 로그 확인
docker-compose -f docker-compose-cluster.yml logs -f
```

### 중지 및 정리

```bash
# 컨테이너 중지
docker-compose down

# 볼륨까지 완전 삭제
docker-compose down -v

# 클러스터 설정의 경우
docker-compose -f docker-compose-cluster.yml down -v
```

## ⚙️ 설정 상세 설명

### 핵심 Environment 변수

| 변수 | 설명 | 값 예시 |
|------|------|---------|
| `node.name` | 노드 이름 | `es-dev` |
| `cluster.name` | 클러스터 이름 | `es-dev-cluster` |
| `discovery.type` | 디스커버리 타입 | `single-node` |
| `bootstrap.memory_lock` | 메모리 스왑 방지 | `true` |
| `ES_JAVA_OPTS` | JVM 힙 메모리 설정 | `-Xms512m -Xmx512m` |
| `xpack.security.enabled` | 보안 기능 활성화 | `false` (개발용) |

### 포트 설명

| 포트 | 용도 |
|------|------|
| `9200` | REST API (HTTP) |
| `9300` | 노드간 통신 (Transport) |
| `5601` | Kibana 웹 인터페이스 |

### 메모리 설정 가이드

| 용도 | 권장 메모리 | 설정 값 |
|------|-------------|---------|
| 기본 개발/테스트 | 512MB | `-Xms512m -Xmx512m` |
| 중간 규모 개발 | 1-2GB | `-Xms1g -Xmx1g` |
| 대용량 테스트 | 4GB+ | `-Xms4g -Xmx4g` |

## 🧪 테스트 방법

### 기본 상태 확인

```bash
# ES 상태 확인
curl http://localhost:9200

# 클러스터 헬스 체크
curl http://localhost:9200/_cluster/health

# 노드 정보 확인
curl http://localhost:9200/_nodes
```

### 인덱스 및 문서 조작

```bash
# 인덱스 생성
curl -X PUT "localhost:9200/my-index" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1
  }
}'

# 문서 추가
curl -X POST "localhost:9200/my-index/_doc/1" -H 'Content-Type: application/json' -d'
{
  "title": "첫 번째 문서",
  "content": "Elasticsearch 테스트 문서입니다",
  "timestamp": "2024-01-01"
}'

# 문서 검색
curl http://localhost:9200/my-index/_search

# 전문 검색
curl -X GET "localhost:9200/my-index/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "content": "테스트"
    }
  }
}'
```

### 관리 명령어

```bash
# 인덱스 목록 확인
curl http://localhost:9200/_cat/indices?v

# 매핑(스키마) 확인
curl http://localhost:9200/my-index/_mapping

# 샤드 정보 확인
curl http://localhost:9200/_cat/shards?v
```

## 📊 Kibana 사용법

Kibana는 `http://localhost:5601`에서 접속할 수 있습니다.

### 주요 메뉴

1. **Dev Tools** (`/app/dev_tools#/console`)
    - ES REST API를 브라우저에서 직접 테스트
    - 쿼리 작성 및 실행

2. **Index Management** (`/app/management/data/index_management`)
    - 인덱스 생성, 삭제, 설정 관리
    - 인덱스 템플릿 관리

3. **Discover** (`/app/discover`)
    - 데이터 탐색 및 검색
    - 로그 분석

4. **Dashboard** (`/app/dashboards`)
    - 데이터 시각화
    - 차트 및 그래프 생성

### Dev Tools 예시

Kibana Dev Tools에서 다음과 같이 실행할 수 있습니다:

```javascript
// 인덱스 생성
PUT my-index
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1
  }
}

// 문서 추가
POST my-index/_doc
{
  "title": "Kibana에서 추가한 문서",
  "content": "Dev Tools를 사용한 테스트",
  "timestamp": "2024-01-01"
}

// 검색
GET my-index/_search
{
  "query": {
    "match_all": {}
  }
}
```

## 🔧 트러블슈팅

### 메모리 관련 오류

**증상**: `bootstrap checks failed` 또는 OutOfMemory 오류

**해결방법**:
```bash
# Linux/Mac에서 vm.max_map_count 증가
sudo sysctl -w vm.max_map_count=262144

# 영구 적용
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf

# Docker Desktop (Windows/Mac)의 경우 메모리 할당량 증가
```

### 권한 관련 오류

**증상**: 볼륨 마운트 권한 오류

**해결방법**:
```bash
# 데이터 디렉토리 권한 설정
sudo chown -R 1000:1000 /path/to/elasticsearch/data

# 또는 볼륨을 사용하지 않고 테스트
docker-compose down -v
docker-compose up -d
```

### 포트 충돌

**증상**: `Port already in use` 오류

**해결방법**:
```bash
# 사용 중인 포트 확인
netstat -tulpn | grep :9200

# 다른 포트로 변경
ports:
  - "9201:9200"  # 9201로 변경
```

### 클러스터 형성 실패

**증상**: 노드가 클러스터에 조인하지 못함

**해결방법**:
```bash
# 모든 컨테이너 완전 삭제 후 재시작
docker-compose -f docker-compose-cluster.yml down -v
docker-compose -f docker-compose-cluster.yml up -d

# 로그 확인
docker-compose -f docker-compose-cluster.yml logs -f
```

## 📚 유용한 리소스

- [Elasticsearch 공식 문서](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Kibana 공식 문서](https://www.elastic.co/guide/en/kibana/current/index.html)
- [Docker Compose 공식 문서](https://docs.docker.com/compose/)

## 🏷 주요 개념 정리

| 개념 | 설명 |
|------|------|
| **노드 (Node)** | Elasticsearch의 단일 서버 인스턴스 |
| **클러스터 (Cluster)** | 여러 노드가 모여 하나의 시스템을 구성 |
| **인덱스 (Index)** | 관계형 DB의 "데이터베이스"와 유사한 개념 |
| **샤드 (Shard)** | 인덱스를 여러 조각으로 나눈 것 |
| **복제본 (Replica)** | 샤드의 복사본, 백업 및 성능 향상용 |

이 가이드를 통해 Elasticsearch 로컬 개발환경을 성공적으로 구축하고 활용하시기 바랍니다! 🚀