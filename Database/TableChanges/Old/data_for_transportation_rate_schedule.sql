delete dbo.transportation_rate_schedule where rate_scheduled_type_id=1800

go
insert into dbo.transportation_rate_schedule (rate_scheduled_type_id,rate_type, rate)
select 1800,'MDQ',100
union all select
1800,'Reservation_Charge',	200
union all select
1800,	'Commodity',		300
union all select
1800,	'Gas_Research_Institute_Charge',	400
union all select
1800,'Actual_Cost_Adj_Charge',	500
union all select
1800,'Take_of_Pay_Charge',	600
union all select
1800,'Other_Charges'	,	700
union all select
1800,'Fuel_Charge',		800

go

declare @template_id int
set @template_id=153


INSERT INTO [dbo].[user_defined_deal_fields_template]
           ([template_id]
           ,[field_name]
           ,[Field_label]
           ,[Field_type]
           ,[data_type]
           ,[is_required]
           ,[sql_string]
           ,[create_user]
           ,[create_ts]
           ,[update_user]
           ,[update_ts]
           ,[udf_type]
           ,[sequence]
           ,[field_size])
     select
           @template_id
,rate_type
,rate_type
,'t'
,'nvarchar(50)'
,'n'
,''
,'farrms_admin'
,getdate()
,'farrms_admin'
,getdate()
,'s'
,id
,null

from transportation_rate_schedule

