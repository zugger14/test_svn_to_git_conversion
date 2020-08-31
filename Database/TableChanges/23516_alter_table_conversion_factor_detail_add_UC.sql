IF NOT EXISTS(SELECT 1  
FROM sys.objects  
WHERE type = 'UQ' AND OBJECT_NAME(parent_object_id) = N'conversion_factor_detail' and name = 'UC_conversion_factor_detail' )

BEGIN
    ALTER TABLE conversion_factor_detail
	/**
	  Add unique constraint.
	*/
    ADD CONSTRAINT UC_conversion_factor_detail UNIQUE(conversion_factor_id,effective_date)
END
