DECLARE @report_id VARCHAR(100)
SELECT @report_id = r.report_id FROM report r WHERE r.[name] = 'Earning Report'
IF @report_id IS NOT NULL 
 EXEC spa_rfx_report_dhx  @flag='d',@report_id = @report_id, @process_id=NULL   





