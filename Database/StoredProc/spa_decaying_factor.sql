IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_decaying_factor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_decaying_factor]
GO 

CREATE proc [dbo].[spa_decaying_factor]	@flag as Char(1),					
					@decay_id  int=NULL,
					@state_value_id  int=NULL,
					@technology int=NULL,
					@year int=NULL,
					@decay_per float=NULL,
					@assignment_type_value_id int=NULL,
					@curve_id int=NULL,
					@gen_code_value int=NULL,
					@gen_year int=null

								

AS 

if @flag='s'
begin
	declare @sql_stmt varchar(5000)

	set @sql_stmt='
	select Decay_id [Decay ID],cv.code Jurisdiction, gcv.code [Gen State], tech.code Technology, 
	assig.code [Assignment Type],pc.curve_name [Env Product], Year,  Gen_year [Gen Year],
	Cast((( 1-Decay_Per) * 100) as varchar) + ''%''  [Decay %], 
	Cast((( Decay_Per) * 100) as varchar) + ''%''  [Remaining %] 
	 from decaying_factor d
	left outer join static_data_value tech on tech.value_id=d.technology 
	left outer join static_data_value assig on assig.value_id=d.assignment_type_value_id
	left outer join source_price_curve_def pc on pc.source_curve_def_id=d.curve_id
	left outer join static_data_value cv on cv.value_id=d.state_value_id
	left outer join static_data_value gcv on gcv.value_id=d.gen_code_value
	where 1=1 '
	if @year is not null
			set @sql_stmt =	 @sql_stmt + ' and year='+cast(@year as varchar)		
	
	if @curve_id is not null
			set @sql_stmt = @sql_stmt + ' and d.curve_id='+cast(@curve_id as varchar)	

			set @sql_stmt = @sql_stmt + ' order by decay_id desc '
	exec(@sql_stmt) 
end

else if @flag='a'

begin

	select * from decaying_factor where decay_id=@decay_id

end

else if @flag='i'

begin
	insert into  decaying_factor
	(
		state_value_id,
		technology,
		[year],
		decay_per,
		assignment_type_value_id,
		curve_id,
		gen_code_value,
		gen_year
		
	)

	values

	(
		@state_value_id,
		@technology,
		@year,
		@decay_per,
		@assignment_type_value_id,
		@curve_id,
		@gen_code_value,
		@gen_year		
	)

	If @@ERROR <> 0
	BEGIN
		
		Exec spa_ErrorHandler @@ERROR, 'spa_decaying_factor' , 
				'Decaying Factor', 'Error', 'Error on creating Decaying Factor', ''
		RETURN
	END
	Else
	BEGIN
		Select 	'Success' ErrorCode, 
			'spa_decaying_factor' Module, 
			'Decaying Factor' Area, 
			 '' Status, 
			'Decaying Factor successfully created.' Message, 
			'' Recommendation
	
		RETURN
	END

		
end

else if @flag='u'

begin

	update  decaying_factor   set  	state_value_id=@state_value_id,
					technology=@technology,
					[year]=@year,
					decay_per=@decay_per,
					assignment_type_value_id=@assignment_type_value_id,
					curve_id=@curve_id,
					gen_code_value=@gen_code_value,
					gen_year=@gen_year
					where decay_id=@decay_id
	If @@ERROR <> 0
	BEGIN
		
		Exec spa_ErrorHandler @@ERROR, 'spa_decaying_factor' , 
				'Decaying Factor', 'Error', 'Error on saving Decaying Factor', ''
		RETURN
	END
	Else
	BEGIN
		Select 	'Success' ErrorCode, 
			'spa_decaying_factor' Module, 
			'Decaying Factor' Area, 
			 '' Status, 
			'Decaying Factor successfully saved.' Message, 
			'' Recommendation
	
		RETURN
	END

end

else if @flag='d'

begin

	delete decaying_factor
	where decay_id=@decay_id 
	If @@ERROR <> 0
	BEGIN
		
		Exec spa_ErrorHandler @@ERROR, 'spa_decaying_factor' , 
				'Decaying Factor', 'Error', 'Error on deleting Decaying Factor', ''
		RETURN
	END
	Else
	BEGIN
		Select 	'Success' ErrorCode, 
			'spa_decaying_factor' Module, 
			'Decaying Factor' Area, 
			 '' Status, 
			'Decaying Factor successfully deleted.' Message, 
			'' Recommendation
	
		RETURN
	END

end






