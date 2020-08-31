SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[whatif_criteria_book]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[whatif_criteria_book]
    (
    [whatif_criteria_book_id]	INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    [portfolio_group_id]		INT NULL REFERENCES dbo.maintain_portfolio_group(portfolio_group_id),
    [criteria_id]				INT NULL REFERENCES dbo.maintain_whatif_criteria(criteria_id),
    [book_name]					VARCHAR(100) NULL,
    [book_description]			VARCHAR(500) NULL,
    [book_parameter]			VARCHAR(500) NULL,
    
    [create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]					DATETIME NULL DEFAULT GETDATE(),
    [update_user]    			VARCHAR(50) NULL,
    [update_ts]      			DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table whatif_criteria_book EXISTS'
END

GO