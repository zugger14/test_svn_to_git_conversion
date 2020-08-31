--===========================================================================================
--This Procedure returns All notes
--Input Parameters:
--@internal_type_value_id - value id of type_id = 25 @ static_data_value table
--@notes_object_id - id of the object that can contain many notes, for general pass 0 and for others required
--@notes_id - optional, when passed will select only one row
--@notes_category - optional
--@date_from - date from when note is created
--@date_to - date to when note is created
--===========================================================================================

/****** Object:  StoredProcedure [dbo].[spa_Get_All_Notes]    Script Date: 03/16/2010 16:03:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Get_All_Notes]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Get_All_Notes]

GO

CREATE PROC [dbo].[spa_Get_All_Notes]
			@internal_type_value_id		INT				= NULL,
			@notes_object_id			VARCHAR (50)	= NULL ,
			@notes_id					INT				= NULL,
			@date_from					VARCHAR (20)	= NULL,
			@date_to					VARCHAR (20)	= NULL,
			@risk_control_activity_id	INT				= NULL,
			@source_system_id			INT				= NULL,
			@notes_user					VARCHAR (20)	= NULL,
			@notes_share_email_enable	BIT				= NULL
AS


SET NOCOUNT ON

Declare @Sql_Select varchar(5000)


SELECT @Sql_Select = 'SELECT 
						notes_id AS ID, sdv.code AS [Notes Category], 
						dbo.FNAHyperLinkText(10102913, notes_subject, notes_id) AS Subject,
						attachment_file_name [File Name],  
						dbo.FNADateFormat(an.create_ts) AS [Created on Date], an.create_user AS [Created by User]      
						FROM application_notes an
						LEFT JOIN static_data_value sdv ON sdv.value_id = an.internal_type_value_id
						WHERE 1=1 '

IF @internal_type_value_id IS NOT NULL 
	SELECT @Sql_Select = @Sql_Select + ' AND internal_type_value_id = ' + CAST(@internal_type_value_id AS VARCHAR) 
	
IF @notes_id IS NOT NULL 
	SELECT @Sql_Select = @Sql_Select + ' AND notes_id = ' + CAST(@notes_id as VARCHAR)

IF @notes_object_id IS NOT NULL AND @notes_object_id<>''
	SELECT @Sql_Select = @Sql_Select + ' AND notes_object_id = ''' + CAST(@notes_object_id as VARCHAR)+ ''''

IF @date_from IS NOT NULL 
	SELECT @Sql_Select = @Sql_Select + ' AND an.create_ts >= CONVERT(DATETIME, ''' + @date_from  + ''', 102)'

IF @date_to IS NOT NULL	
	SELECT @Sql_Select = @Sql_Select + ' AND an.create_ts <= CONVERT(DATETIME, ''' + @date_to +  ' 23:59' + ''', 102)'


IF @date_from IS NOT NULL AND  @date_to IS NOT NULL	
	SELECT @Sql_Select = @Sql_Select + ' AND an.create_ts BETWEEN  CONVERT(DATETIME, ''' + @date_from + ''', 102) AND CONVERT(DATETIME, ''' + @date_to +  ' 23:59' + ''', 102)'

IF @risk_control_activity_id IS NOT NULL 
	SELECT @Sql_Select = @Sql_Select + ' AND SUBSTRING(notes_object_id ,0, CHARINDEX(''-'',notes_object_id)) = ' + CAST(@risk_control_activity_id AS VARCHAR)

IF @source_system_id IS NOT NULL
	SELECT @Sql_Select = @Sql_Select + ' AND source_system_id = '+CAST(@source_system_id AS VARCHAR)

IF @notes_user IS NOT NULL
	SELECT @Sql_Select = @Sql_Select + ' AND (an.create_user = ''' + CAST(@notes_user AS VARCHAR) + ''' OR an.update_user = ''' + CAST(@notes_user AS VARCHAR) + ''')'

IF @notes_share_email_enable IS NOT NULL
	SELECT @Sql_Select = @Sql_Select + ' AND an.notes_share_email_enable = ' + CAST(@notes_share_email_enable AS VARCHAR)

SET @Sql_Select = @Sql_Select + ' ORDER BY an.create_ts desc'

EXEC spa_print @Sql_Select

Exec(@Sql_Select)

