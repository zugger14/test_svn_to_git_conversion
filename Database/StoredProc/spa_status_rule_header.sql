IF OBJECT_ID(N'[dbo].[spa_status_rule_header]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_status_rule_header]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-03-27
-- Description: CRUD operations for table status_rule_header

-- Params:
-- @flag CHAR(1) - Operation flag
-- @status_rule_header_id INT - status rule id,
-- @status_rule_name VARCHAR(100) - status rule name,
-- @status_rule_type INT - status rule type,
-- @status_rule_desc VARCHAR(500) - status rule description,
-- @default CHAR(1) - default flag y - defalut, n - not default
-- @active CHAR(1) - active flag - y - active, n - not active
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_status_rule_header]
    @flag CHAR(1),
    @status_rule_header_id INT = NULL,
    @status_rule_name VARCHAR(100) = NULL,
    @status_rule_type INT = NULL,
    @status_rule_desc VARCHAR(500) = NULL,
    @default CHAR(1) = NULL,
    @active CHAR(1) = NULL
AS

IF @flag = 's'
BEGIN
    SELECT srh.status_rule_id [ID],
           srh.status_rule_name [Rule Name],
           sdv.[type_name] [Rule Type],
           srh.status_rule_desc [Rule Description],
           srh.[active] [Active],
           srh.[default] [Default],
           srh.status_rule_type [Status Rule Type]   -- hidden column
    FROM   status_rule_header srh LEFT JOIN static_data_type sdv ON sdv.[type_id] = srh.status_rule_type
END
ELSE IF @flag = 'a'
BEGIN
    SELECT srh.status_rule_id,
           srh.status_rule_name,
           srh.status_rule_type,
           srh.status_rule_desc,
           srh.[active],
           srh.[default]
    FROM   status_rule_header srh
    WHERE srh.status_rule_id = @status_rule_header_id
END
ELSE IF @flag = 'i'
BEGIN
    BEGIN TRY
    	INSERT INTO status_rule_header (
			status_rule_type,
			status_rule_name,
			status_rule_desc,
			[active],
			[default]
		)
		VALUES (
			@status_rule_type
			, @status_rule_name
			, @status_rule_desc
			, @active
			, @default
	    	
		) 
    	
    	EXEC spa_ErrorHandler 0,
    	     'status_rule_header',
    	     'spa_status_rule_header',
    	     'Success',
    	     'Data Successfully Saved.',
    	     ''
	END TRY
    BEGIN CATCH
		DECLARE @desc    VARCHAR(500)
		DECLARE @err_no  INT
		DECLARE @err_msg VARCHAR(200)
		SET @err_msg = ERROR_MESSAGE()
	    	
		SET @desc = 'Fail to insert Data ( Errr Description:' + @err_msg + ').'
		
		SELECT @err_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no,
			 'status_rule_header',
			 'spa_status_rule_header',
			 'Error',
			 @desc,
			 @err_msg
    END CATCH
END

ELSE IF @flag = 'u'
BEGIN
    BEGIN TRY
    	UPDATE status_rule_header
    	SET    status_rule_type = @status_rule_type,
    	       status_rule_name = @status_rule_name,
    	       status_rule_desc = @status_rule_desc,
    	       [active] = @active,
    	       [default] = @default
    	WHERE  status_rule_id = @status_rule_header_id 
    	
    	EXEC spa_ErrorHandler 0,
    	     'status_rule_header',
    	     'spa_status_rule_header',
    	     'Success',
    	     'Data Successfully Saved.',
    	     ''
	END TRY
    BEGIN CATCH
		DECLARE @desc1    VARCHAR(500)
		DECLARE @err_no1  INT
		DECLARE @err_msg1 VARCHAR(200)
		SET @err_msg1 = ERROR_MESSAGE()
	    	
		SET @desc1 = 'Fail to insert Data ( Errr Description:' + @err_msg1 + ').'
		
		SELECT @err_no1 = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no1,
			 'status_rule_header',
			 'spa_status_rule_header',
			 'Error',
			 @desc1,
			 @err_msg1
    END CATCH    
END
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		DELETE 
		FROM   status_rule_header
		WHERE  status_rule_id = @status_rule_header_id
		
		EXEC spa_ErrorHandler 0,
		     'status_rule_header',
		     'spa_status_rule_header',
		     'Success',
		     'Data Successfully Deleted.',
		     ''
	END TRY
	BEGIN CATCH
		DECLARE @err_msg2 VARCHAR(200)
		SET @err_msg2 = ERROR_MESSAGE()
		EXEC spa_ErrorHandler -1,
		     'status_rule_header',
		     'spa_status_rule_header',
		     'DB Error',
		     'Deletion failed due to presence of data on detail table.',
		     @err_msg2
	END CATCH    
END