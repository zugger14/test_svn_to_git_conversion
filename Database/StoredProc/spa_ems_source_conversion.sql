
IF OBJECT_ID(N'[dbo].[spa_ems_source_conversion]', N'P') IS NOT NULL
DROP PROC [dbo].[spa_ems_source_conversion]
GO
--spa_ems_source_conversion 's',4
--exec spa_ems_source_conversion 's',23,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL,NULL,NULL,1180
CREATE PROCEDURE [dbo].[spa_ems_source_conversion]
@flag char(1),
@ems_input_id int=NULL,
@conversion_id int=NULL,
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
@char_factor float=null,
@uom_id int=null,
@emission_type int=null,
@uom_id_by int=null,
@ems_conversion_type_id int=null,
@effective_date varchar(20)=null,
@source int=null,
@generator_id int=null,
@conversion_comment varchar(250)=null
AS
--for Test
-- 	declare @ems_input_id int
-- 	set @ems_input_id=12
--	drop table #temp_clms
--	drop table #temp
--
BEGIN
DECLARE @sql varchar(8000)
declare @i int,@clm varchar(100), @tot_row int,@static_data_type int,
		@clm_name varchar(1000),@tbl_name varchar(100),
		@join1 varchar(1000),@clm1 varchar(100)
create table #temp(
		[Conv ID] int	,
				
)
create table #temp_clms(
	tid int identity(1,1),
	clm_name varchar(200) COLLATE DATABASE_DEFAULT,
	static_data_type int
)
IF @flag='s' 
BEGIN
	
	insert #temp_clms
	select Code,t.static_data_type from ems_static_data_type t left join
	ems_input_characteristics c on t.type_id=c.type_id 
	where c.ems_source_input_id=@ems_input_id
	set @tot_row=@@rowcount
	

--	if @tot_row > 0
--	begin
		set @i=1
		set @clm_name=''
		set @join1=''
		while @i<=@tot_row
		begin
			select @clm=clm_name,@static_data_type=static_data_type from #temp_clms where tid=@i
			exec( 'Alter table #temp add ['+ @clm +'] varchar(100) null')
				set @clm1='char'+cast(@i  as varchar)
				if @static_data_type is not null
					set @tbl_name='static_data_value'
				else
					set @tbl_name='ems_static_data_value'
				if @i=1
				begin
					set @join1=' left outer join '+@tbl_name+' esv'+cast(@i  as varchar) +' on esv'+cast(@i  as varchar)+'.value_id=esc.'+@clm1
					set @clm_name=' esv'+cast(@i  as varchar) +'.code'
				end
				else
				begin
					set @join1=@join1 + ' left outer join '+@tbl_name+' esv'+cast(@i  as varchar) +' on esv'+cast(@i  as varchar)+'.value_id=esc.'+@clm1
					set @clm_name=@clm_name +', esv'+cast(@i  as varchar) +'.code'
				end	
			set @i=@i+1
		end
		Alter table #temp add Factor varchar(500) null
		Alter table #temp add [Conv Type] varchar(500) null		
		Alter table #temp add [Effective Date] varchar(100) null	
		Alter table #temp add Source varchar(100) null	
		Alter table #temp add Comments varchar(100) null	
		if @clm_name<>''
			set @clm_name=@clm_name +','
		set @sql='insert #temp
		select conversion_id, '+ @clm_name +' cast(char_factor as varchar)+'' '' + ISNULL(s1.uom_name,'''') + 
		case when (esc.ems_conversion_type_id IN (1182, 1183,1189)) then '''' else  '' of '' + 
		spcd.curve_name end +ISNULL(''/''+s2.uom_name,''''),sdv.code,dbo.fnadateformat(esc.effective_date),source.code,conversion_comment 
		from ems_source_conversion esc '+ @join1 +'
		left outer join source_uom s1 on s1.source_uom_id=esc.uom_id
		left outer join source_uom s2 on s2.source_uom_id=esc.uom_id_by
		left outer  join source_price_curve_def spcd on spcd.source_curve_def_id=esc.emission_type 
		left outer join static_data_value sdv on sdv.value_id=esc.ems_conversion_type_id
		left outer join static_data_value source on source.value_id=esc.source
		where 1=1'
		+ case when @ems_input_id is not null then ' And ems_source_input_id=' +cast(@ems_input_id as varchar) else '' end
		+ case when @effective_date is not null then ' And ISNULL(esc.effective_date,''9999-01-01'')>='''+@effective_date+'''' else '' end
		+ case when @source is not null then ' And esc.source>='+cast(@source as varchar)else '' end
		+ case when @uom_id is not null then ' And esc.uom_id='+cast(@uom_id as varchar)else '' end
		+ case when @uom_id_by is not null then ' And esc.uom_id_by='+cast(@uom_id_by as varchar)else '' end
		+ case when @generator_id is not null then ' And esc.generator_id='+cast(@generator_id as varchar)else ' AND esc.generator_id is null ' end

		if @ems_conversion_type_id is not null
			set @sql=@sql+ ' and esc.ems_conversion_type_id='+cast(@ems_conversion_type_id as varchar)
		EXEC spa_print @sql
		
		exec (@sql)

		select * from #temp
--	end
-- 	else
-- 	begin	
-- 		--select 'Error' ErrorCode, 'Please define Characteristic for conversion' Message 
-- 		
-- 		select 'Error' ErrorCode, 'EMS Conversion' Module, 
-- 		'spa_ems_source_conversion' Area, 'DB Error' Status, 
-- 		'Please define Characteristic for conversion.' Message, '' Recommendation
-- 
-- 	end

END


ELSE IF @flag='a'
BEGIN
	
	select conversion_id,char1,char2,char3,char4,char5,char6,char7,char8,char9,char10,char_factor,
		uom_id,	emission_type,	uom_id_by ,ems_conversion_type_id, dbo.FNADateFormat(effective_date),source,generator_id,conversion_comment
	from ems_source_conversion where conversion_id=@conversion_id
END

ELSE IF @flag='i'
BEGIN

	
	Insert into ems_source_conversion(
		ems_source_input_id,
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
		char_factor,
		uom_id,
		emission_type,
		uom_id_by,
		ems_conversion_type_id,
		effective_date,
		source,generator_id,conversion_comment
	)
	
	select 
		@ems_input_id,
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
		@char_factor,
		@uom_id,
		@emission_type,
		@uom_id_by,
		@ems_conversion_type_id,
		@effective_date,
		@source,@generator_id,@conversion_comment
		

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
		ems_source_conversion
	set	
		ems_source_input_id=@ems_input_id,
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
		char_factor=@char_factor,
		uom_id=@uom_id,
		emission_type=@emission_type,
		uom_id_by=@uom_id_by,
		ems_conversion_type_id=@ems_conversion_type_id,
		effective_date=@effective_date,
		source=@source,
		generator_id=@generator_id,
        conversion_comment=@conversion_comment

	where

		conversion_id=@conversion_id


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


	delete from ems_source_conversion 
		where conversion_id=@conversion_id

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









