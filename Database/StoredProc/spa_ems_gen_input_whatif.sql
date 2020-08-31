
/****** Object:  StoredProcedure [dbo].[spa_ems_gen_input_whatif]    Script Date: 06/15/2009 20:56:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_gen_input_whatif]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ems_gen_input_whatif]
/****** Object:  StoredProcedure [dbo].[spa_ems_gen_input_whatif]    Script Date: 06/15/2009 20:56:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[spa_ems_gen_input_whatif]
@flag char(1),
@ems_input_id int=NULL,
@ems_gen_id int=NULL,
@generator_id int=NULL,
@estimate_type char(1)=NULL,
@term_start varchar(20)=NULL,
@term_end varchar(20)=NULL,
@frequency varchar(20)=NULL,
@char1 int=null,
@char2 int=null,
@char3 int=null,
@char4 int=null,
@char5 int=null,
@char6 int=null,
@char7 int=null,
@char8 int=null,
@char9 int=null,
@char10 int=null,
@input_value float=null,
@uom_id int=null,
@forecast_type int=NULL,
@criteria_id INT = NULL,
@value_shift FLOAT = null

AS
--for Test
-- 	declare @ems_input_id int
-- 	set @ems_input_id=12
--	drop table #temp_clms
--	drop table #temp
--
BEGIN
DECLARE @sql varchar(8000)
DECLARE @max_input_value float,@min_input_value float

declare @i int,@clm varchar(100), @tot_row int,
		@clm_name varchar(1000),
		@join1 varchar(1000),@clm1 varchar(100),
		@static_data_type int,@tbl_name varchar(100)

if @term_start is null
	select @term_start=min(term_start) from ems_gen_input_whatif where generator_id=@generator_id
if @term_end is null
	select @term_end=max(term_start) from ems_gen_input_whatif where generator_id=@generator_id

create table #temp(
		ID int,
		[Term Start] varchar(20) COLLATE DATABASE_DEFAULT,
		[Term End] varchar(20) COLLATE DATABASE_DEFAULT,
		Frequency varchar(50) COLLATE DATABASE_DEFAULT	
)
create table #temp_clms(
	tid int identity(1,1),
	clm_name varchar(200) COLLATE DATABASE_DEFAULT,
	static_data_type int
)

set @estimate_type='r'
--#######If insert ot update , check to see the value is valid, that is lies between maximum and minimum values
if @input_value is not null
BEGIN
select @max_input_value=isnull(max_value,999999999),@min_input_value=isnull(min_value,-999999999)
	from ems_input_valid_values where ems_source_input_id=@ems_input_id
if @input_value not between @min_input_value and @max_input_value
	begin
		select 'Error' ErrorCode, 'EmissionInput' Module, 
				'spa_ems_gen_input_whatif' Area, 'DB Error' Status, 
			'Value for the input is out of range.It should be between '+cast(@min_input_value as varchar)+' and '+cast(@max_input_value as varchar), '' Recommendation
		return	
	end

END


IF @flag='s' 
BEGIN
	insert #temp_clms
	select Code,t.static_data_type from ems_static_data_type t join
	ems_input_characteristics c on t.type_id=c.type_id 
	where c.ems_source_input_id=@ems_input_id

	--select Code from ems_static_data_type where ems_source_input_id=@ems_input_id
	set @tot_row=@@rowcount
	
	
	
	if @tot_row > 0
	begin
		set @i=1
		set @clm_name=''
		set @join1=''
		while @i<=@tot_row
		begin
			select @clm=clm_name from #temp_clms where tid=@i
			select @clm=clm_name,@static_data_type=static_data_type from #temp_clms where tid=@i
			
			exec( 'Alter table #temp add ['+ @clm +'] varchar(100) null')
			
			if @static_data_type is not null
					set @tbl_name='static_data_value'
				else
					set @tbl_name='ems_static_data_value'
	
			set @clm1='char'+cast(@i  as varchar)
				
				if @i=1
				begin
					
				if @static_data_type=10009
					set @join1=' left outer join '+@tbl_name+' esv'+cast(@i  as varchar) +' on esv'+cast(@i  as varchar)+'.value_id=rg.technology'
				else if @static_data_type=10023
					set @join1=' left outer join '+@tbl_name+' esv'+cast(@i  as varchar) +' on esv'+cast(@i  as varchar)+'.value_id=rg.fuel_value_id'
				else if @static_data_type=10010
					set @join1=' left outer join '+@tbl_name+' esv'+cast(@i  as varchar) +' on esv'+cast(@i  as varchar)+'.value_id=rg.classification_value_id'
				else
					set @join1=' left outer join '+@tbl_name+' esv'+cast(@i  as varchar) +' on esv'+cast(@i  as varchar)+'.value_id=esc.'+@clm1
					
					set @clm_name=' esv'+cast(@i  as varchar) +'.code'
				end
				else
				begin
					if @static_data_type=10009
					set @join1=@join1 + ' left outer join '+@tbl_name+' esv'+cast(@i  as varchar) +' on esv'+cast(@i  as varchar)+'.value_id=rg.technology'
					else if @static_data_type=10023
					set @join1=@join1 + ' left outer join '+@tbl_name+' esv'+cast(@i  as varchar) +' on esv'+cast(@i  as varchar)+'.value_id=rg.fuel_value_id'
					else if @static_data_type=10010
					set @join1=@join1 + ' left outer join '+@tbl_name+' esv'+cast(@i  as varchar) +' on esv'+cast(@i  as varchar)+'.value_id=rg.classification_value_id'
					else
					set @join1=@join1 + ' left outer join '+@tbl_name+' esv'+cast(@i  as varchar) +' on esv'+cast(@i  as varchar)+'.value_id=esc.'+@clm1
					
					set @clm_name=@clm_name +', esv'+cast(@i  as varchar) +'.code'
				end	
			set @i=@i+1
		end
		Alter table #temp add Value float null
		Alter table #temp add UOM varchar(100) NULL
		Alter table #temp add Scenario varchar(100) null
		Alter table #temp add [Value Shift] float null
		
		--if isnull(@estimate_type,'') = 'f'
		--begin
			--Alter table #temp add [Series Type] varchar(100) null
		--end
--		SELECT @clm_name 
		
		set @sql='insert #temp
		select ems_generator_id, dbo.FNADateFormat(term_start), dbo.FNADateFormat(term_end),sdv.code, '+ @clm_name +', input_value,s1.uom_name, 
		sdv3.code Scenario, value_shift [Shift Value]
		--,sdv2.code 
		from ems_gen_input_whatif esc inner join ems_source_input esi on esc.ems_input_id=esi.ems_source_input_id
		left outer join rec_generator rg on rg.generator_id=esc.generator_id
		 '+ @join1 +'
		left outer join source_uom s1 on s1.source_uom_id=esc.uom_id
		left outer join static_data_value sdv on sdv.value_id=esc.frequency
		left outer join static_data_value sdv2 on sdv2.value_id=esc.forecast_type 
		LEFT JOIN static_data_value sdv3 ON sdv3.value_id = esc.criteria_id
		
		where ems_input_id=' +cast(@ems_input_id as varchar) +' and esc.generator_id='+cast(@generator_id as varchar)+
		case when @estimate_type is not null then ' and estimate_type='''+@estimate_type+'''' else '' end +' and (
		(term_start between '''+ @term_start +''' and '''+ @term_end +'''
		or term_end between '''+ @term_start +''' and '''+ @term_end +''') or esi.constant_value=''y'')'

--		if  @forecast_type is not null
--		begin
--		set	@sql = @sql + ' and esc.forecast_type = '+cast(@forecast_type as varchar)
--		end
--		
--		set @sql = @sql + ' ORDER BY cast(term_start as datetime)'

		IF @criteria_id IS NOT NULL 
			SET @sql = @sql + ' AND criteria_id=' + CAST(@criteria_id AS VARCHAR) 
			
		EXEC spa_print @sql
		exec (@sql)
		
		select * from #temp order by cast([Term Start] as datetime)
	end
	else
	begin	
		set @sql=
		'select ems_generator_id ID,dbo.FNADateFormat(term_start) [Term Start], dbo.FNADateFormat(term_end) [Term End],sdv.code Frequency,
		input_value Value,s1.uom_name UOM, sdv3.code Scenario, value_shift [Shift Value]
		--,ISNULL(sdv2.code,''Default Inventory'') [Series Type]
		 from ems_gen_input_whatif esc inner join ems_source_input esi on esc.ems_input_id=esi.ems_source_input_id
		 left outer join source_uom s1 on s1.source_uom_id=esc.uom_id
		left outer join static_data_value sdv on sdv.value_id=esc.frequency
		left join static_data_value sdv2 on sdv2.value_id=esc.forecast_type
		LEFT JOIN static_data_value sdv3 ON sdv3.value_id = esc.criteria_id
		where ems_input_id='+cast(@ems_input_id as varchar)+'and generator_id='+cast(@generator_id as varchar)+'
		and ((term_start between '''+@term_start+''' and '''+@term_end+''' ) or esi.constant_value=''y'')'+
		 case when @estimate_type is not null then ' and estimate_type='''+@estimate_type+'''' else '' END
		 IF @criteria_id IS NOT NULL 
			SET @sql = @sql + ' AND criteria_id=' + CAST(@criteria_id AS VARCHAR) 
		--+ case when @forecast_type is not null then ' And esc.forecast_type='+cast(@forecast_type as varchar) else '' end 
		+' Order by term_start'
		
		
			
		EXEC spa_print @sql
		exec (@sql)

	end

END

ELSE IF @flag='a'
BEGIN
	
	select ems_generator_id,estimate_type,
	dbo.FNADateFormat(term_start),
	dbo.FNADateFormat(term_end),frequency, char1,char2,char3,char4,char5,char6,char7,char8,char9,char10,input_value,
	egi.uom_id,egi.generator_id,ems_input_id,input_name,egi.forecast_type,rg.technology,rg.fuel_value_id,criteria_id,value_shift	
	from ems_gen_input_whatif  egi join ems_source_input esi 
	on egi.ems_input_id=esi.ems_source_input_id
	left join rec_generator rg on egi.generator_id=rg.generator_id
	where ems_generator_id=@ems_gen_id
END
ELSE IF @flag='i'
BEGIN

	declare @i_term_start varchar(100), @i_term_end varchar(100),@i_name varchar(100)
	select @i_term_start=dbo.FNADateFormat(term_start),@i_term_end=dbo.FNADateFormat(term_end),@i_name=input_name from ems_gen_input_whatif g join ems_source_input t on g.ems_input_id=t.ems_source_input_id
	where t.constant_value='y' and t.ems_source_input_id=@ems_input_id and generator_id=@generator_id

	if @i_name is not null 
	begin
		select 'Error' ErrorCode, 'EmissionInput' Module, 
				'spa_ems_gen_input_whatif' Area, 'DB Error' Status, 
			'Constant Input: '+ @i_name +' can not insert duplicate. <br> Last entered on start term: '+@i_term_start, '' Recommendation
		return	
	end


	Insert into ems_gen_input_whatif(
		ems_input_id,
		generator_id,
		estimate_type,
		term_start,
		term_end,
		frequency,
		char1,
		char2,
		char3,
		char4,
		char5,
		char6,
		char7,
		char8,
		char9,
		char10,
		input_value,
		uom_id,
		--forecast_type
		criteria_id,
		value_shift
	)
	
	select 
		@ems_input_id,
		@generator_id,
		@estimate_type,
		@term_start,
		@term_end,
		@frequency,
		@char1,
		@char2,
		@char3,
		@char4,
		@char5,
		@char6,
		@char7,
		@char8,
		@char9,
		@char10,
		@input_value,
		@uom_id,
		--@forecast_type
		@criteria_id,
		@value_shift


	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Ems Source Inputs", 
		"spa_ems_source_model", "DB Error", 
		"Error Inserting Ems Source Model Inputs.", ''
	else
		Exec spa_ErrorHandler 0, 'Ems Source Model', 
		'spa_meter', 'Success', 
		'Ems Source Model Inputs successfully inserted.',''
		

END

ELSE IF @flag='u'
BEGIN

	update	 
		ems_gen_input_whatif
	set	
		term_start=@term_start,
		term_end=@term_end,
		frequency=@frequency,
		char1=@char1,
		char2=@char2,
		char3=@char3,
		char4=@char4,
		char5=@char5,
		char6=@char6,
		char7=@char7,
		char8=@char8,
		char9=@char9,
		char10=@char10,
		input_value=@input_value,
		uom_id=@uom_id,
		--forecast_type = @forecast_type
		criteria_id=@criteria_id,
		value_shift=@value_shift
		

	where

		ems_generator_id=@ems_gen_id


		If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Ems Source Input", 
		"spa_ems_source_model", "DB Error", 
		"Error Updating Ems Source Model Inputs.", ''
	else
		Exec spa_ErrorHandler 0, 'Ems Source Model', 
		'spa_ems_source_model', 'Success', 
		'Ems Source Model Inputs successfully Updated.',''

END
ELSE IF @flag='d'
BEGIN


	delete from ems_gen_input_whatif 
		where ems_generator_id=@ems_gen_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Ems Source Model", 
		"spa_ems_source_model", "DB Error", 
		"Error Deleting Ems Source Model Inputs.", ''
	else
		Exec spa_ErrorHandler 0, 'Ems Source Model', 
		'spa_meter', 'Success', 
		'Ems Source Model Inputs successfully Deleted.',''
END

END






