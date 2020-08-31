UPDATE source_counterparty
SET
	is_active = 'y'
WHERE is_active IS NULL

UPDATE source_minor_location
SET
	is_active = 'y'
WHERE is_active IS NULL

UPDATE contract_group
SET
	is_active = 'y'
WHERE is_active IS NULL

UPDATE source_price_curve_def
SET
	is_active = 'y'
WHERE is_active IS NULL

