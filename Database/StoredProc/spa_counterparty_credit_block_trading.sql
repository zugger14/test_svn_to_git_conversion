IF OBJECT_ID(N'[spa_counterparty_credit_block_trading]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_counterparty_credit_block_trading]
GO

CREATE PROCEDURE [dbo].[spa_counterparty_credit_block_trading]
	@flag AS CHAR(1),
	@counterparty_credit_block_id INT = NULL,
	@counterparty_credit_info_id INT = NULL,
	@comodity_id INT = NULL,
	@deal_type_id INT = NULL,
	--added later
	@contract INT = NULL,
	@active CHAR(1) = NULL,
	@buysell_allow CHAR(1) = NULL
AS

DECLARE @sql VARCHAR(5000)

IF @flag = 's'
BEGIN
	SELECT ccbt.counterparty_credit_block_id [Credit Block ID],
		ccbt.counterparty_credit_info_id [Counterparty Credit Info ID],
		sc.commodity_name  + case when ssd.source_system_name='farrms' then '' else  '.' + ssd.source_system_name  end [Commodity],
		sdt.deal_type_id [Deal Type],
		cg.contract_name AS [Contract],
		ccbt.[active] AS [Active],
		CASE WHEN ccbt.buysell_allow = 'b' THEN 'Buy'
				WHEN ccbt.buysell_allow = 's' THEN 'Sell'
				WHEN ccbt.buysell_allow = 'o' THEN 'Both'
		END
		AS [Buy/Sell Allow]
	FROM counterparty_credit_block_trading ccbt
	LEFT JOIN counterparty_credit_info cci ON cci.counterparty_credit_info_id=ccbt.counterparty_credit_info_id
	LEFT JOIN source_commodity sc ON sc.source_commodity_id=ccbt.comodity_id
	LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id=ccbt.deal_type_id
	LEFT JOIN source_system_description ssd ON sc.source_system_id = ssd.source_system_id
	LEFT JOIN contract_group cg ON cg.contract_id = ccbt.[contract]
	WHERE ccbt.counterparty_credit_info_id = @counterparty_credit_info_id
	ORDER BY ssd.source_system_name, sc.commodity_name

	IF @counterparty_credit_block_id IS NOT NULL
	BEGIN
		SET @sql = @sql + ' AND counterparty_credit_block_id = ' + CAST(@counterparty_credit_block_id AS VARCHAR)
	END
	EXEC spa_print @sql
	EXEC(@sql)
END

ELSE IF @flag = 'a'
BEGIN
	SET @sql='
		SELECT counterparty_credit_block_id,
			counterparty_credit_info_id ,
			comodity_id ,
			deal_type_id,
			contract,
			active,
			buysell_allow 
		FROM counterparty_credit_block_trading
		WHERE counterparty_credit_block_id = ' + CAST(@counterparty_credit_block_id AS VARCHAR)

	IF @counterparty_credit_block_id IS NOT NULL
	BEGIN
		SET @sql = @sql + 'AND counterparty_credit_block_id = ' + CAST(@counterparty_credit_block_id AS VARCHAR)
	END

	EXEC(@sql)
END

ELSE IF @flag = 'i'
BEGIN
	INSERT INTO counterparty_credit_block_trading (
		counterparty_credit_info_id,
		comodity_id,
		deal_type_id,
		[contract],
		[active],
		buysell_allow)
	VALUES (
		@counterparty_credit_info_id, 
		@comodity_id ,
		@deal_type_id,
		@contract,
		@active,
		@buysell_allow)

	IF @@ERROR <> 0
	BEGIN
		EXEC spa_ErrorHandler @@ERROR,
			'Counterparty Block Trading',
			'spa_counterparty_credit_block_trading',
			'DB Error',
			'Insetion  of counterparty_credit_info failed.',
			''
		RETURN
	END
	ELSE
	BEGIN
		DECLARE @recommendation VARCHAR(100) = SCOPE_IDENTITY()
		EXEC spa_ErrorHandler 0,
			'Counterparty Block Trading',
			'spa_counterparty_credit_block_trading',
			'Success',
			'counterparty_credit_block_trading successfully inserted.',
			@recommendation 
	END
END

ELSE IF @flag = 'u'
BEGIN
	UPDATE counterparty_credit_block_trading
	SET counterparty_credit_info_id = @counterparty_credit_info_id,
		comodity_id = @comodity_id,
		deal_type_id = @deal_type_id,
		[contract] = @contract,
		[active] = @active,
		buysell_allow = @buysell_allow
	WHERE counterparty_credit_block_id = @counterparty_credit_block_id
	
	IF @@ERROR <> 0
	BEGIN
		EXEC spa_ErrorHandler @@ERROR,
			'Counterparty Block Trading',
			'spa_counterparty_credit_block_trading',
			'DB Error',
			'Update of counterparty_credit_block_trading failed.',
			''
		RETURN
	END
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 0,
			'Counterparty Block Trading',
			'spa_counterparty_credit_block_trading',
			'Success',
			'counterparty_credit_block_trading  successfully updated.',
			''
	END
END

ELSE IF @flag = 'd'
BEGIN
	DELETE FROM counterparty_credit_block_trading WHERE counterparty_credit_block_id = @counterparty_credit_block_id
	IF @@ERROR <> 0
	BEGIN
		EXEC spa_ErrorHandler @@ERROR,
			'Counterparty Credit Info',
			'spa_counterparty_credit_info',
			'DB Error',
			'Deletion of counterparty_credit_info failed.',
			''
		RETURN
	END
	ELSE 
	BEGIN
		EXEC spa_ErrorHandler 0,
			'Counterparty Block Trading',
			'spa_counterparty_credit_block_trading',
			'Success',
			'counterparty_credit_block_trading successfully deleted.',
			''
	END
END

GO