IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_source_sink_group_template]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ems_source_sink_group_template]
GO  
/*********************************************
Created By: Anal Shrestha
Created On:10/08/2008
This SP is used to inset, select and delete from ems_source_sink_group_template
EXEC spa_ems_source_sink_group_template 's'
*********************************************/

CREATE PROCEDURE [dbo].[spa_ems_source_sink_group_template]
	@flag char(1),
	@source_group_template_id INT=NULL,
	@group_template_name VARCHAR(50)=NULL,
	@group_template_description VARCHAR(100)=NULL


AS
BEGIN

DECLARE @sql_stmt VARCHAR(5000)	

	IF @flag='s'
		BEGIN
			SET @sql_stmt='
						SELECT 
							[source_group_template_id],[group_template_name],[group_template_description]
						FROM 
							ems_source_sink_group_template
						WHERE 1=1'
						+CASE WHEN @source_group_template_id IS NOT NULL THEN ' AND source_group_template_id='+CAST(@source_group_template_id AS VARCHAR) ELSE '' END

			EXEC(@sql_stmt)
					
						

		END
		
	
END


