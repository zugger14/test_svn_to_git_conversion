IF OBJECT_ID(N'spa_reject_finalized_link', N'P') IS NOT NULL
	DROP PROCEDURE spa_reject_finalized_link
GO 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/**
This sp deletes a finalized generated hedging relationship
In addition to deleting the link this also deletes hedged items transactions
	Parameters: 
	@link_id  : Link IDs

*/

CREATE PROCEDURE [dbo].[spa_reject_finalized_link] 
	@link_id VARCHAR(MAX)
AS

SET NOCOUNT ON
DECLARE @source_deal_header_id VARCHAR(1000)

SELECT fld.source_deal_header_id 
INTO #temp
FROM fas_link_detail fld 
INNER JOIN source_deal_header sdh ON fld.source_deal_header_id=sdh.source_deal_header_id 
	AND hedge_or_item = 'i' 
INNER JOIN dbo.SplitCommaSeperatedValues(@link_id) i on i.item = fld.link_id
INNER JOIN gen_deal_header gdh ON  sdh.deal_id=gdh.deal_id

SELECT @source_deal_header_id=ISNULL(@source_deal_header_id +',','')+ CAST(source_deal_header_id AS VARCHAR) FROM  #temp
CREATE TABLE #returnval (
	[errorcode]			VARCHAR(500) COLLATE DATABASE_DEFAULT, 
	[message]			VARCHAR(500) COLLATE DATABASE_DEFAULT,
	[area]				VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[status]			VARCHAR(50)	COLLATE DATABASE_DEFAULT,
	[module]			VARCHAR(500) COLLATE DATABASE_DEFAULT,
	[recommendation]	VARCHAR(500) COLLATE DATABASE_DEFAULT
)

CREATE TABLE #error_handler (
	[errorcode]			VARCHAR(500) COLLATE DATABASE_DEFAULT, 
	[module]			VARCHAR(500) COLLATE DATABASE_DEFAULT,
	[area]				VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[status]			VARCHAR(50) COLLATE DATABASE_DEFAULT,
	[message]			VARCHAR(500) COLLATE DATABASE_DEFAULT,
	[recommendation]	VARCHAR(500) COLLATE DATABASE_DEFAULT
)
--EXEC spa_ErrorHandler 0, 'Link Header Table',   
--		'spa_faslinkheader', 'Success', 'Hedging Relationship ID deleted.', ''  
--		return
BEGIN TRY
	BEGIN TRAN

	IF OBJECT_ID('adiha_process.dbo.validation_table_farrms_admin_to_delete') IS NULL 
	BEGIN 
		CREATE TABLE adiha_process.dbo.validation_table_farrms_admin_to_delete (
			ErrorCode VARCHAR(500), 
			MODULE  VARCHAR(500),
			Area VARCHAR(100),
			Status VARCHAR(50),
			Message VARCHAR(500),
			Recommendation VARCHAR(500))	
	END
 
	EXEC spa_faslinkheader 'd', @link_id

	INSERT INTO #error_handler 
	SELECT * FROM adiha_process.dbo.validation_table_farrms_admin_to_delete
 
 	IF EXISTS(SELECT errorcode FROM #error_handler WHERE errorcode='Error')
	BEGIN
		SELECT * FROM #error_handler
		ROLLBACK TRAN
		IF OBJECT_ID('adiha_process.dbo.validation_table_farrms_admin_to_delete') IS NOT NULL 
			DROP TABLE adiha_process.dbo.validation_table_farrms_admin_to_delete
		RETURN
	END

	DECLARE @st_where VARCHAR(1000)
	--SET @st_where='link_id = '+CAST(@link_id AS VARCHAR)+' and link_type = ''link'''

	----exec spa_delete_ProcessTable 'calcprocess_deals',@st_where
	--	EXEC('delete calcprocess_deals where ' + @st_where)

	DELETE rs
	FROM calcprocess_deals rs
	INNER JOIN dbo.SplitCommaSeperatedValues(@link_id) i on i.item = rs.link_id
	WHERE rs.link_type = 'link'

	--delete from gen_fas_link_detail
	--SELECT * 
	DELETE FROM gfld
	FROM gen_fas_link_header gflh
	INNER JOIN  fas_link_header flh ON flh.link_description = gflh.link_description
	INNER JOIN dbo.FNASplit(@link_id, ',') z On z.item = flh.link_id 
	INNER JOIN gen_fas_link_detail gfld ON gfld.gen_link_id = gflh.gen_link_id

	--delete from gen_fas_link_header
	--SELECT * 
	DELETE FROM gflh
	FROM gen_fas_link_header gflh
	INNER JOIN  fas_link_header flh ON flh.link_description = gflh.link_description
	INNER JOIN dbo.FNASplit(@link_id, ',') z On z.item = flh.link_id 
 
	----EXEC spa_delete_ProcessTable 'calcprocess_deals',@st_where
	--	EXEC('delete calcprocess_deals where ' + @st_where)
	IF OBJECT_ID('tempdb..#to_delete_gen_deal_header_id') IS NOT NULL 
		DROP TABLE #to_delete_gen_deal_header_id

	SELECT gdh.gen_deal_header_id
		INTO #to_delete_gen_deal_header_id
	FROM gen_deal_header gdh
	INNER JOIN gen_deal_detail gdd ON gdh.gen_deal_header_id = gdd.gen_deal_header_id
	INNER JOIN source_deal_header sdh ON sdh.deal_id = gdh.deal_id
	INNER JOIN dbo.FNASplit(@source_deal_header_id, ',') z On z.item = sdh.source_deal_header_id 
	--WHERE sdh.source_deal_header_id IN (@source_deal_header_id)

	DELETE gdd
	FROM gen_deal_detail gdd 
	INNER JOIN #to_delete_gen_deal_header_id del ON gdd.gen_deal_header_id = del.gen_deal_header_id

	DELETE gdh
	FROM gen_deal_header gdh 
	INNER JOIN #to_delete_gen_deal_header_id del ON gdh.gen_deal_header_id = del.gen_deal_header_id

	DECLARE @st1 VARCHAR(8000)
	SET @st1=''
	--select @st1= @st1+case when isnull(@st1,'')='' then '' else ' ; ' end + 'delete source_Deal_pnl'+isnull(prefix_location_table,'')+ ' where source_deal_header_id IN
	--(select source_deal_header_id from #temp)' from process_table_location where tbl_name='source_deal_pnl' group by prefix_location_table

	SELECT @st1 = @st1 + CASE WHEN ISNULL(@st1, '') = '' THEN '' ELSE ' ; ' END + 'delete '
				 + CASE WHEN ISNULL(MAX(dbase_name), 'dbo') = 'dbo' THEN 'dbo' ELSE MAX(dbase_name) + '.dbo' END + '.source_Deal_pnl'
					+ ISNULL(prefix_location_table, '') + ' WHERE source_deal_header_id IN
				 (SELECT source_deal_header_id FROM #temp)' 
	FROM process_table_archive_policy WHERE tbl_name = 'source_Deal_pnl' GROUP BY prefix_location_table

	--PRINT @st1
	EXEC(@st1)

	--Now delete the item deals
	IF @source_deal_header_id IS NOT NULL
	BEGIN
		EXEC [dbo].[spa_sourcedealheader] @flag = 'd', @source_deal_header_id = @source_deal_header_id, @call_from_import = 'y'

		IF EXISTS (SELECT 1 FROM #returnval WHERE ErrorCode = 'Error')
		BEGIN
			ROLLBACK 
			SELECT * FROM #returnval 
			RETURN
		END
	END

	IF OBJECT_ID('adiha_process.dbo.validation_table_farrms_admin_to_delete') IS NOT NULL 
		DROP TABLE adiha_process.dbo.validation_table_farrms_admin_to_delete
	 
	COMMIT TRAN
	--SELECT * FROM #error_handler	
	EXEC spa_ErrorHandler 0, 'Link Header Table',   
		'spa_faslinkheader', 'Success', 'Hedging Relationship ID deleted.', ''  
END TRY
BEGIN CATCH
	ROLLBACK
	SELECT  'Error', ErrorCode, ERROR_MESSAGE() [description], Area, r.[Status], r.Module, r.Recommendation
	FROM #returnval r
END CATCH
	
GO