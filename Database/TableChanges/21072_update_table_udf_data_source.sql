IF EXISTS(SELECT 1 FROM udf_data_source WHERE [udf_data_source_name] = 'custom')
BEGIN
	update udf_data_source set udf_data_source_name = 'Custom' where udf_data_source_name = 'custom' 
END

GO 

IF EXISTS(SELECT 1 FROM udf_data_source WHERE [udf_data_source_name] = 'currency')
BEGIN
	update udf_data_source set udf_data_source_name = 'Currency' where udf_data_source_name = 'currency' 
END

GO