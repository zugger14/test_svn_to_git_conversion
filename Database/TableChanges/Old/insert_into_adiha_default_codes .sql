IF NOT EXISTS (
       SELECT 1
       FROM   adiha_default_codes
       WHERE  default_code_id = 54
   )
BEGIN
    INSERT INTO adiha_default_codes
      (
        default_code_id
       ,default_code
       ,code_description
       ,code_def
       ,instances
      )
    VALUES
      (
        54
       ,'regression_testing'
       ,'Regression Testing'
       ,'Regression Testing'
       ,1
      )
END
ELSE
BEGIN
    PRINT 'Already Exists'
END

IF NOT EXISTS (
       SELECT 1
       FROM   adiha_default_codes_params
       WHERE  default_code_id = 54
   )
BEGIN
    INSERT INTO adiha_default_codes_params
    VALUES
      (
        1
       ,54
       ,'regression_testing'
       ,3
       ,NULL
       ,'h'
      )
END
ELSE
BEGIN
    PRINT 'Already Exists'
END
IF NOT EXISTS (
       SELECT 1
       FROM   adiha_default_codes_values
       WHERE  default_code_id = 54
   )
BEGIN
    INSERT INTO adiha_default_codes_values
    VALUES
      (
        1
       ,54
       ,1
       ,1
       ,'Regression Testing'
      )
END
ELSE
BEGIN
    PRINT 'Already Exists'
END

IF NOT EXISTS (
       SELECT 1
       FROM   adiha_default_codes_values_possible
       WHERE  var_value = '1'
              AND default_code_id = 54
   )
BEGIN
    INSERT INTO adiha_default_codes_values_possible
      (
        default_code_id
       ,var_value
       ,[description]
      )
    VALUES
      (
        54
       ,1
       ,'Regression Testing'
      )
END
ELSE
BEGIN
    PRINT 'Already Exists'
END