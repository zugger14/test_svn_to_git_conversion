IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_nomination_group]') AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_nomination_group]
GO

CREATE PROC [dbo].[spa_nomination_group]
@flag AS CHAR(1),
@nomination_group_id AS INT = NULL,
@nomination_group AS INT = NULL,
@effective_date AS DATETIME = NULL,
@priority AS INT = NULL

AS

IF @flag = 's'
BEGIN
	DECLARE @sql_str VARCHAR(1000)
	SET @sql_str = ' 
			SELECT ng.[nomination_group_id] AS ID, 
				   sdv1.[description] AS [Nomination Group], 
				   sdv2.[description] AS [Priority], 
				   dbo.FNADateFormat(ng.[effective_date]) AS [Effective Date]
			FROM nomination_group ng
				LEFT JOIN static_data_value sdv1
					ON sdv1.value_id = ng.[nomination_group]
				LEFT JOIN static_data_value sdv2
					ON sdv2.value_id = ng.[priority]
			WHERE 1 = 1'
	IF @nomination_group IS NOT NULL 
		SET @sql_str = @sql_str + ' AND ng.[nomination_group] = ' + CAST(@nomination_group AS VARCHAR(10))
	IF @effective_date IS NOT NULL 
		SET @sql_str = @sql_str + ' AND ng.[effective_date] <= ''' + CAST(@effective_date AS VARCHAR(30)) + ''''

	exec spa_print @sql_str
	EXEC (@sql_str)			
END
ELSE IF @flag = 'i'
BEGIN
	IF EXISTS (SELECT 1 FROM nomination_group WHERE [nomination_group] = @nomination_group AND effective_date = @effective_date AND [priority] = @priority)
	BEGIN
		EXEC spa_ErrorHandler -1
							, ''
							, 'spa_nomination_group'
							, 'DBError'
							, 'The combination on Nomination Group, Effective Date and Priority already exists.'
							, ''
		RETURN
	END
	
	INSERT INTO nomination_group ([nomination_group], [effective_date], [priority])
	VALUES (@nomination_group, @effective_date, @priority)
		
	EXEC spa_ErrorHandler 0
						, ''
						, 'spa_nomination_group'
						, 'Success'
						, 'Data successfully inserted.'
						, ''
	
END
ELSE IF @flag = 'g'
	BEGIN
	SELECT 
		sdv.value_id [nomination_group_id], 
		sdv.description [nomination_group], 
		MAX(sdv1.code) [priority], 
		dbo.FNADateFormat(MAX(ng1.effective_date)) [Effective Date]
	FROM 
	static_data_value sdv
	LEFT JOIN nomination_group ng ON ng.nomination_group = sdv.value_id
	OUTER APPLY
		(SELECT  MAX(effective_date) AS effective_date
			FROM nomination_group WHERE nomination_group = ng.nomination_group
		) ng1 
			OUTER APPLY
		(SELECT  MAX([priority]) AS [priority]
			FROM nomination_group WHERE nomination_group = ng.nomination_group AND effective_date = ng1.effective_date
		) ng2 		
		LEFT JOIN static_data_value sdv1 ON sdv1.value_id = ng2.[priority]
	WHERE
		sdv.type_id = 31800
	GROUP BY sdv.value_id,sdv.description
	ORDER BY sdv.description
END
ELSE IF @flag = 'l'
	BEGIN
	SELECT ng.nomination_group_id [ID], 
	--sdv1.[description] [Nomination Group], 
	sdv1.description [Nomination Group],
	sdv2.value_id [Priority], 
	CONVERT(VARCHAR(10),ng.effective_date,120) [Effective Date]
	FROM nomination_group ng 
	INNER JOIN static_data_value sdv1 ON sdv1.value_id = ng.nomination_group
	INNER JOIN static_data_value sdv2 ON sdv2.value_id = ng.[priority]
	where ng.nomination_group = @nomination_group 
	ORDER BY [Effective Date] DESC
END

ELSE IF @flag = 'm'
	BEGIN
	SELECT nomination_group from nomination_group
	WHERE nomination_group_id = @nomination_group_id 
END


ELSE IF @flag = 'd'
BEGIN
	DELETE  from nomination_group where nomination_group_id = @nomination_group_id 
	EXEC spa_ErrorHandler 0
						, 'Process Form Data'
						, 'spa_nomination_group'
						, 'Success'
						, 'Data successfully deleted.'
						, ''
END

ELSE IF @flag = 'k'
BEGIN 
	SELECT sdv.code from nomination_group ng
	INNER JOIN static_data_value sdv ON ng.nomination_group = sdv.value_id
	where nomination_group_id = @nomination_group_id
END

ELSE IF @flag = 'e'
BEGIN
	BEGIN TRY		
		DECLARE @desc NVARCHAR(50)
		--DECLARE @desc NVARCHAR(50)
		DECLARE @nom_group_id INT
		SELECT @nom_group_id = nomination_group FROM nomination_group where nomination_group_id =  @nomination_group_id
		DELETE  from nomination_group where nomination_group = @nom_group_id
		
		EXEC spa_ErrorHandler 0
						, 'data'
						, 'spa_nomination_group'
						, 'Success'
						, 'Data successfully deleted.'
						, ''
		RETURN
		END TRY	
		BEGIN CATCH
			ROLLBACK TRAN 
			
			DECLARE @err_no INT = ERROR_NUMBER()

			IF @err_no = 547 --FK voilation
			BEGIN 
				SET @desc =  'Error Found: Data Used in other Entity.'
			END 
			ELSE 
			BEGIN 
				SET @desc = 'Error Found: ' + ERROR_MESSAGE()
			END
			
	
			EXEC spa_ErrorHandler -1, 
				'Process Form Data', 
				'spa_process_form_data', 
				'Error', 
				@desc, 
					''
			RETURN
		END CATCH

END



