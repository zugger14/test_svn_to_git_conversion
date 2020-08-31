--select * from report where name like '%Hourly Position Extract Report%'

CREATE TABLE #temp_delete_multiple_report (report_id INT)

INSERT INTO #temp_delete_multiple_report 
	SELECT report_id FROM Report WHERE NAME   IN ('Hourly Position Extract Report' , 'Power ToU Position Report')

IF CURSOR_STATUS('local','Report_delete') > = -1
		BEGIN
			DEALLOCATE Report_delete
		END

		DECLARE Report_delete CURSOR LOCAL FOR
		
		SELECT report_id
		FROM   #temp_delete_multiple_report  
		DECLARE @report_id varchar(100)
		
		OPEN Report_delete 
		FETCH NEXT FROM Report_delete 
		INTO @report_id
		WHILE @@FETCH_STATUS = 0
		BEGIN			
			EXEC spa_rfx_report_dhx  @flag='d',@report_id = @report_id, @process_id=NULL		
		FETCH NEXT FROM Report_delete INTO @report_id
		END
		CLOSE Report_delete
		DEALLOCATE Report_delete




