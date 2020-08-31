
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_source_major_location]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_source_major_location]
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
/************************************************************************************/
/*	Modified By: Pawan KC														   */
/*	Modified By:22/03/2009														   */
/*	Description:Added fields operator,counterparty,contract,volume,uom as tables   */
/*				source_major_location,major_location_detail are merged.			   */
/************************************************************************************/

CREATE PROC [dbo].[spa_source_major_location]
@flag VARCHAR(1),
@source_major_location_ID INT = NULL,
@source_system_id INT = NULL,
@location_name VARCHAR(100) = NULL,
@location_description VARCHAR(255) = NULL,
@location_type INT = NULL,
@region INT = NULL,
@owner VARCHAR(250) = NULL,
@operator VARCHAR(100) = NULL,
@counterparty INT = NULL,
@contract INT = NULL,
@volume FLOAT = NULL,
@uom INT = NULL,
@filter_value  VARCHAR(max) = NULL

--@major_location_detail_id int =null
AS
DECLARE @Sql_Select VARCHAR(3000), @msg_err VARCHAR(2000)

SELECT @filter_value = NULLIF(NULLIF(@filter_value, '<FILTER_VALUE>'), '')

IF @source_system_id IS NULL
	SET @source_system_id=2

IF @flag IN ('c', 'x')
BEGIN
	CREATE TABLE #final_privilege_list(value_id INT, is_enable VARCHAR(20) COLLATE DATABASE_DEFAULT )
	EXEC spa_static_data_privilege @flag = 'p', @source_object = 'location_group'
END

BEGIN TRY
	IF  @flag = 'i'
	BEGIN
		DECLARE @count VARCHAR(100)
        SELECT  @count = COUNT(*)
        FROM source_major_location
        WHERE location_name = @location_name  
        IF ( @count > 0 ) 
            BEGIN
                EXEC spa_ErrorHandler @count,
                    "This data already exist",
                    "spa_source_major_location", "DB Error",
                    "This data already exist", ''
                RETURN
            END
	
		INSERT INTO [dbo].[source_major_location](
					[source_system_id]
					,[location_name]
					,[location_description]
					,[location_type]
					,[region]
					,[owner]
					,[operator]
					,[counterparty]
					,[contract]
					,[volume]
					,[uom]
					
			)
			 VALUES(
					 @source_system_id
					,@location_name
					,@location_description
					,@location_type
					,@region
					,@owner
					,@operator 
					,@counterparty 
					,@contract 
					,@volume 
					,@uom 
		)
	END
	
	ELSE IF  @flag = 'u'
		UPDATE [dbo].[source_major_location]
		SET [source_system_id] =@source_system_id
			,[location_name] =@location_name
			,[location_description] =@location_description
			,[location_type] =@location_type
			,[region] =@region
			,[owner] =@owner
			,[operator]=@operator 
			,[counterparty]=@counterparty 
			,[contract]=@contract
			,[volume]=@volume 
			,[uom]=@uom

		 WHERE source_major_location_id=@source_major_location_id
		 
	ELSE IF  @flag = 's'
	BEGIN
		SET @Sql_Select=' 	
			SELECT 
			 sm.[source_major_location_ID] AS [Source Major Location ID]
			  ,sm.[location_name] as [Location Group]
			  ,sm.[location_description] as [Description]
			  ,sdv1.[code] as [Location Type]
			  ,sdv.[code] as Region
			  ,sm.[owner] as Owner
              ,sm.[operator] as Operator
			  ,sc.[counterparty_name] as Counterparty
			  ,cg.[contract_name] as Contract
			  ,sm.[volume] as Volume
			  ,su.[uom_name] as UOM  
		  FROM [dbo].[source_major_location] sm
		  LEFT JOIN static_data_value sdv1 ON sdv1.value_id=sm.location_type
		  LEFT JOIN static_data_value sdv ON sdv.value_id=sm.region
		  LEFT JOIN source_counterparty sc ON sm.counterparty=sc.source_counterparty_id
		  LEFT JOIN contract_group cg ON cg.contract_id=sm.contract
		  LEFT JOIN source_uom su ON su.source_uom_id=sm.uom
		  '

		IF @source_system_id IS NOT NULL
			SET @Sql_Select=@Sql_Select +  ' where sm.source_system_id=' + CONVERT(VARCHAR(20), @source_system_id)
		
		EXEC(@SQL_select)
	END
	ELSE IF  @flag = 'k'
	BEGIN
		
		CREATE TABLE #temp_location(source_major_location_id INT)
		
		INSERT INTO #temp_location
		SELECT source_minor_location_id FROM [dbo].source_minor_location S
		INNER JOIN delivery_path dp on S.source_major_location_id = dp.from_location
		WHERE dp.imbalance_from = 'y'
		
		INSERT INTO #temp_location
		SELECT source_minor_location_id FROM [dbo].source_minor_location S
		INNER JOIN delivery_path dp on S.source_major_location_id = dp.to_location
		WHERE dp.imbalance_to = 'y'
		
		SET @Sql_Select=' 	
			SELECT 
			 sm.[source_major_location_ID]
			  ,sm.[location_name] as [Name]
			  ,sm.[location_description] as [Description]
			  ,sdv1.[code] as [Location Type]
			  ,sdv.[code] as Region
			  ,sm.[owner] as Owner
              ,sm.[operator] as Operator
			  ,sc.[counterparty_name] as Counterparty
			  ,cg.[contract_name] as Contract
			  ,sm.[volume] as Volume
			  ,su.[uom_name] as UOM  
		  FROM [dbo].[source_major_location] sm
		  INNER JOIN #temp_location tl on sm.source_major_location_id = tl.source_major_location_id
		  LEFT JOIN static_data_value sdv1 ON sdv1.value_id=sm.location_type
		  LEFT JOIN static_data_value sdv ON sdv.value_id=sm.region
		  LEFT JOIN source_counterparty sc ON sm.counterparty=sc.source_counterparty_id
		  LEFT JOIN contract_group cg ON cg.contract_id=sm.contract
		  LEFT JOIN source_uom su ON su.source_uom_id=sm.uom
		  '

		IF @source_system_id IS NOT NULL
			SET @Sql_Select=@Sql_Select +  ' where sm.source_system_id=' + CONVERT(VARCHAR(20), @source_system_id)
		exec spa_print @SQL_select
		EXEC(@SQL_select)
	END

	ELSE IF  @flag = 'd'
	BEGIN
		BEGIN TRY
			BEGIN TRAN
				DELETE [dbo].[source_major_location] WHERE source_major_location_ID=@source_major_location_ID
				EXEC spa_ErrorHandler 0
				, 'MaintainDefination'
				, 'spa_source_major_location'
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
				, 'spa_source_major_location'
				, 'DB Error'
				, 'Selected data is in use and cannot be deleted.'
				, 'Foreign key constrains'
		END CATCH
	END
		
	ELSE IF  @flag = 'a'
			SELECT	[source_major_location_ID]
					,[source_system_id]
					,[location_name]
					,[location_description]
					,[create_user]
					,[create_ts]
					,[update_user]
					,[update_ts]
					,[location_type]
					,[region] 
					,[owner]
					,[operator]
					,[counterparty]
					,[contract]
					,[volume]
					,[uom] 
			  FROM [dbo].[source_major_location]
			WHERE source_major_location_id=@source_major_location_id
	

	DECLARE @msg VARCHAR(2000)
	SELECT @msg=''
	if @flag='i'
		SET @msg='Data Successfully Inserted.'
	ELSE if @flag='u'
		SET @msg='Data Successfully Updated.'
	ELSE if @flag='d'
		SET @msg='Data Successfully Deleted.'

	IF @msg<>''
		EXEC spa_ErrorHandler 0, 'source_major_location table', 
				'spa_source_major_location', 'Success', 
				@msg, ''
END TRY
BEGIN CATCH
	DECLARE @error_number INT
	SET @error_number = error_number()
	SET @msg_err = ''
	
	IF @flag = 'i'
		SET @msg_err='Fail Insert Data.'
	ELSE IF @flag = 'u'
		SET @msg_err = 'Fail Update Data.'
	ELSE IF @flag = 'd'
		SET @msg_err='Fail Delete Data.'
	--SET  @msg_err=@msg_err +'(Err_No:' +cast(@error_number as VARCHAR) + '; Description:' + error_message() +'.'
	EXEC spa_ErrorHandler @error_number
						, 'source_major_location table'
						, 'spa_source_major_location'
						, 'DB Error'
						, @msg_err
						, ''
END CATCH

IF @flag = 'x' -- Location Group Dropdown with privilege
BEGIN
	SET @Sql_Select = 'SELECT sml.source_major_location_ID, 
								sml.location_name,
								MIN(fpl.is_enable) [status]
						FROM #final_privilege_list fpl
						' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
							source_major_location sml ON sml.source_major_location_id = fpl.value_id 
						GROUP BY sml.source_major_location_ID, sml.location_name'
	EXEC(@Sql_Select)
END
ELSE IF  @flag = 'c'--Modified to add privilege
BEGIN
	SET @Sql_Select=' 	
		SELECT 
			sml.[source_major_location_ID] AS [Source Major Location ID],
			sml.[location_name] as [Location Group],
			MIN(fpl.is_enable) [status]
		FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
			source_major_location sml ON sml.source_major_location_id = fpl.value_id
		LEFT JOIN static_data_value sdv1 ON sdv1.value_id=sml.location_type
		LEFT JOIN static_data_value sdv ON sdv.value_id=sml.region
		LEFT JOIN source_counterparty sc ON sml.counterparty=sc.source_counterparty_id
		LEFT JOIN contract_group cg ON cg.contract_id=sml.contract
		LEFT JOIN source_uom su ON su.source_uom_id=sml.uom'

	IF @filter_value IS NOT NULL AND @filter_value <> '-1' 
	BEGIN
		SET @sql_select += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @filter_value + ''') s ON s.item = sml.[source_major_location_ID]'
	END	

	IF @source_system_id IS NOT NULL
		SET @Sql_Select=@Sql_Select +  ' WHERE sml.source_system_id=' + CONVERT(VARCHAR(20), @source_system_id)
		
	SET @Sql_Select += ' GROUP BY sml.[source_major_location_ID], sml.[location_name]'
	EXEC(@SQL_select)
END
