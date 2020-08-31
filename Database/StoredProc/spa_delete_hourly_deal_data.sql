IF OBJECT_ID('[dbo].[spa_delete_hourly_deal_data]','p') IS NOT NULL
DROP PROC [dbo].[spa_delete_hourly_deal_data]
GO

CREATE proc [dbo].[spa_delete_hourly_deal_data] 
	@source_deal_detail_id INT,
	@granularity_id INT = NULL,
	@prod_dates VARCHAR(MAX) = NULL,
	@hours  varchar(max) = NULL 
AS

--exec spa_mv90_data_hour_delete $source_deal_detail_id, $prod_dates, $hours
--DECLARE 
--	@source_deal_detail_id INT,
--	@prod_dates VARCHAR(MAX),
--	@hours  varchar(max)
	
--SET @source_deal_detail_id = 10290
--SET @prod_dates = '2009-02-01,2009-02-02,2009-02-03'
--SET @hours = 'Hr1,Hr2,Hr3'

	
DECLARE @sql VARCHAR(MAX)
DECLARE @tmp_hours VARCHAR(1000)
DECLARE @tmp_prod_dates VARCHAR(1000)
DECLARE @st_tbl VARCHAR(100)

set @st_tbl='dbo.deal_detail_hour'


SELECT @tmp_prod_dates = COALESCE(@tmp_prod_dates+ ',' + '''' + dbo.FNAGetSQLStandardDate([Item]) + '''', ''''  + dbo.FNAGetSQLStandardDate([Item]) + '''') FROM SplitCommaSeperatedValues(@prod_dates)
SELECT @tmp_hours = COALESCE(@tmp_hours + ',Hr' + [Item] + '=0','Hr'+[Item] + '=0') FROM SplitCommaSeperatedValues(@hours)

BEGIN TRY
BEGIN TRAN 

IF @tmp_hours IS NOT NULL and @tmp_prod_dates IS NOT NULL 
BEGIN
	SET @sql = 'update '+@st_tbl+' set ' + @tmp_hours + ' where source_deal_detail_id = ' + CAST(@source_deal_detail_id AS VARCHAR) + ' and term_date in (' + @tmp_prod_dates + ')'
	EXEC spa_print @sql
	EXEC (@sql)
	
--	SET @sql = 'update '+@st_tbl+'_price set ' + @tmp_hours + ' where source_deal_header_id = ' + CAST(@source_deal_detail_id AS VARCHAR) + ' and prod_date in (' + @tmp_prod_dates + ')'
--	EXEC spa_print @sql
--	EXEC (@sql)
	
	COMMIT TRAN 
END

END TRY
BEGIN CATCH
	Exec spa_ErrorHandler -1, 'Hourly deal data tables', 'spa_delete_hourly_deal_data', 'DB Error', 'The selected rows cannot be deleted.', ''
	ROLLBACK TRAN 
	RETURN
END CATCH

EXEC spa_ErrorHandler 0, 'Hourly deal data tables', 'spa_delete_hourly_deal_data', 'Success', 'The selected rows successfully deleted.', ''
