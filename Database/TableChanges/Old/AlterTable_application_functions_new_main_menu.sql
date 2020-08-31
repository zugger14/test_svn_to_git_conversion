IF COL_LENGTH('application_functions', 'file_path') IS NULL
BEGIN
    ALTER TABLE application_functions ADD file_path VARCHAR(2000) NULL
END
GO




-- seperate following scripts later
UPDATE application_functions
SET file_path = '_setup/maintain_static_data/maintain.static.data.php'
WHERE function_id = 10101000

UPDATE application_functions
SET file_path = '_contract_administration/maintain_contract_group/maintain.contract.new.main.php'
WHERE function_id = 10211000

UPDATE application_functions
SET file_path = '_setup/formula_builder/new.formula.builder.main.php'
WHERE function_id = 10105600

--file path for setup location
UPDATE application_functions 
SET file_path = '_setup/setup_location/setup.location.main.php' 
WHERE function_id = 10102500
