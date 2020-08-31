Declare 
@report_id INT
 
SET @report_id = (Select report_id from report where name = 'Options Greeks Report')
EXEC spa_rfx_report_dhx  @flag='d',@report_id = @report_id, @process_id=NULL  