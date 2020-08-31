IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[spa_calc_inventory_accounting_entries]') AND [type] IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_calc_inventory_accounting_entries]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_calc_inventory_accounting_entries] 
	@as_of_date VARCHAR(20),
	@as_of_date_to VARCHAR(20) = NULL,
	@account_group_id INT = NULL,
	@user_login_id VARCHAR(100) = NULL,
	@calc_forward CHAR(1) = 'n',
	@batch_process_id VARCHAR(120) = NULL,
	@batch_report_param VARCHAR(5000) = NULL
AS

SET NOCOUNT ON

BEGIN
	DECLARE @spa VARCHAR(500)
	DECLARE @job_name VARCHAR(100)

	IF @user_login_id IS NULL
		SET @user_login_id = dbo.FNADBUSER()


	IF @as_of_date = '' OR @as_of_date IS NULL
		SET @as_of_date = 'NULL'

	IF @as_of_date_to = '' OR @as_of_date_to IS NULL
		SET @as_of_date_to = @as_of_date

	IF @account_group_id IS NULL
		SET @account_group_id = ''

	IF @job_name IS NULL
		SET @job_name = 'Inventory_calc_' + @batch_process_id
  
	WHILE CAST(@as_of_date AS DATETIME) <= CAST(@as_of_date_to AS DATETIME)
	BEGIN
		SET @spa = 'spa_calc_inventory_accounting_entries_job ''' + @as_of_date + ''', ''' + @as_of_date + ''', ' + ISNULL(CAST(@account_group_id AS VARCHAR), 'NULL') + ', ''' + @batch_process_id + ''', ''' + @job_name + ''', ''' + @user_login_id + ''', ''' + @calc_forward + ''''
		EXEC (@spa)
		SET @as_of_date = DATEADD(DAY, 1, @as_of_date)
	END

	DECLARE @desc VARCHAR(1000)
	SET @desc = 'Inventory Accounting Caclulation completed for as of date ' + dbo.FNAUserDateFormat(@as_of_date, @user_login_id)

	EXEC spa_message_board 'u', @user_login_id, NULL, 'Inventory', @desc, '', '', 's', @job_name, @as_of_date, @batch_process_id

	EXEC spa_ErrorHandler 0, 'Inventory', 'process run', 'Status', 'Your process has been run and will complete shortly. Please check/refresh your message board.', ''
END