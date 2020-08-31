IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_rfx_check_data_source]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_rfx_check_data_source]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ============================================================================================================================
-- Create date: 2012-09-11
-- Author : ssingh@pioneersolutionsglobal.com
-- Description:Checks and Validates the TSQL passed from the application. 
               
-- Params:
-- @data_source_tsql			VARCHAR(MAX) : sql statement passed from the application 
-- @data_source_alias			VARCHAR(50) : alias given to the sql statement 
-- @criteria					VARCHAR(5000) : parameter and their values 
-- @data_source_process_id		VARCHAR(50) : process_id passed 
-- ============================================================================================================================

CREATE PROCEDURE [dbo].[spa_rfx_check_data_source]
	@data_source_tsql				VARCHAR(MAX)= NULL
	, @data_source_alias			VARCHAR(50) = NULL
	, @criteria						VARCHAR(5000) = NULL
	, @data_source_process_id		VARCHAR(50) = NULL
AS

/*-------------------------------------------------Test Script-------------------------------------------------------*/
/*
 DECLARE
	@criteria				varchar(5000) = NULL
	, @process_id			varchar(50) = NULL
	, @data_source_tsql		VARCHAR(MAX) = NULL
	, @data_source_alias	VARCHAR(50) = NULL
	, @validate				BIT = 0	
	
	set @process_id  = '118422'
	SET @data_source_tsql 
	= '--[__batch_report__]   
	SELECT  template_id,template_name FROM  source_deal_header_template WHERE template_id = 1 '
	--SET @sql_source_tsql 
	--= 'SELECT  template_id,template_name FROM  source_deal_header_template WHERE template_id = 1 '
	SET @data_source_alias = 'test'
	SET @validate = 1
	                     
--*/
/*-------------------------------------------------Test Script END -------------------------------------------------------*/

BEGIN TRY
	EXEC spa_rfx_handle_data_source
		@data_source_tsql			
		, @data_source_alias		
		, @criteria					
		, @data_source_process_id	
		, 1		--@validate					
		, 1		--@handle_single_line_sql	

	EXEC spa_ErrorHandler 0,'spa_rfx_check_data_source', 
		'spa_rfx_check_data_source','Success', 
		'Report Writer query is valid.','Success'
END TRY
BEGIN CATCH
	DECLARE @error_msg VARCHAR(1000)
	SET @error_msg = ERROR_MESSAGE()
	
	EXEC spa_print 'ERROR in [spa_rfx_check_data_source]: ' --+ @error_msg

	EXEC spa_ErrorHandler -1, 'spa_rfx_check_data_source', 
			'spa_rfx_check_data_source', 'Error', 
			@error_msg, 'Error'
END CATCH












