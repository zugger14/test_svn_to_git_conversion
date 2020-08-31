IF OBJECT_ID('[dbo].[spa_holiday_group]', 'p') IS NOT NULL
    DROP PROC [dbo].[spa_holiday_group]
GO

CREATE PROCEDURE [dbo].[spa_holiday_group]
	@flag CHAR(1),
	@hol_group_id INT = NULL,
	@hol_group_value_id INT = NULL,
	@fromdate VARCHAR(20) = NULL,
	@todate VARCHAR(20) = NULL,
	@description VARCHAR(100) = NULL,
	@exp_date VARCHAR(20) = NULL,
	@settlement_date VARCHAR(20) = NULL
AS
DECLARE @sql VARCHAR(MAX) = ''
DECLARE @where_clause VARCHAR(100) = ''
BEGIN
	IF @flag = 's'
	BEGIN
	    IF @fromdate IS NOT NULL AND @todate IS NOT NULL
	    BEGIN 
	           SET @where_clause = ' AND hol_date BETWEEN ''' + @fromdate + ''' AND ''' + @todate + ''''
	    END
		ELSE IF @fromdate IS NOT NULL AND @todate IS NULL
	    BEGIN 
	           SET @where_clause = ' AND hol_date >= ''' + @fromdate + '''' 
	    END
	    ELSE IF @fromdate IS NULL AND @todate IS NOT NULL
	    BEGIN 
	           SET @where_clause = ' AND hol_date <= ''' + @todate + ''''
	    END
	    SET @sql =  'SELECT hol_group_id [ID],
						dbo.FNADateFormat(hol_date) [Holiday/Maturity From],
						dbo.FNADateFormat(hol_date_to) [Holiday/Maturity To],
						dbo.FNADateFormat(exp_date) AS [Expiration Date],
						dbo.FNADateFormat(settlement_date) AS [Settlement Date],
						hg.[description] [Description]
					FROM   holiday_group hg
					INNER JOIN static_data_value sd ON  sd.value_id = hg.hol_group_value_id
					WHERE  hol_group_value_id =' + CAST(@hol_group_value_id AS VARCHAR(10)) + @where_clause + ' ORDER BY hol_date'
	    EXEC(@sql)
	 END   
	IF @flag = 'a'
	    SELECT hol_group_id [ID],
	           dbo.FNADateFormat(hol_date) [Holiday/Maturity From],
	           dbo.FNADateFormat(hol_date_to) [Holiday/Maturity To],
	           hg.[description] [Description],
	           dbo.FNADateFormat(exp_date)[Expiration Date],
	           dbo.FNADateFormat(settlement_date)
	    FROM   holiday_group hg
	           INNER JOIN static_data_value sd ON  sd.value_id = hg.hol_group_value_id
	    WHERE  hol_group_id = @hol_group_id
	
	
	IF @flag = 'i'
	BEGIN
		DECLARE @duplicate_entry INT
		SET @duplicate_entry = 0
	    BEGIN TRY
	    	IF EXISTS(SELECT 1
	              FROM   holiday_group hg
	              WHERE  hg.hol_date = @fromdate
	              AND hg.hol_group_value_id = @hol_group_value_id
	              --AND hg.exp_date = @settlement_date 
				)
			BEGIN
				SET @duplicate_entry = 1
				
				EXEC spa_ErrorHandler 1,
				     'Holiday Group',
				     'spa_holiday_group',
				     'DB Error',
				     'Duplicate holiday/maturity from date can not be inserted.',
				     ''	             
			END
			ELSE
			BEGIN
				INSERT INTO holiday_group
				  (
				    hol_group_value_id,
				    hol_date,
				    hol_date_to,
				    [description],
				    exp_date,
				    settlement_date
				  )
				SELECT @hol_group_value_id,
				       @fromdate,
				       @todate,
				       @description,
				       @exp_date,
				       @settlement_date
				
				EXEC spa_ErrorHandler 0,
				     'Holiday Group',
				     'spa_holiday_group',
				     'Success',
				     'Successfully Saved Holiday values.',
				     ''
			END
	    END TRY
	    BEGIN CATCH
			DECLARE @errorMessage VARCHAR(100)
			SET @errorMessage = 'Failed to saved Holiday values.'
			
			EXEC spa_ErrorHandler 1,
			     'Holiday Group',
			     'spa_holiday_group',
			     'DB Error',
			     @errorMessage,
			     ''			
	    END CATCH

	END
	
	IF @flag = 'u'
	BEGIN
		    UPDATE holiday_group
		    SET    hol_date = @fromdate,
		           hol_date_to = @todate,
		           exp_date = @exp_date,
		           settlement_date = @settlement_date,
		           [description] = @description
		    WHERE  hol_group_id = @hol_group_id
		
		IF @@ERROR <> 0
	        EXEC spa_ErrorHandler @@ERROR,
	             'Holiday Group',
	             'spa_holiday_group',
	             'DB Error',
	             'Error Updating Values',
	             ''
	    ELSE
	        EXEC spa_ErrorHandler 0,
	             'Holiday Group',
	             'spa_holiday_group',
	             'Success',
	             'Holiday values successfully Updated.',
	             ''
	END
	
	IF @flag = 'd'
	BEGIN
	    DELETE FROM   holiday_group WHERE  hol_group_id = @hol_group_id
	    
	    IF @@ERROR <> 0
	        EXEC spa_ErrorHandler @@ERROR,
	             'Holiday Group',
	             'spa_holiday_group',
	             'DB Error',
	             'Error Deleting Values',
	             ''
	    ELSE
	        EXEC spa_ErrorHandler 0,
	             'Holiday Group',
	             'spa_holiday_group',
	             'Success',
	             'Holiday values successfully Deleted.',
	             ''
	END
END




