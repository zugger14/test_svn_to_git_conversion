SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[whatif_criteria_deal]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[whatif_criteria_deal]
    (
    [whatif_criteria_deal_id]	INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    [portfolio_group_id]		INT NULL REFERENCES dbo.maintain_portfolio_group(portfolio_group_id),
    [criteria_id]				INT NULL REFERENCES dbo.maintain_whatif_criteria(criteria_id),
    [deal_id]					INT NULL,
    
    [create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]					DATETIME NULL DEFAULT GETDATE(),
    [update_user]    			VARCHAR(50) NULL,
    [update_ts]      			DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table whatif_criteria_deal EXISTS'
END

GO