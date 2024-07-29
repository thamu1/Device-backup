import datetime
import pandas as pd
from google.cloud import bigquery
import os
import pathlib
import re
import subprocess
from google.oauth2 import service_account
from google.cloud import storage
import json
import logging
import typing

def main(
    source_urls: typing.List[str],
    source_files: typing.List[pathlib.Path],
    target_file: pathlib.Path,
    target_gcs_bucket: str,
    target_gcs_path: str,
    pipeline_name: str,
    sheet_name_to_rd: str,
    file_type:str,
    headers: typing.List[str],
    fltr_dash_board_ind:str,    
) -> None:

    key_path = "dev-analytics-datasci-12.json"
    credentials = service_account.Credentials.from_service_account_file(
    key_path, scopes=["https://www.googleapis.com/auth/cloud-platform"],
    )

    bq_client = bigquery.Client(credentials=credentials, project=credentials.project_id,)
    gcs_client = storage.Client(credentials=credentials, project=credentials.project_id,)
    logging.info(
        f"BLS {pipeline_name} process started at "
        + str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    )

    logging.info("Creating 'files' folder")
    pathlib.Path("./files").mkdir(parents=True, exist_ok=True)
    logging.info(f"path 'source_urls' folder-{source_urls}")
    logging.info(f"path 'source_files' folder-{source_files}")
    logging.info(f"path fltr_dash_board_ind -{fltr_dash_board_ind}")
    logging.info("Downloading file...")
    download_file(source_urls, source_files)
    logging.info(f"Reading the file(s)....type{file_type}")
    if(file_type=="sas"):
        df =read_SASdata(source_files,fltr_dash_board_ind)
    else:
        df =read_exceldata(source_files,sheet_name_to_rd)
    
    #df = read_files(source_files)
    #df =read_exceldata(source_files,sheet_name_to_rd)
    

    logging.info("Transform: Removing whitespace from headers names...")
    #df.columns = df.columns.str.strip()

    logging.info("Transform: Trim Whitespaces...")
    #trim_white_spaces(df, columns)

    if pipeline_name == "custom_kpod":
        logging.info("Transform: Replacing values...")
        #df["value"] = df["value"].apply(reg_exp_tranformation, args=(r"^(\-)$", ""))

    logging.info("Transform: Reordering headers..")
    df = df[headers]

    logging.info(f"Saving to output file.. {target_file}")
    try:
        save_to_new_file(df, file_path=str(target_file))
    except Exception as e:
        logging.error(f"Error saving output file: {e}.")
    logging.info("..Done!")

    logging.info(
        f"Uploading output file to.. gs://{target_gcs_bucket}/{target_gcs_path}"
    )
    upload_file_to_gcs(target_file, target_gcs_bucket, target_gcs_path,gcs_client)

    logging.info(
        f"KPOD {pipeline_name} process completed at "
        + str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    )


def save_to_new_file(df: pd.DataFrame, file_path: pathlib.Path) -> None:
    df.to_csv(file_path, index=False)


def download_file(
    source_urls: typing.List[str], source_files: typing.List[pathlib.Path]
) -> None:
    for url, file in zip(source_urls, source_files):
        logging.info(f"Downloading file from {url} ...")
        subprocess.check_call(["gsutil", "cp", f"{url}", f"{file}"])


def read_files(source_files, joining_key):
    df = pd.DataFrame()
    for source_file in source_files:
        if os.path.splitext(source_file)[1] == ".csv":
            _df = pd.read_csv(source_file)
        else:
            _df = pd.read_csv(source_file, sep="\t")

        if df.empty:
            df = _df
        else:
            df = pd.merge(df, _df, how="left", on=joining_key)
    return df


def trim_white_spaces(df: pd.DataFrame, columns: typing.List[str]) -> None:
    for col in columns:
        df[col] = df[col].astype(str).str.strip()


def reg_exp_tranformation(str_value: str, search_pattern: str, replace_val: str) -> str:
    return re.sub(search_pattern, replace_val, str_value)


def upload_file_to_gcs(file_path: pathlib.Path, gcs_bucket: str, gcs_path: str,gcs_client:storage) -> None:
    bucket = gcs_client.bucket(gcs_bucket)
    blob = bucket.blob(gcs_path)
    blob.upload_from_filename(file_path)



def read_exceldata(source_files,sheet_name_to_rd):
    df = pd.DataFrame()
    for source_file in source_files:
        if os.path.splitext(source_file)[1] == ".xlsx":
            _df = pd.read_excel(source_file,sheet_name=sheet_name_to_rd)
        else:
            _df = pd.read_csv(source_file, sep="\t")

        if df.empty:
            df = _df
    #df = pd.DataFrame()
    #df = pd.read_excel('records.xlsx', sheet_name='Employees')
    # print whole sheet data
    print(df)
    return df


def read_SASdata(source_files,fltr_dash_board_ind):
    df = pd.DataFrame()
    for source_file in source_files:
        logging.info(f"reading sas file  {source_file}")
        if os.path.splitext(source_file)[1] == ".sas7bdat":
            _df = pd.read_sas(source_file, format = 'sas7bdat', encoding="latin-1")
            #_df =_df.loc[_df['DASH_BOARD_IND'] == 'B']
            _df =_df.query(fltr_dash_board_ind)
        else:
            _df = pd.read_csv(source_file, sep="\t")

        if df.empty:
            df = _df
    #df = pd.DataFrame()
    #df = pd.read_excel('records.xlsx', sheet_name='Employees')
    # print whole sheet data
    print(df)
    return df


#client = bigquery.Client()

def get_bq_results(bq_client:bigquery):
    now = datetime.datetime.now()


    # Perform a query.
    MASTER_QUERY = 'SELECT  	global_member_token	,raw_score,	score_rank,	score_create_date,	model_name FROM `dev-analytics-datasci.analytics_locm_scoring_staging.emailclick_score` LIMIT 1'
    master_query_job = bq_client.query(MASTER_QUERY)  # API request
    master_rows = master_query_job.result()  # Waits for query to finish
    row_count = 0
    for row in master_rows:
            main_qry1 = row['global_member_token'] or '<none>'
            msg_template = row['raw_score']
            msg_to = row['score_rank']
            msg_hdr = row['model_name'] 
            msg_alert_type = row['score_create_date']
            print(f'msg_alert_type {main_qry1}')
    print(f"msg_alert_type {msg_alert_type}")
    print(f"msg_hdr {msg_hdr}")
    print(f"msg_alert_type {msg_alert_type}")
    print(f" execution date in master table complete-{now}")
    print("Executed successfully- End")


if __name__ == "__main__":
    logging.getLogger().setLevel(logging.INFO)

    main(
        source_urls=json.loads(os.environ["SOURCE_URLS"]),
        source_files=json.loads(os.environ["SOURCE_FILES"]),
        target_file=pathlib.Path(os.environ["TARGET_FILE"]).expanduser(),
        target_gcs_bucket=os.environ["TARGET_GCS_BUCKET"],
        target_gcs_path=os.environ["TARGET_GCS_PATH"],
        pipeline_name=os.environ["PIPELINE_NAME"],
        sheet_name_to_rd=os.environ["SHEET_NAME_TO_READ"],
        file_type=os.environ["FILE_TYPE"],
        headers=json.loads(os.environ["CSV_HEADERS"]),
        fltr_dash_board_ind=os.environ["FLTR_DASH_BOARD_IND"],
        
    )
