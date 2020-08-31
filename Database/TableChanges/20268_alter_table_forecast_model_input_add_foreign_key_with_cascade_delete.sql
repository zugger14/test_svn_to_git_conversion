IF EXISTS (SELECT 1
           FROM sys.foreign_keys 
           WHERE object_id = OBJECT_ID(N'[dbo].[FK__forecast___forec__42CEA4AE]') 
             AND parent_object_id = OBJECT_ID(N'[dbo].[forecast_model_input]'))
BEGIN
	ALTER TABLE forecast_model_input DROP CONSTRAINT FK__forecast___forec__42CEA4AE
	ALTER TABLE forecast_model_input ADD CONSTRAINT FK__forecast___forec__42CEA4AE FOREIGN KEY (forecast_model_id) REFERENCES forecast_model(forecast_model_id) ON DELETE CASCADE
END 
ELSE
BEGIN
	ALTER TABLE forecast_model_input ADD CONSTRAINT FK__forecast___forec__42CEA4AE FOREIGN KEY (forecast_model_id) REFERENCES forecast_model(forecast_model_id) ON DELETE CASCADE
END	