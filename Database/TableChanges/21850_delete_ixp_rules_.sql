DECLARE
	@id INT

DECLARE db_cursor CURSOR FOR 
SELECT ixp_rules_id
FROM ixp_rules 
where ixp_rules_name IN (
	'Counterparty Product Import',
	'Deal Type Definition',
	'Delivery Group Path',
	'LSE Import',
	'Nymex Price Import',
	'Price Curve Import from Linked Server',
	'Price Import from Web Services',
	'Price Import from XML',
	'Ticket',
	'Time Series Data',
	'REC Actual Volume Import',
	'REC Forecast Volume Import',
	'Source Book Map  and Gl codes',
	'Source Facility',
	'Storage Contract',
	'Source Book Map and Gl codes',
	'TimeSeries Weather Data',
	'Deals and Shaped Volume',
	'Jurisdiction Eligibility',
	'Import Book Structure'
)

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @id  

WHILE @@FETCH_STATUS = 0  
BEGIN  
	  --print @id
      EXEC spa_ixp_rules @flag = 'd', @ixp_rules_id = @id, @show_delete_msg = 'y'
	  --EXEC spa_ixp_rules_export @id

      FETCH NEXT FROM db_cursor INTO @id 
END 

CLOSE db_cursor  
DEALLOCATE db_cursor 

