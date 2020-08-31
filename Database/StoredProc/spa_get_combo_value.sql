IF OBJECT_ID(N'[dbo].[spa_get_combo_value]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_get_combo_value]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: arai@pioneersolutionsglobal.com
-- Create date: 2015-07-08
-- Description: Return the value of combo reference to another combo
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- @combo_id - Hold the combo id
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_get_combo_value]
    @flag CHAR(1),
	@combo_id VARCHAR(MAX) = NULL

AS 
SET NOCOUNT ON
	DECLARE @SQL VARCHAR(MAX)
	
	IF @flag = 'c'
	BEGIN
	    SET @SQL = 
	        'SELECT contract_id, [contract_name] FROM contract_group where contract_id in (select contract_id from counterparty_contract_address where counterparty_id in ('
	        + @combo_id + '))'
	    
	    EXEC (@sql)
	    RETURN
	END
	
	IF @flag = 'x'
	BEGIN
	    SET @SQL = 
	        'SELECT value_id, code from static_data_value where type_id = ' + @combo_id
	    
	    EXEC (@sql)
	    RETURN
	END
	
	IF @flag = 'r'
	BEGIN
	    SET @sql = 
	        'SELECT [type_id], [type_name] FROM static_data_type sdt WHERE sdt.[type_id] IN (10097,10098, 11099, 11100, 11101, 11102)'
	    
	    EXEC (@sql)
	    RETURN
	END
	
	IF @flag = 'm'
	BEGIN
	    SET @sql = 
	        'SELECT [value_id], code FROM static_data_value WHERE [type_id] = ' 
	        + @combo_id
	    
	    EXEC (@sql)
	    RETURN
	END

	IF @flag = 'h'
	BEGIN
		SELECT 'y' as [id], 'Yes' [value] UNION ALL SELECT 'n' as [id], 'No' [value]
	END

	IF @flag = 'y'
	BEGIN
	    SET @sql = 'SELECT ''f'', ''Finalized'' UNION ALL SELECT ''e'', ''Estimate'''
	    EXEC (@sql)
	    RETURN
	END






