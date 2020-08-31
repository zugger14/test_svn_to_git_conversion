IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'state_properties_duration' AND column_name IN ('code_value', 'state_value_id'))
BEGIN
  ALTER TABLE state_properties_duration ADD code_value INT
END