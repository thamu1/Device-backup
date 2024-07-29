

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

from google.analytics.data_v1beta.types import (Dimension, Metric, DateRange, Metric, OrderBy, 
                                               FilterExpression, MetricAggregation, CohortSpec)
from google.analytics.data_v1beta.types import RunRealtimeReportRequest,BatchRunReportsRequest, RunReportRequest

from google.oauth2 import service_account
import pandas as pd

def report(recon_date:int, property_id:str, credentials_path:str, dimensions: List[str], metrics: List[Metric], row_limit:int=10000 ,quota_usage:bool=False):

    # from google.oauth2 import service_account
    os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = credentials_path
    
    # credentials = service_account.Credentials.from_service_account_file(filename=credentials_path,)
    
    st_date = str(date.today() - timedelta(days=recon_date))
    en_date = str(date.today() - timedelta(days=1))
    
    # client = BetaAnalyticsDataClient(credentials=credentials) 
    client = BetaAnalyticsDataClient() 
    
    dimension_list = [Dimension(name=dim) for dim in dimensions]
    metrics_list = [Metric(name=m) for m in metrics]
    
    hostnames = ['rare.us',
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
    
    groupnames = ['Partner']
    
    sesssionli = ['google']
    
    countrynames = ['United States']
    
    request = BatchRunReportsRequest(
        property=f"properties/{property_id}",
        # ignore_unknown_fields=True,
        requests=[
           RunReportRequest(
                property=f"properties/{property_id}",
                ignore_unknown_fields= True,
                dimensions=dimension_list,
                metrics=metrics_list,
                date_ranges=[DateRange(start_date=st_date, end_date=en_date)],
                order_bys = [OrderBy(dimension = OrderBy.DimensionOrderBy(dimension_name = "date") , desc = True)],
                dimension_filter=FilterExpression(
                        and_group=FilterExpressionList(
                            expressions=[
                                FilterExpression(
                                    filter=Filter(field_name="hostName", in_list_filter = Filter.InListFilter(values = hostnames, case_sensitive = True)),
                                ),
                                FilterExpression(
                                    filter=Filter(field_name="country", in_list_filter = Filter.InListFilter(values = countrynames, case_sensitive = True)),
                                ),
                                FilterExpression(
                                    filter=Filter(field_name="sessionSource", in_list_filter = Filter.InListFilter(values = sesssionli, case_sensitive = True)),
                                ),
                                FilterExpression(
                                    not_expression=FilterExpression( filter = Filter(field_name="sessionDefaultChannelGroup", in_list_filter = Filter.InListFilter(values = groupnames, case_sensitive = True))),
                                ),
                            ]
                        )
                    ), 
                ),
            ]
        )
    
    
    response = client.batch_run_reports(request) #.run_realtime_report(report_request)

    return response
    


result = report(
    property_id=331273219,
    credentials_path="D:/PCH/PCH Dev Team/Prashant/GA4 Wom/service_id_json/ga_wom.json",
    # credentials_path = "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/restricted/bigdata/prod/keystores/gcp/prod-ga4-wom-rpt/svc-prod-ga4-wom-rpt-c5c06cb656fd.json",
    recon_date=12,
    dimensions=["date", "hostName","sessionSource", "country"], # "sessionSource" ga:hostname, ga:country, ga:channelGrouping
    metrics=["totalUsers","screenPageViews", "sessions"], # ga:users, ga:pageviews, ga:sessions
    row_limit=100000
)

# print(res)

for res in result.reports:
    
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

    print(df)
    
    hdl_staging_loc="D:/PCH/PCH Dev Team/Prashant/GA4 Wom/logcheck/batch_report/report.csv"
    
    df.to_csv(hdl_staging_loc)


