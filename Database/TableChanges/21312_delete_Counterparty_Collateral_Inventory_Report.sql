--Deleting Counterparty Collateral Inventory Report
DECLARE @report_id INT = NULL
	
SELECT @report_id = r.report_id  
FROM report AS r 
WHERE  r.name = 'Counterparty Collateral Inventory Report'

EXEC spa_rfx_report_dhx  @flag='d',@report_id = @report_id, @process_id=NULL	