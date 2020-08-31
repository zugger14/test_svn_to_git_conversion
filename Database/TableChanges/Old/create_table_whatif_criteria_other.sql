SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[whatif_criteria_other]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[whatif_criteria_other]
    (
    [whatif_criteria_other_id]  INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    [portfolio_group_id]		INT NULL REFERENCES dbo.maintain_portfolio_group(portfolio_group_id),
    [criteria_id]				INT NULL REFERENCES dbo.maintain_whatif_criteria(criteria_id),
    [counterparty]				INT NULL,
    [buy]						CHAR(1) NULL,
    [sell]						CHAR(1) NULL,
    [buy_index]					INT NULL,
    [buy_price]					NUMERIC(20, 10) NULL,
    [buy_volume]				NUMERIC(20, 10) NULL,
    [buy_uom]					INT NULL,
    [buy_term_start]			DATETIME NULL,
    [buy_term_end]				DATETIME NULL,
    [sell_index]				INT NULL,
    [sell_price]				NUMERIC(20, 10) NULL,
    [sell_volume]				NUMERIC(20, 10) NULL,
    [sell_uom]					INT NULL,
    [sell_term_start]			DATETIME NULL,
    [sell_term_end]				DATETIME NULL,
    
    [create_user]    			VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]      			DATETIME NULL DEFAULT GETDATE(),
    [update_user]    			VARCHAR(50) NULL,
    [update_ts]      			DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table whatif_criteria_other EXISTS'
END

GO
