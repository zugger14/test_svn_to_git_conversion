IF NOT EXISTS(
       SELECT 1
       FROM   process_functions_detail
       WHERE  functionId = 112
              AND userVendorFlag = 'u'
   )
BEGIN
    INSERT INTO process_functions_detail
      (
        functionId,
        filterId,
        userVendorFlag
      )
    VALUES
      (
        112,
        'DealIU',
        'u'
      ) 
    PRINT 'Data Inserted. 112, DealIU, u'
END
ELSE
BEGIN
    PRINT 'Data already exists.'
END

IF NOT EXISTS(
       SELECT 1
       FROM   process_functions_detail
       WHERE  functionId = 110
              AND userVendorFlag = 'u'
   )
BEGIN
    INSERT INTO process_functions_detail
      (
        functionId,
        filterId,
        userVendorFlag
      )
    VALUES
      (
        110,
        'MiddleOffice',
        'u'
      ) 
    PRINT 'Data Inserted. 110, MiddleOffice, u'
END
ELSE
BEGIN
    PRINT 'Data already exists.'
END

