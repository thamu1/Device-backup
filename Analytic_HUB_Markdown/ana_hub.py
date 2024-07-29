import os
import pandas as pd 
import sys

resultFile = "" # "D:/PCH/PCH Team/Prashant/Bigquery Analytics Hub/test.html"
csvLoc = "" # "D:/PCH/PCH Team/Prashant/Bigquery Analytics Hub/sample.csv"

# "D:/PCH/PCH Dev Team/Ravi/Bigquery Analytics Hub/result/dms_prospect.html"
# "D:/PCH/PCH Dev Team/Ravi/Bigquery Analytics Hub/sample/dms_prospect.csv"

# "D:/PCH/PCH Dev Team/Ravi/Bigquery Analytics Hub/result/dms_customer.html"
# "D:/PCH/PCH Dev Team/Ravi/Bigquery Analytics Hub/sample/dms_customer.csv"




if len(sys.argv) >= 2:
    resultFile = sys.argv[1]
    csvLoc = sys.argv[2]
    insufficient_arguments = False
else:
    insufficient_arguments = True
    print("Insufficient arguments passed for executing the python util.")

if(not insufficient_arguments):

    if(os.path.exists(resultFile)):
        os.remove(resultFile)


    start = """<html>
        <head>
            <style>
                table, tr, th, td {
                    border: 1px solid black;
                    border-collapse: collapse;
                }
            </style>
        </head>
        <body>
        <div>
            <center><h2>Analytics Hub Subscription Info</h2></center>
        </div>
        """

    end = f""" 
            </body>
        </html>
        """
        
        
    def htmlin(text):
        file = open(resultFile,"+a")
        file.write(text)
        
    try:
        if(os.path.exists(csvLoc)):

            df = pd.read_csv(csvLoc, encoding='windows-1254')

            if len(df) > 0:
                htmlin(start)
                topic_title = f"""<div id="topic_title">
                        <table cellpadding="3px">
                            <tr>
                                <th>Subject Area   :</th>
                                <td>DMS Customer</td>
                            </tr>
                        </table>
                        <br>
                        <table cellpadding="3px">
                            <tr>
                                <th>Analytics Hub Source Dataset Name   :</th>
                                <td>pgc_analytics_dms_customer</td>
                            </tr>
                        </table>
                    </div><br>"""
                htmlin(topic_title)
                
                tabhdst="""<div>
                    <table cellpadding="3px" table-layout: fixed>
                    <tr>
                        <th>ID</th>
                        <th>Details</th>
                    </tr>"""
                htmlin(tabhdst)
                
                for i in df.values:  
                    i[2] = str(i[2]).replace("\n","").strip().lower().capitalize() 
                    
                            
                    table = f"""<tr>
                        <th>{int(i[0])}</th>
                        <td>
                            <table cellpadding="3px">
                                <tr>
                                    <th bgcolor= "#BFCEDB">Name</th>
                                    <td>{str(i[1])}</td>
                                </tr>
                                <tr>
                                    <th bgcolor= "#BFCEDB">PrimaryKey</th>
                                    <td>{i[3]}</td>
                                </tr>
                                <tr>
                                    <th bgcolor= "#BFCEDB">Description</th>
                                    <td>{i[2]}</td>
                                </tr>
                            </table>
                            <table cellpadding="3px">
                                <tr>
                                    <th bgcolor= "#BFCEDB">SourceSystem</th>
                                    <td>{str(i[4])}</td>
                                    <th bgcolor= "#BFCEDB">SourceLanding</th>
                                    <td>{str(i[5])}</td>
                                    <th bgcolor= "#BFCEDB">Frequency</th>
                                    <td>{str(i[6])}</td>
                                </tr>
                                <tr>
                                    <th bgcolor= "#BFCEDB">AvgRecordVolume</th>
                                    <td>{str(i[8])}</td>
                                    <th bgcolor= "#BFCEDB">AvgDataSize</th>
                                    <td>{str(i[9])}</td>
                                    <th bgcolor= "#BFCEDB">DataRetention</th>
                                    <td>{str(i[10])}</td>
                                </tr>
                                <tr>
                                    <th bgcolor= "#BFCEDB">ClusteringColumn</th>
                                    <td>{i[12]}</td>
                                    <th bgcolor= "#BFCEDB">Support</th>
                                    <td>{str(i[13])}</td>
                                    <th bgcolor= "#BFCEDB">Status</th>
                                    <td>{str(i[14])}</td>
                                </tr>
                                <tr>
                                    <th bgcolor= "#BFCEDB">PartitionColumn</th>
                                    <td>{str(i[11])}</td>
                                    <th bgcolor= "#BFCEDB">RefreshTime</th>
                                    <td>{str(i[7])}</td>
                                </tr>
                            </table>
                        </td>
                    </tr>"""
                    htmlin(table)
                    
                tabhded = """</table>
                    </div>"""
                htmlin(tabhded)
                htmlin(end)
            else:
                htmlin(start)
                htmlin("<h1> There is nothing in given csv file</h1>")
                htmlin(end)
        else:
                htmlin(start)
                htmlin("<h1> There is no CSV file located</h1>")
                htmlin(end)
                
    except:
        htmlin(start)
        htmlin("<h1> Oops! Something went wrong.. </h1>")
        htmlin(end)


else:
    print("Insufficient arguments passed")
        

