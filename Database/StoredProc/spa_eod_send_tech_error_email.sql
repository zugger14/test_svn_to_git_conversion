IF OBJECT_ID(N'[dbo].[spa_eod_send_tech_error_email]', N'P') IS NOT NULL
    DROP PROC [dbo].[spa_eod_send_tech_error_email]
GO

-- ============================================================================================================================
-- Author: Pawan Adhikari
-- Create date: 2012-03-09 08:45PM
-- Description: Insert EOD Process error messages into email notes, to be mailed later.
--              
-- Params:
-- @params varchar(20) - Specific Email Parameters
-- @detail_status varchar(100) - Detailed Message
-- ============================================================================================================================
CREATE PROC [dbo].[spa_eod_send_tech_error_email]
	@params VARCHAR(8000),
	@detail_status VARCHAR(5000)
AS
BEGIN
	EXEC spa_email_notes 
	     @flag = 'b',
	     @role_type_value_id = 6,
	     @email_module_type_value_id = 17802,
	     @send_status = 'n',
	     @active_flag = 'y',
	     @template_params = @params,
	     @attachment_file_name = @detail_status
END

