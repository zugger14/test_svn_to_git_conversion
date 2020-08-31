--Default Probabilty
UPDATE static_data_value
SET    code = 'Probability',
       [description] = 'Default Probabilty'
WHERE  value_id = 4024

--Default Recovery Rate
UPDATE static_data_value
SET    code = 'Recovery',
       [description] = 'Default Recovery Rate'
WHERE  value_id = 4025

--Curve Correlation
UPDATE static_data_value
SET    code = 'curve_correlation',
       [description] = 'Curve Correlation'
WHERE  value_id = 4026

--Curve Volatility
UPDATE static_data_value
SET    code = 'curve_volatility',
       [description] = 'Curve Volatility'
WHERE  value_id = 4027

--Deal Import
UPDATE static_data_value
SET    [description] = 'Deal Import'
WHERE  value_id = 4055


UPDATE application_functions
SET	function_desc = 'Curve Volatility'
WHERE function_id = 10131777 

UPDATE application_functions
SET	function_desc = 'Curve Correlation'
WHERE function_id = 10131776 
