IF OBJECT_ID('spa_import_data_enhancement_for_accrual','P') IS NOT NULL
	DROP PROC spa_import_data_enhancement_for_accrual
GO

CREATE PROCEDURE [dbo].[spa_import_data_enhancement_for_accrual]
	@default CHAR(1) = '',
	@batch_process_id VARCHAR(100) = NULL,
	@batch_report_param VARCHAR(MAX) = NULL-- Dummy variables
AS
BEGIN	
	DECLARE @user_login_id VARCHAR(100), @msg VARCHAR(100)
	SET @user_login_id = dbo.FNADBUser()
	SET @msg = 'Import Data Enhancement For Accrual run successfully.'
	
	IF NOT EXISTS(
			SELECT 1
			FROM   holiday_group hg
					INNER JOIN static_data_value sdv
						ON  sdv.value_id = hg.hol_group_value_id
			WHERE  sdv.code = 'NL Holiday'
					AND CAST(hg.hol_date AS DATE) = CAST(GETDATE() AS DATE)
		)
	BEGIN
		DECLARE @as_of_date VARCHAR(10) = CONVERT(CHAR(10), GETDATE(), 126) 
		EXEC spa_accural_data_enhancements @as_of_date
	END
		
	EXEC spa_message_board 'u', @user_login_id, NULL, 'Import Data Enhancement For Accrual' , @msg, '', '', 's', @msg, NULL , @batch_process_id		
	
END
GO