from google.cloud import storage
import os
from io import BytesIO
import pandas as pd
import subprocess
import shutil
import json
from datetime import datetime, date, timedelta



class BQTableDtls:
    def __init__(self, object_properties_json):
        self._obj = self._prepare(object_properties_json)
        self._object_id = ""
        self._object_name = ""
        self._airflow_mapping_id = ""
        self._exec_order = ""
        self._project_name = ""
        self._gcp_conn_var = ""
        self._gcp_svc_json_path_var = ""
        self._gcp_conn_bigdata_etl_metadata = ""
        self._gcp_schema_initial = ""
        self._gcp_schema_intermediate = ""
        self._gcp_schema_final = ""
        self._obj_gcs_path = ""
        self._gcp_partition_cols = {}
        self._gcp_cluster_cols = []
        self._load_type = ""
        self._airflow_control_flag = ""
        self._vw_sql_except_columns = ""
        self._vw_sql_loc = ""
        self._obj_gcs_final_alter_name = ""
        self._obj_gcs_stg_to_final_split_flag = ""
        self._recon_start_limit = ""
        self._recon_end_limit = ""
        self._frequency = ""
        self._subjectarea_name = ""
        self._gcp_schema_sas_final = ""

    def _prepare(self, object_properties_json):

        client = storage.Client()

        bucket_name = object_properties_json.split("/")[0] # "bkt_dev_fq_goldcore"

        bucket = client.get_bucket(bucket_or_name= bucket_name)

        source_path = "/".join(object_properties_json.split("/")[1:]) # "airflow/gcs/data/bigdata/variables/group_binding_id_100/"

        file = bucket.blob(source_path).open()
        object_json_data = json.loads(file.read())
        
        return object_json_data

    @property
    def object_id(self):
        return self._object_id

    @object_id.setter
    def object_id(self, i):
        self._object_id = self._obj['airflow_binding_id'][0][str(i)]['object_id']

    @property
    def object_name(self):
        return self._object_name

    @object_name.setter
    def object_name(self, i):
        self._object_name = self._obj['airflow_binding_id'][0][str(i)]['object_name']

    @property
    def airflow_mapping_id(self):
        return self._airflow_mapping_id

    @airflow_mapping_id.setter
    def airflow_mapping_id(self, i):
        self._airflow_mapping_id = self._obj['airflow_binding_id'][0][str(i)]['airflow_mapping_id']

    @property
    def exec_order(self):
        return self._exec_order

    @exec_order.setter
    def exec_order(self, i):
        self._exec_order = self._obj['airflow_binding_id'][0][str(i)]['exec_order']

    @property
    def project_name(self):
        return self._project_name

    @project_name.setter
    def project_name(self, i):
        self._project_name = self._obj['airflow_binding_id'][0][str(i)]['project_name']

    @property
    def gcp_conn_var(self):
        return self._gcp_conn_var

    @gcp_conn_var.setter
    def gcp_conn_var(self, i):
        self._gcp_conn_var = self._obj['airflow_binding_id'][0][str(i)]['gcp_conn_var']

    @property
    def gcp_svc_json_path_var(self):
        return self._gcp_svc_json_path_var

    @gcp_svc_json_path_var.setter
    def gcp_svc_json_path_var(self, i):
        self._gcp_svc_json_path_var = self._obj['airflow_binding_id'][0][str(i)]['gcp_svc_json_path_var']

    @property
    def gcp_conn_bigdata_etl_metadata(self):
        return self._gcp_conn_bigdata_etl_metadata

    @gcp_conn_bigdata_etl_metadata.setter
    def gcp_conn_bigdata_etl_metadata(self, i):
        self._gcp_conn_bigdata_etl_metadata = self._obj['airflow_binding_id'][0][str(i)]['gcp_conn_bigdata_etl_metadata']

    @property
    def gcp_schema_initial(self):
        return self._gcp_schema_initial

    @gcp_schema_initial.setter
    def gcp_schema_initial(self, i):
        self._gcp_schema_initial = self._obj['airflow_binding_id'][0][str(i)]['gcp_schema_initial']

    @property
    def gcp_schema_intermediate(self):
        return self._gcp_schema_intermediate

    @gcp_schema_intermediate.setter
    def gcp_schema_intermediate(self, i):
        self._gcp_schema_intermediate = self._obj['airflow_binding_id'][0][str(i)]['gcp_schema_intermediate']

    @property
    def gcp_schema_final(self):
        return self._gcp_schema_final

    @gcp_schema_final.setter
    def gcp_schema_final(self, i):
        self._gcp_schema_final = self._obj['airflow_binding_id'][0][str(i)]['gcp_schema_final']

    @property
    def obj_gcs_path(self):
        return self._obj_gcs_path

    @obj_gcs_path.setter
    def obj_gcs_path(self, i):
        self._obj_gcs_path = self._obj['airflow_binding_id'][0][str(i)]['obj_gcs_path']

    @property
    def gcp_partition_cols(self):
        return self._gcp_partition_cols

    @gcp_partition_cols.setter
    def gcp_partition_cols(self, i):
        self._gcp_partition_cols = self._obj['airflow_binding_id'][0][str(i)]['gcp_partition_cols']

    @property
    def gcp_cluster_cols(self):
        return self._gcp_cluster_cols

    @gcp_cluster_cols.setter
    def gcp_cluster_cols(self, i):
        self._gcp_cluster_cols = self._obj['airflow_binding_id'][0][str(i)]['gcp_cluster_cols']

    @property
    def load_type(self):
        return self._load_type

    @load_type.setter
    def load_type(self, i):
        self._load_type = self._obj['airflow_binding_id'][0][str(i)]['load_type']

    @property
    def airflow_control_flag(self):
        return self._airflow_control_flag

    @airflow_control_flag.setter
    def airflow_control_flag(self, i):
        self._airflow_control_flag = self._obj['airflow_binding_id'][0][str(i)]['airflow_control_flag']

    @property
    def vw_sql_except_columns(self):
        return self._vw_sql_except_columns

    @vw_sql_except_columns.setter
    def vw_sql_except_columns(self, i):
        self._vw_sql_except_columns = self._obj['airflow_binding_id'][0][str(i)]['vw_sql_except_columns']

    @property
    def vw_sql_loc(self):
        return self._vw_sql_loc

    @vw_sql_loc.setter
    def vw_sql_loc(self, i):
        self._vw_sql_loc = self._obj['airflow_binding_id'][0][str(i)]['vw_sql_loc']

    @property
    def obj_gcs_final_alter_name(self):
        return self._obj_gcs_final_alter_name

    @obj_gcs_final_alter_name.setter
    def obj_gcs_final_alter_name(self, i):
        self._obj_gcs_final_alter_name = self._obj['airflow_binding_id'][0][str(i)]['obj_gcs_final_alter_name']

    @property
    def obj_gcs_stg_to_final_split_flag(self):
        return self._obj_gcs_stg_to_final_split_flag

    @obj_gcs_stg_to_final_split_flag.setter
    def obj_gcs_stg_to_final_split_flag(self, i):
        self._obj_gcs_stg_to_final_split_flag = self._obj['airflow_binding_id'][0][str(i)]['obj_gcs_stg_to_final_split_flag']

    @property
    def recon_start_limit(self):
        return self._recon_start_limit

    @recon_start_limit.setter
    def recon_start_limit(self, i):
        self._recon_start_limit = self._obj['airflow_binding_id'][0][str(i)]['recon_start_limit']

    @property
    def recon_end_limit(self):
        return self._recon_end_limit

    @recon_end_limit.setter
    def recon_end_limit(self, i):
        self._recon_end_limit = self._obj['airflow_binding_id'][0][str(i)]['recon_end_limit']

    @property
    def frequency(self):
        return self._frequency

    @frequency.setter
    def frequency(self, i):
        self._frequency = self._obj['airflow_binding_id'][0][str(i)]['frequency']

    @property
    def subjectarea_name(self):
        return self._subjectarea_name

    @subjectarea_name.setter
    def subjectarea_name(self, i):
        self._subjectarea_name = self._obj['airflow_binding_id'][0][str(i)]['subjectarea_name']

    @property
    def gcp_schema_sas_final(self):
        return self._gcp_schema_sas_final

    @gcp_schema_sas_final.setter
    def gcp_schema_sas_final(self, i):
        self._gcp_schema_sas_final = self._obj['airflow_binding_id'][0][str(i)]['gcp_schema_sas_final']

    @property
    def length_list(self):
        return len(self._obj['object_list_sorted'])

    @property
    def object_id_list_sorted(self):
        return self._obj['object_list_sorted']
