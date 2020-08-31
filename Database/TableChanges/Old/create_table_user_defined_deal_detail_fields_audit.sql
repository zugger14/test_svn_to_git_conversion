
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_defined_deal_detail_fields_audit]') AND type in (N'U'))
BEGIN

	CREATE TABLE [dbo].[user_defined_deal_detail_fields_audit](
		[udf_audit_id] INT IDENTITY(1,1)  NOT NULL,
		[udf_deal_id] [int] NULL,
		[source_deal_detail_id] [int] NULL,
		[udf_template_id] [int] NULL,
		[udf_value] [varchar](8000) NULL,
		[create_user] [varchar](50) NULL,
		[create_ts] [datetime] NULL,
		[update_user] [varchar](50) NULL,
		[update_ts] [datetime] NULL,
		[user_action] VARCHAR(50),
        [header_audit_id] INT,
	 CONSTRAINT [PK_user_defined_deal_detail_fields_audit] PRIMARY KEY CLUSTERED 
	(
		[udf_audit_id] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]
		
END
ELSE 
BEGIN
	PRINT 'Table [user_defined_deal_detail_fields_audit] already exsists.'
END
GO



