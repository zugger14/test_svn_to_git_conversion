SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[etag_detail]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[etag_detail] (
		[etag_detail_id]			INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		[etag_id]      				INT NOT NULL,
		[term]  					DATETIME NOT NULL,
		[hrs]  						INT NULL,
		[etag_value]				NUMERIC(38, 20) NULL,
		[create_user]    			NVARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]      			DATETIME NULL DEFAULT GETDATE(),
		[update_user]    			NVARCHAR(50) NULL,
		[update_ts]      			DATETIME NULL
    )
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_etag_detail]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_etag_detail]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_etag_detail]
ON [dbo].[etag_detail]
FOR UPDATE
AS
    UPDATE etag_detail
    SET update_user = dbo.FNADBUser(),
        update_ts = GETDATE()
    FROM etag_detail t
    INNER JOIN DELETED u ON t.[etag_detail_id] = u.[etag_detail_id]
GO
