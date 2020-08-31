ALTER TABLE report_where_column_required ADD clm_type char(1)
Go
ALTER TABLE dbo.report_where_column_required ADD
	control_type varchar(250) NULL,
	data_source varchar(8000) NULL,
	default_value varchar(500) NULL
GO                