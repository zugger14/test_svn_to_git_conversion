SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[deal_required_document]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[deal_required_document](
    	[deal_required_document_id]     INT IDENTITY(1, 1) NOT NULL,
    	[source_deal_header_id]         INT NOT NULL REFERENCES source_deal_header(source_deal_header_id),
    	[document_type]                 INT NOT NULL REFERENCES documents_type(document_id),
    	[comments]                      VARCHAR(5000) NULL,
    	[create_user]                   VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                     DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                   VARCHAR(50) NULL,
    	[update_ts]                     DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table deal_required_document EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_deal_required_document]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_deal_required_document]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_deal_required_document]
ON [dbo].[deal_required_document]
FOR UPDATE
AS
    UPDATE deal_required_document
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM deal_required_document t
      INNER JOIN DELETED u ON t.[deal_required_document_id] = u.[deal_required_document_id]
GO