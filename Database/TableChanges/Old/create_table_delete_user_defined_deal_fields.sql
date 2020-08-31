--create table delete_user_defined_deal_detail_fields
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF NOT EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[delete_user_defined_deal_fields]')
              AND TYPE IN (N'U')
   )
BEGIN
    CREATE TABLE [dbo].[delete_user_defined_deal_fields]
    (
    	[rowid]                  [int] IDENTITY(1, 1) NOT NULL,
    	[udf_deal_id]            [int] NOT NULL,
    	[source_deal_header_id]  [int] NULL,
    	[udf_template_id]        [int] NULL,
    	[udf_value]              [varchar](8000) NULL,
    	[create_user]            [varchar](50) NULL,
    	[create_ts]              [datetime] NULL,
    	[update_user]            [varchar](50) NULL,
    	[update_ts]              [datetime] NULL,
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table [delete_user_defined_deal_fields] already exsists.'
END
GO

SET ANSI_PADDING OFF
