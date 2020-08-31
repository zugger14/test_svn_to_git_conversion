SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[deal_remarks]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[deal_remarks](
    	[deal_remarks_id]           INT IDENTITY(1, 1) NOT NULL,
    	[source_deal_header_id]     INT NOT NULL REFERENCES source_deal_header(source_deal_header_id),
    	[deal_remarks]              VARCHAR(2000) NULL,
    	[create_user]               VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                 DATETIME NULL DEFAULT GETDATE(),
    	[update_user]               VARCHAR(50) NULL,
    	[update_ts]                 DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table deal_remarks EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_deal_remarks]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_deal_remarks]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_deal_remarks]
ON [dbo].[deal_remarks]
FOR UPDATE
AS
    UPDATE deal_remarks
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM deal_remarks t
      INNER JOIN DELETED u ON t.[deal_remarks_id] = u.[deal_remarks_id]
GO