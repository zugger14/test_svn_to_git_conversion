IF NOT EXISTS (
       SELECT 1
       FROM   adiha_default_codes
       WHERE  default_code_id = 101
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
        101
       ,'session_timeout'
       ,'Application session timeout value.'
       ,'Session Timeout'
       ,1
      )
END
ELSE
BEGIN
    PRINT 'Session Timeout default code already exists.'
END

IF NOT EXISTS (
       SELECT 1
       FROM   adiha_default_codes_values
       WHERE  default_code_id = 101
   )
BEGIN
    INSERT INTO adiha_default_codes_values
    VALUES
      (
        1
       ,101
       ,1
       ,1800
       ,'Application session timeout value in secs.'
      )
END
ELSE
BEGIN
    PRINT 'Session Timeout default code value already exists.'
END

