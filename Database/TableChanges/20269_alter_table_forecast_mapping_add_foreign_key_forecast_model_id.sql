DELETE fmi FROM forecast_mapping_input fmi 
	INNER JOIN forecast_mapping fmm ON fmm.forecast_mapping_id = fmi.forecast_mapping_id
	LEFT JOIN forecast_model fm ON fmm.forecast_model_id = fm.forecast_model_id
WHERE fm.forecast_model_id IS NULL 

DELETE fmd FROM forecast_mapping_datarange fmd 
	INNER JOIN forecast_mapping fmm ON fmm.forecast_mapping_id = fmd.forecast_mapping_id
	LEFT JOIN forecast_model fm ON fmm.forecast_model_id = fm.forecast_model_id
WHERE fm.forecast_model_id IS NULL 

DELETE fmm FROM forecast_model fm 
	right JOIN forecast_mapping fmm ON fmm.forecast_model_id = fm.forecast_model_id
WHERE fm.forecast_model_id IS NULL 

  
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_forecast_mapping_forecast_model_id]')
  				AND parent_object_id = OBJECT_ID(N'[dbo].[forecast_mapping]'))
BEGIN
	ALTER TABLE [dbo].[forecast_mapping] ADD CONSTRAINT [FK_forecast_mapping_forecast_model_id] 
	FOREIGN KEY([forecast_model_id])
	REFERENCES [dbo].[forecast_model] ([forecast_model_id])
END
  
