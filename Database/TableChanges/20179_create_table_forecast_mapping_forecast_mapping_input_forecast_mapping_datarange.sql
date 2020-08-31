SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

------ formula_mapping
IF OBJECT_ID(N'[dbo].[forecast_mapping]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].forecast_mapping (
		forecast_mapping_id			INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		forecast_model_id			INT, 
		[output_id]					INT,
		[create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]					DATETIME NULL DEFAULT GETDATE(),
		[update_user]				VARCHAR(50) NULL,
		[update_ts]					DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table [dbo].forecast_mapping EXISTS'
END

GO

IF OBJECT_ID('[dbo].[TRGUPD_forecast_mapping]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_forecast_mapping]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_forecast_mapping]
ON [dbo].[forecast_mapping]
FOR UPDATE
AS
    UPDATE workflow_event_message
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM forecast_mapping t
      INNER JOIN DELETED u ON t.forecast_mapping_id = u.forecast_mapping_id
GO


------ formula_mapping_input
IF OBJECT_ID(N'[dbo].[forecast_mapping_input]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].forecast_mapping_input (
		forecast_mapping_input_id	INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		forecast_mapping_id			INT REFERENCES forecast_mapping(forecast_mapping_id) NOT NULL,
		forecast_model_input_id		INT,
		input						VARCHAR(100),
		forecast					INT,
		[create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]					DATETIME NULL DEFAULT GETDATE(),
		[update_user]				VARCHAR(50) NULL,
		[update_ts]					DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table [dbo].forecast_mapping_input EXISTS'
END

GO


IF OBJECT_ID('[dbo].[TRGUPD_forecast_mapping_input]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_forecast_mapping_input]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_forecast_mapping_input]
ON [dbo].[forecast_mapping_input]
FOR UPDATE
AS
    UPDATE workflow_event_message
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM forecast_mapping_input t
      INNER JOIN DELETED u ON t.forecast_mapping_input_id = u.forecast_mapping_input_id
GO


------ formula_mapping_neural_network
IF OBJECT_ID(N'[dbo].[forecast_mapping_datarange]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].forecast_mapping_datarange (
		forecast_mapping_datarange_id	INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		forecast_mapping_id				INT REFERENCES forecast_mapping(forecast_mapping_id) NOT NULL,
		forecast_mapping_data_type		INT,
		value							VARCHAR(200),
		granularity						INT,
		[create_user]					VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]						DATETIME NULL DEFAULT GETDATE(),
		[update_user]					VARCHAR(50) NULL,
		[update_ts]						DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table [dbo].forecast_mapping_datarange EXISTS'
END

GO

IF OBJECT_ID('[dbo].[TRGUPD_forecast_mapping_datarange]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_forecast_mapping_datarange]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_forecast_mapping_datarange]
ON [dbo].[forecast_mapping_datarange]
FOR UPDATE
AS
    UPDATE forecast_mapping_datarange
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM forecast_mapping_datarange t
      INNER JOIN DELETED u ON t.forecast_mapping_datarange_id = u.forecast_mapping_datarange_id
GO