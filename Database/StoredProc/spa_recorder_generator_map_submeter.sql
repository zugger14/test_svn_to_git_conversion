
/****** Object:  StoredProcedure [dbo].[spa_recorder_generator_map_submeter]    Script Date: 12/11/2008 15:52:40 ******/
IF OBJECT_ID(N'[dbo].[spa_recorder_generator_map_submeter]', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_recorder_generator_map_submeter]
GO


CREATE PROCEDURE [dbo].[spa_recorder_generator_map_submeter]
	@flag char(1),
	@generator_id int=NULL,
	@recorder_id varchar(100)=NULL,
	@map_id int=null,
	@allocation_per float=null,
	@from_vol float=null,
	@to_vol float=null
AS
BEGIN

DECLARE @sql varchar(8000)
declare @url varchar(1000)
IF @flag='s'
BEGIN
	SELECT rgm.[ID]
		,rg.Name [Generator]
		,CAST(mi.recorderid AS VARCHAR)+'&nbsp; '  [Sub Recorder ID]
		,CAST( rgm.allocation_per * 100 AS VARCHAR) +' %' [Allocation]
		,from_vol [From Volume]
		,to_vol [To Volume] 
	FROM 	recorder_generator_map_submeter rgm  
	INNER JOIN rec_generator rg ON rg.generator_id=rgm.generator_id
	INNER JOIN meter_id mi ON mi.meter_id = rgm.meter_id
	WHERE rgm.generator_id=@generator_id
END
IF @flag='a'
BEGIN
select rgm.[ID],generator_id ,rgm.meter_id , rgm.allocation_per,from_vol,to_vol
        from 	recorder_generator_map_submeter rgm 
       where rgm.id=@map_id


END
IF @flag='r'
BEGIN

select rgm.meter_id,rg.Name GeneratorName, cast( rgm.allocation_per * 100 as varchar) +' %' [Allocation] ,from_vol [From Volume],to_vol [To Volume]
       from  recorder_generator_map_submeter rgm  join rec_generator rg 
     on rg.generator_id=rgm.generator_id
       where rgm.meter_id=@recorder_id


END
ELSE IF @flag='i'
BEGIN

	if(select sum(allocation_per)+@allocation_per from recorder_generator_map_submeter where meter_id=@recorder_id)>1
	begin
		set @url='<a href="../../dev/spa_html.php?spa=spa_recorder_generator_map_submeter ''r'',null,'''+cast(@recorder_id as varchar)+'''">Click here...</a>'
		select 'Error' ErrorCode, 'Rec Generator Submeter' Module, 
				'spa_recorder_generator_map_submeter' Area, 'DB Error' Status, 
			'Recorder '+@recorder_id +' cannot be allocated more than 100%, Please view this report '+@url Message, '' Recommendation
		return	
	end
	

	if (select max(to_vol) from recorder_generator_map_submeter where meter_id=@recorder_id and id not in (@map_id))>@from_vol OR
		 exists (select * from recorder_generator_map_submeter where meter_id=@recorder_id and from_vol is not null and to_vol is  null)
	begin
		set @url='<a href="../../dev/spa_html.php?spa=spa_recorder_generator_map_submeter ''r'',null,'''+cast(@recorder_id as varchar)+'''">Click here...</a>'
		select 'Error' ErrorCode, 'Rec Generator Submeter' Module, 
				'spa_recorder_generator_map_submeter' Area, 'DB Error' Status, 
			'Specified volume cannot be allocated to Recorder '+@recorder_id +',Please view this report '+@url Message, '' Recommendation
		return	
	end
	insert into recorder_generator_map_submeter(
		generator_id,
		meter_id,
		allocation_per,
		from_vol,
		to_vol	
	)
	values(
		@generator_id,
		@recorder_id,
		@allocation_per,
		@from_vol,
		@to_vol	
	)

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Rec Generator Submeter", 
		"spa_rec_generator_submeter", "DB Error", 
		"Error on Inserting Recorder ID.", ''
	else
		Exec spa_ErrorHandler 0, 'Rec Generator Submeter', 
		'spa_recorder_generator_map_submeter', 'Success', 
		'Recorder ID successfully inserted.',''
		

END
ELSE IF @flag='u'
BEGIN
	
	if(select sum(allocation_per)+@allocation_per from recorder_generator_map_submeter where meter_id=@recorder_id and id not in (@map_id))>1 
	begin
		EXEC spa_print '1'
		set @url='<a href="../../dev/spa_html.php?spa=spa_recorder_generator_map_submeter ''r'',null,'''+cast(@recorder_id as varchar)+'''">Click here...</a>'
		select 'Error' ErrorCode, 'Rec Generator Submeter' Module, 
				'spa_recorder_generator_map_submeter' Area, 'DB Error' Status, 
			'Recorder '+@recorder_id +' cannot be allocated more than 100%, Please view this report '+@url Message, '' Recommendation
		return	
	end

	if (select max(to_vol) from recorder_generator_map_submeter where meter_id=@recorder_id and id not in (@map_id))>@from_vol OR
		 exists (select * from recorder_generator_map_submeter where meter_id=@recorder_id and from_vol is not null and to_vol is  null)
	begin
		EXEC spa_print '2'
		set @url='<a href="../../dev/spa_html.php?spa=spa_recorder_generator_map_submeter ''r'',null,'''+cast(@recorder_id as varchar)+'''">Click here...</a>'
		select 'Error' ErrorCode, 'Rec Generator Submeter' Module, 
				'spa_recorder_generator_map_submeter' Area, 'DB Error' Status, 
			'Specified volume cannot be allocated to Recorder '+@recorder_id +',Please view this report '+@url Message, '' Recommendation
		return	
	end

	update recorder_generator_map_submeter
	set
		meter_id=@recorder_id,
		allocation_per=@allocation_per,
		from_vol=@from_vol,
		to_vol=@to_vol
	where 
		id=@map_id
	
	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Rec Generator Submeter", 
		"spa_rec_generator_submeter", "DB Error", 
		"Error on Updating Recorder ID.", ''
	else
		Exec spa_ErrorHandler 0, 'Rec Generator Submeter', 
		'spa_recorder_generator_map_submeter', 'Success', 
		'Sub-Recorder ID successfully updated.',''
		

END
ELSE IF @flag='d'
BEGIN

	
	DELETE from recorder_generator_map_submeter
	where 	id=@map_id

	If @@ERROR <> 0

		Exec spa_ErrorHandler @@ERROR, "Rec Generator Submeter", 
		"spa_recorder_generator_map_submeter", "DB Error", 
		"Error on Deleting Recorder ID.", ''
	ELSE 

		If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "Rec Generator Submeter", 
			"spa_recorder_generator_map_submeter", "DB Error", 
			"Error on Deleting Contract Group.", ''
		else
			Exec spa_ErrorHandler 0, 'Rec Generator Submeter', 
			'spa_recorder_generator_map_submeter', 'Success', 
			'Recorder ID successfully Deleted.',''	
END

END














