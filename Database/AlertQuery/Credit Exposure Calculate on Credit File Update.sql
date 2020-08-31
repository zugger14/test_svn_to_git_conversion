IF EXISTS (SELECT 1 FROM adiha_process.sys.tables WHERE [name] = 'alert_counterparty_process_id_ac')
BEGIN
	IF EXISTS(SELECT 1 FROM staging_table.alert_counterparty_process_id_ac)
	BEGIN
		DECLARE @user_name VARCHAR(50)
		SET @user_name= dbo.fnadbuser()
		DECLARE @set_up_as_of_date VARCHAR(20)
		SELECT @set_up_as_of_date = as_of_date FROM module_asofdate
		DECLARE @counterparty_id VARCHAR(20)
		SELECT @counterparty_id = counterparty_id FROM staging_table.alert_counterparty_process_id_ac
		EXEC spa_Calc_Credit_Netting_Exposure @set_up_as_of_date, @user_name, 4500, NULL, NULL, NULL, @counterparty_id, 'n', 'n', 'n', 0, NULL, NULL, NULL
	END
END