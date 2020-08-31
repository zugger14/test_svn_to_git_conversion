IF OBJECT_ID(N'[dbo].[spa_status_rule_detail]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_status_rule_detail]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-03-27
-- Description: CRUD operations for table status_rule_detail

-- Params:
-- @flag CHAR(1) - Operation flag
-- @spa_status_rule_detail_id INT - status rule detail id,
-- @status_rule id INT - status rule id,
-- @event_id INT - event id,
-- @from_status_id INT - from status id,
-- @to_status_id INT - to status id,
-- @change_to_status_id INT - status id to be changed,
-- @workflow_activity_id INT - workflow id
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_status_rule_detail]
    @flag CHAR(1),
    @spa_status_rule_detail_id INT = NULL,
    @status_rule_id INT = NULL,
    @event_id INT = NULL,
    @from_status_id INT = NULL,
    @to_status_id INT = NULL,
    @change_to_status_id INT = NULL,
    @status_rule_type INT = NULL,
    @deal_header_fields VARCHAR(MAX) = NULL,
    @deal_detail_fields VARCHAR(MAX) = NULL,
    @open_deal_confirmation CHAR(1) = 'n',
    @open_deal_ticket CHAR(1) = 'n',
    @send_trader_notification CHAR(1) = 'n'
AS
IF @flag = 's'
BEGIN
	SELECT srd.status_rule_detail_id [ID],
		   srh.status_rule_name [Rule Name],
		   sdv1.code [Event],
		   sdv2.code [From Status],
		   sdv3.code [To Status],
		   sdv4.code [Change To Status]
	FROM   status_rule_detail srd
	INNER JOIN status_rule_header srh ON srh.status_rule_id = srd.status_rule_id
	LEFT JOIN static_data_value sdv1 ON srd.event_id = sdv1.value_id AND sdv1.[type_id] = 19500
	LEFT JOIN static_data_value sdv2 ON srd.from_status_id = sdv2.value_id AND sdv2.[type_id] = @status_rule_type
	LEFT JOIN static_data_value sdv3 ON srd.to_status_id = sdv3.value_id AND sdv3.[type_id] = @status_rule_type
	LEFT JOIN static_data_value sdv4 ON srd.Change_to_status_id = sdv4.value_id AND sdv4.[type_id] = @status_rule_type 
	WHERE srd.status_rule_id = @status_rule_id
END
ELSE IF @flag = 'a'
BEGIN
    SELECT srd.status_rule_detail_id,
		   srd.status_rule_id,
		   srd.event_id,
		   srd.from_status_id,
		   srd.to_status_id,
		   srd.Change_to_status_id,
		   srd.workflow_activity_id,
		   srd.update_fields,
		   srd.update_fields_detail,
		   srd.open_deal_confirmation,
		   srd.open_deal_ticket,
		   srd.send_trader_notification
	FROM   status_rule_detail srd
    WHERE srd.status_rule_detail_id = @spa_status_rule_detail_id
END
ELSE IF @flag = 'i'
BEGIN
    BEGIN TRY
    	INSERT INTO status_rule_detail (
    		status_rule_id,
    		event_id,
    		from_status_id,
    		to_status_id,
    		Change_to_status_id,
    		update_fields,
    		update_fields_detail,
    		open_deal_confirmation,
    		open_deal_ticket,
    		send_trader_notification
		)
		VALUES (
    		@status_rule_id,
    		@event_id,
    		@from_status_id,
    		@to_status_id,
    		@change_to_status_id,
    		@deal_header_fields,
    		@deal_detail_fields,
    		@open_deal_confirmation,
    		@open_deal_ticket,
    		@send_trader_notification
		) 
    	
    	EXEC spa_ErrorHandler 0,
    	     'status_rule_detail',
    	     'spa_status_rule_detail',
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
			 'status_rule_detail',
			 'spa_status_rule_detail',
			 'Error',
			 @desc,
			 @err_msg
    END CATCH
END

ELSE IF @flag = 'u'
BEGIN
    BEGIN TRY
    	UPDATE status_rule_detail
    	SET    status_rule_id = @status_rule_id,
    	       event_id = @event_id,
    	       from_status_id = @from_status_id,
    	       to_status_id = @to_status_id,
    	       Change_to_status_id = @change_to_status_id,
    	       update_fields =  @deal_header_fields,
    	       update_fields_detail = @deal_detail_fields,
    	       open_deal_confirmation = @open_deal_confirmation,
    		   open_deal_ticket = @open_deal_ticket,
    		   send_trader_notification = @send_trader_notification
    	WHERE  status_rule_detail_id = @spa_status_rule_detail_id
    	
    	EXEC spa_ErrorHandler 0,
    	     'status_rule_detail',
    	     'spa_status_rule_detail',
    	     'Success',
    	     'Data Successfully Saved.',
    	     ''
	END TRY
    BEGIN CATCH
		DECLARE @desc1    VARCHAR(500)
		DECLARE @err_no1  INT
		DECLARE @err_msg1 VARCHAR(200)
		SET @err_msg1 = ERROR_MESSAGE()
	    	
		SET @desc = 'Fail to insert Data ( Errr Description:' + @err_msg1 + ').'
		
		SELECT @err_no1 = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no1,
			 'status_rule_detail',
			 'spa_status_rule_detail',
			 'Error',
			 @desc1,
			 @err_msg1
    END CATCH
END
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		DELETE 
		FROM   status_rule_detail
		WHERE  status_rule_detail_id = @spa_status_rule_detail_id
		
		EXEC spa_ErrorHandler 0,
		     'status_rule_detail',
		     'spa_status_rule_detail',
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
		     'Deletion failed due to presence of data on workflow table.',
		     @err_msg2
	END CATCH 
	
	
    
END