INSERT INTO storage_asset (asset_name,asset_description,commodity_id,location_id)
SELECT DISTINCT sml.Location_Name,sml.Location_Name,50,gaivs.storage_location
FROM [general_assest_info_virtual_storage] gaivs
INNER JOIN contract_group cg ON cg.contract_id = gaivs.agreement 
INNER JOIN source_minor_location sml ON sml.source_minor_location_id = gaivs.storage_location
INNER JOIN static_data_value sdv ON sdv.value_id = gaivs.storage_type
LEFT JOIN static_data_value sdv1 ON sdv.value_id = gaivs.fees
INNER JOIN source_counterparty sc ON sc.source_counterparty_id = gaivs.source_counterparty_id 
	
UPDATE  gaivs
	SET gaivs.storage_asset_id = sa.storage_asset_id
FROM general_assest_info_virtual_storage gaivs
INNER JOIN storage_asset sa ON sa.location_id = gaivs.storage_location
