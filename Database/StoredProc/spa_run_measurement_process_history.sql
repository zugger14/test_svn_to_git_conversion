IF OBJECT_ID(N'spa_run_measurement_process_history', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_run_measurement_process_history]
GO

--drop proc [dbo].[spa_run_measurement_process_history]
--go

--spa_run_measurement_process_history 's','1,100','45,33',NULL,'2007-01-01','2007-08-31'
--spa_run_measurement_process_history 's',NULL,NULL,NULL,'2007-01-01','2007-08-31'
--spa_run_measurement_process_history 'd',NULL,NULL,NULL,'2007-06-30',null
CREATE PROCEDURE [dbo].[spa_run_measurement_process_history]
	@flag CHAR(1),
	@sub_entity_id VARCHAR(500) = NULL,
	@strategy_entity_id VARCHAR(500) = NULL,
	@book_id VARCHAR(500) = NULL,
	@from_date VARCHAR(20) = NULL,
	@to_date VARCHAR(20) = NULL
AS
SET NOCOUNT ON
DECLARE @sql VARCHAR(5000)
IF @flag = 's'
BEGIN
	SELECT dbo.FNADateFormat(as_of_date) [As of Date]
	FROM   measurement_run_dates
	WHERE  as_of_date BETWEEN @from_date AND @to_date
	       
	       /*
	       set @sql=' select dbo.FNADateFormat(as_of_date) [As Of Date] from (
	       select Distinct as_of_date
	       from report_measurement_values m join 
	       portfolio_hierarchy pSub on m.sub_entity_id=pSub.entity_id
	       join portfolio_hierarchy pSt on m.strategy_entity_id=pSt.entity_id
	       join portfolio_hierarchy pBok on m.book_entity_id=pBok.entity_id
	       where as_of_date between '''+@from_date +''' and '''+ @to_date +''''
	       if @sub_entity_id is not null
	       set @sql=@sql+' and sub_entity_id in ('+ @sub_entity_id+')'
	       if @strategy_entity_id is not null
	       set @sql=@sql+' and strategy_entity_id in ('+ @strategy_entity_id+')'
	       if @book_id is not null
	       set @sql=@sql+' and book_entity_id in ('+ @book_id+')'
	       set @sql=@sql+') x order by as_of_date desc'
	       --	EXEC spa_print @sql
	       execute(@sql)
	       */
END	
ELSE IF @flag = 'd'
     BEGIN
         DECLARE @closed_book_count INT

		 SELECT @from_date = dbo.FNAClientToSqlDate(@from_date)
         SELECT @closed_book_count = COUNT(*)
         FROM   close_measurement_books
         WHERE  as_of_date >= @from_date
         
         DECLARE @msg VARCHAR(200)
         IF @closed_book_count > 0
         BEGIN
             SET @msg = 'Measurement book already closed for run as of date ' + 
                 @from_date
             
             EXEC spa_ErrorHandler 1,
                  'Measurement History',
                  'spa_run_measurement_process_history',
                  'Error',
                  @msg,
                  ''
         END
         ELSE
         BEGIN
             SET @msg = 'Measurement results deleted for as of date ' + @from_date
             EXEC spa_purge_all_measurement_values @from_date
             DELETE measurement_run_dates
             WHERE  as_of_date = @from_date
             
             EXEC spa_ErrorHandler 0,
                  'Measurement History',
                  'spa_run_measurement_process_history',
                  'Success',
                  @msg,
                  ''
         END
     END
IF @flag = 'c' -- Copy prior MTM Value
BEGIN
    SELECT TOP 12 CONVERT(VARCHAR, as_of_date, 102) as_of_date,
           dbo.FNADateFormat(as_of_date) [As of Date]
    FROM   measurement_run_dates
    ORDER BY
           as_of_date DESC
END











