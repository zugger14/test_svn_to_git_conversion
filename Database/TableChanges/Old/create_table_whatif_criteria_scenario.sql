SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[whatif_criteria_scenario]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[whatif_criteria_scenario]
    (
    [criteria_id]					INT REFERENCES dbo.maintain_whatif_criteria(criteria_id) PRIMARY KEY,
    --[scenario_id]					INT NULL REFERENCES dbo.maintain_scenario(scenario_id),
    --[scenario_name]					VARCHAR(100) NULL,
    [scenario_copy]					CHAR(1) NULL,
    [shift_by]						CHAR(1) NULL,
    [shift_value]					NUMERIC(20, 10) NULL,
    [source]						VARCHAR(50) NULL,
    [use_existing_values]			CHAR(1) NULL,
    [create_user]					VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]						DATETIME NULL DEFAULT GETDATE(),
    [update_user]					VARCHAR(50) NULL,
    [update_ts]						DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table whatif_criteria_scenario EXISTS'
END

GO

