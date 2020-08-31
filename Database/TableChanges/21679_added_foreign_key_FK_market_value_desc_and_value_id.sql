UPDATE spcd
SET spcd.market_value_desc = NULL
FROM source_price_curve_def spcd
LEFT JOIN static_data_value sdv
	ON spcd.market_value_desc = sdv.value_id
		AND sdv.type_id = 29700
WHERE sdv.value_id IS NULL
	AND spcd.market_value_desc IS NOT NULL

--existency check for creating foreign key
IF NOT EXISTS( 
	SELECT 1
	FROM sys.foreign_keys 
	WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FK_market_value_desc_and_value_id]') 
		AND parent_object_id = OBJECT_ID(N'[dbo].[source_price_curve_def]')
)
BEGIN
	ALTER TABLE source_price_curve_def 
	ADD CONSTRAINT FK_market_value_desc_and_value_id
	FOREIGN KEY (market_value_desc)
	REFERENCES static_data_value (value_id)
	PRINT 'FK_market_value_desc_and_value_id added'

END 