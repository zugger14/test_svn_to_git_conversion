BEGIN TRY
	IF EXISTS (SELECT  'x' FROM source_minor_location sml WHERE sml.profile_id NOT IN (SELECT fp.profile_id FROM forecast_profile fp))
	BEGIN
		UPDATE sml
		SET sml.profile_id = NULL 
		FROM source_minor_location sml WHERE sml.profile_id NOT IN (SELECT fp.profile_id FROM forecast_profile fp)
	END
END TRY
BEGIN CATCH
	SELECT
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_STATE() AS ErrorState,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_LINE() AS ErrorLine,
		ERROR_MESSAGE() AS ErrorMessage
	
END CATCH

