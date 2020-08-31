/************************************************************
 * Adding new note type Renewable Source
 ************************************************************/

IF NOT EXISTS (
       SELECT 1
       FROM   static_data_value sdv
       WHERE  sdv.code = 'Renewable Source'
              AND sdv.[type_id] = 25
   )
BEGIN
    INSERT INTO static_data_value
      (
        [type_id],
        code,
        [description]
      )
    VALUES
      (
        25,
        'Renewable Source',
        'Renewable Source'
      )
END
ELSE
    PRINT 'Renewable Source already exist.'