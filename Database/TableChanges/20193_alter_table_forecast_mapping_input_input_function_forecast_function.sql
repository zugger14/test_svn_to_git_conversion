 IF COL_LENGTH('forecast_mapping_input', 'input_function') IS NULL
 BEGIN
     ALTER TABLE forecast_mapping_input ADD input_function int
 END
 GO
 
 IF COL_LENGTH('forecast_mapping_input', 'forecast_function') IS NULL
 BEGIN
     ALTER TABLE forecast_mapping_input ADD forecast_function int
 END
 GO
 
