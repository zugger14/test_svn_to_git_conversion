
IF OBJECT_ID(N'[dbo].[spa_counterparty_contract_rate_schedule]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_counterparty_contract_rate_schedule]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: msingh@pioneersolutionsglobal.com
-- Create date: 2014-03-24
-- Description: CRUD operations for table counterparty_contract_rate_schedule
 
-- Params:
-- @flag CHAR(1) - Operation flag

-- [spa_counterparty_contract_rate_schedule] @flag ='a', @path_id = '1282,1283,1284', @counterparty_id= 4348

-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_counterparty_contract_rate_schedule]
    @flag					CHAR(1)
	, @counterparty_id		INT = NULL
	, @contract_id			INT = NULL
	, @rate_schedule_id		INT = NULL
	, @new_contract_id		INT = NULL
	, @path_id				VARCHAR(500) = NULL
	, @mode					CHAR(1) = 'u'
AS
SET NOCOUNT ON
DECLARE @err_msg VARCHAR(250)
DECLARE @sql VARCHAR(MAX)
		
IF @flag = 's'
BEGIN
	SELECT contract_id, rate_schedule_id
	FROM counterparty_contract_rate_schedule
END
ELSE IF @flag = 'a'
BEGIN
	SELECT ccrs.contract_id [Contract ID], cg.contract_name [Contract], ccrs.rate_schedule_id [Rate Schedule ID], sdv.code [Rate Schedule], ccrs.path_id [Path Id]
	FROM counterparty_contract_rate_schedule ccrs
	INNER JOIN contract_group cg ON cg.contract_id = ccrs.contract_id
	LEFT JOIN static_data_value sdv ON sdv.value_id = ccrs.rate_schedule_id AND sdv.[type_id] = 1800 --Transportation Rate Schedule
	WHERE counterparty_id = @counterparty_id
	AND path_id = @path_id
	
END
ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
		
		INSERT INTO counterparty_contract_rate_schedule(counterparty_id, contract_id, rate_schedule_id, path_id)
		VALUES(@counterparty_id, @contract_id, @rate_schedule_id, @path_id)
		
		EXEC spa_ErrorHandler 0
		, 'counterparty_contract_rate_schedule'			-- Name the tables used in the query.
		, 'spa_counterparty_contract_rate_schedule'		-- Name the stored proc.
		, 'Success'										-- Success message is case of successful operation.
		, 'Successfully saved data.'					-- Operations status.
		, ''
		
	END TRY
	BEGIN CATCH		
		SET @err_msg = ERROR_MESSAGE()	
		
		EXEC spa_ErrorHandler 1
		, 'counterparty_contract_rate_schedule' 
		, 'spa_counterparty_contract_rate_schedule'
		, 'Error' 
		, 'Failed to save data.'
		, @err_msg
	END CATCH	
END
ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		SET @sql = '
			UPDATE counterparty_contract_rate_schedule
			SET rate_schedule_id = ' + CAST(@rate_schedule_id AS VARCHAR(10))  +
			CASE WHEN ISNULL(@new_contract_id, '') <> @contract_id 
				THEN ', contract_id = ' + CAST(@new_contract_id AS VARCHAR(10)) ELSE '' END + '				
			WHERE counterparty_id = ' + CAST(@counterparty_id AS VARCHAR(10)) + '
				AND contract_id = ' + CAST(@contract_id AS VARCHAR(10))	+ '
				AND path_id = ' + CAST(@path_id AS VARCHAR(10))	
			
		EXEC(@sql)	
				
	EXEC spa_ErrorHandler 0
		, 'counterparty_contract_rate_schedule'			-- Name the tables used in the query.
		, 'spa_counterparty_contract_rate_schedule'		-- Name the stored proc.
		, 'Success'										-- Success message is case of successful operation.
		, 'Successfully updated data.'					-- Operations status.
		, ''
	END TRY
	BEGIN CATCH
		SET @err_msg = ERROR_MESSAGE()
		
		EXEC spa_ErrorHandler 1
		, 'counterparty_contract_rate_schedule' 
		, 'spa_counterparty_contract_rate_schedule'
		, 'Error' 
		, 'Failed to update data.'
		, @err_msg
		
	END CATCH
END
ELSE IF @flag = 'd'
BEGIN
	DELETE FROM counterparty_contract_rate_schedule 
	WHERE counterparty_id = @counterparty_id
			AND contract_id = @contract_id	
			AND path_id = @path_id
END
ELSE IF @flag = 'g'
BEGIN
	IF @mode = 'i'
	BEGIN

		IF OBJECT_ID(N'tempdb..#counterparty_list') IS NOT NULL
			DROP TABLE #counterparty_list

		IF OBJECT_ID(N'tempdb..#contract_list') IS NOT NULL
			DROP TABLE #contract_list

		CREATE TABLE #counterparty_list(source_counterparty_id INT, counterparty VARCHAR(200), [status] VARCHAR(20))
		CREATE TABLE #contract_list(contract_id INT, [Name] VARCHAR(200), [status] VARCHAR(20))

		INSERT INTO #counterparty_list
		EXEC spa_source_counterparty_maintain @flag = 'c'

		INSERT INTO #contract_list
		EXEC spa_contract_group @flag = 'p'

		SELECT TOP 1 
			'' counterparty_contract_rate_schedule_id,
			cl.source_counterparty_id counterparty_id ,
			cll.contract_id,
			'' rate_schedule_id,
			'' [rank] FROM #counterparty_list cl
			OUTER APPLY (SELECT TOP 1 contract_id FROM #contract_list ) cll
					
	END
	ELSE
	BEGIN
		SELECT
			ccrs.counterparty_contract_rate_schedule_id,
			ccrs.counterparty_id,
			ccrs.contract_id,
			ccrs.rate_schedule_id,
			ccrs.rank
		FROM counterparty_contract_rate_schedule ccrs
		--INNER JOIN source_counterparty sc ON sc.source_counterparty_id = ccrs.counterparty_id
		WHERE  ccrs.path_id = @path_id -- AND
		--ccrs.counterparty_id = @counterparty_id
	END

	
END
ELSE IF @flag = 'p' --Used for Contract Path dropdown and added privilege
BEGIN
	CREATE TABLE #final_privilege_list(value_id INT, is_enable VARCHAR(20) COLLATE DATABASE_DEFAULT )
	EXEC spa_static_data_privilege @flag = 'p', @source_object = 'contract'
	
	SET @sql = '
				SELECT DISTINCT cg.contract_id ID,
						CASE WHEN cg.source_contract_id <> cg.[contract_name] THEN cg.source_contract_id + '' - '' + cg.[contract_name] ELSE cg.[contract_name] END 
						 + CASE WHEN cg.source_system_id=2 THEN '''' ELSE CASE WHEN cg.source_system_id IS NULL THEN '''' ELSE ''.'' + ssd.source_system_name END END AS Name,
						 MIN(fpl.is_enable) [status]
				FROM #final_privilege_list fpl 
				' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
					 contract_group cg ON cg.contract_id = fpl.value_id
					LEFT JOIN source_system_description ssd on	ssd.source_system_id = cg.source_system_id
					INNER JOIN (
						SELECT contract_id 
						FROM counterparty_contract_rate_schedule c
							INNER JOIN dbo.SplitCommaSeperatedValues(''' + @path_id + ''')AS scsv
								ON scsv.item = c.path_id
						UNION
						SELECT contract FROM delivery_path dp
							INNER JOIN dbo.SplitCommaSeperatedValues(''' + @path_id + ''')AS scsv
								ON scsv.item = dp.path_id
					) c
					ON cg.contract_id = c.contract_id
				'
	SET @sql += 'GROUP BY cg.contract_id, cg.source_contract_id, cg.contract_name, cg.source_system_id, ssd.source_system_name ORDER BY Name'	
	EXEC(@sql)
END

