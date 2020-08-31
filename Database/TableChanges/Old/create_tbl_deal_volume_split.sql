SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].deal_volume_split', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].deal_volume_split
    (
	deal_volume_split_id INT IDENTITY(1, 1) NOT NULL,	
	source_deal_detail_id_from INT,	
	source_deal_detail_id_to INT,	
	bookout_id VARCHAR(100),
	bookout_date DATETIME,
	bookout_amt NUMERIC(38,18),
	lineup VARCHAR(1000),
	is_finalized CHAR(1),
	bookout_match CHAR(1),
	[create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
	[create_ts] DATETIME NULL DEFAULT GETDATE(),
	[update_user] VARCHAR(50) NULL,
	[update_ts] DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table deal_volume_split EXISTS'
END
 
GO