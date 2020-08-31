IF OBJECT_ID(N'[dbo].[spa_deal_status_privilege_mapping]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_deal_status_privilege_mapping]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-05-16
-- Description: CRUD operations for table deal_status_privilege_mapping

-- Params:
-- @flag CHAR(1) - Operation flag
-- @deal_status_privilege_mapping_id INT  - deal_status_privilege_mapping_id - primary key of table @deal_status_privilege_mapping
-- @from_status_value_id INT - deal status id 
-- @to_status_value_id INT - deal status id
-- ============================================================================================================================
CREATE PROCEDURE [dbo].[spa_deal_status_privilege_mapping]
    @flag CHAR(1),
    @deal_status_privilege_mapping_id INT = NULL,
    @from_status_value_id INT = NULL,
    @to_status_value_id INT = NULL
AS
BEGIN
	DECLARE @desc VARCHAR(500)
	DECLARE @err_no INT
	DECLARE @err_msg VARCHAR(200)
	
	IF @flag = 'i'
	BEGIN
		BEGIN TRY
    		INSERT INTO deal_status_privilege_mapping (from_status_value_id, to_status_value_id)
    		VALUES (@from_status_value_id, @to_status_value_id)
    	
    		EXEC spa_ErrorHandler 0,
    		     'deal_status_privilege_mapping',
    		     'spa_deal_status_privilege_mapping',
    		     'Success',
    		     'Privileges successfully mapped.',
    		     ''
		END TRY
		BEGIN CATCH
			SET @err_msg = ERROR_MESSAGE()
		    SET @desc = 'Fail to insert Data ( Errr Description:' + @err_msg + ').'
			SELECT @err_no = ERROR_NUMBER()
			
			EXEC spa_ErrorHandler @err_no,
			     'deal_status_privilege_mapping',
			     'spa_deal_status_privilege_mapping',
			     'Error',
			     @desc,
			     @err_msg
		END CATCH         
	END
	ELSE IF @flag = 'u'
	BEGIN
		BEGIN TRY
    		UPDATE deal_status_privilege_mapping
    		SET from_status_value_id = @from_status_value_id,
    			to_status_value_id = @to_status_value_id
    		WHERE deal_status_privilege_mapping_id = @deal_status_privilege_mapping_id    			
    	
    	EXEC spa_ErrorHandler 0,
    		     'deal_status_privilege_mapping',
    		     'spa_deal_status_privilege_mapping',
    		     'Success',
    		     'Privileges successfully mapped.',
    		     ''
		END TRY
		BEGIN CATCH
			SET @err_msg = ERROR_MESSAGE()
		    SET @desc = 'Fail to update Data ( Errr Description:' + @err_msg + ').'
			SELECT @err_no = ERROR_NUMBER()
			
			EXEC spa_ErrorHandler @err_no,
				 'deal_status_privilege_mapping',
			     'spa_deal_status_privilege_mapping',
			     'Error',
			     @desc,
			     @err_msg
		END CATCH
	END
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRY
			DELETE 
			FROM   deal_status_privilege_mapping
			WHERE  deal_status_privilege_mapping_id = @deal_status_privilege_mapping_id
			
			EXEC spa_ErrorHandler 0,
				 'deal_status_privilege_mapping',
				 'spa_deal_status_privilege_mapping',
				 'Success',
				 'Data Successfully Deleted.',
				 ''
		END TRY
		BEGIN CATCH
			SET @err_msg = ERROR_MESSAGE()
			EXEC spa_ErrorHandler -1,
				 'deal_status_privilege_mapping',
				 'spa_deal_status_privilege_mapping',
				 'DB Error',
				 'Deletion failed.',
				 @err_msg
		END CATCH
	END
	ELSE IF @flag = 's'
	BEGIN
		SELECT dspm.deal_status_privilege_mapping_id [ID],
		       sdv1.code [From Status],
		       sdv2.code [To Status]
		FROM   deal_status_privilege_mapping dspm
		LEFT JOIN static_data_value sdv1 ON sdv1.value_id = dspm.from_status_value_id
		LEFT JOIN static_data_value sdv2 ON sdv2.value_id = dspm.to_status_value_id
	END
	ELSE IF @flag = 'a'
	BEGIN
		SELECT dspm.deal_status_privilege_mapping_id,
		       dspm.from_status_value_id,
		       dspm.to_status_value_id
		FROM   deal_status_privilege_mapping dspm
		WHERE dspm.deal_status_privilege_mapping_id = @deal_status_privilege_mapping_id
	END
END
