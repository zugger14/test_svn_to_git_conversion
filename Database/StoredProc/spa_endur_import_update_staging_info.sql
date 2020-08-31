IF OBJECT_ID(N'dbo.spa_endur_import_update_staging_info', N'P') IS NOT NULL
	DROP PROCEDURE dbo.spa_endur_import_update_staging_info
GO

CREATE PROCEDURE dbo.spa_endur_import_update_staging_info
	  @parse_type				INT, --  deal : 5, mtm : 6, price : 4
	  @file_name VARCHAR(100) = NULL,
	  @folder_endur_or_user VARCHAR(2),
	  @file_type VARCHAR(25),
	  @file_as_of_date VARCHAR(25),
	  @file_timestamp VARCHAR(25),
	  @violation_file_level VARCHAR(2) = NULL
AS


IF @parse_type = 5
BEGIN
	UPDATE adiha_process.dbo.stage_deals_rwe_de SET [file_name] = @file_name, folder_endur_or_user = @folder_endur_or_user,
	file_type = @file_type, file_as_of_date = @file_as_of_date, file_timestamp = @file_timestamp 
	WHERE [file_name] IS NULL

END

ELSE IF @parse_type = 6
BEGIN
	UPDATE adiha_process.dbo.stage_mtm_rwe_de SET [file_name] = @file_name, folder_endur_or_user = @folder_endur_or_user,
	file_type = @file_type, file_as_of_date = @file_as_of_date, file_timestamp = @file_timestamp, violation_file_level = @violation_file_level 
	WHERE [file_name] IS NULL
      	
END

ELSE IF @parse_type = 4
BEGIN
	UPDATE adiha_process.dbo.stage_spc_rwe_de SET [file_name] = @file_name, folder_endur_or_user = @folder_endur_or_user,
	file_type = @file_type, file_as_of_date = @file_as_of_date, file_timestamp = @file_timestamp, violation_file_level = @violation_file_level 
	WHERE [file_name] IS NULL
      	
END 

