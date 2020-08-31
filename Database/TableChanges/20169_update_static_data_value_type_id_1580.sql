
-- At Risk Limit
IF EXISTS (
       SELECT 1
       FROM   static_data_value sdv
       WHERE  sdv.[type_id] = 1580
              AND sdv.code = 'At Risk'
              AND sdv.value_id = 1584
   )
BEGIN
    UPDATE static_data_value
    SET    code         = 'At Risk Limit'
    WHERE  value_id     = 1584
END
ELSE
    PRINT 'At Risk does not exist.'

-- Default VaR Limit	
IF EXISTS (
       SELECT 1
       FROM   static_data_value sdv
       WHERE  sdv.[type_id] = 1580
              AND sdv.code = 'Default VaR limit'
              AND sdv.value_id = 1585
   )
BEGIN
    UPDATE static_data_value
    SET    code         = 'Default VaR Limit'
    WHERE  value_id     = 1585
END
ELSE
    PRINT 'Default VaR limit does not exist.'	

-- Integrated VaR Limit
IF EXISTS (
       SELECT 1
       FROM   static_data_value sdv
       WHERE  sdv.[type_id] = 1580
              AND sdv.code = 'Integrated VaR limit'
              AND sdv.value_id = 1586
   )
BEGIN
    UPDATE static_data_value
    SET    code         = 'Integrated VaR Limit'
    WHERE  value_id     = 1586
END
ELSE
    PRINT 'Integrated VaR limit does not exist.'
	
-- MTM Limit
IF EXISTS (
       SELECT 1
       FROM   static_data_value sdv
       WHERE  sdv.[type_id] = 1580
              AND sdv.code = 'MTM limit'
              AND sdv.value_id = 1580
   )
BEGIN
    UPDATE static_data_value
    SET    code         = 'MTM Limit'
    WHERE  value_id     = 1580
END
ELSE
    PRINT 'MTM limit does not exist.'
	
-- Position and Tenor Limit
IF EXISTS (
       SELECT 1
       FROM   static_data_value sdv
       WHERE  sdv.[type_id] = 1580
              AND sdv.code = 'Position and Tenor limit'
              AND sdv.value_id = 1581
   )
BEGIN
    UPDATE static_data_value
    SET    code         = 'Position and Tenor Limit'
    WHERE  value_id     = 1581
END
ELSE
    PRINT 'Position and Tenor limit does not exist.'
	
-- Position Limit
IF EXISTS (
       SELECT 1
       FROM   static_data_value sdv
       WHERE  sdv.[type_id] = 1580
              AND sdv.code = 'Position limit'
              AND sdv.value_id = 1588
   )
BEGIN
    UPDATE static_data_value
    SET    code         = 'Position Limit'
    WHERE  value_id     = 1588
END
ELSE
    PRINT 'Position limit does not exist.'
	
-- RAROC Integrated Limit
IF EXISTS (
       SELECT 1
       FROM   static_data_value sdv
       WHERE  sdv.[type_id] = 1580
              AND sdv.code = 'RAROC Integrated limit'
              AND sdv.value_id = 1583
   )
BEGIN
    UPDATE static_data_value
    SET    code         = 'RAROC Integrated Limit'
    WHERE  value_id     = 1583
END
ELSE
    PRINT 'RAROC Integrated limit does not exist.'
	
-- RAROC Limit
IF EXISTS (
       SELECT 1
       FROM   static_data_value sdv
       WHERE  sdv.[type_id] = 1580
              AND sdv.code = 'RAROC limit'
              AND sdv.value_id = 1582
   )
BEGIN
    UPDATE static_data_value
    SET    code         = 'RAROC Limit'
    WHERE  value_id     = 1582
END
ELSE
    PRINT 'RAROC limit does not exist.'
	
-- Tenor Limit
IF EXISTS (
       SELECT 1
       FROM   static_data_value sdv
       WHERE  sdv.[type_id] = 1580
              AND sdv.code = 'Tenor limit'
              AND sdv.value_id = 1587
   )
BEGIN
    UPDATE static_data_value
    SET    code         = 'Tenor Limit'
    WHERE  value_id     = 1587
END
ELSE
    PRINT 'Tenor limit does not exist.'							