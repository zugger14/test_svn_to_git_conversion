UPDATE map_function_category
SET is_active = 0

UPDATE  mfc
SET is_active = 1
FROM map_function_category mfc
INNER JOIN static_data_value sdv ON sdv.type_id = 800 AND mfc.function_id = sdv.value_id
WHERE sdv.code IN 
(
'-',
'(',
')',
'*',
'/',
'+',
'<',
'<=',
'<>',
'=',
'>',
'AVG',
'CEILING',
'MAX',
'MIN',
'POWER',
'RollingAVG',
'RollingSum',
'Round',
'SQRT',
'IF Condition',
'ISNULL',
'DaysInYr',
'Month',
'PeakHours',
'Year',
'GetLogicalValue',
'ROW',
'AveragePrice',
'GetCurveValue',
'CHANNEL',
'MeterVol',
'DaysInMnth',
'ContractPriceValue',
'ShapedVol',
'ShapedDealPrice',
'WeekDay',
'WeekDaysInMth',
'DealType',
'PriorFinalizedAmount',
'PriorFinalizedVol',
'GetTimeSeriesData'
)