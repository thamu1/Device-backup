Snowflake
---------

Note:
-----
    - Snowflake only availble on cloud. Saas. 
    - Compute and storage are seperated with different Billings.
    - database storage : Hybrid columnar storage.
    - Scaling policy : 
        . Standard : Scale out, adding cluter, can run Multiple query, cluster st when query queued or detected. 2 to 3 check then shutdown. 
        . Economy : Scale in, sequential query execution, cluster st only enough query to load, 5 to 6 checks then shutdown.
    - Snowflake credit is a unit of measure. Pay for.
    - Size of Vm determines how fast query will run.
    - Query prossion flow: Query -> Cloud service Layer [query plan] -> Multi-cluster compute [process the data stored in storage] <- Storage
    - If we want to see stages and file format we should be account admin or need necessary permission.
    - permanent , temporary, transient table.
        - can create transient from permanent.
    - Fail safe data only can access by snowflake


Optimization:
-------------
    - based on location of the cluster, data transfer location, cost differ.
    - Larger data transfer & store incur more cost.
    - Auto suspension and auto resume.
    - Monitor operations to avoid unnecessary cost.
    - Compress data before store. storing Data will internally compress again by snowflake.
    - Choose Int / timestemp column, avoid stored as varchar.
    - Use Transient Table to avoid History table storage.
    - Use resource monitor to setup alert.

Queries:
--------
    - use role accountadmin;

    Warehouse create query: [Recommand to use UI]
        - create warehouse <warehouse-name> with
            warehouse_size = "XSMALL"
            warehouse_type = "standard"
            auto_suspend = 600
            auto_resume = true
            min_cluster = 1
            max_cluster = 3
            scaling_policy = "standard|economy"
            comment = "own cmt"
    
    Resource Monitor: [Recommand to use UI]
        - create or replace resource <resource-monitor-name> with
            credit_quota = 100 
            frequency = weekly
            start_timestamp = "2025-09-25 00:00 IST"
            triggers on 50 percent do notify
                     on 75 percent do notify
                     on 85 percent do suspend
                     on 100 percent do suspend_immediate;

    Alert:
        - alter warehouse <warehouse-name> 
            set resource_monitor = <resource-monitor-name> 


Basic:
------
    - Cloud data warehouse.
    - Pay what we use
    - Sperate compute and Storage
    - Elastic (based on the workload it can increase/decrese compute) and Highly scalable

Editions:
---------
    > Go to > Snowflake trial > to create 30 days free account

    - Standard : 1 day time travel + level of support and cost
    - Enterprise : 90 days time traval + Multi cluster warehouse + Materialized view
    - Business critical : Enterprise + Enhanced security + data protection + database failover/failback
    - Virtual private snowflake.


Roles:
------
    - AccountAdmin : top-level role, 
    - UserAdmin : create user and roles.
    - SecurityAdmin :  Modify and monitor user role (grant and revoke)
    - SysAdmin : Privillege to create(grant permissions) warehouse, databases, other objects.
    - Public : automatic grant role to every users.

    privillages : Modify, Monitor, Operator, Usage.

    - Creating role::
        - Use [SysAdmin | AccountAdmin]
        . Role: create or replace role <role-1>;
        . User: create or replace user <user-1> password = "<>" default_role = "<role-1>";
        . Secure view: 
            > Create or replace secure view <view-1> as 
              <DQL-query> where Role_column = Current_role()
        . Grant basic access to role:    
            => grant role <role-1> to user <user-1>;
            => grant usage on warehouse [& database | & schema] to role <role-1>;
            => grant select on view <view-1> to role <role-1>;

Architecture:
-------------
    - link : https://www.linkedin.com/pulse/exploring-snowflake-architecture-concepts-pirathipan-loganathan/
    - Warehouse tab > Create warehouse.

data hirarchy:
--------------
    - Access privillages can be given to user in the database/table page.

Account:
--------
    - For seeing billing, User roles etc, We need to be AccountAdmin.
    - This button only enable when login with AccountAdmin.

credit Calculations:
--------------------
    - snowflake.account_usage.query_history [ex : based on query type calculate credit]
    - snowflake.account_usage.warehouse_metering_history [ex : Based on warehouse calculate credit]

Resource Monitor:
----------------
    Setup:
        - Enable Notification prior creating Resouce monitor.
        - Log in as Account admin > Account > Resource Monitor > Create
        - or use Resource Monitor query
    
    - Credit Quota
    - Schedule
    - Monitor level
    - Notify : Send notificaiton to administrator and Perform no action
    - Notify and Suspend : send notification to administrator and Suspend after execution.
    - Notify and Suspend Immediately : send notification to administrator and suspend all assigned warehouse immediately.

    IF Suspend and Suspend Immediately enabled, If warehouse suspended due to reached threshold limit. can not start warehouse Until any one of the following condition is met.
        - Next interval, If any, starts
        - Credit quota increased for monitor.
        - creadit Threshold increased.
        - warehouse no longer assigned to Monitor.
        - Monitor is dropped.

    Note:
        - Resource Monitor Must have at least one action defined.

Partitioning:
-------------
    - Unlike others Snowflake follows Micro-partitions
    - Which enables Faster query and efficient DML.
    - Size : 50 - 500 MB before compression.
    - columner storage.

Clustering:
-----------
    - Data stored in table are sorted/ordered.
    - Process to optimize data retrival due to avoid unnecessary scanning.
    - Clustering is computationally expensive.


Creating External Storage:
--------------------------
    - create or replace table <database>.<schema>.<table-name>
        (col datatype constraints)

    - Create integration:
        create or replace storage integration <integration_name>
        type = external_stage
        storage_provider = s3
        enabled = true
        storage_aws_role_arn = "arn.aws.iam::<>:role/<>" # get it from aws iam service.
        // AZURE_TENANT_ID = '<GET IT from azure active directory>'
        storage_allowed_locations = ("s3://<bucket-path>", "extra") // ('azure://<service-account>.blob.core.windows.net/<container-name>/')

        - desc integration <integration-name>

        - AWS take : 
            . storage_aws_iam_user_arn value
            . storage_aws_external_id
            . Edit aws trust relationship
        
        - Azure take:
            . azure_consent_url -> allow permission by taking url
            . create a role in IAM 
            . Role: Storage blob data contributor.

    - Create file format:
        create or replace file format <db>.<schema>.<csv>_format
        type = csv
        field_delimiter = ","
        skip_header = 1
        null_if = ("Null", "null")
        empty_field_as_null = true
    
    - Create Stage:
        create or replace stage <db>.<schema>.<stg-name>
        URL = "s3://<path>"
        storage_integration = <integration-name>
        file_format = <db>.<schema>.csv_format

        show stages;

        list @<stage-name>;

    - Test data:
        select * ($1, $n [rep col like 1col, n col]) 
        from @<db>.<schema-name>.<stg-name>

    - Copy into:

        - stage table / external location everytime mentioned in @ symbol.

        copy into <table-name>
        from @<db>.<shema>.<stg-name>
        on_error = continue

        (or) 

        // Column name are case sensitive

        copy into <table-name>
        from (
            select 
            $1:<col-name> :: <varchar(datatype)>
            , $1:<col-name> :: <varchar(datatype)>
            // METADATA$FILENAME // For getting file name
            // METADATA$FILE_ROW_NUMBER // getting row number
            // TO_TIMESTAMP_NTZ(currrent_timestamp)
            from @<db>.<schema>.<table-name>
        ) 


Snow Pipe:
----------

    - It is a snowflakes serverless feature that used to load the data from File system (s3, GCS, Gen2, etc.)
        to snowflake systerm as soon as arraived.
    - Copy command need external scheduling, Meanwhile Snow pipe automatically trigger using file notificaiton/ Event Notification.
    
    Disadvantage:
        - Snow pipe is expensive than COPY INTO.
        - Throughput limit: amount of data load per second is limited.


    Steps:
        
        - Create Table:
            create or replace table <db>.<schema>.<tbl-name>( col datatype )
        
        - Storage integration:
            create or replace storage integration <integration-name>
            type = external_stage
            storage_provider = s3/azure
            enabled = true
            // storage_aws_role_arn = "arn:aws:iam::<>" 
            // AZURE_TENANT_ID = '<GET IT from azure active directory>'
            storage_allowed_locations = ("s3://<path>", )

            desc integration <integration-name>;

            - show pipes;
            - take arn url from the result set (channal ARN).
            - go to > aws s3 > bucket > properties 
                > Events > add notification > choose - all object create events > send to - SQS Queue > SQS - add SQS queue ARN > SQS queue ARN - <Paste the arn link>

        - create file format:
            create or replace file format <db>.<schema>.<csv>_format
            type = <csv>
            field_delimiter = <",">
            skip_header = 1
            null_if = ("NULL", "null")
            empty_field_as_null = true
        
        - create Stage:
            create or replace <db>.<schema>.<stg-name>
            URL = "s3://<path>"
            storage_integration = <integration-name>
            file_format = <db>.<schema>.<file-format>

        - Create PIPE:
            create or replace pipe <db>.<schema>.<pipe-name> 
            auto_ingest = true
            as (
                copy into <db>.<schema>.<trg-table-name>
                from @<db>.<schema>.<stg-name>
                on_error = continue
            );

        
        select * from <db>.<schema>.<trg-table-name>

Different Types of Table:
-------------------------
    - Permanent: 
        . Default
        . Higer number of Retention days
        . Have fail-safe period of 7 days.
    - Temporary: 
        . Store non permanent data.
        . only with in session, other user cannot see.
        . clone not allowed.
        . temp table and table name can be same.
        . Higer precedence to be temp table.
    - Transient
        . Similar to permanent table. Diff, do not have file safe period.
        . It is created only when table do not required protection and recovery.
        . Can create transient databse and schema as well.
        . Under Transient level, all the tables or schemas are transient by defination.

    Syntax:
        create or replace [transient | temporary] [database | schema | table] <name>
        ( options )

        create or replace transient table <tbl-name>
        clone <per-tbl-name>


Time Travel:
------------
    - Achieved by `at | before(<condition>)`
    - Standard edition:
        . Time travel retention period: (Transient = 0, permanent = 1)
        . Fail safe: (Transient = 0, permanent = 1)
    - Enterprise edition: 
        . Time travel retention period : 0-90 days (Transient - 1 days, temp - 10) 
        . Fail safe (Transient = 0, permanent = 7)
    - Can set retention periods table level while creating it or altering it using `data_retention_time_in_days = `.
        . create table <tbl-name>(col datatype) data_retention_time_in_days = `n`
        . alter table <tbl-name> set data_retention_time_in_days = `n`
    - fail safe:
        . Used to protect data from system failure or disaster.
        . period starts immediately after time travel period ends.
        . permanent table: 7 days.
        . Transient table: 0 days.

    - History access:
        . Show [tables | databases | schema] history [like <tbl-name>] [in <db> | <db>.<schema>]
    
    - Restore dropped:
        - undrop [table | schema | database] <Full-name>;
    
    - Example:
        . SELECT * FROM <tbl-name> AT[/ BEFORE](TIMESTAMP => '2024-03-13 13:56:09.553 +0100'::TIMESTAMP);
        . SELECT * FROM <tbl-name> AT[/ BEFORE](OFFSET => -60*5); -- give 5 minutes before table;
        . SELECT * FROM my_table AT[/ BEFORE](STATEMENT => 'query-id');

    - Clone:
        - create or replace <db>.<schema>.<table> 
        clone <db>.<schema>.<stg-table-name>
        AT[/ BEFORE](<Condition>)
    
    Note:
        . It require ACCOUNT_ADMIN role to set retention period.
        . Fail safe is not accessible by snowflake user.
        . Fail safe info can visible only by AccountAdmin and SecurityAdmin

Task:
-----
    - Kind of Trigger. Used to automate or schedule Queries. 
    - Can execute single query or can call stored procedure.
    - Types: Tree task, Sandalone Task.
    - Tree task:
        . Tree task can have 1000 task max and A task can have 100 max child Task.
        . For each run it require avg 5 min to complete
    
    - Create task:
        Create or replace task <task-name1>
        WAREHOUSE = <warehouse-name>
        SCHEDULE = "<n minutes|hours|seconds>" | [<USING CRON <expr> <time_zone> ]
        CONFIG = <configuration_string>
        <session_parameter> = <value> [ , <session_parameter> = <value> ... ]
        SUSPEND_TASK_AFTER_NUM_FAILURES = <num> 
        COMMENT = '<string_literal>'
        AFTER <string>, [, <string>]

        AS < SQL query (DDL/DML/DDL / call procedure) >; 

    - To see info:
        Show tasks;  describe task <task-name>

    - start / suspend task:  
        - ALTER TASK <task-name> [resume | suspend | REMOVE AFTER | ADD AFTER [<task-name> ,  ]] 
        
    - Drop task:
        DROP TASK [ IF EXISTS ] <name>

    - Creating role to manage task:
        - Use [SysAdmin | AccountAdmin]
        - Create role <role-name> comment ""
        - Grant usage on warehouse <warehouse-name> to role <role-name>
        - Grant create task, execute task, execute managed task 
            on account [schema <schema-name> | warehouse <ware-name>] 
            to role <role-name>
        
    Note:
        - We can not create a child task from multiple parent task.
        - The child task only trigger right after completion of Parent task. 
        - If we set dependencies, child can not schedule it.
        - By default created task is suspended, Need to trigger manually using alter command

Stream:
-------
    - Track the source table Changes(DML changes).
    - source table -> Initial snapshot -> Track changes -> Snapshot taken
    - Stream does not contain any table data.
    - It store only and difference between 2 offsets for the source table and return CDC records by leverage versioning history.
    - Types: 
        1. Standard:

            - Create:
                * Create or replace stream <stream-name> on table <old-table-name>
                * Alter stream <stream-name> set comment = ""
                * drop stream <stream-name>
            - Info: show streams; describe stream <stream-name>
            - Access stream table metadata:
                select to_timestamp(SYSTEM$STREAM_GET_TABLE_TIMESTAMP(<steam-name>));
            - The modified data will be in <stream-name> table.
                select * from <stream-name>;
            - Take the updated rows from <stream-name> table and update the Final table as per requirement.
                . insert: METADATA$ACTION = "INSERT" and METADATA$ISUPDATE = "FALSE"
                . update: METADATA$ACTION = "INSERT" and METADATA$ISUPDATE = "TRUE"
                . delete: METADATA$ACTION = "DELETE" and METADATA$ISUPDATE = "FALSE"

        2. Append only:
        3. Insert only:
        
    - Transaction:
        BEGIN
            DML operation;
            COMMIT / ROLLBACK;
        END;

Zero-copy Cloning:
------------------

    - Create a copy of existing databases, schema, non-temp tables
    - quickly take a snapshot of objects(databases, schema, tables).
    - Until make any changes in clone object it will share the original storage.
    - The changes made in original | clone not affect the clone | original
    - Useful for creating instant backups that do not incur any additional costs(Until changes are made to the cloned object.)
    - It copy all the stages, stream, task, everything.

    Syntax:
        . create or replace [database | schema | table] 
            <object-name> clone <existing-object-name>
            [ [at | before] ([timestamp | offset | statement] => <value>) ]

    Swap tables:
        - Swap table metadata and data with other table metadata and data.

        * Alter table <table-name> swap with <another-table-name>

    
    Note:
        - Inorder to identify the object is cloned or not use the below query. 
            . If ID = Clone_group_id => Original table
            . If ID != Clone_group_id => Clone table.
        
            select * from Information_schema.table_storage_metrics
            where table_name = "<tbl-name>" and table_catalog = "<database-name>" and table_schema = "<schema-name>"
            and table_dropped is null and schema_dropped is null;
    
Data Sharing:
-------------
    - Share the same data resources with multiple application or users.   
    - It is enable for Account Admin.
    - No actual data is copied or transferred between accounts. It gives the access to underlying storage.
    - Sharing is done using cloud services layer and metadata store. Only take cost for query compute cost not storage.
    - Types: 
        . Provider acc (Outbound share): 
            . Any snowflake account which produce or create data.
            . share with other snowflake account. no limit on number of shares.
        . Consumer acc (Inbound share):   
            . Any snowflake account which consumes data. No limit on number of shares.
            . It created automatically as soon as provider create outbound shares and add the consumer acc id.
    - Inbound Share between region:
        . Operation on Original Account:

            * Create Share > create share <share-name>
            * grant usage on database <db-name> to share <share-name>
                grant usage on schema <schema-name> to share <share-name>
                grant select on table <table-name> to share <share-name>;
                // grant all privileges on table <table-name> to share <share-name> # will Fail it allow read only to share.

            * alter share <share-name> [add | remove] accounts = <snow-id> // Take it from snowflake url eg: qc918229.us-east-2.aws ..
            * Show Shares; show grants to share <share-name>;
            * Drop share <share-name>;

        . Operation on Shared account:
            * create database <db-name> from share <snow-id.share-name>
        
    - Allowed objects: Tables, External Tables, Secure views, Secure Materialized views, Secure UDFs.
    
    - Note: 
        - All database objects shared between accounts are `read only`. can not do DML, clone, Time-travel, Re-shared
        - The object can not be modified or deleted, including adding or modify table data.
        - Share between same region is allowed but across cloud need different approch.

View:
-----
    - View virtual table.
    - show views; show materialized views;
    - Types:
        - secure view:
            . Does not store any data create from sql query. 
            . Unauthorized user can see defination using GET_DDL or Desc command
            . Both view and materialized view can be secured.
            . Can be row level security
            . snowflake bypass some Optimization when evaluvating secured view
            . Syntax:
                * create or replace secure view | materialized view <view-name> as <sql-query>

        - Materialized view:
            . Pre-computed data derived from query. Useful for frequently accessed data from query.
            . It only work on Enterprise edition or higher.
            . Maintenance of Materialized view incurs additional cost.
            . Limitation:
                . can query only a single table
                . self join not supported.
                . Can not query another M-view, Non-M-view, User defined table function.
                . Many aggregate function not supported.
                . Does not support Having, order by, limit, window functions, UDF etc.
            . Syntax:
                * create or replace Materialized view <view-name> as <sql-query>
    
    - Row level access using secure view:
        . Role: create or replace role <role-1>;
        . User: create or replace user <user-1> password = "<>" default_role = "<role-1>";
        . Secure view: 
            > Create or replace secure view <view-1> as 
              <DQL-query> where Role_column = Current_role()
        . Grant basic access to role:    
            => grant role <role-1> to user <user-1>;
            => grant usage on warehouse [& database | & schema] to role <role-1>;
            => grant select on view <view-1> to role <role-1>;

        
Data Masking:
    - Hide the original data with modified content. Applied column level.
    - Only available in Enterprise edition.
    - Functions: Sha, md5
    - Eg: PII (Personal Identifiable Information)
    - Note: Input data type and output data type should be same.

    > create role <masking-admin>;
    > grant create masking policy on schema <schema-name> to role <masking-admin>;
    > grant apply masking policy on account to role <masking-admin>;
    > Create Body : create or replace masking policy <policy-name> as (<arg datatype>, <arg datatype>)
        returns <data-type> -> 
        case when current_role() in (<role-name>) then <original-val>
        else "<some-masked text>"
        end ;

    > Alter Masking Body : Alter masking policy <policy-name> set BODY -> case when <con> then <val> else <val> end;
    
    > Set Masking: alter [table | view] <table-name> modify column <column-name> set masking policy <masking-policy-name>;
    > UnSet Masking: alter [table | view] <table-name> modify column <column-name> unset masking policy <masking-policy-name>;
    > desc masking policy <making-policy-name>;

    
















