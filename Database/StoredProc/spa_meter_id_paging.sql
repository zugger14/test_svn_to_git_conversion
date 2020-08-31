IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_meter_id_paging]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_meter_id_paging]
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[spa_meter_id_paging]
	@flag CHAR(1), -- 'c' show counterparty report
	@recorderid VARCHAR(1000) =NULL,
	@desc VARCHAR(255)=NULL,
	@meter_manufacturer VARCHAR(100)=NULL,
	@meter_type VARCHAR(100)=NULL,
	@meter_serial_number VARCHAR(100)=NULL,
	@meter_certification DATETIME=NULL,
	@meter_id VARCHAR(500)=NULL,
	@sub_meter_id INT = NULL,
	@location_id INT = NULL,
	@process_id_paging VARCHAR(200) = NULL, 
	@page_size INT = NULL,
	@page_no INT = NULL
		
AS


DECLARE @user_login_id  VARCHAR(50),
        @tempTable      VARCHAR(MAX)
 
DECLARE @flag_paging    CHAR(1)

SET @user_login_id = dbo.FNADBUser()

IF @process_id_paging IS NULL
BEGIN
    SET @flag_paging = 'i'
    SET @process_id_paging = REPLACE(NEWID(), '-', '_')
END

SET @tempTable = dbo.FNAProcessTableName(
        'paging_meter_id',
        @user_login_id,
        @process_id_paging
    )

EXEC spa_print @tempTable

DECLARE @sql VARCHAR(MAX)


IF @flag_paging = 'i'
BEGIN
    IF @flag = 's'
    BEGIN
    	SET @sql = 'CREATE TABLE ' + @tempTable + 
            ' (
			sno INT IDENTITY(1,1), 
			recorderid VARCHAR(50),
			Description VARCHAR(100),
			meter_id INT,
			[Sub Meter] VARCHAR(100)
		)'
        
        EXEC spa_print @sql 
        EXEC (@sql)
        
        
        SET @sql = 'INSERT ' + @tempTable + 
            '(
					recorderid,
					Description,
					meter_id,
					[Sub Meter]
		)' +
			' EXEC spa_meter_id ' +
            dbo.FNASingleQuote(@flag) + ',' +
            dbo.FNASingleQuote(@recorderid) + ',' +
            dbo.FNASingleQuote(@desc) + ',' +
            dbo.FNASingleQuote(@meter_manufacturer) + ',' +
            dbo.FNASingleQuote(@meter_type) + ',' +
            dbo.FNASingleQuote(@meter_serial_number) + ',' +
            dbo.FNASingleQuote(@meter_certification) + ',' +
            dbo.FNASingleQuote(@meter_id) + ',' +
            dbo.FNASingleQuote(@sub_meter_id) + ',NULL, NULL, NULL, NULL, NULL, NULL,' + 
            dbo.FNASingleQuote(@location_id)
 
        EXEC spa_print @sql 
        EXEC (@sql)
        
        SET @sql = 'select count(*) TotalRow,''' + @process_id_paging + ''' process_id  from ' + @tempTable
        
        EXEC spa_print @sql
        EXEC (@sql)
    END
   
END

ELSE
BEGIN
	
	DECLARE @row_from INT, @row_to INT 
	SET @row_to = @page_no * @page_size
	IF @page_no > 1 
	SET @row_from = ((@page_no-1) * @page_size) + 1
	ELSE 
	SET @row_from = @page_no

    IF @flag = 's'
    BEGIN
        SET @sql =
            'SELECT recorderid [Recorder ID],
                    DESCRIPTION [Description],
                    meter_id [Meter ID],
                    [Sub Meter] [Sub Meter]
             FROM   ' + @tempTable + '
             WHERE  sno BETWEEN ' + CAST(@row_from AS VARCHAR) + ' AND 
                    ' + 
            CAST(@row_to AS VARCHAR) + '
             ORDER BY
                    sno ASC'
         
		EXEC spa_print @sql 
		EXEC (@sql)               
    END
END