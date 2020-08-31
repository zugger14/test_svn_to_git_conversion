SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[maintain_field_deal1]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[maintain_field_deal1](
	[field_deal_id] [int] IDENTITY(1,1) NOT NULL,
	[field_id] [int]  NOT NULL,
	[farrms_field_id] [varchar](50) NULL,
	[default_label] [varchar](150) NULL,
	[field_type] [char](1) NULL,
	[data_type] [varchar](50) NULL,
	[default_validation] [int] NULL,
	[header_detail] [char](1) NULL,
	[system_required] [char](1) NULL,
	[sql_string] [varchar](5000) NULL,
	[field_size] [int] NULL,
	[is_disable] [char](1) NULL,
	[window_function_id] [varchar](50) NULL,
	[is_hidden] [char](1) NULL,
	[default_value] [varchar](200) NULL,
	[insert_required] [char](1) NULL,
	[data_flag] [char](1) NULL,
 CONSTRAINT [PK_maintain_field_deal1] PRIMARY KEY CLUSTERED 
(
	[field_deal_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

END
ELSE
BEGIN
    PRINT 'Table maintain_field_deal1 already EXISTS'
END

SET ANSI_PADDING OFF
GO

INSERT INTO maintain_field_deal1
(
	field_id,
	farrms_field_id,
	default_label,
	field_type,
	data_type,
	default_validation,
	header_detail,
	system_required,
	sql_string,
	field_size,
	is_disable,
	window_function_id,
	is_hidden,
	default_value,
	insert_required,
	data_flag
)
SELECT 
	field_id,
	farrms_field_id,
	default_label,
	field_type,
	data_type,
	default_validation,
	header_detail,
	system_required,
	sql_string,
	field_size,
	is_disable,
	window_function_id,
	is_hidden,
	default_value,
	insert_required,
	data_flag
FROM dbo.maintain_field_deal

IF EXISTS (SELECT * FROM sys.objects WHERE object_id IN(OBJECT_ID(N'[dbo].[maintain_field_deal]'), OBJECT_ID(N'[dbo].[maintain_field_deal1]'))  AND type in (N'U'))
BEGIN
	DROP TABLE maintain_field_deal
END

EXECUTE sp_rename N'dbo.maintain_field_deal1', N'maintain_field_deal', 'OBJECT'


