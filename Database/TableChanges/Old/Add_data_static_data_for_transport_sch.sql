
insert into static_data_type(type_id,type_name,internal,description) values(1800,'Transportation Rate Schedule',1,'Transportation Rate Schedule')



set identity_insert static_data_value on
insert into static_data_value(value_id,type_id,code,description) values(1800,1800,'Schedule1','Schedule1')
insert into static_data_value(value_id,type_id,code,description) values(1801,1800,'Schedule2','Schedule2')

set identity_insert static_data_value off

select * from static_data_value where type_id = 1800

go

if object_id('[dbo].[transportation_rate_schedule]') is not null
	drop table [dbo].[transportation_rate_schedule]
go


CREATE TABLE [dbo].[transportation_rate_schedule](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[rate_scheduled_type_id] [int] NULL,
	[rate_type] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[rate] [float] NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_transportation_rate_schedule] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[transportation_rate_schedule]  WITH CHECK ADD  CONSTRAINT [FK_transportation_rate_schedule_static_data_value] FOREIGN KEY([rate_scheduled_type_id])
REFERENCES [dbo].[static_data_value] ([value_id])


go
insert into dbo.transportation_rate_schedule (rate_scheduled_type_id,rate_type, rate)
select 1800,'MDQ',100
union all select
1800,'Reservation Charge',	200
union all select
1800,	'Commodity',		300
union all select
1800,	'Gas Research Institute Charge',	400
union all select
1800,'Actual Cost Adj Charge',	500
union all select
1800,'Take of Pay Charge',	600
union all select
1800,'Other Charges'	,	700
union all select
1800,'Fuel Charge',		800

