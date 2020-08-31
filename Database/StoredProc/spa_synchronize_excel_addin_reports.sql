IF OBJECT_ID('spa_synchronize_excel_addin_reports','P') IS NOT NULL
	DROP PROC spa_synchronize_excel_addin_reports
GO

CREATE PROCEDURE [dbo].[spa_synchronize_excel_addin_reports]
	@default CHAR(1) = '',
	@batch_process_id VARCHAR(100) = NULL,
	@batch_report_param VARCHAR(MAX) = NULL-- Dummy variables
AS
BEGIN	
	DECLARE @user_login_id VARCHAR(100), @msg VARCHAR(100)
	SET @user_login_id = dbo.FNADBUser()
	SET @msg = 'Snapshots sucessfully published to view report.'
	
	EXEC spa_synchronize_excel_reports '','n','y'
	
	EXEC spa_message_board 'u', @user_login_id, NULL, 'Excel Add-in Snapshots' , @msg, '', '', 's', @msg, NULL , @batch_process_id		
	
END
GO