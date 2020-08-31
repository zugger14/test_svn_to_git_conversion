IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetInputCharacterstics]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAGetInputCharacterstics]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


CREATE FUNCTION [dbo].[FNAGetInputCharacterstics] (@input_id int,@term_start datetime)
--ALTER FUNCTION [dbo].[FNAGetInputCharacterstics] (@input_id int,@term_start datetime)
RETURNS VARCHAR(8000) AS  	
BEGIN

-- declare @input_id int
-- declare @term_start varchar(20)
-- 
-- set @input_id = 885431 --885432
-- set @term_start = '2008-01-01'

--set @input_id=33946
--set @input_id=33957

	DECLARE @code varchar(100)
	DECLARE @input_name varchar(100)
	DECLARE @desc varchar(8000)
	DECLARE @sequence_id int
	DECLARE @char1 varchar(50)
	DECLARE @char2 varchar(50)
	DECLARE @char3 varchar(50)
	DECLARE @char4 varchar(50)
	DECLARE @char5 varchar(50)
	DECLARE @char6 varchar(50)
	DECLARE @char7 varchar(50)
	DECLARE @char8 varchar(50)
	DECLARE @char9 varchar(50)
	DECLARE @char10 varchar(50)
	DECLARE @ems_source_input_id int
	
	
--	select @char1=char1,@char2=char2,@char3=char3,@char4=char4,@char5=char5,@char6=char6,@char7=char7,@char8=char8,@char9=char9, @char10=char10
--	from ems_calc_detail_value where input_id = @input_id 
	--and term_start = @term_start

	select @char1=esdt1.code,
		   @char2=esdt2.code,
		   @char3=esdt3.code,
		   @char4=esdt4.code,
           @char5=esdt5.code,
           @char6=esdt6.code,
           @char7=esdt7.code,
           @char8=esdt8.code,
           @char9=esdt9.code, 
           @char10=esdt10.code
	from ems_gen_input 
		 left join ems_static_data_value esdt1 on esdt1.value_id=char1
		 left join ems_static_data_value esdt2 on esdt2.value_id=char2
		 left join ems_static_data_value esdt3 on esdt3.value_id=char3
		 left join ems_static_data_value esdt4 on esdt4.value_id=char4
		 left join ems_static_data_value esdt5 on esdt5.value_id=char5
		 left join ems_static_data_value esdt6 on esdt6.value_id=char6
		 left join ems_static_data_value esdt7 on esdt7.value_id=char7
		 left join ems_static_data_value esdt8 on esdt8.value_id=char8
		 left join ems_static_data_value esdt9 on esdt9.value_id=char9
		 left join ems_static_data_value esdt10 on esdt10.value_id=char10
		where ems_generator_id = @input_id 	
	
	set @code = NULL
	SET @input_name = null



	DECLARE a_cursor CURSOR FOR
	--eic.sequence_id, eic.type_char_id , 
	select distinct eic.sequence_id, esdt.code, esi.input_name,esi.ems_source_input_id
	from
	ems_gen_input egi left join  ems_calc_detail_value ecdv
	on ecdv.input_id = egi.ems_generator_id  left join
	ems_input_characteristics eic on eic.ems_source_input_id = egi.ems_input_id left join 
	ems_static_data_type esdt on esdt.type_id = eic.type_id left join
	ems_source_input esi on esi.ems_source_input_id = egi.ems_input_id 
	where 
	--ecdv.input_id = @input_id 
	egi.ems_generator_id = @input_id 
	and egi.term_start = @term_start
	order by eic.sequence_id
	
	
	OPEN a_cursor
	
	FETCH NEXT FROM a_cursor
	INTO @sequence_id, @code, @input_name,@ems_source_input_id
	
	WHILE @@FETCH_STATUS = 0   -- book
	BEGIN 
	
		--Select @sequence_id, @code, @ems_source_input_id
		if @sequence_id is null
		begin
			--set @desc =  dbo.FNAHyperLinkText(225,isnull(@input_name, 'Uknown Input'),@ems_source_input_id) + '(No characteristics'
			set @desc =  dbo.FNAEmissionHyperlink(2,12101300,isnull(@input_name, 'Uknown Input'),@ems_source_input_id,NULL) + '(No characteristics'	
			break
		end
		if @sequence_id = 1
			--set @desc =  dbo.FNAHyperLinkText(225,isnull(@input_name, 'Uknown Input'),@ems_source_input_id) + '('
			set @desc =  dbo.FNAEmissionHyperlink(2,12101300,isnull(@input_name, 'Uknown Input'),@ems_source_input_id,NULL) + '('
		else
			set @desc = @desc + ', '
			

		if @sequence_id = 1
			set @desc = @desc + @code + '=' + @char1
		if @sequence_id = 2
			set @desc = @desc + @code + '=' + @char2
		if @sequence_id = 3
			set @desc = @desc + @code + '=' + @char3
		if @sequence_id = 4
			set @desc = @desc + @code + '=' + @char4
		if @sequence_id = 5
			set @desc = @desc + @code + '=' + @char5
		if @sequence_id = 6
			set @desc = @desc + @code + '=' + @char6
		if @sequence_id = 7
			set @desc = @desc + @code + '=' + @char7
		if @sequence_id = 8
			set @desc = @desc + @code + '=' + @char8
		if @sequence_id = 9
			set @desc = @desc + @code + '=' + @char9
		if @sequence_id = 10
			set @desc = @desc + @code + '=' + @char10
		

		FETCH NEXT FROM a_cursor
		INTO @sequence_id, @code, @input_name,@ems_source_input_id
	
	END -- end book
	CLOSE a_cursor
	DEALLOCATE  a_cursor
	
	set @desc = @desc + ')'

	RETURN @desc

END




















