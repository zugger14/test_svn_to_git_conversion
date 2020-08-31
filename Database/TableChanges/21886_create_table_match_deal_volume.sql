SET ANSI_NULLS ON
GO
 
-- drop table match_deal_volume
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[match_deal_volume]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[match_deal_volume] (
    	[match_deal_volume_id]		INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
		buy_source_deal_detail_id INT,
		sell_source_deal_detail_id INT,
		term_start DATETIME,
		match_vol NUMERIC(38,20),
		buy_outstanding_vol NUMERIC(38,20),
		sell_outstanding_vol NUMERIC(38,20),

    	[create_user]                   VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                     DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                   VARCHAR(50) NULL,
    	[update_ts]                     DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table match_deal_volume exists'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_match_deal_volume]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_match_deal_volume]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_match_deal_volume]
ON [dbo].[match_deal_volume]
FOR UPDATE
AS
    UPDATE match_deal_volume
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM match_deal_volume t
      INNER JOIN DELETED u ON t.[match_deal_volume_id] = u.[match_deal_volume_id]
GO