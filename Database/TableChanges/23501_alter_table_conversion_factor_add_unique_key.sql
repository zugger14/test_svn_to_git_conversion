IF NOT EXISTS(
       SELECT 'X'
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS
       WHERE  CONSTRAINT_NAME = 'UC_conversion_factor'
   )
BEGIN
    ALTER TABLE conversion_factor
    ADD CONSTRAINT UC_conversion_factor 
        UNIQUE(conversion_value_id,effective_date,from_uom,to_uom)
END



