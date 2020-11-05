IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_user_application_log]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_user_application_log]
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO


CREATE procedure [dbo].[spa_user_application_log]
	@flag				CHAR(1),
	@date_from			NVARCHAR(20),
    @date_to			NVARCHAR(20),
    @user_login_id_1	NVARCHAR(100) = NULL, 
    @function_id		INT = NULL,
	@product_id			INT = 10000000,
    @batch_process_id 	VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL,
	@enable_paging 		INT = 0, 
	@page_size 			INT = NULL,
	@page_no 			INT = NULL
	
	AS
	BEGIN
		SET NOCOUNT ON
	
	/*******************************************1st Paging Batch START**********************************************/
	DECLARE @str_batch_table VARCHAR(8000)
	DECLARE @user_login_id VARCHAR(50)
	DECLARE @sql_paging VARCHAR(8000)
	DECLARE @is_batch bit
			 
	SET @str_batch_table = ''
	SET @user_login_id = dbo.FNADBUser() 

	SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END		

	IF @is_batch = 1
		SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)

	IF @enable_paging = 1 --paging processing
	BEGIN
		IF @batch_process_id IS NULL
			SET @batch_process_id = dbo.FNAGetNewID()
		
		SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)

		--retrieve data from paging table instead of main table
		IF @page_no IS NOT NULL  
		BEGIN
			SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no)    
			EXEC (@sql_paging)  
			RETURN  
		END
	END
	/*******************************************1st Paging Batch END**********************************************/ 
	DECLARE @sql VARCHAR(MAX)
	DECLARE @url            VARCHAR(500)
	DECLARE @desc           VARCHAR(500)
	DECLARE @url_deal       VARCHAR(500)


	IF @flag = 'r'
	BEGIN		
		SET @sql = 'SELECT 
						au.user_f_name + '' '' + CASE WHEN au.user_m_name IS NOT NULL THEN au.user_m_name + '' '' ELSE '''' END  + au.user_l_name + '' ('' + au.user_login_id + '')''				[User Name],
						ual.function_name  [Window Name],						
						dbo.FNAUserDateTimeFormat(ual.log_date, 1, dbo.FNAdbuser())										[Log Date/ Time]
					' + @str_batch_table + ' 				 
					FROM user_application_log ual
					INNER JOIN setup_menu sm ON sm.function_id = ual.function_id AND sm.product_category = ' + CAST(@product_id AS VARCHAR(15)) + '
					INNER JOIN application_users au ON au.user_login_id = ual.user_login_id
					--LEFT JOIN  application_functions af ON af.function_call = ual.instance_name
					LEFT JOIN  application_functions af1 ON af1.function_id = sm.parent_menu_id
					LEFT JOIN  application_functions af2 ON af2.function_id = af1.func_ref_id
					LEFT JOIN  application_functions af3 ON af3.function_id = af2.func_ref_id
					LEFT JOIN  application_functions af4 ON af4.function_id = af3.func_ref_id
					LEFT JOIN  setup_menu sm1 ON sm1.function_id = sm.parent_menu_id AND sm1.product_category = 10000000
					LEFT JOIN  setup_menu sm2 ON sm2.function_id = sm1.parent_menu_id AND sm2.product_category = 10000000
					LEFT JOIN  setup_menu sm3 ON sm3.function_id = sm2.parent_menu_id AND sm3.product_category = 10000000
					WHERE 1=1 ' 
		            
		IF @user_login_id_1 IS NOT NULL
		BEGIN
			SET @sql = @sql + ' AND ual.user_login_id = ''' + @user_login_id_1 + ''''
		END
		
		IF @function_id IS NOT NULL
		BEGIN
			SET @sql = @sql + 'AND (
								sm.function_id = ' + CAST(@function_id AS NVARCHAR) +'
								OR sm.parent_menu_id = ' + CAST(@function_id AS NVARCHAR) +' 
								OR af1.func_ref_id = ' + CAST(@function_id AS NVARCHAR) +'
								OR af2.func_ref_id = ' + CAST(@function_id AS NVARCHAR) +'
								OR af3.func_ref_id = ' + CAST(@function_id AS NVARCHAR) +'
								OR af4.func_ref_id = ' + CAST(@function_id AS NVARCHAR) +'
								OR sm1.function_id = ' + CAST(@function_id AS NVARCHAR) +'
								OR sm2.function_id = ' + CAST(@function_id AS NVARCHAR) +'
								OR sm3.function_id = ' + CAST(@function_id AS NVARCHAR) +'							
								)'
		END
		
		SET @sql = @sql + 'AND CONVERT(NVARCHAR(10), ual.log_date, 120) BETWEEN ISNULL(''' + @date_from + ''', ''1900-01-01'') AND ISNULL(''' + @date_to + ''', ''9999-01-01'')						  
						ORDER BY au.user_f_name, ual.log_date DESC'
						
		--PRINT @sql
		EXEC (@sql)
	END
	
	/*******************************************2nd Paging Batch START**********************************************/
	IF @is_batch = 1
	BEGIN
		SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)   
		EXEC(@str_batch_table)                   

		SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_user_application_log', 'User Activity Log Report')         
		EXEC(@str_batch_table)        
		RETURN
	END

	--if it is first call from paging, return total no. of rows and process id instead of actual data
	IF @enable_paging = 1 AND @page_no IS NULL
	BEGIN
	   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	   EXEC(@sql_paging)
	END
 
	/*******************************************2nd Paging Batch END**********************************************/
 
END
GO

