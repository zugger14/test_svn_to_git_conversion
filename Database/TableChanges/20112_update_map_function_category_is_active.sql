-- Active formula: contractvalue, volume, RateScheduleFee
SET NOCOUNT ON 
UPDATE map_function_category 
	SET is_active = 1 
WHERE function_id in (
	815,813,-860
)

PRINT '********** Formula : contractvalue, volume, RateScheduleFee has been enabled (if available) |Script executed successfully|************'