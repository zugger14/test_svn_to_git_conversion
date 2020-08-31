if OBJECT_ID('dbo.position_run_log') is not null
drop table dbo.position_run_log
go

create table dbo.position_run_log (
process_id varchar(50)
,source_run varchar(100)
,start_time datetime
,end_time datetime
,no_deals int
,deal_total_volume numeric(38,20)
,position_breakdown_volume numeric(38,20)
,run_status varchar(1)
,create_user varchar(30)
,insert_type TINYINT,
job_name varchar(150),
remarks varchar(500)
)

