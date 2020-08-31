--select * from static_data_value where type_id=800 order by value_id

set identity_insert static_data_value ON
GO
insert into static_data_value(type_id,value_id,code,description)
select 800,895,'ImbalanceVol','Imbalance Volume'
UNION
select 800,896,'AverageDailyPrice','Monthly Average of Daily Price'
UNION
select 800,897,'LocationVol','Volume in the Location'
GO
set identity_insert static_data_value OFF
