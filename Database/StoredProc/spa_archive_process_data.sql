
-----

------stored procedure spa_archive_process_data
IF OBJECT_ID('[dbo].[spa_archive_process_data]') IS NOT NULL
    DROP PROC [dbo].[spa_archive_process_data]
GO


--spa_archive_process_data 'y','2007-12-01','farrms_admin',0
CREATE  PROC [dbo].[spa_archive_process_data] 
@close_status VARCHAR(1) = 'y'
,@as_of_date DATETIME
,@archive_type_id INT
,@user_login_id VARCHAR(50)
,@run_schedule INT = NULL
AS

/*
DECLARE @close_status     VARCHAR(1),
        @as_of_date       VARCHAR(30),
        @user_login_id    VARCHAR(50),
        @archive_type_id  INT,
        @run_schedule     INT

SET @close_status = 'y'
SET @as_of_date = '2002-01-01'
SET @archive_type_id = 2151
SET @user_login_id = 'farrms_admin'
SET @run_schedule = NULL

*/

DECLARE @spa                     VARCHAR(500)
DECLARE @job_name                VARCHAR(100)
DECLARE @process_id              VARCHAR(100)
DECLARE @msmt_run_schedule_time  VARCHAR(30)
DECLARE @running_date            VARCHAR(30)
DECLARE @min                     INT
DECLARE @url                     VARCHAR(500)
DECLARE @desc                    VARCHAR(500)
DECLARE @desc1                   VARCHAR(500)

DECLARE @errorcode               VARCHAR(200)
DECLARE @tbl_name                VARCHAR(30)

SET @process_id = REPLACE(NEWID(), '-', '_')
SET @desc = ''
SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id +
       '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id
       + ''''

EXEC spa_print @url

IF ISNULL(@run_schedule, 0) = 0
    SET @min = -1
ELSE
BEGIN
    SELECT @msmt_run_schedule_time = msmt_run_schedule_time
    FROM   run_measurement_param
    
    IF ISNULL(@msmt_run_schedule_time, '') = ''
        SET @min = -1
    ELSE
    BEGIN
        EXEC spa_print 'yyyyyyyyyyy'
        SET @running_date = CONVERT(VARCHAR(10), GETDATE(), 120) + ' ' + @msmt_run_schedule_time
        EXEC spa_print @running_date
       -- EXEC spa_print DATEDIFF(mi, GETDATE(), CAST(@running_date AS DATETIME))
        SET @min = DATEDIFF(mi, GETDATE(), CAST(@running_date AS DATETIME))
        EXEC spa_print @min
    END
END

SET @process_id = REPLACE(NEWID(), '-', '_')
IF @user_login_id IS NULL
    SET @user_login_id = dbo.FNADBUser()

SET @job_name = 'closingYear_' + @process_id
SET @spa = 'spa_archive_process_data_job  ''' + @close_status + ''',''' + CAST(@as_of_date AS VARCHAR) 
    + ''',' + CAST(@archive_type_id AS VARCHAR) + ',''' +
    @job_name + ''',''' + @user_login_id + ''', ''' + @process_id + ''''

exec spa_print @spa
IF @min = -1
    EXEC spa_run_sp_as_job @job_name,
         @spa,
         'ClosingYear',
         @user_login_id,
         NULL,
         NULL,
         'y'
ELSE
    EXEC spa_run_sp_as_job_schedule @job_name,
         @spa,
         'ClosingYear',
         @user_login_id,
         @min,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         'y'

GO
