IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_counterparty_bank_info]') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.spa_counterparty_bank_info
 GO 

CREATE PROC dbo.spa_counterparty_bank_info
@flag CHAR(1),
@bank_id INT = NULL,
@counterparty_id INT = NULL,
@bank_name VARCHAR(100) = NULL,
@wire_ABA VARCHAR(50) = NULL,
@ACH_ABA VARCHAR(50) = NULL,
@Account_no VARCHAR(50) = NULL,
@Address1 NVARCHAR(1000) = NULL,
@Address2 NVARCHAR(1000) = NULL,
@accountname VARCHAR(50) = NULL,
@reference VARCHAR(50) = NULL,
@currency INT = NULL,
@xml	VARCHAR(MAX) = NULL

AS 
BEGIN
SET NOCOUNT ON
	IF @flag='s'
		SELECT bank_id,
			   counterparty_id,
			   sc.currency_name AS [Currency],
			   bank_name AS [Bank Name],
			   wire_aba AS [ABA No],
			   ACH_ABA AS [Swift No],
			   account_no AS [Account No],
			   Address1,
			   Address2,
			   accountname,
			   reference
		FROM   counterparty_bank_info cbi 
		LEFT JOIN source_currency sc ON cbi.currency = sc.source_currency_id
		WHERE  counterparty_id = @counterparty_Id	

	ELSE IF @flag = 'a'
			 SELECT bank_id,
					counterparty_id,
					bank_name AS [Bank Name],
					wire_aba AS [ABA No],
					ACH_ABA AS [Swift No],
					account_no AS [Account No],
					Address1,
					Address2,
					accountname,
					reference,
					currency
			 FROM   counterparty_bank_info
			 WHERE  bank_id = @bank_id
	ELSE IF @flag='i'		
	BEGIN
		INSERT INTO counterparty_bank_info(
			counterparty_id,
			bank_name,
			wire_ABA,
			ACH_ABA,
			Account_no,
			Address1,
			Address2,
			accountname,
			reference,
			currency
		)
		select
			@counterparty_id,
			@bank_name,
			@wire_ABA,
			@ACH_ABA,
			@Account_no,
			@Address1,
			@Address2,
			@accountname,
			@reference,
			@currency
				
		If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "Bank Info", 
			"spa_counterparty_bank_info", "DB Error", 
			"Error on Inserting Recorder ID.", ''
		else
			Exec spa_ErrorHandler 0, 'Bank Info', 
			'spa_counterparty_bank_info', 'Success', 
			'Bank Info successfully inserted.',''

	END
	ELSE IF @flag='u'		
	BEGIN
		update counterparty_bank_info
		set
			counterparty_id=@counterparty_id,
			bank_name=@bank_name,
			wire_ABA=@wire_ABA,
			ACH_ABA=@ACH_ABA,
			Account_no=@Account_no,
			Address1=@Address1,
			Address2=@Address2,
			accountname=@accountname,
			reference = @reference,
			currency = @currency
		
		where
			bank_id=@bank_id
			
		If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "Bank Info", 
			"spa_counterparty_bank_info", "DB Error", 
			"Error on Inserting Recorder ID.", ''
		else
			Exec spa_ErrorHandler 0, 'Bank Info', 
			'spa_counterparty_bank_info', 'Success', 
			'Changes have been saved successfully.',''

	END
	ELSE IF @flag='d'		
	BEGIN
		delete from counterparty_bank_info
		where
			bank_id=@bank_id
			
		If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "Bank Info", 
			"spa_counterparty_bank_info", "DB Error", 
			"Error on Inserting Recorder ID.", ''
		else
			Exec spa_ErrorHandler 0, 'Bank Info', 
			'spa_counterparty_bank_info', 'Success', 
			'Changes have been saved successfully.',''

	END
	ELSE IF @flag = 't'
	BEGIN 
		SELECT bank_id
			,accountname
			,Account_no
			,sc.currency_name
			,ACH_ABA
			,wire_ABA
			,bank_name
			,Address1
			,Address2
			,reference 
			,CASE WHEN primary_account = 'y' THEN 'Yes' ELSE 'No' END 
		FROM   counterparty_bank_info cbi 
		LEFT JOIN source_currency AS sc ON sc.source_currency_id = cbi.currency
		WHERE  counterparty_id =  @counterparty_Id
	END
	ELSE IF @flag = 'v'
	BEGIN
		DECLARE @idoc int
		EXEC sp_xml_preparedocument @idoc OUTPUT,
									@xml
		IF OBJECT_ID('tempdb..#temp_update_detail') IS NOT NULL
		  DROP TABLE #temp_update_detail

		IF OBJECT_ID('tempdb..#temp_delete_detail') IS NOT NULL
		  DROP TABLE #temp_delete_detail
		IF OBJECT_ID('tempdb..#temp_insert_detail') IS NOT NULL
		  DROP TABLE #temp_insert_detail
		
		SELECT
			bank_id,
			counterparty_id,
			bank_name,
			wire_ABA,
			ACH_ABA,
			account_no,
			Address1,
			Address2,
			account_name,
			reference,
			currency
		INTO #temp_update_detail
		FROM OPENXML(@idoc, '/Root/GridUpdate', 1)
		WITH (
			bank_id				INT,
			counterparty_id		INT,
			bank_name			VARCHAR(100),
			wire_ABA			VARCHAR(50),
			ACH_ABA				VARCHAR(50),
			account_no			VARCHAR(50),
			address1			VARCHAR(50),
			address2			VARCHAR(50),
			account_name		VARCHAR(50),
			reference			VARCHAR(50),
			currency			INT
		)

		SELECT
		  grid_id
		INTO #temp_delete_detail
		FROM OPENXML(@idoc, '/Root/GridDelete', 1)
		WITH (
			grid_id INT
		)

		SELECT
			bank_id,
			counterparty_id,
			bank_name,
			wire_ABA,
			ACH_ABA,
			account_no,
			address1,
			address2,
			account_name,
			reference,
			currency
		INTO #temp_insert_detail
		FROM OPENXML(@idoc, '/Root/GridInsert', 1)
		WITH (
			bank_id INT,
			counterparty_id INT,
			bank_name	VARCHAR(100),
			wire_ABA	VARCHAR(50),
			ACH_ABA		VARCHAR(50),
			account_no	VARCHAR(50),
			address1	VARCHAR(50),
			address2	VARCHAR(50),
			account_name	VARCHAR(50),
			reference	VARCHAR(50),
			currency	INT
		)
				
		UPDATE cbi
		SET  counterparty_id = tud.counterparty_id,
			bank_name = tud.bank_name,
			wire_ABA = tud.wire_ABA,
			ACH_ABA = tud.ACH_ABA,
			Account_no = tud.account_no,
			Address1 = tud.address1,
			Address2 = tud.address2,
			accountname = tud.account_name,
			reference = tud.reference,
			currency = tud.currency
		FROM counterparty_bank_info cbi
		INNER JOIN #temp_update_detail tud ON cbi.bank_id = tud.bank_id
		
		INSERT INTO counterparty_bank_info (
			counterparty_id,
			bank_name,
			wire_ABA,
			ACH_ABA,
			Account_no,
			Address1,
			Address2,
			accountname,
			reference,
			currency )
		
		SELECT
			tid.counterparty_id,
			tid.bank_name,
			tid.wire_ABA,
			tid.ACH_ABA,
			tid.account_no,
			tid.address1,
			tid.address2,
			tid.account_name,
			tid.reference,
			tid.currency
		FROM #temp_insert_detail tid

		DELETE cbi 
		FROM counterparty_bank_info cbi
		INNER JOIN #temp_delete_detail tdd ON cbi.bank_id = tdd.grid_id

		EXEC spa_ErrorHandler @@error,
							  'Counterparty Bank detail saved.',
							  'spa_counterparty_bank_info',
							  'Success',
							  'Changes have been saved successfully.',
							  ''	
	 
	  END

END




