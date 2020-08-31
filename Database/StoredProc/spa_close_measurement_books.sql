IF OBJECT_ID(N'[dbo].[spa_close_measurement_books]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_close_measurement_books]
GO 

CREATE  PROC [dbo].[spa_close_measurement_books]
@flag CHAR(1),
@as_of_date DATETIME = NULL,
@sub_id INT = NULL,
@user_login_id VARCHAR(50) = NULL,
@run_schedule INT = NULL,
@archive_type_id INT = 2150, --Hard Coded for Run Measurment Data For Now In Future data is populated according to combo value.
@batch_process_id    VARCHAR(50) = NULL, 
@batch_report_param  VARCHAR(1000) = NULL,
@xml			VARCHAR(MAX) = NULL
AS

--DECLARE
--@flag CHAR(1),
--@as_of_date DATETIME = NULL,
--@sub_id INT = NULL,
--@user_login_id VARCHAR(50) = NULL,
--@run_schedule INT = NULL,
--@archive_type_id INT = 2150, --Hard Coded for Run Measurment Data For Now In Future data is populated according to combo value.
--@batch_process_id    VARCHAR(50) = NULL, 
--@batch_report_param  VARCHAR(1000) = NULL,
--@xml			VARCHAR(MAX) = NULL

--SET @flag = 'h'
--SET  @xml='<Root><GridGroup><GridRow  close_measurement_books_id="2" sub_id="1249" close_date="2027-05-01" closed_by="farrms_admin" closed_on="05/19/2017" ></GridRow> <GridRow  close_measurement_books_id="36" sub_id="1275" close_date="2026-07-10" closed_by="farrms_admin" closed_on="05/26/2017" ></GridRow> <GridRow  close_measurement_books_id="1" sub_id="1249" close_date="2016-05-01" closed_by="farrms_admin" closed_on="05/19/2017" ></GridRow> </GridGroup></Root>'
 

SET NOCOUNT ON
--declare @flag char(1),@as_of_date datetime,@sub_id int
-- set @flag='i'
--set @as_of_date='2006-01-31'
--set @sub_id=null
--select @user_login_id ='farrms_admin',@run_schedule =null
--DROP TABLE #tmp
--

DECLARE @sql_stmt VARCHAR(5000)
IF @user_login_id IS NULL
    SET @user_login_id = dbo.FNADBUser()

DECLARE @desc             VARCHAR(8000)
DECLARE @month_1st_date1  DATETIME
DECLARE @month_last_date  DATETIME
DECLARE @idoc INT	
--Always convert to first day of the month here ...
SET @month_1st_date1 = CAST(CAST(YEAR(@as_of_date) AS VARCHAR) + '-' + CAST(MONTH(@as_of_date) AS VARCHAR)+ '-01' AS DATETIME)
SET @month_last_date = DATEADD(d, -1, DATEADD(m, 1, @month_1st_date1))
SET @desc = ''


IF @flag = 's'
BEGIN
    SET @sql_stmt = 
        ' SELECT cmb.close_measurement_books_id,
				 cmb.sub_id,
				 dbo.FNADateFormat(cmb.as_of_date) [Close Date],
                 cmb.create_user [Closed By],
                 dbo.FNADateFormat(cmb.create_ts) [Closed On]
          FROM   close_measurement_books cmb
                 LEFT JOIN static_data_value sdv
                      ON  sdv.value_id = cmb.archive_type_id
          WHERE  1 = 1
                 AND ISNULL(archive_type_id, 2150) = '+ CAST(@archive_type_id AS VARCHAR)    ---2150 Hard Coded for Run Measurment Data for Now in future for other implementation can chagne.
   
    SET @sql_stmt = @sql_stmt + ' ORDER BY cmb.as_of_date DESC'
    
    --PRINT (@sql_stmt)
    EXEC (@sql_stmt)
END

--Check Close Book or not
ELSE IF @flag = 'c'
     BEGIN
         IF EXISTS (
                SELECT as_of_date
                FROM   close_measurement_books
                WHERE  as_of_date >= dbo.FNAGetContractMonth(@as_of_date)
                       AND ISNULL(archive_type_id, 2150) = @archive_type_id
            )
             SELECT 'Closed' STATUS
         ELSE
             SELECT 'Not Closed' STATUS
     END

ELSE IF @flag = 'v'
     BEGIN
         --Validating Start********************************************************************************
         IF @archive_type_id = 2150   --This Validation is applied for Run Measurment Data Only
         BEGIN
			 IF NOT EXISTS(
					SELECT as_of_date
					FROM   measurement_run_dates
					WHERE  YEAR(as_of_date) = YEAR(@month_last_date)
						   AND MONTH(as_of_date) = MONTH(@month_last_date)
				)
			 BEGIN
				 SET @desc = 
					 'Measurement has not been run for the accounting period for specified date '
					 + dbo.FNADateFormat(@as_of_date) + '.'
	             
				 EXEC spa_ErrorHandler -1,
					  'Close Accounting Books',
					  'spa_close_measurement_books',
					  'DB Error',
					  @desc,
					  ''
	             
				 RETURN
			 END	
         END
         
         IF EXISTS(
                SELECT as_of_date
                FROM   close_measurement_books
                WHERE  YEAR(as_of_date) = YEAR(@month_last_date)
                       AND MONTH(as_of_date) = MONTH(@month_last_date)
                       AND ISNULL(archive_type_id, 2150) =  @archive_type_id
            )
         BEGIN
             SET @desc = 'Accounting period for specified date ' + dbo.FNADateFormat(@as_of_date)
                 + ' has already been closed.'
             
             EXEC spa_ErrorHandler -1,
                  'Close Accounting Books',
                  'spa_close_measurement_books',
                  'DB Error',
                  @desc,
                  ''
             
             RETURN
         END 
         
         --Prior than current month is found unclosed
         SELECT YEAR(mrd.as_of_date) yr,
                MONTH(mrd.as_of_date) mnth INTO #tmp
         FROM   close_measurement_books cmb
                RIGHT JOIN measurement_run_dates mrd
                     ON  YEAR(cmb.as_of_date) = YEAR(mrd.as_of_date)
                     AND MONTH(cmb.as_of_date) = MONTH(mrd.as_of_date)
         WHERE  YEAR(cmb.as_of_date) IS NULL
                AND mrd.as_of_date < @month_1st_date1
                AND ISNULL(cmb.archive_type_id, 2150) =  @archive_type_id
         GROUP BY
                YEAR(mrd.as_of_date),
                MONTH(mrd.as_of_date)
         
         --	if  exists(select as_of_date from process_table_location where isnull(prefix_location_table,'')='' and as_of_date<@month_1st_date1)
         IF EXISTS(
                SELECT *
                FROM   #tmp
            )
         BEGIN
             SET @desc = 'Accounting period prior to ' + dbo.FNADateFormat(@as_of_date)
                 + ' must be closed first.'
             
             EXEC spa_ErrorHandler -1,
                  'Close Accounting Books',
                  'spa_close_measurement_books',
                  'DB Error',
                  @desc,
                  ''
             
             RETURN
         END         
         --End Validating ******************************************************************
	END
ELSE IF @flag = 'i'
	BEGIN         
         IF @@ERROR <> 0
             EXEC spa_ErrorHandler @@ERROR,
                  'Close Accounting Books',
                  'spa_close_measurement_books',
                  'DB Error',
                  'Failed to close the accounting period.',
                  ''
         ELSE
         BEGIN
         	/*Added to show process start messgae in message board start*/
         	DECLARE @message VARCHAR(500)
         	SET @message = 'Batch process has been scheduled to run as of date ' + dbo.FNADateFormat(@as_of_date)
         	
         	EXEC  spa_message_board
         		@flag = u,
         		@user_login_id = @user_login_id,
         		@message_id = null,
         		@source = 'Archive.Data',
         		@description = @message,
         		@url_desc = null,
         		@url = null,
         		@type = 's', 
				@process_id = @batch_process_id
         	/*Added to show process start messgae in message board end*/
         	
         	 EXEC spa_archive_process_data 'y',
		     @month_1st_date1,
		     @archive_type_id,
		     @user_login_id,
		     @run_schedule
		
			EXEC spa_ErrorHandler 0,
				 'Close Accounting Books',
				 'spa_archived_data_log',
				 'Success',
				 'Archive data process for the period has been Scheduled. Status will be provided on the message board, Please refresh the message board.',
				 ''
         END
     END	
ELSE IF @flag = 'd'
     BEGIN
        IF EXISTS(
                SELECT *
                FROM   close_measurement_books
                WHERE  as_of_date > @month_last_date
						AND ISNULL(archive_type_id, 2150) = @archive_type_id
            )
         BEGIN
             SET @desc = 'Accounting period beyond ' + dbo.FNAUserDateFormat(@month_last_date, @user_login_id)
                 + 
                 ', is already closed. It is not allowed to un-close this period.'
             
             EXEC spa_ErrorHandler -1,
                  'Close Accounting Books',
                  'spa_close_measurement_books',
                  'DB Error',
                  @desc,
                  ''
             
             RETURN
         END
         
         IF NOT EXISTS(
                SELECT *
                FROM   close_measurement_books
                WHERE  YEAR(as_of_date) = YEAR(@as_of_date)
                       AND MONTH(as_of_date) = MONTH(@as_of_date)
					   AND ISNULL(archive_type_id, 2150) = isnull(@archive_type_id, 2150)
            )
            --	if  not exists(select * from close_measurement_books where year(as_of_date)=year(@as_of_date) and month(as_of_date)=month(@as_of_date))
         BEGIN
             SET @desc = 'The accounting period ' + dbo.FNAUserDateFormat(@month_last_date, @user_login_id)
                 + ' has not been closed.'
             
             EXEC spa_ErrorHandler -1,
                  'Close Accounting Books',
                  'spa_close_measurement_books',
                  'DB Error',
                  @desc,
                  ''
             
             RETURN
         END
         
         SET @sql_stmt = 
             '
				DELETE 
				FROM   close_measurement_books
				WHERE  as_of_date = ''' + CAST(@as_of_date AS VARCHAR) + ''' AND ISNULL(archive_type_id, 2150) = '+ CAST(@archive_type_id AS VARCHAR)
				--+
				--CASE 
				--  WHEN @sub_id IS NOT NULL THEN ' and sub_id=' + CAST(@sub_id AS VARCHAR)
				--  ELSE ' and sub_id is null'
				--END
         
         --PRINT(@sql_stmt)
         EXEC (@sql_stmt)
         
         IF @@ERROR <> 0
             EXEC spa_ErrorHandler -1,
                  'Close Accounting Books',
                  'spa_close_measurement_books',
                  'DB Error',
                  'Failed to un-close the accounting period.',
                  ''
         ELSE
             EXEC spa_ErrorHandler 0,
                  'Close Accounting Books',
                  'spa_close_measurement_books',
                  'Success',
                  'Succeded to un-close the accounting period.',
                  ''
     END

--Get latest measurement date
ELSE IF @flag = 'm'
     BEGIN
        SELECT max(as_of_date) FROM measurement_run_dates
     END

ELSE IF @flag = 't'
BEGIN
	   SELECT NULL [value], '' [text] UNION	
	   SELECT DISTINCT sub.entity_id [value],sub.entity_name [text] 
       FROM portfolio_hierarchy book
       INNER JOIN    Portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id  
       INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.entity_id  
       WHERE sub.parent_entity_id IS NULL

END

ELSE IF @flag = 'h'
BEGIN		
  EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
  IF OBJECT_ID('tempdb..#temp_close_measurement_books') IS NOT NULL
		DROP TABLE #temp_close_measurement_books
	SELECT close_measurement_books_id,
		   sub_id,
		   close_date AS as_of_date,
		   closed_by AS create_user,
		   closed_on AS create_ts
		  
	into #temp_close_measurement_books
	FROM OPENXML(@idoc, '/Root/GridGroup/GridRow', 1)
	WITH (
			close_measurement_books_id INT '@close_measurement_books_id',
			sub_id INT '@sub_id',
			close_date VARCHAR(20) '@close_date',
			closed_by VARCHAR(50) '@closed_by',
			closed_on VARCHAR(20) '@closed_on'
	)


	IF EXISTS(SELECT 1 FROM #temp_close_measurement_books GROUP BY as_of_date,sub_id HAVING COUNT(1) > 1)
		BEGIN
			EXEC spa_ErrorHandler -1,
					'Close Measurement Books',
					'spa_close_measurement_books',
					'Error'
					, 'Duplicate entry found'
					, ''
			RETURN
		END
	
	IF EXISTS(SELECT 1 FROM close_measurement_books cmb RIGHT JOIN #temp_close_measurement_books tcmb ON cmb.as_of_date = tcmb.as_of_date GROUP BY tcmb.as_of_date,cmb.archive_type_id HAVING COUNT(1) > 1)
		BEGIN
			EXEC spa_ErrorHandler -1,
					'Close Measurement Books',
					'spa_close_measurement_books',
					'Error'
					, 'Duplicate entry found'
					, ''
			RETURN
		END
		BEGIN TRY
		BEGIN TRAN
		MERGE close_measurement_books AS cmb
		USING 
			(
				SELECT
					close_measurement_books_id, 
					sub_id,	
					as_of_date
				FROM #temp_close_measurement_books
			) AS tbl
		ON (cmb.close_measurement_books_id = tbl.close_measurement_books_id) 
		WHEN NOT MATCHED BY TARGET 
		THEN 
			INSERT(sub_id,as_of_date) 
			VALUES(tbl.sub_id,tbl.as_of_date)
		WHEN MATCHED 
		THEN 
			UPDATE 
			SET sub_id = tbl.sub_id,
				as_of_date = tbl.as_of_date
				
		WHEN NOT MATCHED BY SOURCE  THEN
		DELETE;	
		EXEC spa_ErrorHandler 0,
				'Close Measurement Books',
				'spa_close_measurement_books',
				'Success',
				'Changes have been saved successfully.',
				''
		COMMIT
		END TRY

		BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK
		EXEC spa_ErrorHandler -1,
					'Close Measurement Books',
					'spa_close_measurement_books',
					'Error'
					, 'Sorry there was a error.Please try again'
					, ''
		END CATCH
END


GO

