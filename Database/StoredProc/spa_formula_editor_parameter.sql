IF OBJECT_ID(N'[dbo].[spa_formula_editor_parameter]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_formula_editor_parameter]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_formula_editor_parameter]  
	@flag CHAR(1), 
    @formula_name VARCHAR(100)
AS

SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX)

IF @flag = 's'
BEGIN
	SET @sql = 'SELECT	fep.function_name AS [Formula Name],
						fep.field_label [Field Label],
						fep.field_type [Field Type],
						fep.default_value [Default Value],
						fep.tooltip [Tooltip],
						fep.field_size [Field Size],
						REPLACE(REPLACE(REPLACE(sql_string, '''''''', ''&col;''), '','', ''&comma;''), ''='', ''&eq;'') AS [Sql String],
						fep.is_required [Is Required],
						fep.is_numeric [Is Numeric],
						fep.custom_validation [Custom Validation],
						fep.sequence [Sequence],
						fep.blank_option [Blank Option]
	            FROM formula_editor_parameter fep
	            WHERE fep.function_name = ''' + @formula_name + '''
	            ORDER BY fep.sequence'
	 EXEC(@sql)
END
ELSE IF @flag = 'r'
BEGIN
	SET @sql = 'SELECT ds.name [Formula Name],
					   dsc.alias [Field Label],
					   CASE WHEN dsc.widget_id = 1 THEN ''t''
							WHEN dsc.widget_id = 2 THEN ''d''
							ELSE ''t''
					   END [Field Type],
					   dsc.param_default_value [Default Value],
					   dsc.tooltip [Tooltip],
					   NULL [Field Size],
					   REPLACE(REPLACE(REPLACE(dsc.param_data_source, '''''''', ''&col;''), '','', ''&comma;''), ''='', ''&eq;'') AS [Sql String],
					   dsc.reqd_param [Is Required],
					   NULL [Is Numeric],
					   NULL [Custom Validation],
					   NULL [Sequence],
					   dsc.reqd_param [Blank Option]		
	           FROM data_source_column dsc
			   INNER JOIN data_source ds
				ON ds.data_source_id = dsc.source_id
	           WHERE dsc.required_filter = 1 AND  
			   ds.name = ''' + @formula_name + '''
	           --ORDER BY fep.sequence
			   '
	 EXEC(@sql)
END