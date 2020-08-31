IF OBJECT_ID(N'[dbo].[spa_maintain_scenario_dhx]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_maintain_scenario_dhx]
GO

-- ===========================================================================================================
-- Author: bmaharjan@pioneersolutionsglobal.com
-- Create date: 2016-02-16
-- Description: CRUD operation for Setup Whatif Scenario
 
-- Params:
-- @flag     CHAR - Operation flag

-- ===========================================================================================================

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_maintain_scenario_dhx]
	@flag CHAR(1),
	@scenario_group_id INT = NULL,
	@active CHAR(1) = NULL,
	@public CHAR(1) = NULL,
	@user VARCHAR(100) = NULL,
	@role INT = NULL,
	@save_xml XML = NULL,
	@scenario_type CHAR(1) = NULL,
	--for multiple delete
	@del_scenario_group_id VARCHAR(MAX) = NULL
	
AS

SET NOCOUNT ON

DECLARE @idoc INT
DECLARE @DESC VARCHAR(500)
DECLARE @err_no INT 
DECLARE @sql VARCHAR(8000)

EXEC sp_xml_preparedocument @idoc OUTPUT, @save_xml
	
SELECT * INTO #temp_scenario_definition
FROM   OPENXML(@idoc, '/Root/ScenarioDefinition', 1)
		WITH (
			scenario_group_id INT '@scenario_group_id',
			scenario_group_name VARCHAR(100) '@scenario_group_name',
			scenario_group_description VARCHAR(200) '@scenario_group_description',
			[role] VARCHAR(20) '@role',
			[user] VARCHAR(100) '@user',
			active CHAR(1) '@active',
			[public] CHAR(1) '@public',
			scenario_type CHAR(1) '@scenario_type',
			source VARCHAR(20) '@source',
			revaluation CHAR(1) '@revaluation',
			Volatility_source VARCHAR(20) '@Volatility_source'
		)

SELECT * INTO #temp_scenario_detail
FROM   OPENXML(@idoc, '/Root/ScenarioDetail', 1)
		WITH (
			id INT '@id',
			risk_factor CHAR(1) '@risk_factor',
			[shift] VARCHAR(20) '@shift',
			shift_item VARCHAR(20) '@shift_item',
			shift_by CHAR(1) '@shift_by',
			shift_value VARCHAR(20) '@shift_value',
			month_from VARCHAR(20) '@month_from',
			month_to VARCHAR(20) '@month_to',
			use_existing VARCHAR(20) '@use_existing',
			scenario_type CHAR(1) '@scenario_type',
			[shift1] VARCHAR(20) '@shift1',
			[shift2] VARCHAR(20) '@shift2',
			[shift3] VARCHAR(20) '@shift3',
			[shift4] VARCHAR(20) '@shift4',
			[shift5] VARCHAR(20) '@shift5',
			[shift6] VARCHAR(20) '@shift6',
			[shift7] VARCHAR(20) '@shift7',
			[shift8] VARCHAR(20) '@shift8',
			[shift9] VARCHAR(20) '@shift9',
			[shift10] VARCHAR(20) '@shift10'				
		)

--Load the left side grid.
IF @flag = 'm'
BEGIN
	--SELECT A MATCHED ROW FROM THE TABLE FOR GRID DISPLAY AND REPORT
	SET @sql = 'SELECT	msg.scenario_group_id AS [ID]
						,  msg.scenario_group_name AS [Group Name]
						, msg.scenario_group_description AS [Group Description]
						, msg.[user] AS [User]
						, asr.role_name AS [Role]
						, CASE WHEN msg.[active] = ''y'' THEN ''Yes'' ELSE ''No'' END [Active]
						, CASE WHEN msg.[public] = ''y'' THEN ''Yes'' ELSE ''No'' END [Public]
						, sdv.code AS [Source]
						, vs.code AS [Volatility Source]
						, CASE WHEN msg.scenario_type = ''i'' THEN ''Individual'' ELSE ''Multiple'' END [Scenario Type]
				FROM maintain_scenario_group msg
				LEFT JOIN application_security_role asr ON asr.role_id= msg.[role]
				LEFT JOIN static_data_value sdv ON sdv.value_id = msg.source 
				LEFT JOIN static_data_value vs ON vs.value_id = msg.volatility_source 
				ORDER BY msg.scenario_group_name
				'
	EXEC(@sql)
END

--Load the scenario grid (inside scenario tab)
ELSE IF @flag = 'g'
BEGIN
	SELECT	mc.scenario_id,
			mc.risk_factor,
			mc.shift_group,
			mc.shift_item,
			mc.shift_by,
			CASE WHEN (mc.shift_by = 'c' OR mc.shift_by = 'u') THEN CAST(mc.shift_value AS INT) ELSE CAST(dbo.FNARemoveTrailingZeroes(mc.shift_value) AS FLOAT) END,
			mc.month_from,
			mc.month_to,
			mc.use_existing_values,
			mc.shift1,
			mc.shift2,
			mc.shift3,
			mc.shift4,
			mc.shift5,
			mc.shift6,
			mc.shift7,
			mc.shift8,
			mc.shift9,
			mc.shift10
	FROM maintain_scenario mc
	WHERE mc.scenario_group_id = @scenario_group_id
	AND mc.scenario_type = @scenario_type
END

-- Insert new scenario group and scenario
ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
	BEGIN TRAN
		IF NOT EXISTS (SELECT 1 FROM maintain_scenario_group msg INNER JOIN #temp_scenario_definition temp ON msg.scenario_group_name = temp.scenario_group_name)
		BEGIN
		INSERT INTO maintain_scenario_group 
		(
			scenario_group_name,
			scenario_group_description,
			[role],
			[user],
			active,
			[public],
			scenario_type,
			source,
			revaluation,
			Volatility_source
		)
		SELECT 
			scenario_group_name,
			scenario_group_description,
			[role],
			[user],
			active,
			[public],
			scenario_type,
			source,
			revaluation,
			Volatility_source
		FROM #temp_scenario_definition

		DECLARE @new_scenario_group_id INT
		SET @new_scenario_group_id = SCOPE_IDENTITY()
		
		INSERT INTO maintain_scenario
		(
			risk_factor,
			shift_group,
			shift_item,
			shift_by,
			shift_value,
			month_from,
			month_to,
			use_existing_values,
			scenario_type,
			scenario_group_id,
			[shift1],
			[shift2],
			[shift3],
			[shift4],
			[shift5],
			[shift6],
			[shift7],
			[shift8],
			[shift9],
			[shift10]
		) 
		SELECT 
			risk_factor,
			NULLIF(shift,''),
			NULLIF(shift_item,''),
			NULLIF(shift_by,''),
			CAST(NULLIF(shift_value,'') AS FLOAT),
			NULLIF(month_from,''),
			NULLIF(month_to,''),
			use_existing,
			scenario_type,
			@new_scenario_group_id,
			NULLIF([shift1],''),
			NULLIF([shift2],''),
			NULLIF([shift3],''),
			NULLIF([shift4],''),
			NULLIF([shift5],''),
			NULLIF([shift6],''),
			NULLIF([shift7],''),
			NULLIF([shift8],''),
			NULLIF([shift9],''),
			NULLIF([shift10],'')
		FROM #temp_scenario_detail
		
		EXEC spa_ErrorHandler 0
				, 'maintain_scenario'
				, 'spa_maintain_scenario_dhx'
				, 'Success' 
				, 'Changes have been saved successfully.'
				, @new_scenario_group_id
		END
		ELSE
		BEGIN
			EXEC spa_ErrorHandler 1, 
			'maintain_scenario', 
			'spa_maintain_scenario_dhx', 
			'DB Error', 
			'Duplicate data in <b>Scenario Group</b>.',
			''
		END
	COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		SELECT @err_no = ERROR_NUMBER()

		EXEC spa_ErrorHandler @err_no
			, 'maintain_scenario'
			, 'spa_maintain_scenario_dhx'
			, 'Error'
			, @DESC
			, ''
	END CATCH
END

-- Update scenario group and scenario
ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		BEGIN TRAN
		SELECT @scenario_group_id = scenario_group_id FROM #temp_scenario_definition
		IF NOT EXISTS (SELECT 1 FROM maintain_scenario_group msg 
					   INNER JOIN #temp_scenario_definition temp ON msg.scenario_group_name = temp.scenario_group_name AND msg.scenario_group_id <> @scenario_group_id)
		BEGIN
			UPDATE msg
			SET msg.scenario_group_name = tsd.scenario_group_name,
				msg.scenario_group_description = tsd.scenario_group_description,
				msg.[role] = tsd.[role],
				msg.[user] = tsd.[user],
				msg.active = tsd.active,
				msg.[public] = tsd.[public],
				msg.scenario_type = tsd.scenario_type,
				msg.source = tsd.source,
				msg.revaluation = tsd.revaluation,
				msg.Volatility_source = tsd.Volatility_source
			FROM #temp_scenario_definition tsd
			INNER JOIN maintain_scenario_group msg
			ON tsd.scenario_group_id = msg.scenario_group_id

			DELETE ms 
			FROM maintain_scenario ms
			LEFT JOIN #temp_scenario_detail tsd ON tsd.id = ms.scenario_id
			WHERE (tsd.id IS NULL OR tsd.scenario_type <> @scenario_type) AND ms.scenario_group_id = @scenario_group_id
			

			INSERT INTO maintain_scenario
			(
				risk_factor,
				shift_group,
				shift_item,
				shift_by,
				shift_value,
				month_from,
				month_to,
				use_existing_values,
				scenario_type,
				[shift1],
				[shift2],
				[shift3],
				[shift4],
				[shift5],
				[shift6],
				[shift7],
				[shift8],
				[shift9],
				[shift10],
				scenario_group_id
			) 
			SELECT 
				tsd.risk_factor,
				NULLIF(tsd.[shift],''),
				NULLIF(tsd.shift_item,''),
				NULLIF(tsd.shift_by,''),
				CAST(NULLIF(tsd.shift_value,'') AS FLOAT),
				NULLIF(tsd.month_from,''),
				NULLIF(tsd.month_to,''),
				tsd.use_existing,
				tsd.scenario_type,
				NULLIF(tsd.[shift1],''),
				NULLIF(tsd.[shift2],''),
				NULLIF(tsd.[shift3],''),
				NULLIF(tsd.[shift4],''),
				NULLIF(tsd.[shift5],''),
				NULLIF(tsd.[shift6],''),
				NULLIF(tsd.[shift7],''),
				NULLIF(tsd.[shift8],''),
				NULLIF(tsd.[shift9],''),
				NULLIF(tsd.[shift10],''),
				@scenario_group_id
			FROM #temp_scenario_detail tsd
			WHERE tsd.id = 0
			 
			
			UPDATE ms 
			SET 
				ms.risk_factor = tsd.risk_factor,
				ms.shift_group = NULLIF(tsd.[shift],''),
				ms.shift_item = NULLIF(tsd.shift_item,''),
				ms.shift_by = NULLIF(tsd.shift_by,''),
				ms.shift_value = CAST(NULLIF(tsd.shift_value,'') AS FLOAT),
				ms.month_from = NULLIF(tsd.month_from,''),
				ms.month_to = NULLIF(tsd.month_to,''),
				ms.use_existing_values = tsd.use_existing,
				ms.scenario_type = tsd.scenario_type,
				ms.[shift1] = NULLIF(tsd.[shift1],''),
				ms.[shift2] = NULLIF(tsd.[shift2],''),
				ms.[shift3] = NULLIF(tsd.[shift3],''),
				ms.[shift4] = NULLIF(tsd.[shift4],''),
				ms.[shift5] = NULLIF(tsd.[shift5],''),
				ms.[shift6] = NULLIF(tsd.[shift6],''),
				ms.[shift7] = NULLIF(tsd.[shift7],''),
				ms.[shift8] = NULLIF(tsd.[shift8],''),
				ms.[shift9] = NULLIF(tsd.[shift9],''),
				ms.[shift10] = NULLIF(tsd.[shift10],'')
			FROM #temp_scenario_detail tsd
			INNER JOIN maintain_scenario ms ON tsd.id = ms.scenario_id 
			WHERE ms.scenario_type = @scenario_type
		
			EXEC spa_ErrorHandler 0
				, 'maintain_scenario'
				, 'spa_maintain_scenario_dhx'
				, 'Success' 
				, 'Changes have been saved successfully.'
				, ''
		END
		ELSE
		BEGIN
			EXEC spa_ErrorHandler 1, 
			'maintain_scenario', 
			'spa_maintain_scenario_dhx', 
			'DB Error', 
			'Duplicate data in <b>Scenario Group</b>.',
			''
		END
	COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		SELECT @err_no = ERROR_NUMBER()

		EXEC spa_ErrorHandler @err_no
			, 'maintain_scenario'
			, 'spa_maintain_scenario_dhx'
			, 'Error'
			, @DESC
			, ''
	END CATCH
END

-- Delete scenario group and scenario
ELSE IF @flag = 'd'
BEGIN
    BEGIN TRY
		BEGIN TRAN

			DELETE ms
			FROM maintain_scenario ms
			INNER JOIN dbo.FNASplit(@del_scenario_group_id, ',') a
				ON a.item = ms.scenario_group_id

    		DELETE msg
			FROM maintain_scenario_group msg
			INNER JOIN dbo.FNASplit(@del_scenario_group_id, ',') b
				ON b.item = msg.scenario_group_id

    	COMMIT
		EXEC spa_ErrorHandler 0
			, 'maintain_scenario'
			, 'spa_maintain_scenario_dhx'
			, 'Success'
			, 'Changes have been saved successfully.'
			, @del_scenario_group_id
    END TRY
    BEGIN CATCH
    	ROLLBACK
		EXEC spa_ErrorHandler -1
			, 'maintain_scenario'
			, 'spa_maintain_scenario_dhx'
			, 'Error'
			, 'Failed to delete.'
			, ''
    END CATCH
END