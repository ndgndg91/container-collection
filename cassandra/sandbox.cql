CREATE KEYSPACE my_sandbox WITH replication = {'class': 'NetworkTopologyStrategy', 'dc1': 3};

USE my_sandbox;

CREATE TABLE credit_history
(
    account_id      bigint,    -- 계정 ID (파티션 키)
    event_id        timeuuid,  -- 이벤트 고유 ID (클러스터링 키)
    event_type      text,      -- 이벤트 타입 (애플리케이션에서 캐시된 메타데이터로 보강)
    description     text,      -- 상세 내용
    event_timestamp timestamp, -- 사람이 읽기 편한 이벤트 발생 시각
    PRIMARY KEY ((account_id), event_id)
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