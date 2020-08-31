IF OBJECT_ID(N'[dbo].[spa_hedge_relationship]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_hedge_relationship]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_hedge_relationship]
	@IDs VARCHAR(1000),
	@process_id VARCHAR(100),
	@operation VARCHAR(1) = NULL --v=verify, p=process create hedge relationship
AS

/*-- DEBUG Section --
DECLARE @IDs VARCHAR(1000),
	@process_id VARCHAR(100),
	@operation VARCHAR(1) = NULL

--*/
SET NOCOUNT ON

DECLARE @ProcessTableName VARCHAR(128),
	@user_name VARCHAR(100),
	@process_id_new VARCHAR(50),
	@sql NVARCHAR(MAX),
	@link_id INT

SET @user_name = dbo.FNADBUser()
SET @ProcessTableName = dbo.FNAProcessTableName('matching', @user_name, @process_id)
--SELECT @ProcessTableName

IF OBJECT_ID(@ProcessTableName) IS NULL
BEGIN
	SELECT 'Error' AS ErrorCode,
		'Dedesignation' AS Module,
		'spa_hedge_relationship' AS Area,
		'Error' AS [Status],
		'Failed to dedesignate ROWIDs: ' + @IDs + '; process_id:' + @process_id + '; login_id:' + @user_name + ' since there has already been deleted process table.Hence, it is required to re-run the report.' AS [Message],
		'Please re-run the report.' AS Recommendation
	IF @@TRANCOUNT > 0
		ROLLBACK
	RETURN
END

SELECT rowid = IDENTITY(INT, 1, 1), *
INTO #IDs
FROM dbo.SplitCommaSeperatedValues(@IDs) scsv
-- SELECT rowid=IDENTITY(INT,1,1),* into #IDs FROM dbo.SplitCommaSeperatedValues('1,2,4') scsv

IF OBJECT_ID('tempdb..#tmp_records') IS NOT NULL
	DROP TABLE #tmp_records

CREATE TABLE #tmp_records (no_value INT)

IF ISNULL(@operation, 'v') = 'v'
BEGIN
	SET @sql = '
		INSERT INTO #tmp_records (no_value)
		SELECT COUNT(DISTINCT curve_id)
		FROM #IDs i
		INNER JOIN '+ @ProcessTableName+' p ON i.item=p.rowid '

	--PRINT(@sql)
	EXEC(@sql)

	IF EXISTS (SELECT '1' FROM #tmp_records WHERE no_value > 1)
	BEGIN
		--Put errorCode as Success to make the message box disappear
		SELECT 'Success' AS ErrorCode,
			'Dedesignation' AS Module,
			'spa_hedge_relationship' AS Area,
			'Error' AS [Status],
			'The product (index) of hedge and item do not match. Do you want to proceed?' AS [Message],
			'Please select matched deal.' AS Recommendation
		RETURN
	END

	TRUNCATE TABLE #tmp_records
	-- DELETE adiha_process.dbo.matching_farrms_admin_6BE5C299_FBDE_4F0B_B656_EB4398F7F784 WHERE [deal id=623

	SET @sql = '
		INSERT INTO #tmp_records (no_value)
		SELECT SUM([Volume Avail] * CASE WHEN ISNULL(fbook.hedge_item_same_sign, ''n'') = ''n'' THEN 1 ELSE
					CASE WHEN p.[Type] = ''i'' THEN -1 ELSE 1 END
				END) vol
		FROM #IDs i
		INNER JOIN '+ @ProcessTableName+' p ON i.item = p.rowid
		INNER JOIN source_deal_header dh ON p.[Deal ID] = dh.source_deal_header_id
		INNER JOIN source_system_book_map sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1
			AND dh.source_system_book_id2 = sbmp.source_system_book_id2
			AND dh.source_system_book_id3 = sbmp.source_system_book_id3
			AND dh.source_system_book_id4 = sbmp.source_system_book_id4
		INNER JOIN portfolio_hierarchy p_book ON sbmp.fas_book_id = p_book.entity_id
		INNER JOIN fas_books fbook ON fbook.fas_book_id = p_book.entity_id
	'
	--PRINT(@sql)
	EXEC(@sql)

	IF EXISTS (SELECT '1' FROM #tmp_records WHERE no_value >= 1)
	BEGIN
		--Put errorCode as Success to make the message box disappear
		SELECT 'Success' AS ErrorCode,
			'Dedesignation' AS Module,
			'spa_hedge_relationship' AS Area,
			'Error' AS [Status],
			'The volume of hedge and item do not match. If volume do not match, you may have to adjust % later. Do you want to proceed?' AS [Message],
			'Please select matched deal.' AS Recommendation
		RETURN
	END

	SELECT 'Success' AS ErrorCode,
		'Designation' AS Module,
		'spa_hedge_relationship' AS Area,
		'Success' AS [Status],
		'The validation for  matching criteria is passed.' AS [Message],
		'0' AS Recommendation
	RETURN
END

TRUNCATE TABLE #tmp_records
-- DELETE adiha_process.dbo.matching_farrms_admin_6BE5C299_FBDE_4F0B_B656_EB4398F7F784 WHERE [deal id] = 623

SET @sql = '
		INSERT INTO #tmp_records (no_value)
		SELECT 1
		FROM #IDs i
		INNER JOIN '+ @ProcessTableName+' p ON i.item = p.rowid
		WHERE p.[deal ref id] = ''Offset_deal''
	'

--PRINT(@sql)
EXEC(@sql)

IF EXISTS (SELECT '1' FROM #tmp_records)
BEGIN
	--Put errorCode as Success to make the message box disappear
	SELECT 'Error' AS ErrorCode,
		'Dedesignation' AS Module,
		'spa_hedge_relationship' AS Area,
		'Error' AS [Status],
		'An offset deal is not supported by this operation.' AS [Message],
		'Please select other deal.' AS Recommendation
	RETURN
END

TRUNCATE TABLE #tmp_records

SET @sql = '
	INSERT INTO #tmp_records (no_value)
	SELECT COUNT(DISTINCT tenor)
	FROM (
		SELECT [Type], CONVERT(VARCHAR(10), MIN(term_start), 120) + '' ~ '' + CONVERT(VARCHAR(10), MAX(term_start), 120) tenor
		FROM #IDs i
		INNER JOIN ' + @ProcessTableName + ' p ON i.item = p.rowid
		GROUP BY [Type]
	) a
'

--PRINT(@sql)
EXEC(@sql)

IF EXISTS (SELECT '1' FROM #tmp_records WHERE no_value>1)
BEGIN
	SELECT 'Error' AS ErrorCode,
		'designation' AS Module,
		'spa_hedge_relationship' AS Area,
		'Error' AS [Status],
		'Failed to create hedge relationship since the tenor of selected hedge and item deals are not matched.' AS [Message],
		'Please check min term start and max term end of hedge and item.' AS Recommendation
	RETURN
END

TRUNCATE TABLE #tmp_records

SET @sql = '
	INSERT INTO #tmp_records (no_value)
	SELECT ISNULL(MAX(eff_test_profile_id), -1)
	FROM #IDs i
	INNER JOIN ' + @ProcessTableName + ' p ON i.item = p.rowid
'

--PRINT(@sql)
EXEC(@sql)

IF EXISTS (SELECT '1' FROM #tmp_records where no_value < 0)
BEGIN
	SELECT 'Error' AS ErrorCode,
		'designation' AS Module,
		'spa_hedge_relationship' AS Area,
		'Error' AS [Status],
		'Failed to create hedge relationship since the product (index) is not defined in hedge relationship type. ' AS [Message],
		'Please check in hedge relationship type.' AS Recommendation
	RETURN
END

BEGIN TRY
	BEGIN TRAN
		/*** USING SCOPE_IDENTITY() Inside dynamic query **/
		DECLARE @Params NVARCHAR(500);
		SET @Params = N'@link_id INT OUTPUT';

		SET @sql = '
			INSERT INTO fas_link_header (
				fas_book_id,
				perfect_hedge,
				fully_dedesignated,
				link_description,
				eff_test_profile_id,
				link_effective_date,
				link_type_value_id,
				link_active,
				create_user,
				create_ts,
				update_user,
				update_ts,
				original_link_id,
				link_end_date,
				dedesignated_percentage
			)
			SELECT CASE WHEN MAX(p.fas_book_id) <= 0 THEN 7 ELSE MAX(p.fas_book_id) END fas_book_id,
				''n'',
				''n'' fully_dedesignated,
				MAX(CASE WHEN [type] = ''h'' THEN [Deal REF ID] ELSE '''' END) + ''/'' +
					MAX(CASE WHEN [type] = ''i'' THEN [Deal REF ID] ELSE '''' END) + 
					''('' + MAX([Hedged Item Product]) + '' '' + MAX([Tenor]) +'')'' AS link_description,
				CASE WHEN MAX(p.eff_test_profile_id) <= 0 THEN 1 ELSE MAX(p.eff_test_profile_id) END eff_test_profile_id,
				MAX(link_effective_date) link_effective_date,
				450 AS link_type_value_id,
				''y'' link_active,
				''' + @user_name + ''' create_user,
				GETDATE() create_ts,
				''' + @user_name + ''' update_user,
				GETDATE() update_ts,
				NULL original_link_id,
				NULL link_end_date,
				NULL dedesignated_percentage
			FROM #IDs i
			INNER JOIN ' + @ProcessTableName + ' p ON i.item = p.rowid 
			
			SET @link_id = SCOPE_IDENTITY() '
		
		--PRINT(@sql)
		--EXEC(@sql)
		EXEC sp_executesql @sql, @Params, @link_id = @link_id OUTPUT;

		--PRINT @link_id
		SET @sql = '
			INSERT INTO fas_link_detail (
				link_id,
				source_deal_header_id,
				percentage_included,
				hedge_or_item,
				create_user,
				create_ts,
				update_user,
				update_ts,
				effective_date
			)
			SELECT ' + CAST(@link_id AS VARCHAR) + ',
				p.[deal id],
				p.[Volume % Avail],
				p.[type],
				''' + @user_name + ''' create_user,
				GETDATE() create_ts,
				''' + @user_name + ''' update_user,
				GETDATE() update_ts,
				flh.link_effective_date
			FROM #IDs i
			INNER JOIN ' + @ProcessTableName + ' p ON i.item = p.rowid
			LEFT JOIN fas_link_header flh ON flh.link_id = ' + CAST(@link_id AS VARCHAR)

		--PRINT(@sql)
		EXEC(@sql)

		--don't put Success as ErrorCode to persist the messagebox.
		SELECT 'Done' AS ErrorCode,
			'Designation' AS Module,
			'spa_hedge_relationship' AS Area,
			'Success' AS [Status],
			'Successfully create hedge relationship as link id ' + CAST(@link_id AS VARCHAR(20)) AS [Message],
			@link_id AS Recommendation
		
		COMMIT TRAN
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN

	SELECT 'Error' AS ErrorCode,
		'Designation' as Module,
		'spa_hedge_relationship' AS Area,
		'Error' AS [Status],
		'Fail to create hedge relationship(' + ERROR_MESSAGE() + ')' AS [Message],
		'n/a' AS Recommendation
END CATCH

/*
select * from fas_link_header order by create_ts desc 
select * from fas_link_detail order by create_ts desc
select * from fas_link_detail where link_id =255
fas_link_header where link_id =255
delete fas_link_detail where link_id >=254
delete fas_link_header where link_id >=254
*/

GO