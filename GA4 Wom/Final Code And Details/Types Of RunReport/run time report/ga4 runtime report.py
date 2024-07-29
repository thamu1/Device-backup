

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
                                               FilterExpression, MetricAggregation, CohortSpec,MetricType)
from google.analytics.data_v1beta.types import RunRealtimeReportRequest,BatchRunReportsRequest, RunReportRequest, RunRealtimeReportRequest

from google.oauth2 import service_account
import pandas as pd



def report(recon_date:int, property_id:str, credentials_path:str, dimensions: List[str], metrics: List[Metric], row_limit:int=10000 ,quota_usage:bool=False):

    # from google.oauth2 import service_account
    os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = credentials_path
    
    # credentials = service_account.Credentials.from_service_account_file(filename=credentials_path,)
    
    st_date = str(date.today() - timedelta(days=recon_date))
    en_date = str(date.today())
    
    # client = BetaAnalyticsDataClient(credentials=credentials) 
    client = BetaAnalyticsDataClient() 
    
    dimension_list = [Dimension(name=dim) for dim in dimensions]
    metrics_list = [Metric(name=m) for m in metrics]
    
    hostnames = [
        'www.thetruthaboutknives.com',
        'www.thetruthaboutguns.com',
        'rare.us',]
    # hostnames = ', '.join(hostnames)
    
    report_request = RunRealtimeReportRequest(
        property=f'properties/{property_id}',
        dimensions= dimension_list,
        metrics=metrics_list,
        limit=row_limit,
        date_ranges=[DateRange(start_date = st_date , end_date = en_date)],
        ignore_unknown_fields= True,
        # additionanl filter and ordering from php script
        # dimension_filter=FilterExpression(
        #         and_group=FilterExpressionList(
        #             expressions=[
        #                 FilterExpression(filter=Filter(field_name="hostName",in_list_filter= Filter.InListFilter(values=hostnames, case_sensitive=False),)),
        #             ]
        #         )
        #     ),   
        )
    
    
    response = client.run_realtime_report(report_request) #.run_realtime_report(report_request)

    # output = {}

    # headers = [header.name for header in response.dimension_headers] + [header.name for header in response.metric_headers]
    # rows = []
    # for row in response.rows:
    #     rows.append(
    #         [dimvalue.value for dimvalue in row.dimension_values] + \
    #         [metvalue.value for metvalue in row.metric_values])            
    # output['headers'] = headers
    # output['rows'] = rows
    
    return(response)
    


res = report(
    property_id=331273219,
    credentials_path="D:/PCH/PCH Dev Team/Prashant/GA4 Wom/service id json/ga_wom.json",
    # credentials_path = "/mapr/JMAPRCLUP01.CLASSIC.PCHAD.COM/restricted/bigdata/prod/keystores/gcp/prod-ga4-wom-rpt/svc-prod-ga4-wom-rpt-c5c06cb656fd.json",
    recon_date=8,
    dimensions=["country"], # ga:hostname, ga:country, ga:channelGrouping
    metrics=["activeUsers"], # ga:users, ga:pageviews, ga:sessions
    row_limit=100
)

print(res)


def print_run_report_response(response):
    """Prints results of a runReport call."""
    # [START analyticsdata_print_run_report_response_header]
    print(f"{response.row_count} rows received")
    for dimensionHeader in response.dimension_headers:
        print(f"Dimension header name: {dimensionHeader.name}")
    for metricHeader in response.metric_headers:
        metric_type = MetricType(metricHeader.type_).name
        print(f"Metric header name: {metricHeader.name} ({metric_type})")
    # [END analyticsdata_print_run_report_response_header]

    # [START analyticsdata_print_run_report_response_rows]
    print("Report result:")
    for rowIdx, row in enumerate(response.rows):
        print(f"\nRow {rowIdx}")
        for i, dimension_value in enumerate(row.dimension_values):
            dimension_name = response.dimension_headers[i].name
            print(f"{dimension_name}: {dimension_value.value}")

        for i, metric_value in enumerate(row.metric_values):
            metric_name = response.metric_headers[i].name
            print(f"{metric_name}: {metric_value.value}")
            
            
 