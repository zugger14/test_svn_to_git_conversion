/**
* new db objects for portfolio mapping deal and book
* sligal
* 13th may 2013
**/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID (N'dbo.portfolio_mapping_deal', N'U') IS NULL
BEGIN
	CREATE TABLE dbo.portfolio_mapping_deal
	(
    [portfolio_mapping_deal_id]	INT IDENTITY(1, 1) PRIMARY KEY,
    [mapping_source_value_id]	INT REFERENCES dbo.static_data_value(value_id),
    [mapping_source_usage_id]	INT NULL,
    [deal_id]					INT NULL,
    [create_user]    			VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]      			DATETIME NULL DEFAULT GETDATE(),
    [update_user]    			VARCHAR(50) NULL,
    [update_ts]      			DATETIME NULL
    )
END
GO

-- adding update trigger for above table
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_portfolio_mapping_deal]'))
    DROP TRIGGER [dbo].[TRGUPD_portfolio_mapping_deal]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_portfolio_mapping_deal]
ON [dbo].[portfolio_mapping_deal]
FOR UPDATE
AS
BEGIN
    --this check is required to prevent recursive trigger
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE portfolio_mapping_deal
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM portfolio_mapping_deal pmd
        INNER JOIN DELETED d ON d.portfolio_mapping_deal_id = pmd.portfolio_mapping_deal_id
    END
END
GO
