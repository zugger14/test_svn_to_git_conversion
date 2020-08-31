SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[deal_fields_mapping]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[deal_fields_mapping](
    	[deal_fields_mapping_id]     INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[counterparty_id]            INT REFERENCES source_counterparty(source_counterparty_id) NULL,
    	[template_id]                INT REFERENCES source_deal_header_template(template_id)  NULL,
    	[create_user]                VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                  DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                VARCHAR(50) NULL,
    	[update_ts]                  DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table deal_fields_mapping EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_deal_fields_mapping]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_deal_fields_mapping]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_deal_fields_mapping]
ON [dbo].[deal_fields_mapping]
FOR UPDATE
AS
    UPDATE deal_fields_mapping
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM deal_fields_mapping t
      INNER JOIN DELETED u ON t.[deal_fields_mapping_id] = u.[deal_fields_mapping_id]
GO