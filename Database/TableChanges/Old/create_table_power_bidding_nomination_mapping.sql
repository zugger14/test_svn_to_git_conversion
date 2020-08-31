SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[power_bidding_nomination_mapping]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[power_bidding_nomination_mapping]
    (
    [power_bidding_nomination_mapping_id] INT IDENTITY(1, 1) NOT NULL,
    [source_deal_header_id] INT NOT NULL,
    [grid] INT NOT NULL,
    [buy_sell_flag] CHAR(1) NOT NULL,
    [source_deal_header_id_copy] INT NULL,
    [create_user]    VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]      DATETIME NULL DEFAULT GETDATE(),
    [update_user]    VARCHAR(50) NULL,
    [update_ts]      DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table power_bidding_nomination_mapping already EXISTS'
END
 
GO