IF NOT  EXISTS (SELECT 'x' FROM information_schema.columns WHERE TABLE_NAME = 'cash_flow_model_type'
 AND COLUMN_NAME = 'model_desc')
ALTER TABLE cash_flow_model_type ADD model_desc VARCHAR(100)