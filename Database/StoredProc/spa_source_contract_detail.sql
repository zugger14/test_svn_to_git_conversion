
IF OBJECT_ID('[dbo].[spa_source_contract_detail]','p') IS NOT NULL 
DROP PROCEDURE [dbo].[spa_source_contract_detail]
GO 
SET ANSI_NULLS ON
GO 
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_source_contract_detail]	
@flag AS CHAR(1),	
@contract_id INT = NULL,				
@source_system_id INT = NULL,
@source_contract_id VARCHAR(50) = NULL,
@contract_name VARCHAR(100) = NULL,
@contract_desc VARCHAR(500) = NULL,
@strategy_id INT = NULL,
@is_active CHAR(1) = NULL,
@standard_contract CHAR(1) = NULL,
@counterparty_id VARCHAR(8000) = NULL,
@internal_counterparty_id VARCHAR(8000) = NULL
AS 
SET NOCOUNT ON
DECLARE @Sql_Select VARCHAR(MAX)

IF @flag IN ('r', 'o')
BEGIN
	-- For the privilege
	CREATE TABLE #final_privilege_list(value_id INT, is_enable VARCHAR(20) COLLATE DATABASE_DEFAULT )
	EXEC spa_static_data_privilege @flag = 'p', @source_object = 'contract'
END
IF @flag = 'i'
BEGIN
	IF EXISTS(
	       SELECT 1
	       FROM   contract_group
	       WHERE  source_contract_id       = @source_contract_id
	   )
	BEGIN
			EXEC spa_ErrorHandler -1,
			     'MaintainDefination',
			     'spa_source_contract_detail',
			     'Error',
			     'Contract already exists. Please enter new contract id.',
			     ''
			RETURN
	END
	IF EXISTS (
	       SELECT 1
	       FROM   contract_group
	       WHERE  contract_name            = @contract_name
	)
	BEGIN
			EXEC spa_ErrorHandler -1,
			     'MaintainDefination',
			     'spa_source_contract_detail',
			     'DB Error',
			     'Contract already exists. Please enter new contract name.',
			     ''
			RETURN
	END
	INSERT INTO contract_group
			(
			source_system_id,
			contract_name,
			contract_desc,
			source_contract_id,
			is_active,
			standard_contract,
			volume_granularity
			)
		VALUES
			(										
			ISNULL(@source_system_id,2),
			@contract_name,
			@contract_desc,
			@source_contract_id,
			@is_active,
			@standard_contract,
			980
			)

	IF @standard_contract = 'y'
	BEGIN
		DECLARE @recent_contract_id INT 
		SET @recent_contract_id = SCOPE_IDENTITY()
		INSERT INTO contract_group_detail
			(
			contract_id,
			invoice_line_item_id,
			radio_automatic_manual,
			Prod_type,
			sequence_order,
			hideInInvoice,
			include_charges,
			calc_aggregation
			)
		VALUES
			(
			@recent_contract_id,
			'-10019',
			'c',
			'p',
			'1',
			's',
			'y',
			19002
			)
	END
		IF @@Error <> 0
		EXEC spa_ErrorHandler @@Error, 'MaintainDefination', 
				'spa_source_contract_detail', 'DB Error', 
				'Failed to insert defination value.', ''
		ELSE
		EXEC spa_ErrorHandler 0, 'MaintainDefination', 
				'spa_source_contract_detail', 'Success', 
				'Defination data value inserted.', ''
END

ELSE IF @flag = 'a' 
BEGIN
	SELECT contract_id,
	       source_contract_id,
	       contract_name,
	       contract_desc,
	       source_system_id,
	       is_active,
	       standard_contract
	FROM   contract_group
	WHERE  contract_id = @contract_id
	
END

ELSE IF @flag = 'c' 
BEGIN
	SET @Sql_Select='SELECT cg.contract_id ID,
					 cg.contract_name + CASE WHEN cg.source_system_id=2 THEN '''' ELSE ''.'' + source_system_description.source_system_name END as Name,
					 cg.contract_desc as Description, 
					 source_system_description.source_system_name as System,
					 cg.source_contract_id SourceID,
					 dbo.FNADateTimeFormat(cg.create_ts,1) [Created Date],
					 cg.create_user [Created User],
					 cg.update_user [Updated User],
					 dbo.FNADateTimeFormat(cg.update_ts,1) [Updated Date]  
					 from contract_group  cg
					 INNER JOIN source_system_description on	source_system_description.source_system_id = cg.source_system_id' 
	 
	IF @strategy_id IS NOT NULL 
		SET @Sql_Select=@Sql_Select +  ' INNER JOIN fas_strategy fs ON fs.source_system_id = source_system_description.source_system_id WHERE fs.fas_strategy_id = '+CAST(@strategy_id AS VARCHAR)
	
	                
	IF @source_system_id IS NOT NULL AND @strategy_id IS NOT NULL
		SET @Sql_Select=@Sql_Select +  ' AND cg.source_system_id = ' + CONVERT(varchar(20),@source_system_id) + ''
		
	IF @source_system_id IS NOT NULL AND @strategy_id is null
		SET @Sql_Select=@Sql_Select +  ' WHERE cg.source_system_id = ' + CONVERT(varchar(20),@source_system_id) + ''
		
	IF @source_system_id IS NOT NULL
		SET @Sql_Select=@Sql_Select +  ' AND cg.source_system_id = ' + CAST(@source_system_id AS VARCHAR)
	
	SET @Sql_Select=@Sql_Select + ' AND cg.is_active = ''y''' 
	SET @Sql_Select =  @Sql_Select + ' order by cg.contract_name asc'
	
	EXEC(@SQL_select)

END

ELSE IF @flag = 's' -- for update mode.
BEGIN
	SET @Sql_Select='SELECT cg.contract_id ID,
					 cg.contract_name + CASE WHEN cg.source_system_id=2 THEN '''' ELSE ''.'' + source_system_description.source_system_name END as Name,
					 cg.contract_desc as Description, 
					 source_system_description.source_system_name as System,
					 cg.source_contract_id SourceID,
					 dbo.FNADateTimeFormat(cg.create_ts,1) [Created Date],
					 cg.create_user [Created User],
					 cg.update_user [Updated User],
					 dbo.FNADateTimeFormat(cg.update_ts,1) [Updated Date]  
					 from contract_group  cg
					 INNER JOIN source_system_description on	source_system_description.source_system_id = cg.source_system_id' 
	 
	IF @strategy_id IS NOT NULL 
		SET @Sql_Select=@Sql_Select +  ' INNER JOIN fas_strategy fs ON fs.source_system_id = source_system_description.source_system_id WHERE fs.fas_strategy_id = '+CAST(@strategy_id AS VARCHAR)
	
	                
	IF @source_system_id IS NOT NULL AND @strategy_id IS NOT NULL
		SET @Sql_Select=@Sql_Select +  ' AND cg.source_system_id = ' + CONVERT(varchar(20),@source_system_id) + ''
		
	IF @source_system_id IS NOT NULL AND @strategy_id is null
		SET @Sql_Select=@Sql_Select +  ' WHERE cg.source_system_id = ' + CONVERT(varchar(20),@source_system_id) + ''
		
	IF @source_system_id IS NOT NULL
		SET @Sql_Select=@Sql_Select +  ' AND cg.source_system_id = ' + CAST(@source_system_id AS VARCHAR)
	
	SET @Sql_Select =  @Sql_Select + ' order by cg.contract_name asc'
	
	EXEC(@SQL_select)

END

ELSE IF @flag = 'e' 
BEGIN
	SET @Sql_Select='SELECT DISTINCT cg.contract_id AS contract_id,
					 cg.contract_name + CASE WHEN cg.source_system_id=2 THEN '''' ELSE ''.'' + source_system_description.source_system_name END as contract_name,
					 cg.contract_desc as contract_desc, 
					 source_system_description.source_system_name as source_system_name,
					 cg.source_contract_id source_contract_id,
					 dbo.FNADateTimeFormat(cg.create_ts,1) [create_ts],
					 cg.create_user [create_user],
					 cg.update_user [update_user],
					 dbo.FNADateTimeFormat(cg.update_ts,1) [update_ts]  
					 from contract_group  cg
					 INNER JOIN source_system_description on	source_system_description.source_system_id = cg.source_system_id' 
	 
	IF @strategy_id IS NOT NULL 
		SET @Sql_Select=@Sql_Select +  ' INNER JOIN fas_strategy fs ON fs.source_system_id = source_system_description.source_system_id WHERE fs.fas_strategy_id = '+CAST(@strategy_id AS VARCHAR)
	
	IF @counterparty_id IS NOT NULL
		SET @Sql_Select = @Sql_Select + ' INNER JOIN counterparty_contract_address cca ON cca.contract_id = cg.contract_id AND cca.counterparty_id IN (' + @counterparty_id  + ')'
	                
	IF @source_system_id IS NOT NULL AND @strategy_id IS NOT NULL
		SET @Sql_Select=@Sql_Select +  ' AND cg.source_system_id = ' + CONVERT(varchar(20),@source_system_id) + ''
		
	IF @source_system_id IS NOT NULL AND @strategy_id is null
		SET @Sql_Select=@Sql_Select +  ' WHERE cg.source_system_id = ' + CONVERT(varchar(20),@source_system_id) + ''
		
	IF @source_system_id IS NOT NULL
		SET @Sql_Select=@Sql_Select +  ' AND cg.source_system_id = ' + CAST(@source_system_id AS VARCHAR)

	SET @Sql_Select =  @Sql_Select + ' order by contract_name ASC'
	
	EXEC(@SQL_select)

END
ELSE IF @flag = 'l' --list in grid .. without suffixing source system id.
BEGIN
	SET @Sql_Select='SELECT contract_group.contract_id ID, contract_group.contract_name as Name, contract_group.contract_desc as Description, 
	 source_system_description.source_system_name as System,
	contract_group.source_contract_id SourceID,
			dbo.FNADateTimeFormat(contract_group.create_ts,1) [Created Date],
		contract_group.create_user [Created User],
		contract_group.update_user [Updated User],
			dbo.FNADateTimeFormat(contract_group.update_ts,1) [Updated Date]  
	from contract_group inner join source_system_description on
	source_system_description.source_system_id = contract_group.source_system_id'
	IF @strategy_id IS NOT NULL 
		SET @Sql_Select=@Sql_Select +  ' INNER JOIN fas_strategy fs ON fs.source_system_id = source_system_description.source_system_id WHERE fs.fas_strategy_id = '+CAST(@strategy_id AS VARCHAR)
	                
	IF @source_system_id IS NOT NULL AND @strategy_id IS NOT NULL
		SET @Sql_Select=@Sql_Select +  ' AND contract_group.source_system_id = ' + CONVERT(varchar(20),@source_system_id) + ''
		
	IF @source_system_id IS NOT NULL AND @strategy_id is null
		SET @Sql_Select=@Sql_Select +  ' WHERE contract_group.source_system_id = ' + CONVERT(varchar(20),@source_system_id) + ''
		
	IF @source_system_id IS NOT NULL 
		SET @Sql_Select=@Sql_Select +  ' AND contract_group.source_system_id = ' + CAST(@source_system_id AS VARCHAR)
	
	SET @Sql_Select=@Sql_Select + ' order by contract_group.contract_name asc'
	EXEC(@SQL_select)

END

ELSE IF @flag = 'u'
BEGIN
	IF EXISTS(SELECT source_contract_id from contract_group where source_contract_id=@source_contract_id AND source_system_id=@source_system_id and contract_id <> @contract_id)
	BEGIN
			EXEC spa_ErrorHandler -1, 'MaintainDefination', 
					'spa_source_contract_detail', 'Error', 
					'The Contract ID is already exist. Failed to update definition value.', ''
			RETURN
	END
	IF EXISTS(SELECT source_contract_id from contract_group where contract_name=@contract_name AND source_system_id=@source_system_id and contract_id <> @contract_id)
	BEGIN
			EXEC spa_ErrorHandler -1, 'MaintainDefination', 
					'spa_source_contract_detail', 'Error', 
					'The Contract Name is already exist. Failed to update definition value.', ''
			RETURN
	END

	UPDATE contract_group
	SET    source_system_id = ISNULL(@source_system_id,2),
	       contract_name = @contract_name,
	       contract_desc = @contract_desc,
	       source_contract_id = @source_contract_id,
	       is_active = @is_active,
	       standard_contract = @standard_contract
	WHERE  contract_id = @contract_id
	
	IF @@Error <> 0
		EXEC spa_ErrorHandler @@Error, 'MaintainDefination', 
				'spa_source_contract_detail', 'DB Error', 
				'Failed to update defination value.', ''
		ELSE
		EXEC spa_ErrorHandler 0, 'MaintainDefination', 
				'spa_source_contract_detai', 'Success', 
				'Defination data value updated.', '@source_contract_id'

END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
			BEGIN TRAN
				DELETE FROM contract_group
				WHERE contract_id = @contract_id
				EXEC spa_ErrorHandler 0
				, 'MaintainDefination'
				, 'spa_source_contract_detail'
				, 'Success'
				, 'Maintain Defination Data sucessfully deleted'
				, ''
			COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT <> 0
			ROLLBACK
			DECLARE @error_no int
			SET @error_no = ERROR_NUMBER()
			EXEC spa_ErrorHandler -1
			, 'MaintainDefinition'
			, 'spa_source_contract_detail'
			, 'DB Error'
			--, 'Contract cannot be deleted when already being used.'
			, 'Selected data is in use and cannot be deleted.'
			, 'Foreign key constrains'
	END CATCH
END
ELSE IF @flag = 'x' --for populating the charge type id combobox on Contract Value Formula Window
BEGIN
	SELECT cgd.invoice_line_item_id, sdv.code, cgd.contract_id
	FROM   contract_group cg
	       JOIN contract_group_detail cgd
	            ON  cgd.contract_id = cg.contract_id
	       JOIN static_data_value sdv
	            ON  sdv.value_id = cgd.invoice_line_item_id
	WHERE  cgd.contract_id = @contract_id
END
ELSE IF @flag = 'r'
BEGIN
	SET @Sql_Select = 'SELECT DISTINCT cg.contract_id ID,
							   CASE WHEN cg.source_contract_id <> cg.[contract_name] THEN cg.source_contract_id + '' - '' + cg.[contract_name] ELSE cg.[contract_name] END + 
							   CASE WHEN cg.source_system_id = 2 THEN ''''
								ELSE CASE WHEN cg.source_system_id IS NOT NULL THEN  ''.'' + source_system_description.source_system_name ELSE '''' END
								END AS NAME,
							 MIN(fpl.is_enable) [status]
						FROM #final_privilege_list fpl 
						' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END +
						' contract_group cg ON cg.contract_id = fpl.value_id
						LEFT JOIN source_system_description ON  source_system_description.source_system_id = cg.source_system_id
						LEFT JOIN counterparty_contract_address cca	ON cca.contract_id = cg.contract_id
						WHERE 1 = 1 '
	IF @counterparty_id IS NOT NULL 
	BEGIN
		SET @Sql_Select = @Sql_Select + ' AND cca.counterparty_id = ' + CAST(@counterparty_id AS VARCHAR(10))
	END 
	
	SET @Sql_Select =  @Sql_Select + 'GROUP BY cg.contract_id, cg.source_contract_id, cg.contract_name, cg.source_system_id, source_system_description.source_system_name ORDER BY Name ASC'	

	EXEC(@Sql_Select)
END
ELSE IF @flag = 'o'
BEGIN
	SET @Sql_Select =  'SELECT DISTINCT cg.contract_id ID,
						    CASE 
						        WHEN cg.source_contract_id <> cg.[contract_name] THEN cg.source_contract_id 
						                + '' - '' + cg.[contract_name]
						        ELSE cg.[contract_name]
						    END + CASE 
						                WHEN cg.source_system_id = 2 THEN ''''
						                ELSE CASE 
						                        WHEN cg.source_system_id IS NOT NULL THEN ''.'' + 
						                                source_system_description.source_system_name
						                        ELSE ''''
						                    END
						            END AS NAME,
									MIN(fpl.is_enable) [status]
						FROM #final_privilege_list fpl 
						' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END +
						' contract_group cg ON cg.contract_id = fpl.value_id
						    INNER JOIN counterparty_contract_address cca
						        ON  cca.contract_id = cg.contract_id
						    LEFT JOIN static_data_value sdv
						        ON  sdv.value_id = cca.contract_status
						    LEFT JOIN static_data_value sdv1
						        ON  sdv1.value_id = cca.rounding
						    LEFT JOIN source_counterparty sc2
						        ON  sc2.source_counterparty_id = cca.internal_counterparty_id
						    LEFT JOIN source_system_description
						        ON  source_system_description.source_system_id = cg.source_system_id
						    INNER JOIN source_counterparty  AS sc
						        ON  sc.source_counterparty_id = cca.counterparty_id
					WHERE  1 = 1'

	IF @counterparty_id IS NOT NULL 
		BEGIN
			SET @Sql_Select = @Sql_Select + ' AND cca.counterparty_id = ' + CAST(@counterparty_id AS VARCHAR(10))
		END
	
	IF @internal_counterparty_id IS NOT NULL 
		BEGIN
			SET @Sql_Select = @Sql_Select + ' AND sc2.source_counterparty_id = ' + CAST(@internal_counterparty_id AS	VARCHAR(10))
		END	
		
	SET @Sql_Select =  @Sql_Select + ' GROUP BY cg.contract_id, cg.source_contract_id, cg.contract_name, cg.source_system_id, source_system_description.source_system_name'
	SET @Sql_Select = @Sql_Select + ' ORDER BY  NAME ASC '		
	
	EXEC(@Sql_Select)
END
ELSE IF @flag = 't' -- for update mode.
BEGIN
	SET @Sql_Select='SELECT cg.contract_id ID,
					 cg.contract_name + CASE WHEN cg.source_system_id=2 THEN '''' ELSE ''.'' + source_system_description.source_system_name END as Name
					 from contract_group  cg
					 INNER JOIN source_system_description on	source_system_description.source_system_id = cg.source_system_id' 
	 
	IF @strategy_id IS NOT NULL 
		SET @Sql_Select=@Sql_Select +  ' INNER JOIN fas_strategy fs ON fs.source_system_id = source_system_description.source_system_id WHERE fs.fas_strategy_id = '+CAST(@strategy_id AS VARCHAR)
	
	                
	IF @source_system_id IS NOT NULL AND @strategy_id IS NOT NULL
		SET @Sql_Select=@Sql_Select +  ' AND cg.source_system_id = ' + CONVERT(varchar(20),@source_system_id) + ''
		
	IF @source_system_id IS NOT NULL AND @strategy_id is null
		SET @Sql_Select=@Sql_Select +  ' WHERE cg.source_system_id = ' + CONVERT(varchar(20),@source_system_id) + ''
		
	IF @source_system_id IS NOT NULL
		SET @Sql_Select=@Sql_Select +  ' AND cg.source_system_id = ' + CAST(@source_system_id AS VARCHAR)
	
	SET @Sql_Select =  @Sql_Select + ' order by cg.contract_name asc'
	
	EXEC(@SQL_select)

END
