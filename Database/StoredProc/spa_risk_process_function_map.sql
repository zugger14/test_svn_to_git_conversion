/****** Object:  StoredProcedure [dbo].[spa_risk_process_function_map]    Script Date: 04/12/2009 20:39:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_risk_process_function_map]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_risk_process_function_map]

/****** Object:  StoredProcedure [dbo].[spa_risk_process_function_map]    Script Date: 04/12/2009 20:39:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************
Created By: Anal shrestha
Created On:09/25/2008

EXEC spa_risk_process_function_map 's'
******************************************/
CREATE PROCEDURE [dbo].[spa_risk_process_function_map]
	@flag CHAR(1),
	@function_id int=NULL,
	@risk_description_id int=NULL,
	@function_map_id int=NULL

AS 

BEGIN
DECLARE @sql_stmt VARCHAR(1000)

	IF @flag='s' -- Select the functions form table
		BEGIN
			SET @sql_stmt=
						' select 
							rpf.function_map_id as [FunctionMapID],
							prd.risk_description_id as [DescID],
							prd.risk_description [Description],
							stc.description as Priority,
							user_l_name +'', ''+ user_f_name Owner
						 from  
							risk_process_function_map  rpf
							JOIN process_risk_description prd on prd.risk_description_id=rpf.risk_description_id
							LEFT OUTER JOIN static_data_value as stc ON prd.risk_priority = stc.value_id 
							LEFT OUTER JOIN application_users au on prd.risk_owner=au.user_login_id
						where 1=1 ' 
						+CASE WHEN @function_id IS NOT NULL THEN ' AND rpf.function_id='+cast(@function_id as VARCHAR) ELSE '' END
		
			EXEC(@sql_stmt)
		END
	ELSE IF @flag='i'
		BEGIN
			INSERT INTO risk_process_function_map(function_id,risk_description_id)
				select @function_id,@risk_description_id

		If @@ERROR <> 0
			BEGIN
				Exec spa_ErrorHandler @@ERROR, "risk_process_function_map", 
					"spa_risk_process_function_map", "DB Error", 
					"Failed inserting Data.", ''
		
			END
		ELSE
			
				Exec spa_ErrorHandler 0, "risk_process_function_map", 
					"spa_risk_process_function_map", "Success", 
					"Successfully inserted data.", ''


		END	

	ELSE IF @flag='u'
		BEGIN
--			UPDATE risk_process_function_map
--				SET risk_control_id=@risk_control_id
--			WHERE
--				function_map_id=@function_map_id
		EXEC spa_print 'do nothnig'

		If @@ERROR <> 0
			BEGIN
				Exec spa_ErrorHandler @@ERROR, "risk_process_function_map", 
					"spa_risk_process_function_map", "DB Error", 
					"Failed inserting Data.", ''
		
			END
		ELSE
			
				Exec spa_ErrorHandler 0, "risk_process_function_map", 
					"spa_risk_process_function_map", "Success", 
					"Successfully inserted data.", ''


		END	
	ELSE IF @flag='d'
		BEGIN
			delete from risk_process_function_map where function_map_id=@function_map_id

		If @@ERROR <> 0
			BEGIN
				Exec spa_ErrorHandler @@ERROR, "risk_process_function_map", 
					"spa_risk_process_function_map", "DB Error", 
					"Failed deleting Data.", ''
		
			END
		ELSE
			
				Exec spa_ErrorHandler 0, "risk_process_function_map", 
					"spa_risk_process_function_map", "Success", 
					"Data deleted successfully inserted.", ''


		END	

END






