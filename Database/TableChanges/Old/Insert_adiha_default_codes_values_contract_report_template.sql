IF NOT EXISTS (
       SELECT 1
       FROM   adiha_default_codes
       WHERE  default_code_id = 53
   )
BEGIN
    INSERT INTO adiha_default_codes
    VALUES
      (
        53,
        'contract_report_template',
        'Contract Report Template',
        'Contract Report Template',
        1
      )
END

IF NOT EXISTS (
       SELECT 1
       FROM   adiha_default_codes_params
       WHERE  default_code_id = 53
   )
BEGIN
    INSERT INTO adiha_default_codes_params
    VALUES
      (
        1,
        53,
        'contract_report_template',
        3,
        NULL,
        'h'
      )
END

IF NOT EXISTS (
       SELECT 1
       FROM   adiha_default_codes_values
       WHERE  default_code_id = 53
   )
BEGIN
    INSERT INTO adiha_default_codes_values
    VALUES
      (
        1,
        53,
        1,
        1,
        'Contract Report Templates'
      )
END