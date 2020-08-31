IF OBJECT_ID ('spa_counterparty_epa_account','p') IS NOT NULL 
	DROP PROC spa_counterparty_epa_account 
GO 

CREATE PROC dbo.spa_counterparty_epa_account 
	@flag CHAR(1),
	@counterparty_epa_account_id INT = NULL,
	@counterparty_id INT = NULL,
	@external_type_id INT = NULL,
	@external_value varchar(50) = NULL,
	@xml nvarchar(max) = NULL


AS 
SET NOCOUNT ON
BEGIN 
	/*
	--DECLARE @flag CHAR(1) = 'v',
	--@counterparty_epa_account_id INT = NULL,
	--@counterparty_id INT = NULL,
	--@external_type_id INT = NULL,
	--@external_value varchar(50) = NULL,
	--@xml varchar(5000) = '<Root><GridUpdate counterparty_epa_account_id = "2" counterparty_id="3835" external_type_id="2201" external_value="12"></GridUpdate><GridUpdate counterparty_epa_account_id = "3" counterparty_id="3835" external_type_id="2200" external_value="10"></GridUpdate><GridDelete grid_id="4"></GridDelete><GridDelete grid_id="5"></GridDelete></Root>'
	*/
	DECLARE @sql_stmt VARCHAR(8000)
	,  @idoc INT

	IF @flag = 's'
	BEGIN 
		SELECT @sql_stmt = '

			SELECT counterparty_epa_account_id [Counterparty EPA Account ID],
			       sc.counterparty_name [Counterparty Name],
				   cea.external_type_id,
			       --sdv.code [External Type],
			       external_value [External Value],
			       cg.contract_id [Contract]
			FROM   dbo.counterparty_epa_account cea
			       JOIN dbo.source_counterparty sc ON  sc.source_counterparty_id = cea.counterparty_id
			       JOIN dbo.static_data_value sdv ON  sdv.value_id = cea.external_type_id 
			       left JOIN dbo.contract_group cg ON cg.contract_id = cea.contract_id
			WHERE 1=1 AND cea.counterparty_id = ' + CAST(ISNULL(@counterparty_id, '') AS VARCHAR) 

	
	EXEC (@sql_stmt) 
	
	END  
	ELSE IF @flag = 'a'
	BEGIN 
		SELECT counterparty_epa_account_id, counterparty_id, external_type_id, external_value FROM counterparty_epa_account
		WHERE counterparty_epa_account_id = @counterparty_epa_account_id
		
	END  
	ELSE IF @flag = 'i'
	BEGIN 
		INSERT INTO counterparty_epa_account (counterparty_id, external_type_id, external_value)
		VALUES (@counterparty_id, @external_type_id, @external_value)
		
		IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR, 'Counterparty EPA Account', 
					'spa_counterparty_epa_account', 'DB Error', 
					'Error inserting values', ''
		ELSE
			EXEC spa_ErrorHandler 0, 'Counterparty EPA Account', 
					'spa_counterparty_epa_account', 'Success', 
					'Values successfully inserted.', ''
	END 
	ELSE IF @flag = 'u'
	BEGIN 
		UPDATE counterparty_epa_account SET 
			counterparty_id = @counterparty_id,
			external_type_id = @external_type_id,
			external_value = @external_value
		WHERE counterparty_epa_account_id = @counterparty_epa_account_id 
		
		IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR, 'Counterparty EPA Account', 
					'spa_counterparty_epa_account', 'DB Error', 
					'Error updating values', ''
		ELSE
			EXEC spa_ErrorHandler 0, 'Counterparty EPA Account', 
					'spa_counterparty_epa_account', 'Success', 
					'Values successfully updated.', ''
	END 
	ELSE IF @flag = 'd'
	BEGIN 
		DELETE FROM counterparty_epa_account WHERE counterparty_epa_account_id = @counterparty_epa_account_id 
		
		IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR, 'Counterparty EPA Account', 
					'spa_counterparty_epa_account', 'DB Error', 
					'Error deleting values', ''
		ELSE
			EXEC spa_ErrorHandler 0, 'Counterparty EPA Account', 
					'spa_counterparty_epa_account', 'Success', 
					'Values successfully deleted.', ''
	END 
	ELSE IF @flag = 'v'
	BEGIN
		
		EXEC sp_xml_preparedocument @idoc OUTPUT,
									@xml
		IF OBJECT_ID('tempdb..#temp_update_detail') IS NOT NULL
		  DROP TABLE #temp_update_detail

		IF OBJECT_ID('tempdb..#temp_delete_detail') IS NOT NULL
		  DROP TABLE #temp_delete_detail
		IF OBJECT_ID('tempdb..#temp_insert_detail') IS NOT NULL
		  DROP TABLE #temp_insert_detail

		SELECT
		  counterparty_epa_account_id,
		  counterparty_id,
		  external_type_id,
		  external_value, 
		  NULLIF(contract_id, 0) [contract_id]
		INTO #temp_update_detail
		FROM OPENXML(@idoc, '/Root/GridUpdate', 1)
		WITH (
			counterparty_epa_account_id INT,
			counterparty_id INT,
			external_type_id INT,
			external_value nvarchar(100),
			contract_id INT
		)

		SELECT
		  grid_id
		INTO #temp_delete_detail
		FROM OPENXML(@idoc, '/Root/GridDelete', 1)
		WITH (
			grid_id INT
		)

		SELECT
		  counterparty_epa_account_id,
		  counterparty_id,
		  external_type_id,
		  external_value,
		  NULLIF(contract_id, 0) [contract_id] 
		INTO #temp_insert_detail
		FROM OPENXML(@idoc, '/Root/GridInsert', 1)
		WITH (
			counterparty_epa_account_id INT,
			counterparty_id INT,
			external_type_id INT,
			external_value nvarchar(100),
			contract_id INT
		)
		
		UPDATE cea
		SET cea.counterparty_id = tud.counterparty_id,
			cea.external_type_id = tud.external_type_id,
			cea.external_value = tud.external_value,
			cea.contract_id = tud.contract_id
		FROM counterparty_epa_account cea
		INNER JOIN #temp_update_detail tud ON cea.counterparty_epa_account_id = tud.counterparty_epa_account_id
		
		INSERT INTO counterparty_epa_account (
			counterparty_id,
			external_type_id,
			external_value,
			contract_id )
		SELECT
		tid.counterparty_id,
		tid.external_type_id,
		tid.external_value,
		tid.contract_id
		FROM #temp_insert_detail tid

		
		DELETE cea 
		FROM master_view_counterparty_epa_account cea
		INNER JOIN #temp_delete_detail tdd ON cea.counterparty_epa_account_id = tdd.grid_id

		DELETE cea 
		FROM counterparty_epa_account cea
		INNER JOIN #temp_delete_detail tdd ON cea.counterparty_epa_account_id = tdd.grid_id

		EXEC spa_ErrorHandler @@error,
							  'EPA Account detail saved.',
							  'spa_counterparty_epa_account',
							  'Success',
							  'Changes have been saved successfully.',
							  ''	
	 
	  END

END 
