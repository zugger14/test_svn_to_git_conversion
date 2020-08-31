SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[template_mapping]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[template_mapping] (
		[template_mapping_id] INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
		[template_id]                   INT REFERENCES source_deal_header_template([template_id]) NOT NULL,
		[deal_type_id]                  INT REFERENCES source_deal_type([source_deal_type_id]) NOT NULL,
		[commodity_id]                  INT REFERENCES source_commodity([source_commodity_id]) NOT NULL,
		[create_user]                   VARCHAR(50) NULL DEFAULT [dbo].[FNADBUser](),
		[create_ts]                     DATETIME NULL DEFAULT GETDATE(),
		[update_user]                   VARCHAR(50) NULL,
		[update_ts]                     DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table template_mapping EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_template_mapping]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_template_mapping]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_template_mapping]
ON [dbo].[template_mapping]
FOR UPDATE
AS
    UPDATE template_mapping
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM template_mapping t
      INNER JOIN DELETED u ON t.[template_mapping_id] = u.[template_mapping_id]
GO