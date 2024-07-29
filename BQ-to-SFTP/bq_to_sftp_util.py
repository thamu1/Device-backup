"""
Need to pass Three argument to the main:
    1. root source dir for storing the Ecom_{20231030}1400N.zip
    2. pass the PWSFTP server root location to migrate the Ecom_{20231030}1400N.zip
    3. pass the location where the gcp credential json is available
    4. query that you need as a result

SH file location:
    1. /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/fusion_spectrum_workflow/config/aggviews_cutoff_ftpexport.sh
    2. credentials : /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/codebase/bigdata/prod/online/fusion_spectrum_workflow/scripts/bash/ftp_export/filetranfersasftp2.shv

PWSFTP server details:
    host = "PWSFTP01.classic.pchad.com",
    username = "spectmims",
    password = "Fall2016",
    

file format should be like below:
    Ecom_{20231030}1400N.zip
    
uat-gold-core service id location:
    /mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/restricted/bigdata/uat/keystores/gcp/uat_gold_core/svc-uat-nexus-elt-bigdata-df7679584213.json
"""



import paramiko
import os 
from google.cloud import bigquery, storage
import pandas as pd
from datetime import datetime, date, timedelta
import shutil


# credentials_path = "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/restricted/bigdata/uat/keystores/gcp/uat_gold_core/svc-uat-nexus-elt-bigdata-df7679584213.json"

ssh_client = paramiko.SSHClient()

def sftp_migration(source_loc:str, destination_loc:str):

    host = "PWSFTP01.classic.pchad.com"
    username = "spectmims"
    password = "Fall2016"
    port = 22
    
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh_client.connect(hostname=host,port=port,username=username,password=password)

    sftp = ssh_client.open_sftp()
    try:
        file = sftp.put(localpath= source_loc, remotepath= destination_loc )
        sftp.close()
        ssh_client.close()
        
        return("Success")
    
    except:
        
        sftp.close()
        ssh_client.close()
        
        return("Failed")

def zipmake(source_loc:str):
    try:
        if(os.path.exists(f"{source_loc}.zip")):
            os.remove(f"{source_loc}.zip")
            shutil.make_archive(base_name= source_loc, format='zip', root_dir= source_loc)
            print("location already there so recreated.")
        else:
            shutil.make_archive(base_name= source_loc, format='zip', root_dir= source_loc)

        return 1
    
    except:
        return 0

    
def bqcall(sql:str, credentials_path:str):
    
    # from google.oauth2 import service_account
    # credentials = service_account.Credentials.from_service_account_file(filename=credentials_path,)
    # client = bigquery.Client(credentials= credentials_path)
    
    os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = credentials_path
    client = bigquery.Client()
    gcs_client = storage.Client()
    
    op = client.query(f"{sql}")

    res = op.result().to_dataframe(bqstorage_client= gcs_client)
    
    return res


def main():
    
    credentials_path = "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/restricted/bigdata/uat/keystores	/gcp/uat_gold_core/svc-uat-nexus-elt-bigdata-df7679584213.json"
    
    sql = "select * from `uat-gold-core.it_dms_customer_ext.vw_non_order_tdmnono` limit 1000000;"
    
    df = bqcall(sql= sql, credentials_path= credentials_path)
    
    store_path = "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/staging_temp/bigdata/prod/test/thamo/bq_to_sftp_zip_move/" # source path need to pass.

    file_name = f"Ecom_{(date.today()-timedelta(days=2)).strftime('%Y%m%d')}1400N" # Ecom_202310301400N
    
    dir_loc = f"{store_path}/{file_name}"

    if os.path.exists(f"{dir_loc}"):
        shutil.rmtree(f"{dir_loc}")
        os.mkdir(f"{dir_loc}")
        df.to_csv(f"{dir_loc}/test.csv", index= False)
    else:
        os.mkdir(f"{dir_loc}")
        df.to_csv(f"{dir_loc}/test.csv", index= False)


    zip_status = zipmake(source_loc= f"{dir_loc}")

    if(zip_status == 1):
        
        src_loc = f"{dir_loc}.zip"
        des_loc = f"/Spectrum_MIMS_Product_Views/test2/{file_name}.zip" # destination path need to pass.
    
        mig_status = sftp_migration(source_loc= src_loc, destination_loc= des_loc)
        
        print(mig_status)


main()
# source path
# destination path
# gcp credential path
# sql query