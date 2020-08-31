IF OBJECT_ID(N'[dbo].[spa_import_source_list]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_import_source_list]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================================================================================================
-- Author: Pawan Adhikari
-- Create date: 2012-03-09 08:45PM
-- Description: EOD Log Process Status.
--              
-- Params:
-- @flag char(1) - flag
-- ============================================================================================================================
CREATE PROCEDURE [dbo].[spa_import_source_list]
	@flag CHAR(1),
	@process_id VARCHAR(100) = NULL,
	@data_source_alias VARCHAR(25) = NULL
	
AS

DECLARE @sql VARCHAR(MAX)
DECLARE @source VARCHAR(600)

IF @flag = 's'
BEGIN
	
	SET @sql = 'SELECT sdv.[type_id],
						sdv.value_id,
					   sdv.code,
					   sdv.[description]
				FROM   static_data_value sdv
				INNER JOIN external_source_import esi ON  esi.data_type_id = sdv.value_id
				WHERE  sdv.[type_id] = 4000
				
		union all
				SELECT sdv.[type_id],
						sdv.value_id,
					   sdv.code,
					   sdv.[description]
				FROM   static_data_value sdv
				WHERE  sdv.[value_id] = 4054				
				'

				--UNION ALL

				--SELECT s.[type_id],
				--		s.value_id,
				--	   s.code,
				--	   s.[description]
				--FROM   static_data_value s
				--WHERE  s.type_id = 5450
				--AND entity_id IS NULL
				--AND value_id NOT IN (5457, 5463, 5458, 5453, 5454, 5461, 5456, 5464, 5466, 5455, 5459, 5462, 5460)
				--ORDER BY code'

	EXEC spa_print @sql
	EXEC(@sql)
END
IF @flag = 'a' -- used in Implied Volatility Calculation - Edit - Load From CSV; to populate grid from loaded CSV file
BEGIN
	SET @process_id = ISNULL(@process_id, dbo.FNAGetNewID())
	SET @data_source_alias = ISNULL(@data_source_alias, 'i')
	DECLARE @param_table VARCHAR(200) = 'adiha_process.dbo.temp_import_data_table_' + @data_source_alias + '_' + @process_id

	IF OBJECT_ID(@param_table, N'U') IS NULL
	BEGIN
		SELECT NULL
	END
	ELSE
	BEGIN
		EXEC(' SELECT 
			   CASE t.options WHEN ''Call'' THEN ''c'' WHEN ''Put'' THEN ''p'' ELSE NULL END [options], 
			   CASE t.[Exercise Type] WHEN ''European'' THEN ''e'' WHEN ''American'' THEN ''a'' ELSE NULL END [Exercise Type], 
			   sc.source_commodity_id [commodity_id], spcd.source_curve_def_id [Index], cast(t.term as datetime) Term, cast(t.Expiration as datetime) Expiration, t.Strike, t.Premium, t.Seed 
		       FROM ' + @param_table + ' t 
			   LEFT JOIN source_commodity sc ON sc.commodity_id = t.commodity
			   LEFT JOIN source_price_curve_def spcd ON spcd.curve_name = t.[index]
		  ')

	END

END


 