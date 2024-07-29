# https://developers.google.com/analytics/devguides/reporting/data/v1

"""
- "apis & services" -> library -> enable ga4(google analytic data) api
- we need to create a service account.
- download the private key json. while creating the account
- in analytic UI add your service id into that.
    => home - admin - account access management - add = (your service account mail id) - set as viewer (enough)
"""


import os
from datetime import datetime, timedelta, date
from typing import List
from google.analytics.data_v1beta import BetaAnalyticsDataClient, FilterExpression, FilterExpressionList, Filter 

from google.analytics.data_v1beta.types import (
    Dimension, Metric, DateRange, Metric, OrderBy, FilterExpression,
    RunRealtimeReportRequest,BatchRunReportsRequest, RunReportRequest)

from google.oauth2 import service_account
import pandas as pd



def report(recon_date:int, off:int, property_id:str, credentials_path:str, hostnames:list , dimensions: List[str], metrics: List[Metric], row_limit:int=10 ,quota_usage:bool=False):

    
    # st_date = str(date.today() - timedelta(days=recon_date))
    # en_date = str(date.today())
    
    countrynames = ['United States']
    # 'Organic Social', 'Affiliates', 'Referral', "Organic Search",  'Paid Social', 'Email', 'Paid Search'
    
    groupnames = ['Partner']
    
    st_date = str(date.today() - timedelta(days=recon_date))
    en_date = str(date.today() - timedelta(days=1))
    
    print("-------------date :", st_date, en_date,"-------------")
    
    
    # from google.oauth2 import service_account
    # client = BetaAnalyticsDataClient(credentials=credentials)
    # credentials = service_account.Credentials.from_service_account_file(filename=credentials_path,)
    
    os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = credentials_path
    client = BetaAnalyticsDataClient() 
    
    dimension_list = [Dimension(name=dim) for dim in dimensions]
    metrics_list = [Metric(name=m) for m in metrics]
    
    # hostnames = ', '.join(hostnames)
    
    request = RunReportRequest(
        property=f"properties/{property_id}",
        ignore_unknown_fields= True,
        dimensions=dimension_list,
        metrics=metrics_list,
        limit = row_limit,
        offset = off,
        date_ranges=[DateRange(start_date=st_date, end_date=en_date)],
        order_bys = [OrderBy(dimension = OrderBy.DimensionOrderBy(dimension_name = "date") , desc = True)],
        dimension_filter=FilterExpression(
                and_group=FilterExpressionList(
                    expressions=[
                        FilterExpression(filter=Filter(field_name="hostName",string_filter= Filter.StringFilter(
                                            match_type= Filter.StringFilter.MatchType.EXACT,
                                            value = ', '.join(hostnames), 
                                            case_sensitive = True))),                     
                        # FilterExpression(filter=Filter(field_name="hostName",in_list_filter= Filter.InListFilter(values=hostnames, case_sensitive=True),)),
                        FilterExpression(filter=Filter(field_name="country",in_list_filter= Filter.InListFilter(values=countrynames, case_sensitive=True),)),
                        FilterExpression(not_expression=FilterExpression(filter = Filter(field_name="sessionDefaultChannelGroup", in_list_filter = Filter.InListFilter(values = groupnames, case_sensitive = True))),),
                    ]
                ),
            ),
        )
    response = client.run_report(request)
    
    return(response)
    

def get_report(recon_backtrace:int, hdl_staging_loc:str, mode:str, is_group:list):
    
    # for i in range(1,recon_backtrace+1):
    
    if(mode == "overall"):
        
        hostName = ['www.wideopenspaces.com',
            'www.wideopeneats.com',
            'www.wideopenpets.com',
            'www.wideopencountry.com',
            'www.thetruthaboutknives.com',
            'www.thetruthaboutguns.com',
            'rare.us',
        ]
        
        
    elif(mode == "major"):
        
        hostName = ['www.wideopenroads.com',]
        
    elif(mode == "minor"):
        
        hostName = ['rare.us',
            'fanbuzz.com',
            'altdriver.com',
            'www.wideopenspaces.com',
            'www.wideopeneats.com',
            'www.wideopenpets.com',
            'www.thetruthaboutknives.com',	
            'www.thetruthaboutguns.com',
            'www.wideopencountry.com',
            'www.wideopenroads.com',
        ]
            

    else:
        print("Please choose the correct mode")
        
        
    off = 0
    
    con_df = pd.DataFrame()
    
    for i in range(2):
        res = report(
                property_id=331273219,
                credentials_path="D:/PCH/PCH Dev Team/Prashant/GA4 Wom/service_id_json/ga_wom.json",
                # credentials_path = "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/restricted/bigdata/prod/keystores/gcp/prod-ga4-wom-rpt/svc-prod-ga4-wom-rpt-c5c06cb656fd.json",
                recon_date=recon_backtrace,
                hostnames = hostName,
                off = off,
                dimensions=["date", "hostName","sessionSource"], # ga:hostname, ga:country, ga:channelGrouping
                metrics=["totalUsers","screenPageViews", "sessions"], # ga:users, ga:pageviews, ga:sessions
                row_limit=100000
            )

        off += 100000
    
        if(mode):
            dim_head = res.dimension_headers
            mat_head = res.metric_headers
            rows = res.rows

            header = [i.name for i in dim_head] + [i.name for i in mat_head]

            row_value = []
            for row in (rows):
                row_flag = []
                for dv in (row.dimension_values):
                    row_flag.append(dv.value)
                    
                for mv in (row.metric_values):
                    row_flag.append(mv.value)
                
                row_value.append(row_flag)
                
            df = pd.DataFrame(data = row_value, columns= header)

            con_df = pd.concat([con_df, df])
        
    
    file = f"{hdl_staging_loc}/{mode}/report.csv"
    
    con_df.drop_duplicates(inplace=True)
    print(con_df)

    if(os.path.exists(file)):
        os.remove(file)
        con_df.to_csv(file,index=False)
    else:
        con_df.to_csv(file, index=False)


get_report(recon_backtrace=8,hdl_staging_loc="D:/PCH/PCH Dev Team/Prashant/GA4 Wom/logcheck/",
           mode="major",is_group=[])

            
# dim & met = "Date,Hostname,\"Source Group\",Users,Pageviews,Sessions"  -- screenPageViews
# https://ga-dev-tools.google/ga4/dimensions-metrics-explorer/  => to look dimension and metric
# https://developers.google.com/analytics/devguides/reporting/data/v1/api-schema#metrics    




 