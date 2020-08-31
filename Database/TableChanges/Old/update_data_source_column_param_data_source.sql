UPDATE data_source_column
SET param_data_source = 'browse_curve'
WHERE param_data_source = '10102600' AND widget_id = 7

UPDATE data_source_column
SET param_data_source = 'browse_counterparty'
WHERE param_data_source = '10191000' AND widget_id = 7

UPDATE data_source_column
SET param_data_source = 'browse_location'
WHERE param_data_source = '10102500' AND widget_id = 7

UPDATE data_source_column
SET param_data_source = 'browse_contract_counterparty'
WHERE param_data_source = '10211299' AND widget_id = 7

UPDATE data_source_column
SET param_data_source = 'BrowseTrader'
WHERE param_data_source = '10101199' AND widget_id = 7

UPDATE data_source_column
SET param_data_source = 'BrowseMeter'
WHERE param_data_source = '10103000' AND widget_id = 7

UPDATE dsc 
SET dsc.param_data_source = 'book'
FROM data_source_column dsc 
WHERE dsc.widget_id IN (3,4,5,8)

--for meter browse on shutin view
update dsc
set dsc.param_data_source = 'BrowseMeter'
--select dsc.* 
from data_source_column dsc
inner join data_source ds on ds.data_source_id = dsc.source_id
where ds.name = 'Shutin View' and dsc.name = 'meter_id'
