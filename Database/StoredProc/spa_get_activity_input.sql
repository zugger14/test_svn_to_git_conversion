/****** Object:  StoredProcedure [dbo].[spa_get_activity_input]    Script Date: 06/17/2009 21:21:05 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_activity_input]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_activity_input]
/****** Object:  StoredProcedure [dbo].[spa_get_activity_input]    Script Date: 06/17/2009 21:21:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
  spa_get_activity_input 'rwe'
 */
CREATE PROC [dbo].[spa_get_activity_input]
	@user_login_id VARCHAR(100)
AS
BEGIN
	DECLARE @sql_stmt VARCHAR(1000)
	DECLARE @listCol VARCHAR(500)
	DECLARE @listCol_max VARCHAR(500)
	
	SELECT 
		rpfm.risk_description_id,
		rpfd.publish_table_id,	
		rg.generator_id,
		eis.ems_source_input_id,
		rg.[name],
		eis.input_name,
		eis.char_applies,
		su.source_uom_id, 
		su.uom_name UOM,
		sdv.code InputOutput,
		rpfd.sequence_number,
		rpfd.risk_control_id,
		rpfd.incr_id
	INTO #temp
			
	FROM	
		process_risk_description prd
		INNER JOIN risk_process_function_map rpfm ON prd.risk_description_id=rpfm.risk_description_id
		INNER JOIN risk_process_function_map_detail rpfd ON rpfd.function_map_id=rpfm.function_map_id
		LEFT JOIN rec_generator rg ON rg.generator_id=rpfd.column_value AND publish_table_id=4
		LEFT JOIN ems_source_input eis ON eis.ems_source_input_id=rpfd.column_value AND publish_table_id=8
		LEFT JOIN source_uom su ON su.source_uom_id=eis.uom_id
		LEFT JOIN static_data_value sdv ON sdv.value_id=eis.input_output_id
	WHERE
		rpfd.publish_table_id IN (4,8)	



	SELECT 
		MAX(generator_id) [Generator ID],
		MAX(ems_source_input_id)[Input ID],
		MAX([name])[Source],
		MAX(input_name) [Input],			
		MAX(char_applies) [Char Applies],
		MAX (source_uom_id)[UOM ID],
		MAX(UOM) [UOM],
		MAX(InputOutput) [Input/Output]
	FROM #temp
	
	GROUP BY 
		incr_id
		
END