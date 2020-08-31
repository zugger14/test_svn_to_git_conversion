IF OBJECT_ID(N'[dbo].spa_conversion_factor', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_conversion_factor]

GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON 
GO

/**
	 General stored procedure for conversion factor.

	Parameters
		@flag :'k' - Return conversion factor data 
		@conversion_factor_id    : conversion factor id 
	
**/

CREATE PROCEDURE [dbo].[spa_conversion_factor]
	  @flag CHAR(1)
	, @conversion_factor_id INT = NULL
	
AS
 
SET NOCOUNT ON

/*
--Added for Debugging Purpose
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo
EXEC spa_print 'Use spa_print instead of PRINT statement in debug mode.'

DECLARE
	@flag CHAR(50)
--Drops all temp tables created in this scope.
EXEC spa_drop_all_temp_table
--*/
DECLARE @user_login_id NVARCHAR(25) = dbo.FNADBUser()

IF @flag = 'k'
BEGIN
    SELECT 
          cf.conversion_factor_id
        , sdv.code [conversion_value_id]
        ,  sdv.code + ' ' +'-'+ ' '+su.uom_id + ' '+ 'to'+ ' '+sul.uom_id AS from_uom
        , sul.uom_id AS to_uom
    FROM conversion_factor cf
    INNER JOIN source_uom su ON su.source_uom_id = cf.from_uom
    INNER JOIN source_uom sul ON sul.source_uom_id = cf.to_uom
    INNER JOIN static_data_value sdv on sdv.value_id = cf.conversion_value_id 
END

IF @flag = 'g'
BEGIN
	SELECT  
		  conversion_factor_detail_id
		, conversion_factor_id
		, effective_date
		, dbo.FNARemoveTrailingZero(factor) 
        , actual_forecast
	FROM  conversion_factor_detail WHERE conversion_factor_id = @conversion_factor_id
END
GO

