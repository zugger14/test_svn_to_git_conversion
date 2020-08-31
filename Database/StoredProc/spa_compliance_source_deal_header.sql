IF OBJECT_ID('[dbo].[spa_compliance_source_deal_header]','p') IS NOT NULL
DROP PROC [dbo].[spa_compliance_source_deal_header]
GO

CREATE PROC [dbo].[spa_compliance_source_deal_header]
@function_id		VARCHAR(1000),
@action_type		CHAR(1),
@id					VARCHAR(1000), -- e.g Deal Id
@source				VARCHAR(150) = NULL,
@success_error_flag	CHAR(1) = 's',
@msg				VARCHAR(8000)= NULL

AS

DECLARE @source_deal_header_id INT  

BEGIN TRY
	DECLARE cur_status CURSOR LOCAL FOR
	SELECT item from dbo.splitcommaseperatedvalues(@id)
		
	OPEN cur_status;

	FETCH NEXT FROM cur_status INTO @source_deal_header_id
	WHILE @@FETCH_STATUS = 0
	BEGIN
			
		EXEC spa_compliance_workflow @function_id, @action_type, @source_deal_header_id, @source, @success_error_flag, @msg
	
		FETCH NEXT FROM cur_status INTO @source_deal_header_id
	END;

	CLOSE cur_status;
	DEALLOCATE cur_status;	
	
	
END TRY
BEGIN CATCH
	IF CURSOR_STATUS('local', 'cur_status') >= 0 
	BEGIN
		CLOSE cur_status
		DEALLOCATE cur_status;
	END
END CATCH