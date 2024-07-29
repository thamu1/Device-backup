
from datetime import datetime, date, timedelta 
from dateutil.relativedelta import relativedelta


rst = 1
est = 0


recon_start_dt = str((date.today().replace(day=1)) - relativedelta(months=int(rst)))
recon_end_dt = str(((date.today().replace(day=1)) - relativedelta(months=int(est))) - timedelta(days = 1)) 


print(recon_start_dt)
print(recon_end_dt)
