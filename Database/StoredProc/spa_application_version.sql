IF OBJECT_ID(N'dbo.[spa_application_version]', N'P') IS NOT NULL
    DROP PROC dbo.[spa_application_version]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
	Procedure that is used for inserting, updating and getting current version/theme of application.

	Parameters:
		@flag							:	Operation flag that decides the action to be performed.
		@version_number					:	Version of the application represented in Numeric form. (Eg - 3.6.013)
		@version_label					:	Version of the application represented in Text form.
		@txt_version_label_font_size	:	Define the size of the font that will define the size of the version label.
		@txt_version_theme_name			:	Define the theme name for the version.
*/

CREATE PROC dbo.[spa_application_version]
	@flag CHAR(1) = NULL,
	@version_number VARCHAR(50) = NULL,
	--3.6.013
	@version_label VARCHAR(300) = NULL,
	@version_color VARCHAR(100) = NULL,
	@txt_version_label_font_size VARCHAR(10) = NULL,
	@txt_version_theme_name VARCHAR(20) = NULL
AS
SET NOCOUNT ON

/**
DECLARE @flag CHAR(1) = NULL,
	@version_number VARCHAR(50) = NULL,
	@version_label VARCHAR(300) = NULL,
	@version_color VARCHAR(100) = NULL,
	@txt_version_label_font_size VARCHAR(10) = NULL,
	@txt_version_theme_name VARCHAR(20) = NULL

SELECT @flag = 's'
--*/

DECLARE @db_user VARCHAR(50) = dbo.FNADBUser()


IF @flag = 's'
BEGIN
	-- retrive version from release patches if exist other wise use old logic to display
	IF OBJECT_ID('[dbo].[release_patch]') IS NOT NULL AND EXISTS (SELECT 1 FROM [dbo].[release_patch])
	BEGIN
		SELECT TOP 1
			42 AS [Default Code ID]
			,'application_version' AS [Default Code]
			,'Application Version' AS [Code Description],
			-- Check if the string ends with a Number or String
			CASE WHEN PATINDEX('%[0-9]', rp.[description]) = 0 THEN
				/*
					{
						TEST CASES:
						TRMTracker_Release_Hotfix_4.2.078
						TRMTracker_Release_Hotfix_4.2.0759
						TRMTracker_Release_Hotfix_4.2.075[LADWP Specific]
						TRMTracker_Release_Hotfix_4.2.075-None
						TRMTracker_Release_Hotfix_4.2.075_LADWP
						4.2.075
						TRMTracker_Release_Hotfix_4.2.075 (LADWP Specific)
						TRMTracker_Release_Hotfix_4.2.075\(LADWP Specific)
					}
					* Find the sub-string from where the numbers start to where the string ends
					Example: [TRMTracker_Release_Hotfix_4.2.075 (LADWP Specific)]
					Sub-String => [4.2.075 (LADWP Specific)]
					* Find the sub-string from where the Sub-String starts and to where the letter starts in Sub-String with PATINDEX
					Next-Sub-String => [4.2.075]
				*/
				SUBSTRING(rp.[description], PATINDEX('%[0-9]%', rp.[description]), PATINDEX('%[A-Za-z()\_\\\[ \-]%', SUBSTRING(rp.[description], PATINDEX('%[0-9]%', rp.[description]), LEN(rp.[description]))) - 1)
			ELSE
				SUBSTRING(rp.[description], PATINDEX('%[0-9]%', rp.[description]), LEN(rp.[description]))
			END [Version Number]
		FROM release_patch rp
		ORDER By [Version Number] DESC
	END
	ELSE
	BEGIN
		SELECT adc.default_code_id AS [Default Code ID],
		   default_code AS [Default Code],
		   adc.code_description AS [Code Description],
		   adcv.var_value AS [Version Number]
		FROM   adiha_default_codes adc
			   INNER JOIN adiha_default_codes_values adcv
					ON  adcv.default_code_id = adc.default_code_id
		WHERE adc.default_code_id = 42
	END
END
ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
	BEGIN TRAN
		IF EXISTS (SELECT 1 from application_version_info)
		BEGIN
			UPDATE application_version_info
				SET version_number = @version_number

		END
		ELSE
		BEGIN
			INSERT INTO application_version_info (version_number) VALUES (@version_number)
		END

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler 1,
		     'Application Version',
		     'spa_application_version',
		     'DB Error',
		     'Fail to update app version.',
		     ''
		ROLLBACK TRAN
	END CATCH

END
ELSE IF @flag = 'i'
BEGIN

		IF EXISTS (SELECT 1 from application_version_info where version_label = @version_label AND version_color = @version_color AND version_label_font_size = @txt_version_label_font_size)
		BEGIN
			EXEC spa_ErrorHandler 1,
			'Application Version',
		     'spa_application_version',
		     'DB Error',
		     'Data already exists.',
		     ''
			RETURN
		END


		IF EXISTS (SELECT 1 from application_version_info)
		BEGIN
			UPDATE application_version_info
				SET version_label = @version_label,
					version_color = @version_color,
					version_label_font_size = @txt_version_label_font_size

		END
		ELSE
		BEGIN
			INSERT INTO application_version_info (version_label, version_color,version_label_font_size) 
			VALUES (@version_label, @version_color, @txt_version_label_font_size)
		END

		IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR,
			'Application Version',
		     'spa_application_version',
		     'DB Error',
		     'Fail to update app version label.',
		     ''
		ELSE
		BEGIN
		Exec spa_ErrorHandler 0,
			'Application Version',
		     'spa_application_version',
			'Success',
			'Changes have been saved successfully.',
			''
		END
END

ELSE IF @flag = 't'
BEGIN
	IF EXISTS (SELECT 1 from application_version_info)
	BEGIN
		UPDATE application_version_info
			SET version_theme_name = @txt_version_theme_name
	
	END
	ELSE
	BEGIN
		INSERT INTO application_version_info (version_theme_name) 
		VALUES (@txt_version_theme_name)
	END

	IF @@ERROR <> 0
	EXEC spa_ErrorHandler @@ERROR,
		'Application Version',
			'spa_application_version',
			'DB Error',
			'Fail to save default theme version',
			''
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 0,
			'Application Version',
			'spa_application_version',
			'Success',
			'Changes have been saved successfully.',
			''
	END															
END
ELSE IF @flag = 'k'
BEGIN
	SELECT COALESCE(au.theme_value_id,avi.version_theme_name,'jomsomGreen') [default_theme],
		   ISNULL(avi.version_label_font_size,'14px') [default_label],
		   avi.version_theme_name [version_theme_name]
	FROM application_users au
	LEFT JOIN application_version_info avi ON 1 = 1
	WHERE  au.user_login_id = @db_user
END
