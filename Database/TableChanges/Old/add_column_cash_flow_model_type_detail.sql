IF NOT  EXISTS (SELECT 'x' FROM information_schema.columns WHERE TABLE_NAME = 'cash_flow_model_type_detail'
 AND COLUMN_NAME = 'model_name')
ALTER TABLE cash_flow_model_type_detail ADD model_name VARCHAR(100)

IF NOT  EXISTS (SELECT 'x' FROM information_schema.columns WHERE TABLE_NAME = 'cash_flow_model_type_detail'
 AND COLUMN_NAME = 'model_duration')
ALTER TABLE cash_flow_model_type_detail ADD model_duration VARCHAR(100)

IF NOT  EXISTS (SELECT 'x' FROM information_schema.columns WHERE TABLE_NAME = 'cash_flow_model_type_detail'
 AND COLUMN_NAME = 'at_risks')
ALTER TABLE cash_flow_model_type_detail ADD at_risks CHAR(1)