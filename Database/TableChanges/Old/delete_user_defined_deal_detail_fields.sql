SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF NOT EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[delete_user_defined_deal_detail_fields]')
              AND TYPE IN (N'U')
   )
BEGIN
    CREATE TABLE [dbo].[delete_user_defined_deal_detail_fields]
    (
    	[row_id]                 [int] IDENTITY(1, 1)NOT NULL,
    	[udf_deal_id]            [int] NOT NULL,
    	[source_deal_detail_id]  [int] NULL,
    	[udf_template_id]        [int] NULL,
    	[udf_value]              [varchar](8000) NULL,
    	[create_user]            [varchar](50) NULL,
    	[create_ts]              [datetime] NULL,
    	[update_user]            [varchar](50) NULL,
    	[update_ts]              [datetime] NULL,
    	CONSTRAINT [PK_delete_user_defined_deal_detail_fields] PRIMARY KEY 
    	CLUSTERED([udf_deal_id] ASC)WITH (
    	    PAD_INDEX = OFF,
    	    STATISTICS_NORECOMPUTE = OFF,
    	    IGNORE_DUP_KEY = OFF,
    	    ALLOW_ROW_LOCKS = ON,
    	    ALLOW_PAGE_LOCKS = ON
    	) ON [PRIMARY]
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table [delete_user_defined_deal_detail_fields] already exsists.'
END
GO

SET ANSI_PADDING OFF
GO


