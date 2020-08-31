SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[split_deal_detail_volume]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[split_deal_detail_volume]
    (
    [split_deal_detail_volume_id] INT IDENTITY(1, 1) NOT NULL,
    source_deal_detail_id INT,
	[quantity]		NUMERIC(38, 18) NULL,
    [finalized]		CHAR(1) NULL,
    [create_user]	VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]		DATETIME NULL DEFAULT GETDATE(),
    [update_user]	VARCHAR(50) NULL,
    [update_ts]		DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table split_deal_detail_volume EXISTS'
END
 
GO

