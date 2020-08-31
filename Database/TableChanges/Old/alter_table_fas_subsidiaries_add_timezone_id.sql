IF NOT EXISTS (SELECT 'x' FROM information_schema.columns WHERE table_name = 'fas_subsidiaries' AND column_name = 'timezone_id')
	ALTER TABLE fas_subsidiaries ADD timezone_id INT
