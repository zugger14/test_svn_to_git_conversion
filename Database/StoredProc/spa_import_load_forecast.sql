/****** Object:  StoredProcedure [dbo].[spa_import_source_facility]    Script Date: 03/04/2010 09:59:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_import_load_forecast]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_import_load_forecast]
/****** Object:  StoredProcedure [dbo].[spa_import_source_facility]    Script Date: 03/04/2010 09:59:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spa_import_load_forecast]
	@temp_table_name	VARCHAR(100),  
	@table_id			VARCHAR(100),  
	@job_name			VARCHAR(100),  
	@process_id			VARCHAR(100),  
	@user_login_id		VARCHAR(50)  
  
AS
BEGIN  


	DECLARE @error_code VARCHAR(100),@user VARCHAR(100),@desc VARCHAR(100)
	DECLARE @SQL VARCHAR(MAX)

	CREATE TABLE #count ( cnt INT)

	CREATE TABLE #temp_load_forecast
	(
			location_id INT,
			load_forecast_date  DATETIME,
			load_forecast_hour  INT,
			load_forecast_volume  FLOAT	
	)

	SELECT @error_code = 's',@user_login_id = dbo.FNAdbuser()
	

	SET @SQL='INSERT INTO #temp_load_forecast(location_id,load_forecast_date,load_forecast_hour,load_forecast_volume)
			SELECT
				sml.source_minor_location_id,
				load_forecast_date,
				load_forecast_hour,
				load_forecast_volume	
			FROM
				'+@temp_table_name+' a
				LEFT JOIN source_minor_location sml ON a.location_id=sml.location_name'

	EXEC(@SQL)
	
	DELETE a
	FROM
		Power_load_forecast a
		INNER JOIN source_minor_location sml ON a.location_id=sml.source_minor_location_id
		INNER JOIN 	#temp_load_forecast b ON sml.source_minor_location_id=b.location_id
		AND a.forecast_date=b.load_forecast_date
		AND a.forecast_hour=b.load_forecast_hour


		INSERT INTO Power_load_forecast(location_id,forecast_date,forecast_hour,volume,granularity_id)
			SELECT
				location_id,
				load_forecast_date,
				load_forecast_hour,
				load_forecast_volume,
				982	
		FROM
			#temp_load_forecast

			
	SET @desc='Power Load Forecast Import successful'
	SET @process_id=dbo.FNAGetNewID()
	DECLARE list_user CURSOR FOR 
		SELECT application_users.user_login_id	
			FROM dbo.application_role_user 
				INNER JOIN dbo.application_security_role 
					ON dbo.application_role_user.role_id = dbo.application_security_role.role_id 
				INNER JOIN dbo.application_users 
					ON dbo.application_role_user.user_login_id = dbo.application_users.user_login_id
				WHERE (dbo.application_users.user_active = 'y') AND (dbo.application_security_role.role_type_value_id =2) 							
				GROUP BY dbo.application_users.user_login_id,  dbo.application_users.user_emal_add
	OPEN list_user
		FETCH NEXT FROM list_user INTO 	@user
		WHILE @@FETCH_STATUS = 0
		BEGIN							
			EXEC  spa_message_board 'i', @user,NULL, 'Import.Data',@desc, '', '', 's', 'Interface Adaptor',null,@process_id
			FETCH NEXT FROM list_user INTO 	@user
		END
	CLOSE list_user
	DEALLOCATE list_user
END -- End of Procedure