BEGIN TRAN 

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_state_properties_static_data_value]') AND 
parent_object_id = OBJECT_ID(N'[dbo].[state_properties]'))
ALTER TABLE state_properties DROP CONSTRAINT FK_state_properties_static_data_value 

ALTER TABLE state_properties WITH CHECK ADD CONSTRAINT FK_state_properties_static_data_value FOREIGN KEY (code_value) 
REFERENCES dbo.static_data_value(value_id) ON DELETE CASCADE ON UPDATE NO ACTION 

COMMIT 

