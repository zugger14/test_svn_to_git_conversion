IF OBJECT_ID(N'[testing].[spa_pre_post_configuration]' ,N'P') IS NOT NULL
    DROP PROCEDURE [testing].[spa_pre_post_configuration]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===============================================================================================================
-- Author: rkhatiwada@pioneersolutionsglobal.com
-- Create date: 2012-11-20
-- Description: This proc will be used to perform select, insert, update and delete from generic_mapping_header table
-- Params:
-- @flag CHAR(1) - Operation flag 
--		flags used:	's' --> for selecting desired data to display	
--					'a'	--> to display the data in details grid
--					'i'	--> for inserting the data in pre_post_configuration table
-- ===============================================================================================================

CREATE PROCEDURE [testing].[spa_pre_post_configuration]
	@flag CHAR(1),
	@row_id INT = NULL,
	@module_value_id INT = NULL,
	@tbl_name VARCHAR(150) = NULL,
	@descrptn VARCHAR(1000) = NULL,
	@unique_clms VARCHAR(500) = NULL,
	@compare_clms VARCHAR(500) = NULL,
	@display_clms VARCHAR(500) = NULL,
	@exec_sp VARCHAR(MAX) = NULL,
	@re_calc_sp VARCHAR(MAX) = NULL,
	@as_of_date_filter_clm VARCHAR(50) = NULL,
	@deal_filter_clm VARCHAR(100) = NULL,
	@order_by_clm_index VARCHAR(50) = NULL,
	@regression_group_value_id INT = NULL
AS
	IF @flag='s'
	BEGIN
		DECLARE @sql_str VARCHAR(8000)
	    SET @sql_str = 'SELECT row_id
						  ,sdv.[description] [Module]
						  ,tbl_name [Table Name]
						  ,descrptn [Description]	          
						  ,compare_clms [Compare Columns]
						  ,display_clms [Display Columns]
						  ,sdv1.code [Regression Group]    
					FROM   testing.pre_post_configuration ppc
					LEFT JOIN static_data_value sdv ON ppc.module_value_id = sdv.value_id
					LEFT JOIN static_data_value sdv1 ON ppc.regression_group_value_id = sdv1.value_id WHERE 1=1 '
		IF @module_value_id IS NOT NULL 
		BEGIN
			SET @sql_str = @sql_str + 'AND ppc.module_value_id = ' + CAST(@module_value_id AS VARCHAR(10))
		END	 
		IF @regression_group_value_id IS NOT NULL 
		BEGIN
			SET @sql_str = @sql_str + 'AND sdv1.value_id = ' + CAST(@regression_group_value_id AS VARCHAR(10))
		END
		exec spa_print @sql_str
		EXEC (@sql_str)
	END
	
	IF @flag='x'
	BEGIN
	    SELECT sdv.value_id
	          ,sdv.[description]
	    FROM   static_data_value sdv
	    WHERE  sdv.[type_id] = 22500
	END
	
	IF @flag = 'i'
	BEGIN 
		BEGIN TRY
		INSERT INTO testing.pre_post_configuration
		  (
		    module_value_id
		   ,tbl_name
		   ,descrptn
		   ,unique_clms
		   ,compare_clms
		   ,display_clms
		   ,exec_sp
		   ,re_calc_sp		   
		   ,deal_filter_clm
		   ,order_by_clm_index
		   ,regression_group_value_id
		   ,as_of_date_filter_clm
		  )
		VALUES
		  (
		  	@module_value_id,
		  	@tbl_name,
		  	@descrptn,
		  	@unique_clms,
		  	@compare_clms,
		  	@display_clms,
		  	@exec_sp,
		  	@re_calc_sp,		  	
		  	@deal_filter_clm,
		  	@order_by_clm_index,
		  	@regression_group_value_id,
			@as_of_date_filter_clm
		  )
		  EXEC spa_ErrorHandler 0
			 , 'pre_post_configuration'
			 , 'spa_pre_post_configuration'
			 , 'Success'
			 , 'Data Successfully Inserted.'
			 , '' 
	END TRY
	BEGIN CATCH		
		EXEC spa_ErrorHandler -1
			 , ''
			 , 'spa_pre_post_configuration'
			 , 'Error'
			 , ''
			 , ''
	END CATCH
	END
	
	IF @flag = 'a'
	BEGIN
		SELECT * FROM testing.pre_post_configuration WHERE row_id = @row_id 
	END
	
	IF @flag = 'd'
	BEGIN
		DELETE FROM testing.pre_post_configuration WHERE row_id = @row_id
	END
	
	IF @flag = 'u'
	BEGIN
		BEGIN TRY
		UPDATE testing.pre_post_configuration
		SET 
			module_value_id = @module_value_id,
			tbl_name = @tbl_name,
			descrptn = @descrptn,
			unique_clms = @unique_clms,
			compare_clms = @compare_clms,
			display_clms = @display_clms,
			exec_sp = @exec_sp,
			re_calc_sp = @re_calc_sp,			
			deal_filter_clm = @deal_filter_clm,
			order_by_clm_index = @order_by_clm_index,
			regression_group_value_id = @regression_group_value_id,
			as_of_date_filter_clm = @as_of_date_filter_clm
		WHERE row_id = @row_id
		EXEC spa_ErrorHandler 0
			 , 'pre_post_configuration'
			 , 'spa_pre_post_configuration'
			 , 'Success'
			 , 'Data Successfully Updated.'
			 , '' 
	END TRY
	BEGIN CATCH		
		EXEC spa_ErrorHandler -1
			 , ''
			 , 'spa_pre_post_configuration'
			 , 'Error'
			 , ''
			 , ''
	END CATCH
	END
	IF @flag = 'v'
	BEGIN
		SELECT sdv.value_id, sdv.code FROM static_data_value sdv WHERE sdv.[type_id] = 23800
	END