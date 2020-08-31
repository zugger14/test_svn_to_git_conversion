IF OBJECT_ID(N'spa_calc_mtm', N'P') IS NOT NULL
DROP PROC [dbo].[spa_calc_mtm]
GO
--exec spa_calc_mtm NULL,NULL,NULL,NULL,'130304','2005-10-31',4500, 775,'i','farrms_admin'
--exec spa_calc_mtm NULL,NULL,NULL,NULL,'10','2005-12-01',5029,5140,'i','ubaral'
CREATE procedure [dbo].[spa_calc_mtm]
@sub_id varchar(100)=NULL,
@strategy_id varchar(100)=NULL,
@book_id varchar(100)=NULl,
@source_book_mapping_id varchar (100)=NULL,
@source_deal_header_id varchar (500) =NULL,
@as_of_date datetime,
@curve_source_value_id INT ,
@pnl_source_value_id INT ,
@hedge_or_item char(1) =NULL,
@user_id varchar(100),
@assessment_curve_type_value_id int= 77,
@table_name varchar(100) = NULL
as 

DECLARE @spa varchar(5000)
DECLARE @job_name varchar(100)
DECLARE @process_id varchar(50)
DECLARE @run_date datetime
DECLARE @desc varchar(500)


BEGIN TRY

DECLARE @closed_book_count int


SELECT     @closed_book_count  = COUNT(*) 
FROM         close_measurement_books
WHERE     (as_of_date >= CONVERT(DATETIME, dbo.FNAGetContractMonth(@as_of_date), 102))

-- Check if book is already closed
If @closed_book_count > 0 
BEGIN	
	Select 'Error' ErrorCode, 'Run MTM' Module, 'spa_calc_mtm', 'Book Closed' Status, 
		('Accounting Book already closed for run as of date ' + dbo.FNADateFormat(@as_of_date))  Message, 
		'' Recommendation		
	RETURN
END


set @run_date=getdate()

SET @process_id = REPLACE(newid(),'-','_')
SET @job_name = 'mtm_' + @process_id

If @sub_id IS NULL 
	SET @sub_id = ''

If @strategy_id IS NULL 
	SET @strategy_id = ''

If @book_id IS NULL 
	SET @book_id = ''

If @source_book_mapping_id IS NULL 
	SET @source_book_mapping_id = ''

If @source_deal_header_id IS NULL 
	SET @source_deal_header_id = ''

If @hedge_or_item IS NULL 
	SET @hedge_or_item = ''
if @table_name is NULL
	SET @table_name=''
if @assessment_curve_type_value_id is NULL
	SET @assessment_curve_type_value_id=77

IF  @pnl_source_value_id IS NULL
	SET @pnl_source_value_id=@curve_source_value_id

SET @spa = 'spa_calc_mtm_job ''' + @sub_id + ''', ''' + @strategy_id + ''', ''' +
		@book_id + ''', ''' + @source_book_mapping_id + ''', ''' +
		@source_deal_header_id + ''', ''' +dbo.FNAGetSQLStandardDate(@as_of_date) + ''', ' +
		convert(varchar(100),@curve_source_value_id) + ', ' + convert(varchar(100),@pnl_source_value_id) + ', '''+ @hedge_or_item +''',
		 ''' + @process_id + ''', ''' + @job_name + ''','''+@user_id+''','+cast(@assessment_curve_type_value_id as varchar)+'
		,'''+@table_name+''''

EXEC spa_print @spa

EXEC spa_run_sp_as_job @job_name, @spa, 'Mtm', @user_id

set @desc='MTM  as of date '+dbo.FNADateFormat(@as_of_date)+ ' has been run and will complete shortly.'

EXEC spa_print @desc
Exec spa_ErrorHandler 0, 'Mtm', 
			'Process run', 'Status', 
			@desc, 
			'Please check/refresh your message board.'


END TRY
BEGIN CATCH
	--EXEC spa_print 'Error Found in Catch: ' + ERROR_MESSAGE()
	
	
	Select 'Error' ErrorCode, 'Run MTM' Module, 'spa_calc_mtm', 'Book Closed' Status, 
		('SQL Error Found: ' + ERROR_MESSAGE())  Message, 
		'' Recommendation		
	
END CATCH
