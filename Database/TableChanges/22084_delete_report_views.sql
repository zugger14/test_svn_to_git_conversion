DECLARE @final_script VARCHAR(5000) = ''
--report table
SELECT @final_script += 'EXEC spa_rfx_report @flag = ''d'', @report_id = ' + CAST(report_id AS VARCHAR(50)) + ', @process_id=NULL ' + CHAR(10)  
FROM [report] 
WHERE name IN (
	 'REC Detail Report'
	,'REC Summary Report'
	,'REC Extract Report'
	,'REC Deal Summary Report'
	,'REC Generation Sales Report'
	,'REC Ledger Report'
	,' Net Rec Generation Sales Report 1'
)

--view table
SELECT @final_script += 'EXEC spa_rfx_data_source_dhx @flag = ''d'', @source_id = ' + CAST(data_source_id AS VARCHAR(50)) + ' ' + CHAR(10) 
FROM [data_source]
WHERE name IN (
	 'REC Detail View'
	​,'REC Deal Extract Summary View'
	,'REC Deal Detail View'
	,'REC Product View'
)

EXEC(@final_script)