
IF EXISTS (
       SELECT 1
       FROM   process_functions_detail
       WHERE  process_functions_detail.%%physloc%%
              NOT IN (SELECT MIN(b.%%physloc%%)
                      FROM   process_functions_detail b
                      GROUP BY
                             b.functionId,
                             b.filterId,
                             b.userVendorFlag)
		)
BEGIN
	DELETE 
FROM  process_functions_detail
WHERE process_functions_detail.%%physloc%%
      NOT IN (SELECT MIN(b.%%physloc%%)
              FROM   process_functions_detail b
              GROUP BY b.functionId, b.filterId, b.userVendorFlag)
END
ELSE PRINT 'No Duplicate Records exists'
		