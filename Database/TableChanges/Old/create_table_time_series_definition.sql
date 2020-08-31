if object_id('dbo.time_series_definition') is  null
	create table dbo.time_series_definition	 (
		time_series_definition_id  int identity(1,1)   ,
		time_series_id	 varchar(50)   ,
		time_series_name 	 varchar(100)  , 
		time_series_description	   varchar(200)  , 
		time_series_type_value_id  int,  ---> Internal Static Data value for Grouping
		granulalrity int,
		uom_id	 int   ,
		currency_id	 int ,
		[create_user]   VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]     DATETIME DEFAULT GETDATE(),
		[update_user]   VARCHAR(100) NULL,
		[update_ts]     DATETIME NULL
	)
else 
	print 'Already exist table dbo.time_series_definition'
 


if object_id('dbo.time_series_data') is  null
	create table dbo.time_series_data (
		time_series_definition_id  int,
		effective_date	 datetime,
		maturity datetime,   --(optional to support flat rates)
		curve_source_value_id int, -- (4500..)
		value float,
		is_dst int, -- (to support hourly rates)
		[create_user]   VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]     DATETIME DEFAULT GETDATE(),
		[update_user]   VARCHAR(100) NULL,
		[update_ts]     DATETIME NULL
	)
else 
	print 'Already exist table dbo.time_series_data'
 

