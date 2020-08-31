SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[etag_detail]', N'U') IS NOT NULL
BEGIN
	DROP TABLE [etag_detail]
END

IF OBJECT_ID(N'[dbo].[etag]', N'U') IS NOT NULL
BEGIN
	DROP TABLE [etag]
END

IF OBJECT_ID(N'[dbo].[etag]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[etag] (
		id						INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		etag_id					INT,
		control_areas			INT,
		control_area_type		VARCHAR(100),
		transmission_providers	INT,
		pse						INT,
		point_of_receipt		INT,
		point_of_delivery		INT,
		scheduling_entity		INT,
		generator				VARCHAR(100),
		counterparty_id			INT,
		[create_user]    		VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]      		DATETIME NULL DEFAULT GETDATE(),
		[update_user]    		VARCHAR(50) NULL,
		[update_ts]      		DATETIME NULL		
    )
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_etag]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_etag]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_etag]
ON [dbo].[etag]
FOR UPDATE
AS
    UPDATE etag
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM etag t
    INNER JOIN DELETED u ON t.[etag_id] = u.[etag_id]
GO