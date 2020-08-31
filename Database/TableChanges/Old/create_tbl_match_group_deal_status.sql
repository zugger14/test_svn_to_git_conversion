SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[match_group_deal_status]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].match_group_deal_status
    (
    [match_group_deal_status_id]             INT IDENTITY(1, 1) NOT NULL,
    [match_group_deal_status]      VARCHAR(1000) NULL,
    [value_id]  INT NULL,
    [create_user]    VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]      DATETIME NULL DEFAULT GETDATE(),
    [update_user]    VARCHAR(50) NULL,
    [update_ts]      DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table match_group_deal_status EXISTS'
END
 
GO

IF NOT EXISTS(SELECT 1 FROM match_group_deal_status WHERE [value_id] = 5604)
BEGIN 
	INSERT INTO match_group_deal_status([match_group_deal_status], [value_id])
	SELECT code, value_id FROM static_data_value WHERE [value_id] = 5604
END 

IF NOT EXISTS(SELECT 1 FROM match_group_deal_status WHERE [value_id] = 5603)
BEGIN 
	INSERT INTO match_group_deal_status([match_group_deal_status], [value_id])
	SELECT code, value_id FROM static_data_value WHERE [value_id] = 5603
END 


IF NOT EXISTS(SELECT 1 FROM match_group_deal_status WHERE [value_id] = 5605)
BEGIN 
	INSERT INTO match_group_deal_status([match_group_deal_status], [value_id])
	SELECT code, value_id FROM static_data_value WHERE [value_id] = 5605
END 

GO
 
