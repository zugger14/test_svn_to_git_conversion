SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[maintain_whatif_criteria]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[maintain_whatif_criteria]
    (
    [criteria_id]				INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    [criteria_name]				VARCHAR(100) NULL,
    [criteria_description]		VARCHAR(500) NULL,
    [portfolio_group_id]		INT NULL REFERENCES dbo.maintain_portfolio_group(portfolio_group_id),
    [scenario_id]				INT NULL REFERENCES dbo.maintain_scenario(scenario_id),
    [user]						VARCHAR(50) NULL,
    [role]						VARCHAR(50) NULL,
    [scenario_criteria_group]	INT NULL,
    [active]					CHAR(1) NULL,
    [public]					CHAR(1) NULL,
    
    [create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]					DATETIME NULL DEFAULT GETDATE(),
    [update_user]				VARCHAR(50) NULL,
    [update_ts]					DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table maintain_whatif_criteria EXISTS'
END

GO



