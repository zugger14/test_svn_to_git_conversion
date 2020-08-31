UPDATE state_rec_requirement_data SET compliance_year=0 WHERE renewable_target IS NULL
ALTER TABLE state_rec_requirement_data ALTER COLUMN renewable_target INTEGER NULL
