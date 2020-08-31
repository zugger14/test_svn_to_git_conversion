IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 29700)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (29700, 'Market', 0, 'Market', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 29700 - Market.'
END
ELSE
BEGIN
	PRINT 'Static data type 29700 - Market already EXISTS.'
END


IF OBJECT_ID('tempdb..#tmp_market_value_desc') IS NOT NULL
			DROP TABLE #tmp_market_value_desc

CREATE TABLE #tmp_market_value_desc(
	market_value_desc VARCHAR(50)
)

INSERT INTO #tmp_market_value_desc (market_value_desc)
SELECT DISTINCT market_value_desc from source_price_curve_def spcd
LEFT JOIN static_data_value sdv
	ON CAST(sdv.value_id AS VARCHAR(20)) = spcd.market_value_desc
	AND sdv.type_id = 29700
WHERE sdv.value_id IS NULL
AND NULLIF(spcd.market_value_desc,'NULL') IS NOT NULL

INSERT INTO static_data_value ([type_id],[code],[description])
SELECT 29700,market_value_desc,market_value_desc
FROM #tmp_market_value_desc tmvd
LEFT JOIN static_data_value sdv
	ON sdv.code =  tmvd.market_value_desc
	AND sdv.type_id = 29700
WHERE sdv.value_id IS NULL

UPDATE spcd 
SET spcd.market_value_desc = sdv.value_id 
FROM source_price_curve_def spcd
INNER JOIN static_data_value sdv
	ON sdv.code = spcd.market_value_desc
	AND sdv.type_id = 29700







