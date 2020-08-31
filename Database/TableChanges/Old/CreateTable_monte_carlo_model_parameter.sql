SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[monte_carlo_model_parameter]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[monte_carlo_model_parameter]
    (
    [monte_carlo_model_parameter_id] INT IDENTITY(1, 1) NOT NULL,
    [monte_carlo_model_parameter_name] VARCHAR(100) NULL,
    [volatility] VARCHAR(40) NULL,
    [drift] VARCHAR(40) NULL,
    [as_of_date_from] DATETIME NULL,
    [risk_factor] VARCHAR(200) NULL,
    [data_series] INT NULL,
    [curve_source] INT NULL,
    [no_of_simulation] INT NULL,
    [holding_days] INT NULL,
    [mean_reversion_type] CHAR(1) NULL,
    [mean_reversion_rate] VARCHAR(40) NULL,
    [mean_reversion_level] VARCHAR(40) NULL,
    [create_user] VARCHAR(50) NULL DEFAULT([dbo].[FNADBUser]()),
    [create_ts] DATETIME NULL DEFAULT(GETDATE()),
    [update_user] VARCHAR(50) NULL,
    [update_ts] DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table monte_carlo_model_parameter EXISTS'
END

GO

-- trigger
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (
       SELECT *
       FROM   sys.triggers
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_monte_carlo_model_parameter]')
)

	DROP TRIGGER [dbo].[TRGUPD_monte_carlo_model_parameter]
GO

CREATE TRIGGER [dbo].[TRGUPD_monte_carlo_model_parameter]
ON [dbo].monte_carlo_model_parameter
FOR  UPDATE
AS
	UPDATE monte_carlo_model_parameter
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   monte_carlo_model_parameter s
	INNER JOIN DELETED d ON  s.monte_carlo_model_parameter_id = d.monte_carlo_model_parameter_id	

GO