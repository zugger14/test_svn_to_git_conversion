IF COL_LENGTH('rec_generator_assignment','contract_id') IS NULL
ALTER TABLE rec_generator_assignment ADD contract_id INT