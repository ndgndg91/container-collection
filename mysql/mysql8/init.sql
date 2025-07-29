CREATE USER 'ndgndg91'@'%' IDENTIFIED BY 'ndgndg91';

GRANT RELOAD, FLUSH_TABLES ON *.* TO 'ndgndg91'@'%';
FLUSH PRIVILEGES;

GRANT SUPER, REPLICATION CLIENT ON *.* TO 'ndgndg91'@'%';
FLUSH PRIVILEGES;

GRANT REPLICATION SLAVE ON *.* TO 'ndgndg91'@'%';
FLUSH PRIVILEGES;

SHOW GRANTS FOR 'ndgndg91'@'%';
     
-- 데이터베이스 생성 (원하는 데이터베이스 이름으로 변경하세요)
CREATE DATABASE my_sandbox;

-- 'ndgndg91' 계정에 'my_sandbox'에 대한 모든 권한 부여
GRANT ALL PRIVILEGES ON my_sandbox.* TO 'ndgndg91'@'%';

-- 변경된 권한을 즉시 적용
FLUSH PRIVILEGES;

-- 'ndgndg91' 계정의 현재 권한 확인 (선택 사항)
SHOW GRANTS FOR 'ndgndg91'@'%';
