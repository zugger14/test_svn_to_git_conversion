IF OBJECT_ID('UX_location_price_index_commodity', 'UQ') IS NULL 
BEGIN
	ALTER TABLE location_price_index ADD CONSTRAINT UX_location_price_index_commodity UNIQUE (location_id, commodity_id)
	PRINT 'Unique Constraint UX_location_price_index_commodity added successfully.'
END
ELSE
BEGIN
	PRINT 'Unique Constraint UX_location_price_index_commodity already exists.'
END