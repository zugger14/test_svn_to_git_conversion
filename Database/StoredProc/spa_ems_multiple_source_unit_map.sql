/****** Object:  StoredProcedure [dbo].[spa_ems_multiple_source_unit_map]    Script Date: 05/13/2009 09:44:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_multiple_source_unit_map]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ems_multiple_source_unit_map]
/****** Object:  StoredProcedure [dbo].[spa_ems_multiple_source_unit_map]    Script Date: 05/13/2009 09:44:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec spa_ems_multiple_source_unit_map 'a',1,563
CREATE  procedure [dbo].[spa_ems_multiple_source_unit_map]
@flag char(1),
@ID int=NULL,
@generator_id int=NULL,
@EDR_Unit_ID varchar(100)=null,
@PPA_Unit_ID varchar(100)=null,
@EPA_Unit_ID varchar(100)=null,
@Access_Unit_ID varchar(100)=null,
@Rectracker_ID varchar(100)=null,
@source_name varchar(100)=NULL,
@facility_id varchar(100)=NULL

AS
BEGIN
DECLARE @Sql_Select varchar(8000),
@Sql_Where VARCHAR(5000)

IF @flag='i'
BEGIN
	Insert into ems_multiple_source_unit_map(
		
			generator_id,
			ORSIPL_ID,
			EDR_Unit_ID,
			PPA_Unit_ID,
			EPA_Unit_ID,
			Access_Unit_ID,
			Rectracker_ID
			)
	
			select
 
				@generator_id ,
				rg.[ID],
				@EDR_Unit_ID ,
				@PPA_Unit_ID ,
				@EPA_Unit_ID ,
				@Access_Unit_ID,
				@Rectracker_ID
		FROM
			rec_generator rg where rg.generator_id=@generator_id
		if @@ERROR <> 0
		 	Exec spa_ErrorHandler @@ERROR, "Ems Source Inputs", 
			"spa_ems_source_model", "DB Error", 
			"Error Inserting Ems Source Model Inputs.", ''
		ELSE
		 	Exec spa_ErrorHandler 0, "Ems Source Inputs", 
			"spa_ems_source_model", "Success", 
			"Inserted data successfully.", ''
			
END		 
ELSE IF @flag='s'
BEGIN
		SET @Sql_Where=''		
		SET @Sql_Select='
		SELECT  ems.ID,rg.name as [Source/Sink],
		rg.[id] [Facility ID],
		rg.[id2] Unit,
		EDR_Unit_ID as [EDR Unit Code],
		PPA_Unit_ID as [PPA Unit Code],
		EPA_Unit_ID as [EPA Unit Code],
		Access_Unit_ID as [Access Unit Code],
		RecTracker_ID as [RecTracker ID]
		FROM
			ems_multiple_source_unit_map ems left join rec_generator rg 
			on ems.generator_id=rg.generator_id
		WHERE
			1=1'

		+ case when @source_name is not null then ' And rg.name like ''%'+@source_name+'%''' else '' end
		+ case when @facility_id is not null then ' And rg.[ID] like ''%'+@facility_id+'%''' else '' end

		SET @Sql_Select=@Sql_Select+' order by rg.name'    

EXEC (@Sql_Select)
 
exec spa_print @Sql_Select 		
				
END			
		
ELSE IF @flag='u'
BEGIN
	UPDATE 
			ems_multiple_source_unit_map
			SET
			generator_id=@generator_id,
			EDR_Unit_ID=@EDR_Unit_ID,
			PPA_Unit_ID=@PPA_Unit_ID,
			EPA_Unit_ID=@EPA_Unit_ID,
			Access_Unit_ID=@Access_Unit_ID,
			Rectracker_ID=@Rectracker_ID
	WHERE
			id=@id		
			
    	If @@ERROR <> 0
		 	Exec spa_ErrorHandler @@ERROR, "Ems Source Inputs", 
			"spa_ems_source_model", "DB Error", 
			"Error Inserting Ems Source Model Inputs.", ''
		ELSE
		 	Exec spa_ErrorHandler 0, "Ems Source Inputs", 
			"spa_ems_source_model", "Success", 
			"Updated data successfully.", ''
			
 END
ELSE IF @flag='a'
	select  id,generator_id,EDR_Unit_ID,PPA_Unit_ID,EPA_Unit_ID,Access_Unit_ID,Rectracker_ID
			FROM
			ems_multiple_source_unit_map
			where 
			id=@id
				
			


ELSE IF @flag='d'
	DELETE FROM 
			ems_multiple_source_unit_map
	WHERE
			id=@id
		
			
    	If @@ERROR <> 0
		 	Exec spa_ErrorHandler @@ERROR, "Ems Source Inputs", 
			"spa_ems_source_model", "DB Error", 
			"Error Inserting Ems Source Model Inputs.", ''
		ELSE
		 	Exec spa_ErrorHandler 0, "Ems Source Inputs", 
			"spa_ems_source_model", "Success", 
			"Delete data successfully.", ''
END





		












