IF EXISTS(
       SELECT 1
       FROM   maintain_field_deal 
       WHERE  farrms_field_id = 'certificate'
   )
BEGIN
    UPDATE maintain_field_deal
    SET    system_required     = 'n'
    WHERE  farrms_field_id     = 'certificate'
END
ELSE
    PRINT 'certificate field not found in maintain_field_deal'
	