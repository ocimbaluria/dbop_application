-- AdminCreateUsers.sql

  CREATE USER AQUSER IDENTIFIED BY Welcome12345;
-- CREATE USER AQUSER IDENTIFIED BY "$AQUSER_PASSWORD";
GRANT unlimited tablespace to AQUSER;
GRANT connect, resource TO AQUSER;
GRANT aq_user_role TO AQUSER;
GRANT EXECUTE ON sys.dbms_aqadm TO AQUSER;
GRANT EXECUTE ON sys.dbms_aq TO AQUSER;
-- for observability...
grant select on v$session to aquser;
grant select on gv_$session to aquser;
grant select on gv$persistent_subscribers to aquser;
grant select on v$instance to aquser;
grant select on gv$asm_diskgroup to aquser;
grant select on gv$sysstat to aquser;
grant select on gv$process to aquser;
grant select on gv$system_wait_class to aquser;
grant select on gv$osstat to aquser;


CREATE USER BANKAUSER IDENTIFIED BY Welcome12345;
-- CREATE USER BANKAUSER IDENTIFIED BY "$BANKAUSER_PASSWORD";
GRANT unlimited tablespace to BANKAUSER;
GRANT connect, resource TO BANKAUSER;
GRANT aq_user_role TO BANKAUSER;
grant AQ_ADMINISTRATOR_ROLE to bankauser;
GRANT EXECUTE ON sys.dbms_aq TO BANKAUSER;
GRANT SODA_APP to BANKAUSER;
GRANT SELECT ANY TABLE TO BANKAUSER;
GRANT select on gv_$session to BANKAUSER;
GRANT select on v$diag_alert_ext to BANKAUSER;
GRANT select on DBA_QUEUE_SCHEDULES to BANKAUSER;

CREATE USER BANKBUSER IDENTIFIED BY Welcome12345;
-- CREATE USER BANKBUSER IDENTIFIED BY "$BANKBUSER_PASSWORD";
GRANT unlimited tablespace to BANKBUSER;
GRANT connect, resource TO BANKBUSER;
GRANT aq_user_role TO BANKBUSER;
grant AQ_ADMINISTRATOR_ROLE to bankbuser;
GRANT EXECUTE ON sys.dbms_aq TO BANKBUSER;
GRANT SODA_APP to BANKBUSER;
GRANT SELECT ANY TABLE TO BANKBUSER;
GRANT select on gv_$session to BANKBUSER;
GRANT select on v$diag_alert_ext to BANKBUSER;
GRANT select on DBA_QUEUE_SCHEDULES to BANKBUSER;

-- AQUserCreateQueues.sql

BEGIN
   DBMS_AQADM.CREATE_QUEUE_TABLE (
      queue_table          => 'BANKAQUEUETABLE',
      queue_payload_type   => 'SYS.AQ$_JMS_TEXT_MESSAGE',
      multiple_consumers   => true,
      compatible           => '8.1');

   DBMS_AQADM.CREATE_QUEUE_TABLE (
      queue_table          => 'BANKBQUEUETABLE',
      queue_payload_type   => 'SYS.AQ$_JMS_TEXT_MESSAGE',
      multiple_consumers   => true,
      compatible           => '8.1');

   DBMS_AQADM.CREATE_QUEUE (
      queue_name          => 'BANKAQUEUE',
      queue_table         => 'BANKAQUEUETABLE');

   DBMS_AQADM.CREATE_QUEUE (
      queue_name          => 'BANKBQUEUE',
      queue_table         => 'BANKBQUEUETABLE');

   DBMS_AQADM.START_QUEUE (
      queue_name          => 'BANKAQUEUE');

   DBMS_AQADM.START_QUEUE (
      queue_name          => 'BANKBQUEUE');

--       2hr retention - todo, remove or set as appropriate/common
   DBMS_AQADM.ALTER_QUEUE(
      queue_name        => 'BANKAQUEUE',
      retention_time    => 3600);

END;
/

BEGIN
   DBMS_AQADM.grant_queue_privilege (
      privilege     =>     'ENQUEUE',
      queue_name    =>     'BANKAQUEUE',
      grantee       =>     'BANKAUSER',
      grant_option  =>      FALSE);

   DBMS_AQADM.grant_queue_privilege (
      privilege     =>     'DEQUEUE',
      queue_name    =>     'BANKAQUEUE',
      grantee       =>     'BANKBUSER',
      grant_option  =>      FALSE);

   DBMS_AQADM.grant_queue_privilege (
      privilege     =>     'ENQUEUE',
      queue_name    =>     'BANKBQUEUE',
      grantee       =>     'BANKBUSER',
      grant_option  =>      FALSE);

   DBMS_AQADM.grant_queue_privilege (
      privilege     =>     'DEQUEUE',
      queue_name    =>     'BANKBQUEUE',
      grantee       =>     'BANKAUSER',
      grant_option  =>      FALSE);

   DBMS_AQADM.add_subscriber(
      queue_name=>'BANKAQUEUE',
      subscriber=>sys.aq$_agent('bankb_service',NULL,NULL));

   DBMS_AQADM.add_subscriber(
      queue_name=>'BANKBQUEUE',
      subscriber=>sys.aq$_agent('banka_service',NULL,NULL));
END;
/

-- BankAUser.sql

create table bankauser.accounts (
  accountid integer PRIMARY KEY NOT NULL,
  accountvalue integer CONSTRAINT positive_inventory CHECK (accountvalue >= 0),
  last_updated_date date
);

insert into bankauser.accounts(ACCOUNTID, ACCOUNTVALUE) values (100, 100);

insert into bankauser.accounts(ACCOUNTID, ACCOUNTVALUE) values (200, 200);

insert into bankauser.accounts(ACCOUNTID, ACCOUNTVALUE) values (300, 300);

-- BankBUser.sql

create table bankbuser.accounts (
  accountid integer PRIMARY KEY NOT NULL,
  accountvalue integer CONSTRAINT positive_inventory CHECK (accountvalue >= 0),
  last_updated_date date
);

insert into bankbuser.accounts(ACCOUNTID, ACCOUNTVALUE) values (100, 100);

insert into bankbuser.accounts(ACCOUNTID, ACCOUNTVALUE) values (200, 200);

insert into bankbuser.accounts(ACCOUNTID, ACCOUNTVALUE) values (300, 300);