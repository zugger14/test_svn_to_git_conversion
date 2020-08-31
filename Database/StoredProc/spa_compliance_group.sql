IF OBJECT_ID(N'[dbo].[spa_compliance_group]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_compliance_group]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_compliance_group]
	@flag CHAR(1),
	@logical_name INT = NULL,
	@xmlValue TEXT = NULL,
	@xmlValue2 TEXT = NULL
AS

SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX)
	
IF @flag = 's'
BEGIN
	SET @sql = '
	SELECT cg.compliance_group_id,
		cg.assignment_type,
		cg.assigned_state,
		cg.compliance_year,
		cg.commit_type
	FROM compliance_group cg
	WHERE 1=1 AND cg.logical_name = ' + CAST(@logical_name AS VARCHAR)

	EXEC (@sql)
END

ELSE IF @flag = 'x'
BEGIN
	SET @sql = '
	SELECT compliance_group_id,
		sdv3.code [logical_name],
		sdv.code [assignment_type_name],
		sdv1.code [assigned_state_name],
		sdv2.code [compliance_year_name],
		CASE
			WHEN commit_type = ''a'' THEN ''Aggregate''
			WHEN commit_type = ''d'' THEN ''Detail''
		END	commit_type_name,
		assignment_type, 
		assigned_state, 
		compliance_year, 
		commit_type
	FROM compliance_group cg 
	LEFT JOIN (SELECT * FROM static_data_value sdv WHERE sdv.[type_id] = 10013 ) sdv ON sdv.value_id = cg.assignment_type
	LEFT JOIN (SELECT * FROM static_data_value sdv WHERE sdv.[type_id] = 10002 ) sdv1 ON sdv1.value_id = cg.assigned_state
	LEFT JOIN (SELECT * FROM static_data_value sdv WHERE sdv.[type_id] = 10092 ) sdv2 ON sdv2.value_id = cg.compliance_year
	LEFT JOIN (SELECT * FROM static_data_value sdv WHERE sdv.[type_id] = 28000 ) sdv3 ON sdv3.value_id = cg.logical_name
	WHERE 1 = 1 ' 
	
	IF @logical_name is not null
		set @sql = @sql + ' AND	cg.logical_name = ' + CAST(@logical_name AS VARCHAR)
	
	--IF @assignment_type is not null
	--	set @sql = @sql + ' AND	cg.assignment_type = ' + CAST(@assignment_type AS VARCHAR)
		
	--IF @assigned_state is not null
	--	set @sql = @sql + ' AND	cg.assigned_state = ' + CAST(@assigned_state AS VARCHAR)
		
	--IF @compliance_year is not null
	--	set @sql = @sql + ' AND	sdv2.code = ' + CAST(@compliance_year AS VARCHAR)
		
	EXEC(@sql)
END
	
ELSE 
BEGIN
	BEGIN TRY
		DECLARE @idoc INT
		DECLARE @idoc2 INT
		DECLARE @idoc3 INT
		
		DECLARE @doc VARCHAR(1000)
		DECLARE @doc2 VARCHAR(1000)
		DECLARE @doc3 VARCHAR(1000)
		
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmlValue2
		
		SELECT *
		INTO   #ztbl_xmlvalue
		FROM   OPENXML(@idoc, '/GridGroup/Grid/GridRow', 2)
				WITH (
						id INT '@id',
						compliance_group_id INT '@compliance_group_id',
						logical_name INT '@logical_name',
						ass_type INT '@ass_type',
						ass_state INT '@ass_state',
						compliance_year INT '@compliance_year',
						commit_type CHAR '@commit_type'
					)
		--SELECT * FROM #ztbl_xmlvalue
		
		EXEC sp_xml_preparedocument @idoc2 OUTPUT, @xmlValue
		
		SELECT *
		INTO   #ztbl_xmlvalue2
		FROM   OPENXML(@idoc2, '/Root/PSRecordset', 2)
				WITH (
						[type_id] VARCHAR(50) '@type_id',
						[value_id] VARCHAR(50) '@value_id',
						[code] VARCHAR(50) '@code',
						[description] VARCHAR(100) '@description'
					) 
		--SELECT * FROM #ztbl_xmlvalue2
		
		EXEC sp_xml_preparedocument @idoc3 OUTPUT, @xmlValue2
		
		SELECT *
		INTO   #delete_xmlvalue
		FROM   OPENXML(@idoc3, '/GridGroup/Grid/GridDelete', 2)
				WITH (
						id VARCHAR(50) '@id',
						logical_name INT '@logical_name'
					) 
		--SELECT * FROM #delete_xmlvalue
		
		IF @flag = 'i'
		BEGIN
			BEGIN TRAN
				MERGE dbo.static_data_value AS sdv 
				USING (
					SELECT [type_id],
						[code],
						[description],
						[value_id]
					FROM #ztbl_xmlvalue2
				) zxv2 ON sdv.[value_id] = zxv2.[value_id]

				WHEN NOT MATCHED BY TARGET THEN
				INSERT ([type_id], code, [description])
				VALUES (zxv2.[type_id],	zxv2.[code], zxv2.[description])

				WHEN MATCHED THEN
				UPDATE
				SET code = zxv2.code,
					[description] = zxv2.[description];
		    
				DECLARE @static_data_value_id INT 
				SET @static_data_value_id = (
						SELECT tsdv.[value_id]
						FROM #ztbl_xmlvalue2 tsdv
					)
		    
				IF (@static_data_value_id = '')
					SET @static_data_value_id = SCOPE_IDENTITY()

				MERGE compliance_group AS cg
				USING (
					SELECT [id],
						[logical_name],
						[ass_type],
						[ass_state],
						[compliance_year],
						[commit_type]
					FROM #ztbl_xmlvalue
				) zxv ON cg.[compliance_group_id] = zxv.[id]
		            
				WHEN NOT MATCHED BY TARGET THEN		    
				INSERT ([logical_name], [assignment_type], [assigned_state], [compliance_year], [commit_type])
				VALUES (
					zxv.[logical_name],
					CASE zxv.[ass_type]
							WHEN '' THEN NULL
							ELSE zxv.[ass_type]
					END,
					CASE zxv.[ass_state]
							WHEN '' THEN NULL
							ELSE zxv.[ass_state]
					END,
					CASE zxv.[compliance_year]
							WHEN '' THEN NULL
							ELSE zxv.[compliance_year]
					END,
					CASE zxv.[commit_type]
							WHEN '' THEN NULL
							ELSE zxv.[commit_type]
					END
				)
				WHEN MATCHED THEN
				UPDATE
				SET [logical_name]        = zxv.[logical_name],
					[assignment_type]     = CASE zxv.[ass_type]
												WHEN '' THEN NULL
												ELSE zxv.[ass_type]
											END,
					[assigned_state]      = CASE zxv.[ass_state]
												WHEN '' THEN NULL
												ELSE zxv.[ass_state]
											END,
					[compliance_year]     = CASE zxv.[compliance_year]
												WHEN '' THEN NULL
												ELSE zxv.[compliance_year]
											END,
					[commit_type]         = CASE zxv.[commit_type]
												WHEN '' THEN NULL
												ELSE zxv.[commit_type]
											END;
		    
				DELETE FROM compliance_group
				WHERE compliance_group_id IN (SELECT id FROM #delete_xmlvalue)
		    
				EXEC spa_ErrorHandler 0,
					'Compliance Group',
					'spa_compliance_group',
					'Success',
					'Changes have been saved successfully.',
					@static_data_value_id 
		    
			COMMIT
		END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
		
		DECLARE @msg VARCHAR(5000)
		SELECT @msg = 'Failed Inserting record (' + ERROR_MESSAGE() + ').'
		DECLARE @err_num INT = ERROR_NUMBER()
		IF @err_num = 2601
			SELECT @msg = 'Duplicate data in Date From.'
		ELSE 
		IF @err_num = 2627
			SELECT @msg = 'Duplicate data in (Data Type and <b>Code</b>).'
		ELSE 
		IF @err_num = 241
			SELECT @msg = 'Invalid date format in grid'
		
		EXEC spa_ErrorHandler -1,
			'Compliance Group',
			'spa_compliance_group',
			'DB Error',
			@msg,
			'Failed Inserting Record'
	END CATCH	
END

GO