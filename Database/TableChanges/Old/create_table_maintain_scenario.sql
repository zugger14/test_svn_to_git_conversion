SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[maintain_scenario]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[maintain_scenario]
    (
    [scenario_id]					INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    [scenario_name]					VARCHAR(100) NULL,
    [scenario_description]			VARCHAR(100) NULL,
    [user]							VARCHAR(100) NULL,
    [role]							VARCHAR(100) NULL,
    [active]						CHAR(1) NULL,
    [public]						CHAR(1) NULL,
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
    PRINT 'Table maintain_scenario EXISTS'
END

GO