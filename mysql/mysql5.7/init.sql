-- 1. 기존 사용자 삭제 (권한 초기화를 위해 가장 확실한 방법)
--    만약 'ndgndg91' 사용자가 이미 있다면 삭제하고 다시 만듭니다.
DROP USER IF EXISTS 'ndgndg91'@'%';
FLUSH PRIVILEGES;

-- 2. 사용자 생성
CREATE USER 'ndgndg91'@'%' IDENTIFIED BY 'ndgndg91';

-- 3. 데이터베이스 생성 (이 부분은 'ndgndg91'이 아닌, 관리자 권한을 가진 계정으로 먼저 실행하는 것이 좋습니다.)
CREATE DATABASE IF NOT EXISTS my_sandbox;

-- 4. 'ndgndg91' 사용자에게 'my_sandbox' 데이터베이스에 대한 권한 부여
--    - CREATE: 테이블 생성 (초기 설정 시에 필요)
--    - SELECT, INSERT, UPDATE, DELETE: 데이터 조작 (애플리케이션 운영 시 지속적으로 필요)
--    - DROP: 테이블 삭제 (Spring Boot의 ddl-auto=create-drop, update 등에서 필요)
--    - ALTER: 테이블 구조 변경 (Hibernate의 ddl-auto=update 등에서 컬럼 변경 시 필요)
--    - INDEX: 인덱스 생성/삭제 (Hibernate의 ddl-auto에서 인덱스 관리 시 필요)
--    만약 이 계정이 my_sandbox 내의 모든 것을 제어해야 한다면 ALL PRIVILEGES를 사용하고,
--    그렇지 않다면 필요한 권한만 명시적으로 나열하는 것이 보안에 더 좋습니다.
GRANT CREATE, SELECT, INSERT, UPDATE, DELETE, DROP, ALTER, INDEX ON my_sandbox.* TO 'ndgndg91'@'%';

-- 5. 권한 변경 사항 적용
FLUSH PRIVILEGES;

-- 6. 부여된 권한 확인 (선택 사항)
SHOW GRANTS FOR 'ndgndg91'@'%';

-- --- (여기까지는 관리자 계정으로 실행하는 것을 권장) ---

-- 7. 'ndgndg91' 계정으로 접속하여 실행할 수 있는 부분:
USE my_sandbox;

CREATE TABLE IF NOT EXISTS execution_history
(
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    symbol VARCHAR(100),
    amount BIGINT NOT NULL,
    timestamp TIMESTAMP NOT NULL  DEFAULT CURRENT_TIMESTAMP,
    INDEX index_timestamp(timestamp)
    ) ENGINE=InnoDB;