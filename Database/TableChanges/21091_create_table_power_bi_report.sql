
/****** Object:  Table [dbo].[power_bi_report]    Script Date: 10/10/2017 9:34:52 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[power_bi_report]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[power_bi_report](
	[power_bi_report_id] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](200) NULL,
	[owner] [varchar](45) NULL,
	[is_system] [bit] NULL,
	[description] [varchar](8000) NULL,
	[category_id] [int] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[is_mobile] [bit] NULL,
	[is_published] [bit] NULL,
	[source_report] VARCHAR(1000) NULL,
	[ext_int] INT NULL,
	[report_url] VARCHAR(1000) NULL,
	[process_table] VARCHAR(1000) NULL
 CONSTRAINT [PK_power_bi_report] PRIMARY KEY CLUSTERED 
(
	[power_bi_report_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
ELSE 
 PRINT 'Table power_bi_report EXISTS'
GO

IF NOT(EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'power_bi_report' AND COLUMN_NAME = 'create_user' AND COLUMN_DEFAULT IS NOT NULL))
BEGIN
	ALTER TABLE [dbo].[power_bi_report] ADD  DEFAULT ([dbo].[FNADBUser]()) FOR [create_user]
END
GO
IF NOT(EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'power_bi_report' AND COLUMN_NAME = 'create_ts' AND COLUMN_DEFAULT IS NOT NULL))
BEGIN
	ALTER TABLE [dbo].[power_bi_report] ADD  DEFAULT (getdate()) FOR [create_ts]
END
GO
IF NOT(EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'power_bi_report' AND COLUMN_NAME = 'is_mobile' AND COLUMN_DEFAULT IS NOT NULL))
BEGIN
	ALTER TABLE [dbo].[power_bi_report] ADD    DEFAULT ((0)) FOR [is_mobile]
END
GO
IF NOT(EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'power_bi_report' AND COLUMN_NAME = 'is_published' AND COLUMN_DEFAULT IS NOT NULL))
BEGIN
	ALTER TABLE [dbo].[power_bi_report] ADD    DEFAULT ((0)) FOR [is_published]
END
GO


