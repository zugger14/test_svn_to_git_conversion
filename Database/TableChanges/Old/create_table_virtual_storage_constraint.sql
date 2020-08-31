
/****** Object:  Table [dbo].[virtual_storage_constraint]    Script Date: 07/29/2011 17:26:57 ******/

IF OBJECT_ID(N'[dbo].[virtual_storage_constraint]',N'U') IS NULL
BEGIN 
CREATE TABLE [dbo].[virtual_storage_constraint](
	[constraint_id] [int] IDENTITY(1,1) NOT NULL,
	[constraint_type] [int] REFERENCES static_data_value(value_id) NOT NULL,
	[value] [int] NULL,
	[uom] [int] REFERENCES source_uom(source_uom_id)  NULL,
	[frequency] CHAR(1) NULL,
	[effective_date] [date] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_virtual_storage_constraint] PRIMARY KEY CLUSTERED 
(
	[constraint_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

END 

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[virtual_storage_constraint_create_ts_def]') AND type = 'D')
ALTER TABLE [dbo].[virtual_storage_constraint] ADD  CONSTRAINT [virtual_storage_constraint_create_ts_def]  DEFAULT (getdate()) FOR [create_ts]
GO

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[virtual_storage_constraint_create_user_def]') AND type = 'D')
ALTER TABLE [dbo].[virtual_storage_constraint] ADD  CONSTRAINT [virtual_storage_constraint_create_user_def]  DEFAULT ([dbo].[FNADBUser]()) FOR [create_user]
GO

