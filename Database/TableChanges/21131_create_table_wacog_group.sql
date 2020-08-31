IF EXISTS(SELECT 1 FROM sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[wacog_group]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
	CREATE TABLE [dbo].[wacog_group]
	(
		wacog_group_id INT IDENTITY(1, 1) PRIMARY KEY,
		wacog_group_name VARCHAR(100),
		subbook_id VARCHAR(MAX),
		source_counterparty_id INT,
		contract_id INT,
		trader_id INT,
		template_id INT,
		deal_type VARCHAR(100),
		source_commodity_id INT,
		location_id INT,
		curve_id INT,
		physical_financial_flag CHAR(1),
		buy_sell_flag CHAR(1),
		frequency INT,
		[create_user] VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] DATETIME NULL DEFAULT GETDATE(),
		update_user VARCHAR(100),
		update_ts DATETIME
	)
END

IF EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_wacog_group]'))
    DROP TRIGGER [dbo].[TRGUPD_wacog_group]
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[TRGUPD_wacog_group]
ON [dbo].[wacog_group]
FOR UPDATE
AS
BEGIN
    -- used to prevent recursive trigger
     IF NOT UPDATE(update_ts)
    BEGIN
        UPDATE wacog_group
        SET update_user = dbo.FNADBUser(), 
			update_ts = GETDATE()
        FROM wacog_group p
        INNER JOIN DELETED d 
			ON d.wacog_group_id = p.wacog_group_id
    END
END
GO