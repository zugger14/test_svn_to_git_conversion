SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].deal_volume_split_actual', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].deal_volume_split_actual
    (
	deal_volume_split_actual_id INT IDENTITY(1, 1) NOT NULL,
	deal_volume_split_id INT,	
	source_deal_detail_id INT,	
	actual_volume NUMERIC(38,18),
	[create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
	[create_ts] DATETIME NULL DEFAULT GETDATE(),
	[update_user] VARCHAR(50) NULL,
	[update_ts] DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table deal_volume_split_actual EXISTS'
END
GO