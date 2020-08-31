


/****** Object:  StoredProcedure [dbo].[spa_manual_curve_movement]    Script Date: 08/24/2012 13:46:45 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_manual_curve_movement]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_manual_curve_movement]
GO



/****** Object:  StoredProcedure [dbo].[spa_manual_curve_movement]    Script Date: 08/24/2012 13:46:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[spa_manual_curve_movement] 
@archive_type_value_id		INT = NULL
AS

SET NOCOUNT ON


DECLARE @tbl_name		VARCHAR(100)
DECLARE @stage_tbl_name VARCHAR(100)
DECLARE @ex_curve_id	VARCHAR(500)
DECLARE @period			NUMERIC(20,0)
DECLARE @st				VARCHAR(MAX)
DECLARE @st1			VARCHAR(MAX)
DECLARE @st2			VARCHAR(MAX)
DECLARE @min_date		DATETIME
DECLARE @message		VARCHAR(255)
DECLARE @user_name		VARCHAR(100)
DECLARE @process_id		VARCHAR(100)	
SET @user_name = dbo.FNADBUser()

IF @process_id IS NULL
	BEGIN
		SET @process_id = REPLACE(newid(), '-', '_')
	END
BEGIN TRY

		
--SELECT @tbl_name = main_table_name , @stage_tbl_name = staging_table_name 
--FROM archive_data_policy adp 
--WHERE adp.archive_type_value_id = @archive_type_value_id

SELECT @ex_curve_id = curve_id , @period = period
FROM manual_partition_config_info mpci
WHERE archive_type_value_id = @archive_type_value_id
AND mpci.del_flg = 'TRUE'
--DROP TABLE #tmp_price_curve
EXEC spa_print @tbl_name
EXEC spa_print @stage_tbl_name
EXEC spa_print @ex_curve_id
EXEC spa_print @period 
SET @min_date = GETDATE() - @period
EXEC spa_print @min_date
EXEC spa_print @stage_tbl_name

		
CREATE TABLE #tmp_price_curve(
	[source_curve_def_id]				INT NOT NULL,
	[as_of_date]						DATETIME NOT NULL,
	[Assessment_curve_type_value_id]	INT NOT NULL,
	[curve_source_value_id]				INT NOT NULL,
	[maturity_date]						DATETIME NOT NULL,
	[curve_value]						FLOAT NOT NULL,
	[create_user]						VARCHAR (50) COLLATE DATABASE_DEFAULT NULL,
	[create_ts]							DATETIME NULL,
	[update_user]						VARCHAR (50) COLLATE DATABASE_DEFAULT NULL,
	[update_ts]							DATETIME NULL,
	[bid_value]							FLOAT NULL,
	[ask_value]							FLOAT NULL,
	[is_dst]							INT NOT NULL
) 
--select * from FNASplit(,'','')
SET @st = '
		INSERT INTO #tmp_price_curve 
		SELECT * FROM source_price_curve
		WHERE source_curve_def_id IN ( ' +   @ex_curve_id + ') 
		AND as_of_date <= ''' + CAST(@min_date AS VARCHAR(20)) + ''''
		 
EXEC spa_print @st
EXEC (@st)

SET @st1 = '
		INSERT INTO stage_source_price_curve 
		SELECT * FROM #tmp_price_curve'
		 
EXEC spa_print @st1
EXEC (@st1)
SET @st2 = '
		DELETE FROM source_price_curve WHERE source_curve_def_id IN ( ' +   @ex_curve_id + ') 
		AND as_of_date <= ''' + CAST(@min_date AS VARCHAR(20)) + ''''
		
		 
EXEC spa_print @st2	
EXEC (@st2)

		
--CREATE TABLE #tmp_cache_curve(
--	[Master_ROWID] [int] NULL,
--	[value_type] [varchar](1) COLLATE DATABASE_DEFAULT NULL,
--	[term] [datetime] NULL,
--	[pricing_option] [tinyint] NULL,
--	[curve_value] [float] NULL,
--	[org_mid_value] [float] NULL,
--	[org_ask_value] [float] NULL,
--	[org_bid_value] [float] NULL,
--	[org_fx_value] [float] NULL,
--	[as_of_date] [datetime] NULL,
--	[curve_source_id] [int] NULL,
--	[create_ts] [datetime] NULL,
--	[bid_ask_curve_value] [float] NULL
--) 
--SET @st = '
--		INSERT INTO #tmp_cache_curve 
--		SELECT ccv.* FROM cached_curves_value ccv INNER JOIN Cached_curves cc on cc.ROWID = ccv.Master_ROWID
--		WHERE cc.curve_id IN (' +   @ex_curve_id + ') 
--		AND ccv.as_of_date <= ''' + CAST(@min_date AS VARCHAR(20)) + ''''
		 
--PRINT @st
--EXEC (@st)

--SET @st1 = '
--		INSERT INTO stage_cached_curves_value 
--		SELECT * FROM #tmp_cache_curve'
		 
--PRINT @st1
--EXEC (@st1)
--SET @st2 = '
--		DELETE  from cached_curves_value FROM cached_curves_value ccv INNER JOIN Cached_curves cc on cc.ROWID = ccv.Master_ROWID
--		WHERE cc.curve_id IN ( ' +   @ex_curve_id + ') 
--		AND ccv.as_of_date <= ''' + CAST(@min_date AS VARCHAR(20)) + ''''
		
		 
--PRINT @st2	
--EXEC (@st2)



END	TRY

BEGIN CATCH
	EXEC spa_print 'Archive Error:' --+ ERROR_MESSAGE()
	
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN;
END CATCH




GO


