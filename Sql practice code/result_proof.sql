-- use mapr_bigdata_uat_metahub;
select * from (
SELECT mapping_id,  upperboundvalue, lastboundvalue
 FROM mapr_bigdata_uat_metahub.gcp_ingestion_lastrun
where mapping_id in (6,79,78,72,73,75,94,123) -- 75
and jobstatus = "Success"
group by mapping_id having max(jobendtime)

union all
SELECT mapping_id,  upperboundvalue, lastboundvalue FROM mapr_bigdata_uat_metahub.gcp_ingestion_lastrun
where mapping_id in (6,79,78,72,73,75,94,123) -- 75
and jobstatus = "Failed"
group by mapping_id having max(jobendtime)

union all

select mapping_id, min_value, max_value from (
SELECT 
    ref3.group_binding_id AS parent_binding_id,
    CONCAT(ref3.group_binding_id, ref3.exec_order) AS exec_binding_id,
    ref7.project_name,
    CASE
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref1.appendmode = 'NA' AND ref2.credential_name <> 's3' AND drv.hdl_subtype = 'RELOAD')
            THEN '-1'
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref2.credential_name = 's3' AND drv.hdl_subtype = 'RELOAD')
            THEN '-2'
        ELSE DATE_FORMAT(NOW(), '%H%i%S')
    END AS batch_id,
    drv.sourceid,
    ref3.mapping_id,
    CASE
        WHEN (drv.hdl_loadtype = 'FULL') THEN 'full'
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref1.appendmode = 'NA') THEN 'incr_lstmdf'
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref1.appendmode = 'Y') THEN 'incr_appnd'
    END AS load_type,
    LOWER(drv.hdl_subtype) AS load_subtype,
    ref2.driver,
    CASE
        WHEN (ref2.credential_name = 'mssql') THEN CONCAT('jdbc:sqlserver://', drv.serverip, ';database=', drv.sourcedb)
        WHEN (ref2.credential_name IN ('s3', 'sftp')) THEN drv.serverip
        ELSE CONCAT('jdbc:mysql://', drv.serverip, '/', drv.sourcedb)
    END AS jdbc_url,
    ref2.user_name,
    ref2.password,
    ref1.numberofmappers,
    drv.columnlist,
    drv.tablebase,
    CASE
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref2.credential_name <> 's3' AND ref2.credential_name <> 'sftp' AND ref1.appendmode = 'NA' AND drv.hdl_subtype <> 'RELOAD')
            THEN CASE
                WHEN ((ref4.jobstatus = 'Success' OR ref4.cnt > 0) AND ref4.batch_id <> '-1') THEN 0
                ELSE ref1.cdcbacktracedays
            END
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref2.credential_name <> 's3' AND ref2.credential_name <> 'sftp' AND ref1.appendmode = 'NA' AND drv.hdl_subtype = 'RELOAD')
            THEN ref1.cdcbacktracedays
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref2.credential_name = 's3' AND drv.hdl_subtype = 'RELOAD')
            THEN ref4.upperboundvalue
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref2.credential_name = 's3' AND drv.hdl_subtype = 'LASTMODIFIED')
            THEN CONVERT(REPLACE(REPLACE(SUBSTR(ADDTIME(CAST(CONCAT(SUBSTR(ref4.lastboundvalue, 1, 10), ' ', LPAD(SUBSTR(ref4.lastboundvalue, 12), 2, '0'), ':00:00.0') AS DATETIME), '1:00:00.0'), 1, 13), ' 0', '@'), ' ', '@') USING UTF8)
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref1.appendmode = 'Y' AND drv.hdl_subtype = 'RELOAD')
            THEN 'TBC'
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref1.appendmode = 'Y' AND drv.hdl_subtype <> 'RELOAD')
            THEN CASE
                WHEN (ref4.jobstatus_for_appnd = 'Success') THEN COALESCE(ref4.lastboundvalue + 1, 'TBC')
                when (ref4.jobstatus_for_appnd = 'Failed') Then COALESCE(ref4.upperboundvalue, 1) + (SELECT lastboundvalue+1 
                    FROM (
                        SELECT lastboundvalue, mapping_id,jobendtime
                        FROM gcp_ingestion_lastrun
                        where mapping_id = mapping_id
                        GROUP BY mapping_id 
                    ) t where mapping_id = ref4.mapping_id)
            END
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref2.credential_name = 'sftp')
            THEN CONVERT(ref4.lastboundvalue + INTERVAL 1 SECOND USING UTF8)
        ELSE 'TBC'
    END AS min_value, -- <-------------------------------- here ---------------------------------------------------> -- 
    CASE
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref1.appendmode = 'NA' AND ref2.credential_name <> 's3' AND ref2.credential_name <> 'sftp' AND drv.hdl_subtype = 'RELOAD')
            THEN ref1.endtracedays
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref1.appendmode = 'NA' AND ref2.credential_name <> 's3' AND ref2.credential_name <> 'sftp' AND drv.hdl_subtype <> 'RELOAD')
            THEN CASE
                WHEN ((ref4.jobstatus = 'Success' OR ref4.cnt > 0) AND ref4.batch_id <> '-1') THEN 0
                ELSE ref1.endtracedays
            END
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref2.credential_name = 's3' AND drv.hdl_subtype = 'RELOAD')
            THEN ref4.lastboundvalue
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref2.credential_name = 's3' AND drv.hdl_subtype = 'LASTMODIFIED')
            THEN CONVERT(REPLACE(REPLACE(SUBSTR(NOW() - INTERVAL CAST(SUBSTR(ref1.whereclause, 9) AS SIGNED) HOUR, 1, 13), ' 0', '@'), ' ', '@') USING UTF8)
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref1.appendmode = 'Y' AND drv.hdl_subtype = 'RELOAD')
            THEN ref1.threshold_for_upperlmt
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref1.appendmode = 'Y' AND drv.hdl_subtype <> 'RELOAD')
            THEN CASE
                WHEN (ref4.jobstatus_for_appnd = 'Success') THEN (COALESCE(ref4.lastboundvalue + 1, 0) + ref1.threshold_for_upperlmt)
                when (ref4.jobstatus_for_appnd = 'Failed') Then (COALESCE(ref4.upperboundvalue, 0) + (SELECT lastboundvalue+totalrecordcount+1 
                    FROM (
                        SELECT  totalrecordcount,lastboundvalue, mapping_id,jobendtime
                        FROM gcp_ingestion_lastrun
                        GROUP BY mapping_id 
                    ) t where mapping_id = ref4.mapping_id))
            END
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref2.credential_name = 'sftp')
            THEN NOW()
        ELSE 'TBC'
    END AS max_value, -- <-------------------------------- here ---------------------------------------------------> --
    CASE
        WHEN (drv.hdl_loadtype = 'FULL') THEN drv.idcolumn
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref2.credential_name <> 's3' AND ref2.credential_name <> 'sftp' AND ref1.appendmode = 'NA') THEN drv.datecolumn
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref1.appendmode = 'Y') THEN drv.idcolumn
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref2.credential_name = 's3') THEN 'NA'
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref2.credential_name = 'sftp') THEN drv.datecolumn
    END AS predicate_column,
    CASE
        WHEN (drv.hdl_loadtype = 'FULL') THEN ref1.targetdir
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref1.appendmode = 'NA' AND ref2.credential_name <> 's3' AND ref2.credential_name <> 'sftp' AND drv.hdl_subtype = 'RELOAD')
            THEN ref1.targetdir
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref1.appendmode = 'NA' AND ref2.credential_name <> 's3' AND ref2.credential_name <> 'sftp' AND drv.hdl_subtype <> 'RELOAD')
            THEN CASE
                WHEN ((ref4.jobstatus = 'Success' OR ref4.cnt > 0) AND ref4.batch_id <> '-1')
                THEN CONCAT(SUBSTR(ref1.targetdir, 1, LENGTH(ref1.targetdir) - 1), '_intraday/ing_batch_id=', CONVERT(DATE_FORMAT(NOW(), '%H%i%S') USING UTF8), '/')
                ELSE CONCAT(SUBSTR(ref1.targetdir, 1, LENGTH(ref1.targetdir) - 1), '_cdc/')
            END
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref2.credential_name IN ('s3', 'sftp')) THEN ref1.targetdir
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref1.appendmode = 'Y' AND drv.hdl_subtype = 'RELOAD') THEN ref1.targetdir
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref1.appendmode = 'Y' AND drv.hdl_subtype <> 'RELOAD') THEN CONCAT(SUBSTR(ref1.targetdir, 1, LENGTH(ref1.targetdir) - 1), '_append/')
    END AS targetdir,
    CASE
        WHEN (drv.hdl_loadtype = 'FULL') THEN 'tl'
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref1.appendmode = 'NA' AND ref2.credential_name <> 's3' AND ref2.credential_name <> 'sftp' AND drv.hdl_subtype = 'RELOAD') THEN 'tl'
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref1.appendmode = 'NA' AND ref2.credential_name <> 's3' AND ref2.credential_name <> 'sftp' AND drv.hdl_subtype <> 'RELOAD')
            THEN CASE
                WHEN ((ref4.jobstatus = 'Success' OR ref4.cnt > 0) AND ref4.batch_id <> '-1') THEN 'tl'
                ELSE 'rbld'
            END
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref2.credential_name IN ('s3', 'sftp')) THEN 'tl'
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref1.appendmode = 'Y' AND drv.hdl_subtype = 'RELOAD') THEN 'tl'
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref1.appendmode = 'Y' AND drv.hdl_subtype <> 'RELOAD') THEN 'appnd'
    END AS targetdir_action,
    CASE
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref1.appendmode = 'NA' AND ref2.credential_name <> 's3' AND ref2.credential_name <> 'sftp' AND drv.hdl_subtype <> 'RELOAD')
            THEN CASE
                WHEN ((ref4.jobstatus = 'Failed' AND ref4.cnt > 0 AND ref4.batch_id <> '-1'))
                    THEN CONCAT(SUBSTR(ref1.targetdir, 1, LENGTH(ref1.targetdir) - 1), '_intraday/ing_batch_id=', ref4.batch_id, '/')
                WHEN (COALESCE(ref4.cnt, 0) = 0)
                    THEN CONCAT(SUBSTR(ref1.targetdir, 1, LENGTH(ref1.targetdir) - 1), '_intraday/')
                ELSE 'NA'
            END
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref1.appendmode = 'NA' AND ref2.credential_name <> 's3' AND ref2.credential_name <> 'sftp' AND drv.hdl_subtype = 'RELOAD')
            THEN CONCAT(SUBSTR(ref1.targetdir, 1, LENGTH(ref1.targetdir) - 1), '_intraday/')
        WHEN (drv.hdl_loadtype = 'INCREMENTAL' AND ref1.appendmode = 'Y' AND drv.hdl_subtype = 'RELOAD')
            THEN CONCAT(SUBSTR(ref1.targetdir, 1, LENGTH(ref1.targetdir) - 1), '_append/')
        ELSE 'NA'
    END AS fail_targetdir_drop,
    ref1.tableloadinprocessflag
FROM
    mapr_bigdata_uat_metahub.gcp_ingestion_sources drv
JOIN mapr_bigdata_uat_metahub.gcp_ingestion_controller ref1 ON (drv.sourceid = ref1.sourceid)
JOIN mapr_bigdata_uat_metahub.gcp_credentials ref2 ON (drv.credential_id = ref2.credential_id)
JOIN mapr_bigdata_uat_metahub.gcp_scheduler_ingestion_mapping ref3 ON (drv.sourceid = ref3.sourceid)
LEFT JOIN (
    SELECT 
        subdrv1.mapping_id,
        subdrv1.batch_id,
        subdrv1.upperboundvalue,
        subdrv1.lastboundvalue,
        COALESCE(subdrv4.jobstatus, 'Failed') AS jobstatus,
        subdrv1.lastrundate AS insert_dt,
        COALESCE(subdrv3.cnt, 0) AS cnt,
        subdrv1.jobstatus AS jobstatus_for_appnd
    FROM mapr_bigdata_uat_metahub.gcp_ingestion_lastrun subdrv1
    JOIN (
        SELECT mapping_id, MAX(id) AS id
        FROM mapr_bigdata_uat_metahub.gcp_ingestion_lastrun
        WHERE batch_id <> -2
        GROUP BY mapping_id
    ) subdrv2 ON (subdrv1.mapping_id = subdrv2.mapping_id AND subdrv1.id = subdrv2.id)
    LEFT JOIN (
        SELECT mapping_id, COUNT(1) AS cnt
        FROM mapr_bigdata_uat_metahub.gcp_ingestion_lastrun
        WHERE (jobstatus = 'Success' AND lastrundate = CURDATE())
        GROUP BY mapping_id
    ) subdrv3 ON (subdrv2.mapping_id = subdrv3.mapping_id)
    LEFT JOIN (
        SELECT id, jobstatus
        FROM mapr_bigdata_uat_metahub.gcp_ingestion_lastrun
        WHERE lastrundate = CURDATE()
    ) subdrv4 ON (subdrv2.id = subdrv4.id)
) ref4 ON (ref3.mapping_id = ref4.mapping_id)
JOIN mapr_bigdata_uat_metahub.gcp_exec_classification ref5 ON (drv.classification_id = ref5.classification_id)
JOIN mapr_bigdata_uat_metahub.gcp_subjectarea ref6 ON (drv.subjectarea_id = ref6.subjectarea_id)
JOIN mapr_bigdata_uat_metahub.gcp_project ref7 ON (ref2.project_id = ref7.project_id AND ref5.project_id = ref7.project_id AND ref6.project_id = ref7.project_id)
JOIN mapr_bigdata_uat_metahub.gcp_data_classification ref8 ON (drv.data_type_id = ref8.data_type_id)
JOIN mapr_bigdata_uat_metahub.organization ref9 ON (ref7.org_id = ref9.org_id)
WHERE
    (
        (CASE
            WHEN (drv.frequency = 'daily' AND ref4.cnt <> 0) THEN 'ByPass'
            ELSE 'NotInProcess'
        END) = 'NotInProcess'
        AND ref7.status_flag = 1
        AND ref5.status_flag = 1
        AND ref6.status_flag = 1
        AND drv.status_flag = 1
        AND ref1.tableloadinprocessflag = 'NotInProcess'
        AND ref8.status_flag = 1
        AND ref9.status_flag = 1
    )
ORDER BY CONCAT(ref3.group_binding_id, ref3.exec_order), drv.sourceid
) tab where mapping_id in (6,79,78,72,73,75,94,123) 

) as der

;