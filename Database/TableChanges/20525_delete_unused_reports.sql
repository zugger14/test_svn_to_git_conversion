IF OBJECT_ID('tempdb..#delete_Report') IS NOT NULL
	DROP TABLE #delete_Report
CREATE TABLE #delete_Report (Report_name VARCHAR(500) COLLATE DATABASE_DEFAULT)
INSERT INTO #delete_Report (Report_name)

Select ('Copy of Deal Extract Report') UNION ALL
Select ('Copy of PNL Attribution Reports') UNION ALL
Select ('Copy of MTM Report by Counterparty') UNION ALL
Select ('Collateral Report') UNION ALL
Select ('Collateral Inventory Report') UNION ALL
Select ('MTM Breakdown Report including Fees') UNION ALL
Select ('Capacity Usage Report')UNION ALL
Select ('Financial Position Pivot') UNION ALL
Select ('Deal Detail Report') UNION ALL
select ('Disclosure Counterparty Exposure Report by Tenor')UNION ALL
Select ('Disclosure Counterparty Exposure Report by Rating')

IF OBJECT_ID('tempdb..#delete_Report_confirm') IS NOT NULL
DROP TABLE #delete_Report_confirm
		CREATE TABLE #delete_Report_confirm  (report_id VARCHAR(500) COLLATE DATABASE_DEFAULT, name VARCHAR(500) COLLATE DATABASE_DEFAULT)
INSERT INTO #delete_Report_confirm 
		SELECT report_id, name from Report where name in (select Report_name from #delete_Report)

IF CURSOR_STATUS('local','Report_delete') > = -1
		BEGIN
			DEALLOCATE Report_delete
		END

		DECLARE Report_delete CURSOR LOCAL FOR
		
		SELECT report_id
		FROM   #delete_Report_confirm  
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
