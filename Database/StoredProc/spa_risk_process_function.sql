/****** Object:  StoredProcedure [dbo].[spa_risk_process_function]    Script Date: 04/12/2009 20:40:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_risk_process_function]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_risk_process_function]

/****** Object:  StoredProcedure [dbo].[spa_risk_process_function]    Script Date: 04/12/2009 20:40:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************
Created By: Anal shrestha
Created On:09/25/2008

EXEC spa_risk_process_function 's'
******************************************/
CREATE PROCEDURE [dbo].[spa_risk_process_function]
	@flag CHAR(1),
	@function_id int=NULL,
	@group_name VARCHAR(100)=NULL

AS 

BEGIN
DECLARE @sql_stmt VARCHAR(1000)

	IF @flag='s' -- Select the functions form table
		BEGIN
			SET @sql_stmt=' select function_id as [FunctionID],process_id,function_description as [Description],group_name as [Group Name] from  risk_process_function where 1=1 ' 
							+CASE WHEN @function_id IS NOT NULL THEN ' AND function_id='+cast(@function_id as VARCHAR) ELSE '' END
		
			EXEC(@sql_stmt)
		END
	
	ELSE IF @flag='a' 
		BEGIN
			SET @sql_stmt=' select function_id,group_name from risk_process_function where function_id='+cast(@function_id as varchar)
			EXEC(@sql_stmt)
		END
		 	 
		
	IF @flag='u'
	BEGIN
		
			UPDATE risk_process_function
				SET group_name=@group_name
			WHERE
				function_id=@function_id


		If @@ERROR <> 0
			BEGIN
				Exec spa_ErrorHandler @@ERROR, "risk_process_function", 
					"spa_risk_process_function", "DB Error", 
					"Failed Updating Data.", ''
		
			END
		ELSE
			
				Exec spa_ErrorHandler 0, "risk_process_function", 
					"risk_process_function", "Success", 
					"Successfully updated data.", ''


	END	
END


