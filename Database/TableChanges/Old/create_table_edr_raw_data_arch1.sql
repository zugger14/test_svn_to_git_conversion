IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[edr_raw_data_arch1]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
    CREATE TABLE [dbo].[edr_raw_data_arch1]
	(
	[RECID] [bigint] NOT NULL,
	[stack_id] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[stack_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[facility_id] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[unit_id] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[record_type_code] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[sub_type_id] [int] NULL,
	[edr_date] [datetime] NOT NULL,
	[edr_hour] [tinyint] NOT NULL,
	[edr_value] [numeric] (18, 6) NULL CONSTRAINT [DF_edr_raw_data_arch1_edr_value] DEFAULT ((0)),
	[curve_id] [int] NULL,
	[uom_id] [int] NULL,
	[uom_id1] [int] NULL,
	[create_ts] [datetime] NULL CONSTRAINT [DF_edr_raw_data_arch1_create_ts] DEFAULT (getdate())
	)
    PRINT 'Table Successfully Created'

	ALTER TABLE [dbo].[edr_raw_data_arch1] ADD CONSTRAINT [PK_edr_raw_data_arch1] PRIMARY KEY CLUSTERED ([RECID])
END
