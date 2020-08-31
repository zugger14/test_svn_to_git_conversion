/****** Object:  StoredProcedure [dbo].[spa_ems_source_model_program]    Script Date: 06/10/2009 15:28:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_source_model_program]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ems_source_model_program]
GO

/****** Object:  StoredProcedure [dbo].[spa_ems_source_model_program]    Script Date: 06/10/2009 15:28:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  proc [dbo].[spa_ems_source_model_program]	@flag as Char(1),
                        @ems_source_model_program_id int=null,	
						@ems_source_model_detail_id int=null,									
						@program_scope_value_id int=null,				
						@user_name varchar(50) = NULL,
						@curve_id INT = NULL 
AS 

if @flag='i'
BEGIN
INSERT INTO ems_source_model_program
		(
        ems_source_model_detail_id,
		program_scope_value_id,
		create_user,
		create_ts,
		update_user,
		update_ts,
		curve_id	
		)
	values
		(
        @ems_source_model_detail_id,
		@program_scope_value_id,
		@user_name,
		getdate(),
		@user_name,
		getdate(),
		@curve_id		
		)
		
		If @@Error <> 0
		Exec spa_ErrorHandler @@Error, 'EmissionSourceModel', 
				'spa_ems_source_model_program', 'DB Error', 
				'Failed to insert defination value.', ''
	Else
		Exec spa_ErrorHandler 0, 'EmissionSourceModel', 
				'spa_ems_source_model_program', 'Success', 
				'Defination data value inserted.', ''
END

ELSE IF @flag='u'
BEGIN

	update	 
		ems_source_model_program
	set
        
        ems_source_model_detail_id = @ems_source_model_detail_id,	
		program_scope_value_id=@program_scope_value_id,
        create_user= @user_name,
        create_ts = getdate(),
        update_user = @user_name,
        update_ts = getdate(),
        curve_id = @curve_id
		
		
	where
		ems_source_model_program_id= @ems_source_model_program_id


		If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Ems Source Model Program", 
		"spa_ems_source_model_program", "DB Error", 
		"Error Updating Ems Source Model Program Information.", ''
	else
		Exec spa_ErrorHandler 0, 'Ems Source Model Program', 
		'spa_meter', 'Success', 
		'Ems Source Model Program Information successfully Updated.',''

END
ELSE IF @flag='s'
BEGIN
declare @sql varchar(5000)
Set @sql ='select e.ems_source_model_program_id,
           e.ems_source_model_detail_id,
           e.program_scope_value_id,
           s.code Code,
           e.curve_id
           
   from
          ems_source_model_program e,
          static_data_value s 

   where  e.program_scope_value_id = s.value_id'
	--TODO: confirm with Anal why -1 was being passed
--  +' AND e.ems_source_model_detail_id = ' +CASE WHEN @ems_source_model_detail_id IS NOT NULL THEN CAST(@ems_source_model_detail_id AS Varchar)  ELSE '-1' END

IF @ems_source_model_program_id IS NULL AND @ems_source_model_detail_id IS NULL
	SET @sql = @sql + ' AND 1 = 2'
ELSE
BEGIN
	IF @ems_source_model_detail_id IS NOT NULL
		SET @sql = @sql + ' AND e.ems_source_model_detail_id = ' + CAST(@ems_source_model_detail_id AS varchar)
	If @ems_source_model_program_id IS NOT NULL
		SET @sql = @sql + ' AND e.ems_source_model_program_id = ' + CAST(@ems_source_model_program_id AS varchar)
	If @curve_id IS NOT NULL
		SET @sql = @sql + ' AND e.ems_source_model_program_id = ' + CAST(@curve_id AS varchar)
END

exec spa_print @sql
exec(@sql)

END
ELSE IF @flag='c'   -- call from price curve window to show the program scope for the given curve_id
BEGIN

Set @sql ='SELECT 
				esmp.ems_source_model_program_id,
				esmp.ems_source_model_detail_id,
				esmp.program_scope_value_id,
				sdv.code,esmp.curve_id 
				FROM dbo.ems_source_model_program esmp
					left JOIN dbo.static_data_value sdv ON esmp.program_scope_value_id = sdv.value_id
				WHERE 1=1'
	--TODO: confirm with Anal why -1 was being passed
--  +' AND e.ems_source_model_detail_id = ' +CASE WHEN @ems_source_model_detail_id IS NOT NULL THEN CAST(@ems_source_model_detail_id AS Varchar)  ELSE '-1' END

IF @ems_source_model_program_id IS NULL AND @curve_id IS NULL
	SET @sql = @sql + ' AND 1 = 2'
ELSE
BEGIN
	IF @ems_source_model_detail_id IS NOT NULL
		SET @sql = @sql + ' AND esmp.ems_source_model_detail_id = ' + CAST(@ems_source_model_detail_id AS varchar)
	If @ems_source_model_program_id IS NOT NULL
		SET @sql = @sql + ' AND esmp.ems_source_model_program_id = ' + CAST(@ems_source_model_program_id AS varchar)
	If @curve_id IS NOT NULL
		SET @sql = @sql + ' AND esmp.curve_id = ' + CAST(@curve_id AS varchar)
END

exec spa_print @sql
exec(@sql)

END
ELSE IF @flag='d'
BEGIN
  
 SET @sql ='DELETE FROM ems_source_model_program WHERE 1=1'
            
 SET @sql = @sql + ' AND ems_source_model_program_id = ' + CAST(@ems_source_model_program_id AS Varchar)
exec(@sql)

If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Ems Source Model Program", 
		"spa_ems_source_model_program", "DB Error", 
		"Error Updating Ems Source Model Program Information.", ''
	else
		Exec spa_ErrorHandler 0, 'Ems Source Model Program', 
		'spa_meter', 'Success', 
		'Ems Source Model Program Information successfully Deleted.',''
   
END








