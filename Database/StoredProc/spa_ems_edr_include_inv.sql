 --select * from ems_edr_include_inv
-- exec spa_ems_edr_include_inv 'i',NULL,272,39,'2007-06-01','2007-06-30',703,NULL
--exec spa_ems_edr_include_inv 'i',NULL,272,39,'2007-06-01','2007-06-30',703,NULL

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_edr_include_inv]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ems_edr_include_inv]
GO 

create proc [dbo].[spa_ems_edr_include_inv]
					@flag as Char(1),	
					@id varchar(100)=null,				
					@generator_id  int=NULL,
					@curve_id int=NULL,
					@term_start datetime=NULL,
					@term_end datetime=NULL,
					@frequency float=NULL,
					@use_calc_value char(1)=NULL,
					@series_type int=NULL
	
								

AS 
DECLARE @sql_stmt varchar(5000)
if @term_start is null and @term_end is not null
	set @term_start=@term_end
if @term_end is null and @term_start is not null
	set @term_end=@term_start
if @flag='s'
begin
	set @sql_stmt='
	select 
		[id] as [ID],	
		--generator_id ,curve_id,
		ISNULL(sd.code,''Default Inventory'') as [Series Type],
		dbo.fnadateformat(term_start) as [Term Start],
		dbo.fnadateformat(term_end) as [Term End]		
		--frequency,use_calc_value 
	from  ems_edr_include_inv edr
		  left join static_data_value sd on sd.value_id=edr.series_type
	where
			generator_id='+cast(@generator_id as varchar)+' and curve_id='+cast(@curve_id as varchar)
	+case when @term_start is not null then ' And ((term_start between '''+cast(@term_start as varchar)+''' and '''+cast(@term_end as varchar)+''')OR(term_end between '''+cast(@term_start as varchar)+''' and '''+cast(@term_end as varchar)+'''))' else '' end
exec(@sql_stmt)
end

else if @flag='a'

begin

	select generator_id ,curve_id,dbo.fnadateformat(term_start),
		dbo.fnadateformat(term_end),
		frequency,use_calc_value,series_type  from ems_edr_include_inv where [id]=@id

end

else if @flag='i'
begin

	if exists(select [id] from ems_edr_include_inv where generator_id=@generator_id and curve_id=@curve_id and series_type=@series_type
		and ((@term_start between term_start and term_end) or (@term_end between term_start and term_end)))
	begin
		Exec spa_ErrorHandler 1, 'The selected date overlaps the existing Term.' , 
					'EDR Inventory', 'DB Error', 'The selected date overlaps the existing Term.', ''
			RETURN
	end
	insert into  ems_edr_include_inv
	(
		generator_id ,
		curve_id,
		term_start,
		term_end,
		frequency,
		use_calc_value,
		series_type 		
	)

	values

	(
		@generator_id ,
		@curve_id,
		@term_start,
		@term_end,
		@frequency,
		@use_calc_value,
		@series_type 		
	)

	If @@ERROR <> 0
	BEGIN
		
		Exec spa_ErrorHandler @@ERROR, 'spa_ems_edr_include_inv' , 
				'EDR Inventory', 'Error', 'Error on insertint values', ''
		RETURN
	END
	Else
	BEGIN
		Select 	'Success' ErrorCode, 
			'spa_ems_edr_include_inv' Module, 
			'EDR Inventory' Area, 
			 '' Status, 
			'values successfully inserted.' Message, 
			'' Recommendation
	
		RETURN
	END

		
end

else if @flag='u'

begin
	if exists(select [id] from ems_edr_include_inv where generator_id=@generator_id and curve_id=@curve_id and series_type=@series_type
		and ((@term_start between term_start and term_end) or (@term_end between term_start and term_end)) and id<>@id)
	begin
		Exec spa_ErrorHandler 1, 'The selected date overlaps the existing Term.' , 
					'EDR Inventory', 'Error', 'The selected date overlaps the existing Term.', ''
			RETURN
	end


	update  ems_edr_include_inv   
			set  	generator_id=@generator_id ,
					curve_id=@curve_id,
					term_start=@term_start,
					term_end=@term_end,
					frequency=@frequency,
					use_calc_value=@use_calc_value,
					series_type=@series_type 
					where [id]=@id
	If @@ERROR <> 0
	BEGIN
		
		Exec spa_ErrorHandler @@ERROR, 'spa_ems_edr_include_inv' , 
				'EDR Inventory', 'Error', 'Error on updating values', ''
		RETURN
	END
	Else
	BEGIN
		Select 	'Success' ErrorCode, 
			'spa_ems_edr_include_inv' Module, 
			'EDR Inventory' Area, 
			 '' Status, 
			'Values successfully Updated.' Message, 
			'' Recommendation
	
		RETURN
	END

end

else if @flag='d'

begin

	exec('delete ems_edr_include_inv
	where [ID] in('+@id+')')

	If @@ERROR <> 0
	BEGIN
		
		Exec spa_ErrorHandler @@ERROR, 'spa_ems_edr_include_inv' , 
				'EDR Inventory', 'Error', 'Error on deleting values', ''
		RETURN
	END
	Else
	BEGIN
		Select 	'Success' ErrorCode, 
			'spa_ems_edr_include_inv' Module, 
			'EDR Inventory' Area, 
			 '' Status, 
			'values successfully deleted.' Message, 
			'' Recommendation
	
		RETURN
	END

end












