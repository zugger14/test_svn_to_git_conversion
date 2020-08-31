SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[whatif_criteria_measure]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[whatif_criteria_measure]
    (
    [criteria_id]			INT REFERENCES dbo.maintain_whatif_criteria(criteria_id) PRIMARY KEY,
    [MTM]					CHAR(1) NULL,
    [position]				CHAR(1) NULL,
    [Var]					CHAR(1) NULL,
    [Cfar]					CHAR(1) NULL,
    [Ear]					CHAR(1) NULL,
    [var_approach]			INT NULL,
    [confidence_interval]	INT NULL,
    [holding_days]			INT NULL,
    [no_of_simulations]		INT NULL,
    
    [create_user]    		VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]      		DATETIME NULL DEFAULT GETDATE(),
    [update_user]    		VARCHAR(50) NULL,
    [update_ts]      		DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table whatif_criteria_measure EXISTS'
END

GO