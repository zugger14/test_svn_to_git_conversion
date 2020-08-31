IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='formula_nested' AND column_name='time_bucket_formula_id')
ALTER TABLE  formula_nested ADD time_bucket_formula_id INT	
