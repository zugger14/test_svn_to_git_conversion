
if exists(select 1 from sys.indexes where name='indx_deal_detail_hour')
drop index [indx_deal_detail_hour] ON [dbo].[deal_detail_hour]