--Author: Tara Nath Subedi
--Dated: 2010 April 16
--Issue ID: 2227
--Purpose: Insert / Update / Delete "Transportation Rate Schedule" definition.

IF OBJECT_ID(N'spa_transportation_rate_maintain',N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_transportation_rate_maintain]
GO 
--EXEC spa_transportation_rate_maintain 's'
CREATE PROC [dbo].[spa_transportation_rate_maintain]	
	@flag AS CHAR(1),	
	@transport_value_id INT=NULL,				
	@transport_code VARCHAR(50)=NULL,
	@transport_desc VARCHAR(500)=NULL,
	@user_name VARCHAR(50)=NULL,
	@contract_id VARCHAR(50) = NULL

AS 
SET NOCOUNT ON
DECLARE @Sql_Select VARCHAR(5000)

IF @flag='i'
BEGIN
	DECLARE @cont1 VARCHAR(100)
	SELECT @cont1= COUNT(*) FROM static_data_value WHERE type_id=1800 AND code = @transport_code
	IF (@cont1>0)
	BEGIN
		SELECT 'Error', 'Name ''' + @transport_code + ''' already exists.',
			'spa_transportation_rate_maintain', 'DB Error', 
			'Name ''' + @transport_code + ''' already exists.',''
		RETURN
	END
	
	INSERT INTO static_data_value
			(
			type_id,
			code,
			description,
			create_user,
			create_ts,
			update_user,
			update_ts
			)
		VALUES
			(										
			1800,
			@transport_code,		
			@transport_desc,
			@user_name,
			GETDATE(),
			@user_name,
			GETDATE()
			)

			IF @@Error <> 0
			EXEC spa_ErrorHandler @@Error, 'MaintainDefination', 
					'spa_transportation_rate_maintain', 'DB Error', 
					'Failed to insert definition value.', ''
			ELSE
			EXEC spa_ErrorHandler 0, 'MaintainDefination', 
					'spa_transportation_rate_maintain', 'Success', 
					'Definition data value inserted.', ''
END

ELSE IF @flag='a' 
BEGIN
	SELECT value_id,code,description FROM static_data_value  WHERE value_id=@transport_value_id

END

ELSE IF @flag='s' 
BEGIN
	SET @Sql_Select = 
					'SELECT value_id,
	                     code [Name],
	                     description [Description]
	                   FROM   static_data_value
	                   WHERE  type_id = 1800'
	                   
	 IF @transport_value_id IS NOT NULL
	 BEGIN
	 	SET @Sql_Select = @Sql_Select + 'AND value_id = ' + CAST(@transport_value_id AS VARCHAR(50))
	 END
	 
	 SEt @Sql_Select = @Sql_Select + ' ORDER BY code'
	 --PRINT(@Sql_Select)
	 EXEC(@Sql_Select)
END
ELSE IF @flag='l' 
BEGIN
	SELECT code [Name],description [Description] FROM static_data_value WHERE type_id=1800
END
ELSE IF @flag = 'u'
BEGIN
	DECLARE @cont VARCHAR(100)
	SELECT @cont= COUNT(*) FROM static_data_value WHERE type_id=1800 AND code = @transport_code AND value_id <> @transport_value_id
	IF (@cont>0)
	BEGIN
		SELECT 'Error', 'Name ''' + @transport_code + ''' already exists.',
			'spa_transportation_rate_maintain', 'DB Error', 
			'Name ''' + @transport_code + ''' already exists.',''
		RETURN
	END
	UPDATE static_data_value SET code=@transport_code, description=@transport_desc,
	update_user=@user_name, update_ts=GETDATE()
	WHERE value_id = @transport_value_id
	
	IF @@Error <> 0
		EXEC spa_ErrorHandler @@Error, 'MaintainDefinition', 
				'spa_transportation_rate_maintain', 'DB Error', 
				'Failed to update defination value.', ''
		ELSE
		EXEC spa_ErrorHandler 0, 'MaintainDefinition', 
				'spa_transportation_rate_maintain', 'Success', 
				'Defination data value updated.', ''

END

ELSE IF @flag = 'd'
BEGIN
	
	--DECLARE @count VARCHAR(100)
	--SELECT @count= COUNT(*) FROM transportation_rate_schedule WHERE rate_schedule_id=@transport_value_id
	--IF (@count>0)
	--BEGIN
	--	EXEC spa_ErrorHandler -1, 'MaintainDefinition', 
	--			'spa_transportation_rate_maintain', 'Error', 
	--			'Please Delete the ''Rates/Fees'', associated with ''Rate Schedule'' first.', ''
	--	RETURN
	--END

	--DELETE FROM static_data_value
	--WHERE 	value_id=@transport_value_id

	--IF @@ERROR <> 0
	--	EXEC spa_ErrorHandler @@ERROR, "MaintainDefinition", 
	--			"spa_transportation_rate_maintain", "DB Error", 
	--			"Delete of Maintain Defination Data failed.", ''
	--ELSE
	--	EXEC spa_ErrorHandler 0, 'MaintainDefinition', 
	--			'spa_transportation_rate_maintain', 'Success', 
	--			'Maintain Defination Data sucessfully deleted', ''
	
	
	
	
	----DECLARE @count VARCHAR(100)
	----SELECT @count= COUNT(*) FROM transportation_rate_schedule WHERE rate_schedule_id=@transport_value_id
	----IF (@count>0)
	----BEGIN
	----	SELECT 'Error', 'Please delete the ''Rate/Value'' associated with the ''Rate Schedule'' first.', 
	----		'spa_transportation_rate_maintain', 'DB Error', 
	----		'Please delete the ''Rate/Value'' associated with the ''Rate Schedule'' first.', ''
	----	RETURN
	----END
	----ELSE 
		BEGIN
			DELETE FROM static_data_value
			WHERE 	value_id=@transport_value_id
	
			DELETE FROM transportation_rate_schedule
			WHERE 	rate_schedule_id = @transport_value_id
		END
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, "MaintainDefinition", 
				"spa_transportation_rate_maintain", "DB Error", 
				"Delete of Maintain Defination Data failed.", ''
	ELSE
		EXEC spa_ErrorHandler 0, 'MaintainDefinition', 
				'spa_transportation_rate_maintain', 'Success', 
				'Data sucessfully deleted', ''
END
ELSE IF @flag = 'x'
BEGIN
	SELECT 
		'Transportation' [contract_type],	
		sc.counterparty_name pipeline,		   
		trc.code,
		trc.value_id,
		trc.description,
		sdv.code rate_category		   		   		   
	FROM transportation_rate_category trc
	LEFT JOIN static_data_value sdv
		ON sdv.value_id = trc.rate_category
	LEFT JOIN source_counterparty sc
		ON sc.source_counterparty_id = trc.pipeline
	where trc.contract_type is null  OR trc.contract_type = 't'

	union all 
	select 
		'Storage', 
		sc.counterparty_name pipeline,		   
		trc.code,
		trc.value_id,
		trc.description,
		sdv.code rate_category	
	FROM transportation_rate_category trc
	LEFT JOIN static_data_value sdv
		ON sdv.value_id = trc.rate_category
	LEFT JOIN source_counterparty sc
		ON sc.source_counterparty_id = trc.pipeline
	where trc.contract_type = 's'

	union all 
	select 
		'Others', 
		sc.counterparty_name pipeline,		   
		trc.code,
		trc.value_id,
		trc.description,
		sdv.code rate_category	
	FROM transportation_rate_category trc
	LEFT JOIN static_data_value sdv
		ON sdv.value_id = trc.rate_category
	LEFT JOIN source_counterparty sc
		ON sc.source_counterparty_id = trc.pipeline
	where trc.contract_type = 'o'

	--union blank records if not found for any contract_type, so that grid can display parent folder
	union all
	select 'Transportation',null,null,null,null,null
	where 1=1
	and not exists(
		select top 1 1 FROM transportation_rate_category trc
		LEFT JOIN static_data_value sdv
			ON sdv.value_id = trc.rate_category
		LEFT JOIN source_counterparty sc
			ON sc.source_counterparty_id = trc.pipeline
		where trc.contract_type is null OR trc.contract_type = 't'
	)

	union all
	select 'Storage',null,null,null,null,null
	where 1=1
	and not exists(
		select top 1 1 FROM transportation_rate_category trc
		LEFT JOIN static_data_value sdv
			ON sdv.value_id = trc.rate_category
		LEFT JOIN source_counterparty sc
			ON sc.source_counterparty_id = trc.pipeline
		where trc.contract_type = 's'
	)

	union all
	select 'Others',null,null,null,null,null
	where 1=1
	and not exists(
		select top 1 1 FROM transportation_rate_category trc
		LEFT JOIN static_data_value sdv
			ON sdv.value_id = trc.rate_category
		LEFT JOIN source_counterparty sc
			ON sc.source_counterparty_id = trc.pipeline
		where trc.contract_type = 'o'
	)
END
ELSE IF @flag = 't'
BEGIN
	SELECT 	
		sc.counterparty_name pipeline,		   
		trc.code,
		trc.value_id,
		trc.description,
		sdv.code rate_category		   		   		   
	FROM transportation_rate_category trc
	LEFT JOIN static_data_value sdv
		ON sdv.value_id = trc.rate_category
	LEFT JOIN source_counterparty sc
		ON sc.source_counterparty_id = trc.pipeline
	WHERE trc.contract_type is null  OR trc.contract_type = 't'

END
ELSE IF @flag = 'n'
BEGIN
	SELECT
		trc.value_id, 		   
		trc.code,
		trc.description	
	FROM transportation_rate_category trc
	LEFT JOIN static_data_value sdv
		ON sdv.value_id = trc.rate_category
	LEFT JOIN source_counterparty sc
		ON sc.source_counterparty_id = trc.pipeline
	WHERE trc.contract_type = 's'
END
ELSE IF @flag = 'o'
BEGIN
	SELECT 
		trc.value_id,	   
		trc.code,
		trc.description	
	FROM transportation_rate_category trc
	LEFT JOIN static_data_value sdv
		ON sdv.value_id = trc.rate_category
	LEFT JOIN source_counterparty sc
		ON sc.source_counterparty_id = trc.pipeline
	WHERE trc.contract_type = 'o'
END
ELSE IF @flag = 'y' 
BEGIN
	UPDATE cg  set cg.maintain_rate_schedule = @transport_value_id
	FROM contract_group AS cg WHERE cg.contract_id = @contract_id
END