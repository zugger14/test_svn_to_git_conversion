IF OBJECT_ID(N'[dbo].[spa_run_monte_carlo_model]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_run_monte_carlo_model
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2011-06-06
-- Description: Select curve name

-- Params:
-- @flag CHAR(1) - Operation flag
-- @curve_ids VARCHAR - Curve IDs
-- ===========================================================================================================
CREATE PROCEDURE [dbo].spa_run_monte_carlo_model
    @flag CHAR(1),
    @curve_ids VARCHAR(MAX) = NULL
AS
SET NOCOUNT ON
IF @flag = 's'
BEGIN
	SELECT DISTINCT spcd.source_curve_def_id,
	       spcd.curve_name   AS [Curve Name],
	       spcd.curve_id	 AS [Curve ID],
	       spcd.curve_des    AS [Description],
	       granularity.code  AS [Granularity],
	       sdv.code			 AS [Curve Type],
	       mcmp.monte_carlo_model_parameter_name AS [Simulation Model]
	FROM source_price_curve_def spcd
		INNER JOIN static_data_value granularity ON  granularity.value_id = spcd.Granularity
		INNER  JOIN static_data_value sdv ON sdv.value_id = spcd.source_curve_type_value_id
	    INNER JOIN monte_carlo_model_parameter mcmp ON  mcmp.monte_carlo_model_parameter_id = spcd.monte_carlo_model_parameter_id
	ORDER BY spcd.curve_name, spcd.source_curve_def_id ASC
END
GO