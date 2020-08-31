IF OBJECT_ID('spa_dedesignate_hedges') IS NOT NULL
DROP PROC spa_dedesignate_hedges

GO
--  DROP PROC spa_dedesignate_hedges
-- EXEC spa_dedesignate_hedges '50', 1, '2/15/2003', 451 
-- exec spa_dedesignate_hedges '-228',  1,  '2007-10-23',  451

-- exec spa_dedesignate_hedges '630', 1, '2005-04-01', 451

--SELECT * FROM fas_link_header flh
--SELECT * FROM fas_link_detail flh WHERE flh.link_id=39
--SELECT * FROM fas_link_detail flh WHERE flh.link_id=219
----------REQUIRES IMPROVEMENTS---------
----------------------------------------
CREATE PROCEDURE [dbo].[spa_dedesignate_hedges] @link_id VARCHAR(MAX),
					@dedesignation_percentage VARCHAR(MAX),
					@dedesignation_date VARCHAR(20),
					@dedesignation_type INT,
					@process_id VARCHAR(100)=NULL,
					@IDs VARCHAR(MAX)=NULL
AS
SET NOCOUNT ON
--SET @dedesignation_date = dbo.fnastddate(@dedesignation_date) -- SQL date format should be passed from source.

--RETURN 
/*
---------------USE THE FOLLOWING TO TEST
DECLARE @link_id varchar(5000), @dedesignation_percentage varchar(5000), @dedesignation_date varchar(20), @dedesignation_type INT,@IDs varchar(1000),@process_id varchar(100)
SET @link_id = '321'
SET @dedesignation_percentage = '1'
SET @dedesignation_date = '2009-08-01'
SET @dedesignation_type = 451 --452
set @IDs='16'
set @process_id='1DAE09CB_BFBD_463C_AC12_729EDAF8B2F0'
--SET @from_designation ='n'
drop table #link
drop table #fas_link_header
drop table #fas_link_detail
drop table #links
drop table #links_per
drop table #temp_date_count

--*/
-----------------------
--SET @dedesignation_date = dbo.fnastddate(@dedesignation_date)

DECLARE @sql_stmt VARCHAR (8000),@time_point DATETIME,@cascade BIT
SELECT rowid=IDENTITY(INT,1,1),* INTO #links FROM dbo.SplitCommaSeperatedValues(@link_id) scsv
SELECT rowid=IDENTITY(INT,1,1),* INTO #links_per FROM dbo.SplitCommaSeperatedValues(@dedesignation_percentage) scsv
SET @time_point=GETDATE()

SET @cascade=0
IF @process_id='cascade'
BEGIN
	SET @cascade=1
	SET @process_id=NULL
END
IF NOT EXISTS(SELECT 'k' FROM   fas_link_header flh	INNER JOIN #links l ON l.item=flh.link_id)
BEGIN
	SELECT 'Error' AS ErrorCode,  'Dedesignation' AS MODULE,
	'spa_dedesignated_hedges' AS Area, 'Error' AS Status,
	( 'Failed to dedesignate Link ID: ' + CAST(@link_id AS VARCHAR) + ' not found.' ) AS MESSAGE, 'Selected Link ID not found.' AS Recommendation
	RETURN
END

IF EXISTS(SELECT 'k' FROM   fas_link_header flh	INNER JOIN #links l ON l.item=flh.link_id AND ISNULL(fully_dedesignated, 'n') = 'y' )
BEGIN
	DECLARE @dedesignated_link_ids VARCHAR(8000)
	SELECT @dedesignated_link_ids = ISNULL(@dedesignated_link_ids,'') + CASE WHEN @dedesignated_link_ids IS NULL THEN '' ELSE ',' END +
	 CAST(link_id AS VARCHAR)FROM   fas_link_header flh	INNER JOIN #links l ON l.item=flh.link_id AND ISNULL(fully_dedesignated, 'n') = 'y' 
	SELECT 'Error' AS ErrorCode,  'Dedesignation' AS MODULE,
	'spa_dedesignated_hedges' AS Area, 'Error' AS Status,
	( 'One or many relationships selected have already been fully DeDesignated: ' + CAST(@dedesignated_link_ids AS VARCHAR) + 
	' Further DeDesignation is not allowed!'
	) AS MESSAGE, 'Further DeDesignation is not allowed!' AS Recommendation
	RETURN
END

IF EXISTS(SELECT 'm' FROM #links l INNER JOIN #links_per p ON l.rowid=p.rowid WHERE CAST(p.item AS FLOAT) >1 OR  CAST(p.item AS FLOAT) <0)
BEGIN
	SELECT TOP(1) 'Error' AS ErrorCode,  'Dedesignation' AS MODULE,
	'spa_dedesignated_hedges' AS Area, 'Error' AS Status,
	( 'Failed to dedesignate Link ID: ' + l.item + ' ' + 
	CAST(CAST(p.item AS FLOAT) * 100 AS VARCHAR) + '% on ' +
	CAST(@dedesignation_date AS VARCHAR) ) AS MESSAGE, 'Please select dedesignation percentage between 0 - 100%.' AS Recommendation
	FROM #links l INNER JOIN #links_per p ON l.rowid=p.rowid
	WHERE CAST(p.item AS FLOAT) >1 OR  CAST(p.item AS FLOAT) <0
	RETURN
END


IF EXISTS(SELECT 'k' FROM   fas_link_header flh	INNER JOIN #links l ON l.item=flh.link_id WHERE @dedesignation_date<flh.link_effective_date)
BEGIN
	SELECT 'Error' AS ErrorCode,  'Dedesignation' AS MODULE,
	'spa_dedesignated_hedges' AS Area, 'Error' AS Status,
	( 'Failed to dedesignate Link ID: ' + CAST(@link_id AS VARCHAR) + '.DeDesignation date can not be prior to Hedge Effective Date.' ) AS MESSAGE, 'DeDesignation date can not be prior to Hedge Effective Date.' AS Recommendation
	RETURN
END

IF EXISTS(
SELECT  1 
	FROM   fas_dedesignated_link_header fdlh
		INNER JOIN fas_link_header flh ON flh.link_id = fdlh.original_link_id
	WHERE fdlh.original_link_id = @link_id AND fdlh.dedesignation_date = @dedesignation_date AND fdlh.eff_test_profile_id = flh.eff_test_profile_id AND fdlh.link_effective_date = flh.link_effective_date
)
BEGIN
	SELECT 'Error' AS ErrorCode,  'Dedesignation' AS MODULE,
	'spa_dedesignated_hedges' AS Area, 'Error' AS Status,
	'Link ' + CAST(@link_id AS VARCHAR(10)) + ' has already been de-designated as on = ' + dbo.FNAUserDateFormat(@dedesignation_date, dbo.FNADBUser()) + '. Please select the distinct de-designation date.' AS MESSAGE,
	'Please select the distinct de-designation date.' AS Recommendation
	RETURN
END

CREATE TABLE #temp_date_count
(distinct_date DATETIME)

SET @sql_stmt='insert into #temp_date_count
	select distinct dedesignation_date from fas_dedesignated_link_header 
	where original_link_id in (' + @link_id + ') and dbo.FNADateFormat(dedesignation_date) = ''' + dbo.FNADateFormat(@dedesignation_date) + ''''
EXEC spa_print @sql_stmt
EXEC(@sql_stmt)


--If (select count(*) from #temp_date_count) > 0
--BEGIN
--	Select 'Error' as ErrorCode,  'Dedesignation' as Module,
--	'spa_dedesignated_hedges' as Area, 'Error' as Status,
--	( 'Failed to dedesignate Link ID: ' + cast(@link_id as varchar) + ' since there has already been dedesigantion on the date ' + 
--	'''' + @dedesignation_date + '''.') as Message, 'Please select a different date of DeDesignation' as Recommendation
--	return
--END



-----------NEED TO CHECK FOR dedesignation percentage ----------
----------------------------------------------------------------
---> fix the dedesignation percentage
---> Also make the return status message more clearer (by link id give %)
---> ALSO apply commit/rollback logic
---> also check for link_effective_date
----------------------------------------------------------------
--select * from #links 
--select * from #links_per 
--
--return

--BEGIN TRY
--BEGIN TRAN
	-- Now insert for audit trail
EXEC spa_print 'insert gen NEW link  header'

	INSERT INTO fas_dedesignated_link_header
	(
		original_link_id,
		perfect_hedge,
		fully_dedesignated,
		dedesignation_date,
		dedesignated_percentage,
		link_description,
		eff_test_profile_id,
		link_effective_date,
		link_type_value_id,
		link_active,
		dedesignation_type,
		create_user,
		create_ts,
		update_user,
		update_ts
	)
	SELECT  link_id AS original_link_id, perfect_hedge, fully_dedesignated, 
		@dedesignation_date AS dedesignation_date,
		CAST(p.item AS FLOAT)  AS dedesignated_percentage, 
		CASE WHEN @cascade=1 THEN 'Cascade: ' ELSE '' END +link_description, eff_test_profile_id, link_effective_date, 
		link_type_value_id, link_active,  
		@dedesignation_type AS dedesignation_type,
		dbo.fnadbuser(), GETDATE(), dbo.fnadbuser(), GETDATE()
	FROM   fas_link_header flh
		INNER JOIN #links l ON l.item=flh.link_id
		INNER JOIN #links_per p ON l.rowid=p.rowid
EXEC spa_print 'insert gen NEW link  detail'

	INSERT INTO fas_dedesignated_link_detail
	(
		dedesignated_link_id,
		source_deal_header_id,
		percentage_included,
		hedge_or_item,
		create_user,
		create_ts,
		update_user,
		update_ts,
		effective_date
	)
	SELECT  fas_dedesignated_link_header.dedesignated_link_id, fas_link_detail.source_deal_header_id, 
		fas_link_detail.percentage_included, 
		fas_link_detail.hedge_or_item, 
			dbo.fnadbuser(), GETDATE(), dbo.fnadbuser(), GETDATE(),effective_date
	FROM    fas_link_detail INNER JOIN
			fas_dedesignated_link_header ON fas_link_detail.link_id = fas_dedesignated_link_header.original_link_id
			INNER JOIN #links l ON l.item=fas_link_detail.link_id
	WHERE   fas_dedesignated_link_header.create_ts >=@time_point			
EXEC spa_print 'insert  NEW link  header'

	--SET @sql_stmt = '
		INSERT INTO fas_link_header
		(fas_book_id,
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
		dedesignated_percentage)
		SELECT  fas_book_id, perfect_hedge, 'y' fully_dedesignated, 
			ISNULL(link_description,'') + '- DeDesignation' + CAST (ISNULL(dedesig_times, 0)+1 AS VARCHAR)   AS link_description, 
			eff_test_profile_id, link_effective_date,  
			@dedesignation_type AS link_type_value_id, 
			link_active, NULL create_user, NULL create_ts, NULL update_user, NULL update_ts,
			link_id AS original_link_id, @dedesignation_date  AS link_end_date,
			p.item AS dedesignated_percentage 	
		FROM    fas_link_header flh
		INNER JOIN #links l ON l.item=flh.link_id
			INNER JOIN #links_per p ON l.rowid=p.rowid
		LEFT OUTER JOIN
		(
			SELECT original_link_id, COUNT(*) dedesig_times FROM fas_link_header 
			WHERE original_link_id IS NOT NULL AND link_description LIKE '%- DeDesignation%'   
			GROUP BY original_link_id
		) ot ON ot.original_link_id = flh.link_id
 

EXEC spa_print 'insert  NEW link  detail'


			
	INSERT INTO fas_link_detail
	SELECT  flh.link_id, fld.source_deal_header_id, 
		fld.percentage_included * CAST(p.item AS FLOAT)  AS percentage_included, 
		fld.hedge_or_item, 
		NULL, NULL, NULL, NULL, fld.effective_date
	FROM    fas_link_detail fld INNER JOIN
			fas_link_header flh ON fld.link_id = flh.original_link_id 
			AND 		flh.create_ts >=@time_point
			INNER JOIN #links l ON l.item=fld.link_id
			INNER JOIN #links_per p ON l.rowid=p.rowid

--SELECT * FROM fas_link_detail fld WHERE link_id=237
	-- UPDATE THE EXISTING LINKS TO NEW % 
EXEC spa_print 'UPDATE THE EXISTING LINKS TO NEW % '
	UPDATE fas_link_detail
	SET percentage_included = percentage_included * (1 - CAST(p.item AS FLOAT))
	FROM fas_link_detail fld
		INNER JOIN #links l ON l.item=fld.link_id
			INNER JOIN #links_per p ON l.rowid=p.rowid
EXEC spa_print 'update2'

	UPDATE fas_link_header
	SET fully_dedesignated = 'y'
	FROM fas_link_header flh
		INNER JOIN #links l ON l.item=flh.link_id
		INNER JOIN #links_per p ON l.rowid=p.rowid
	WHERE CAST(p.item AS FLOAT)>=1


IF (@IDs IS NOT NULL) AND (@process_id IS  NULL)
BEGIN
	SELECT rowid=IDENTITY(INT,1,1),* INTO #ID1s FROM dbo.SplitCommaSeperatedValues(@IDs) scsv
	UPDATE r SET process_status='y' FROM dedesignation_criteria_result r INNER JOIN  #ID1s i ON r.row_id=i.item
END 

IF (@IDs IS NOT NULL) AND (@process_id IS NOT NULL)
BEGIN
	DECLARE @ProcessTableName VARCHAR(100),@user_name VARCHAR(100),@process_id_new VARCHAR(50)
	SET @user_name=dbo.fnadbuser()
	DECLARE @sql VARCHAR(MAX)
	SET @ProcessTableName = dbo.FNAProcessTableName('matching', @user_name, @process_id)

	IF OBJECT_ID(@ProcessTableName) IS NULL 
	BEGIN
		SELECT 'Error' AS ErrorCode,  'Dedesignation' AS MODULE,
		'spa_dedesignated_hedges' AS Area, 'Error' AS Status,
		 'Failed to dedesignate ROWIDs: ' + @IDs + '; process_id:'+@process_id+'; login_id:'+@user_name+' since there has already been deleted process table.Hence, it is required to re-run the report.' AS MESSAGE, 'Please re-run the report.' AS Recommendation
		IF @@TRANCOUNT>0
			ROLLBACK
		RETURN
	END
	SELECT rowid=IDENTITY(INT,1,1),* INTO #IDs FROM dbo.SplitCommaSeperatedValues(@IDs) scsv
--	SELECT rowid=IDENTITY(INT,1,1),* into #IDs FROM dbo.SplitCommaSeperatedValues('1,2,4') scsv
	SET @process_id_new=REPLACE(NEWID(),'-','_')
	SET @sql_stmt='
	insert into [dbo].[dedesignated_link_deal](
		[dedesignation_date],
		[link_id] ,
		source_deal_header_id ,
		[per_dedesignation] ,
		[volume_used],
		[hedged_item_deal],
		process_id )
	select link.link_end_date,link.link_id, deal.[Deal ID],deal.per_av,deal.vol_av,deal.[type],'''+@process_id_new+'''
	from (
		select [Deal ID],[Volume % Avail] per_av,[Volume Avail] vol_av,[type] from  #IDs i 
		inner join ' +@ProcessTableName+' p
		on i.item=p.rowid ) deal
	cross join
	(
		SELECT  distinct flh.original_link_id link_id, flh.link_end_date
		FROM    fas_link_detail fld INNER JOIN
				fas_link_header flh ON fld.link_id = flh.original_link_id AND flh.create_ts >='''+CAST(@time_point	AS VARCHAR)+'''
				inner join #links l on l.item=fld.link_id
				INNER JOIN #links_per p ON l.rowid=p.rowid
	) link '

	exec spa_print @sql_stmt
	EXEC(@sql_stmt)
END


	----COMMIT TRAN
SELECT	TOP(1) 'Success' AS [ErrorCode]
		, 'Dedesignation' AS [module]
		, 'spa_dedesignated_hedges' AS [Area]
		, 'Success' AS [status]
		, 'Link has been successfully dedesignated.' AS [message]
		--( 'Link ID: ' + cast(l.item as varchar) + ' ' + 
		--cast(cast(p.item AS FLOAT) * 100 AS varchar) + '% dedesignated on ' +
		--dbo.FNADateFormat(@dedesignation_date) ) as MESSAGE
		, '' AS [Recommendation]
FROM #links l 
INNER JOIN #links_per p ON l.rowid = p.rowid

