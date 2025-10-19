CREATE KEYSPACE my_sandbox WITH replication = {'class': 'NetworkTopologyStrategy', 'dc1': 3};

USE my_sandbox;

CREATE TABLE credit_history
(
    account_id      bigint,    -- 계정 ID (파티션 키)
    event_id        timeuuid,  -- 이벤트 고유 ID (클러스터링 키)
    event_type      text,      -- 이벤트 타입 (애플리케이션에서 캐시된 메타데이터로 보강)
    description     text,      -- 상세 내용
    event_timestamp timestamp, -- 사람이 읽기 편한 이벤트 발생 시각
    PRIMARY KEY ((account_id), event_id) -- 파티션 키 account_id, 클러스터링 키 event_id
) WITH CLUSTERING ORDER BY (event_id DESC)
   AND comment = '사용자 신용정보 변동 기록 (최신순 정렬)'
   AND compaction = {
            'class': 'TimeWindowCompactionStrategy',
            'compaction_window_unit': 'DAYS',
            'compaction_window_size': 30
            };


INSERT INTO credit_history (account_id,
                            event_id,
                            event_type,
                            description,
                            event_timestamp)
VALUES (1001,
        now(), -- Cassandra가 현재 시간을 기준으로 고유한 timeuuid를 생성합니다.
        'PROVIDE_CONSENT', -- 애플리케이션에서 관리하는 6가지 타입 중 하나
        '마케팅 활용을 위한 개인신용정보 제공 동의',
        toTimestamp(now()) -- 사람이 읽기 편한 형태로 현재 시간을 저장합니다.
       );


INSERT INTO credit_history (account_id,
                            event_id,
                            event_type,
                            description,
                            event_timestamp)
VALUES (2022,
        now(),
        'THIRD_PARTY_INQUIRY',
        'A카드사, 대출 한도 조회',
        toTimestamp(now()));

SELECT account_id, event_id, event_type, description, event_timestamp FROM credit_history WHERE account_id = 1001;

-- 1001번 고객의 2025년 10월 20일 이후 기록만 조회
SELECT * FROM credit_history
WHERE account_id = 1001
AND event_id > minTimeuuid('2025-10-20 00:00:00+0000');

-- 1001번 고객의 특정 기간 사이의 기록 조회
SELECT * FROM credit_history
WHERE account_id = 1001
  AND event_id > minTimeuuid('2025-10-01 00:00:00+0000')
  AND event_id < maxTimeuuid('2025-10-31 23:59:59+0000');

-- 2022번 고객의 가장 최신 기록 3건만 조회
SELECT * FROM credit_history WHERE account_id = 2022 LIMIT 3;

-- 중요: 하면 안 되는 쿼리와 ALLOW FILTERING
-- Cassandra에서는 파티션 키를 지정하지 않고 다른 컬럼으로만 조회하는 것을 엄격하게 금지합니다. 클러스터의 모든 노드를 다 뒤져봐야 해서 성능에 치명적이기 때문입니다.

-- (오류 발생!) 파티션 키 없이 다른 컬럼으로 조회 시도
SELECT * FROM credit_history WHERE event_type = 'PROVIDE_CONSENT';
-- 위 쿼리를 실행하면 Cassandra는 에러를 발생시키며, 쿼리 끝에 ALLOW FILTERING을 붙이면 실행은 시켜주겠다고 알려줍니다.

-- 하지만 `ALLOW FILTERING`은 절대로 운영 환경의 애플리케이션 코드에서 사용하면 안 됩니다.
-- 이것은 "성능 저하를 감수하고 모든 노드의 모든 데이터를 스캔하라"는 의미이며, 데이터가 많아지면 시스템 전체를 마비시킬 수 있습니다.
-- ALLOW FILTERING을 써야만 하는 쿼리가 있다면, 그것은 데이터 모델링이 쿼리 방식과 맞지 않게 잘못되었다는 강력한 신호입니다.
