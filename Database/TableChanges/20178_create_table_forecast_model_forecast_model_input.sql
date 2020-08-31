SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

------ formula_model 
IF OBJECT_ID(N'[dbo].[forecast_model]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].forecast_model (
		forecast_model_id			INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		forecast_model_name			VARCHAR(100),
		forecast_type				INT,
		forecast_category			INT,
		forecast_granularity		INT,
		threshold					VARCHAR(100),
		maximum_step				VARCHAR(100),
		learning_rate				VARCHAR(100),
		repetition					VARCHAR(100),
		hidden_layer				VARCHAR(100),
		[algorithm]					VARCHAR(100),
		[error_function]			VARCHAR(100),
		[create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]					DATETIME NULL DEFAULT GETDATE(),
		[update_user]				VARCHAR(50) NULL,
		[update_ts]					DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table [dbo].forecast_model EXISTS'
END

GO

IF OBJECT_ID('[dbo].[TRGUPD_forecast_model]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_forecast_model]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_forecast_model]
ON [dbo].[forecast_model]
FOR UPDATE
AS
    UPDATE workflow_event_message
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM forecast_model t
      INNER JOIN DELETED u ON t.forecast_model_id = u.forecast_model_id
GO


------ formula_model_input
IF OBJECT_ID(N'[dbo].[forecast_model_input]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].forecast_model_input (
		forecast_model_input_id		INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		forecast_model_id			INT REFERENCES forecast_model(forecast_model_id) NOT NULL,
		series_type					INT,
		series						INT,
		formula						INT,
		[create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]					DATETIME NULL DEFAULT GETDATE(),
		[update_user]				VARCHAR(50) NULL,
		[update_ts]					DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table [dbo].forecast_model_input EXISTS'
END

GO


IF OBJECT_ID('[dbo].[TRGUPD_forecast_model_input]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_forecast_model_input]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_forecast_model_input]
ON [dbo].[forecast_model_input]
FOR UPDATE
AS
    UPDATE workflow_event_message
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM forecast_model_input t
      INNER JOIN DELETED u ON t.forecast_model_input_id = u.forecast_model_input_id
GO