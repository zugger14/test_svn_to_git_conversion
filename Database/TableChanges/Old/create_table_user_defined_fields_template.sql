
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[user_defined_fields_template]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[user_defined_fields_template](
		[udf_template_id] [int] IDENTITY(1,1) NOT NULL,
		[field_name] [int] NULL,
		[Field_label] [varchar](50) NULL,
		[Field_type] [varchar](100) NULL,
		[data_type] [varchar](50) NULL,
		[is_required] [char](1) NULL,
		[sql_string] [varchar](500) NULL,
		[create_user] [varchar](50) NULL,
		[create_ts] [datetime] NULL,
		[update_user] [varchar](50) NULL,
		[update_ts] [datetime] NULL,
		[udf_type] [char](1) NULL,
		[sequence] [int] NULL,
		[field_size] [int] NULL,
		[field_id] [int] NULL,
		[default_value] [varchar](500) NULL,
		[book_id] [int] NULL,
		[udf_group] [int] NULL,
		[udf_tabgroup] [int] NULL,
		[formula_id] [int] NULL,
		[internal_field_type] [int] NULL,
	 CONSTRAINT [PK_user_defined_fields_template] PRIMARY KEY CLUSTERED 
	(
		[udf_template_id] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]
END	
GO


IF NOT EXISTS(SELECT 1
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'user_defined_fields_template'      --table name
                      AND COLUMN_NAME = 'udf_type'    --column name where DEFAULT constaint it to be created
                      AND COLUMN_DEFAULT IS NOT NULL)
BEGIN
    ALTER TABLE [dbo].[user_defined_fields_template]
    ADD CONSTRAINT DF_user_defined_fields_template_udf_type DEFAULT ('u') FOR udf_type
END
GO

SET ANSI_PADDING OFF
GO

