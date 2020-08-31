IF NOT EXISTS (SELECT 1 FROM adiha_default_codes WHERE default_code_id = 48)
BEGIN
	INSERT INTO adiha_default_codes
	VALUES
	  (
		48,
		'report_manager',
		'Report Manager',
		'Report Manager',
		1
	  )
END

IF NOT EXISTS (SELECT 1 FROM adiha_default_codes_params WHERE default_code_id = 48)
BEGIN
INSERT INTO adiha_default_codes_params
VALUES
  (
    1,
    48,
    'report_manager',
    3,
    NULL,
    'h'
  )
END

IF NOT EXISTS (SELECT 1 FROM adiha_default_codes_values WHERE default_code_id = 48)
BEGIN
INSERT INTO adiha_default_codes_values
VALUES
  (
    1,
    48,
    1,
    1,
    'Report Manager Views'
  )
END