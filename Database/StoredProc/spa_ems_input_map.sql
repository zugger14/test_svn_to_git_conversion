/****** Object:  StoredProcedure [dbo].[spa_ems_input_map]    Script Date: 06/17/2009 21:25:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_input_map]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ems_input_map]
/****** Object:  StoredProcedure [dbo].[spa_ems_input_map]    Script Date: 06/17/2009 21:25:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[spa_ems_input_map]	@flag as char(1),
					@source_input_id as int=null,
					@input_id VARCHAR(100)=null,
					@source_model_id int=null,
					@generator_id int=null

AS


SET NOCOUNT ON

DECLARE @errorCode Int
declare @sql varchar(5000)
If @flag = 's' 
Begin
--select * from ems_source_input
	--select source_input_id [ID],dbo.FNAEmissionHyperlink(2,12101300,input_name,source_input_id,NULL) [InputType],
	select source_input_id [ID],dbo.FNAEmissionHyperlink(2,12101300,input_name,ems_source_input_id,NULL) [Input Type],
	char_applies [Char Applies],su.uom_name UOM,sdv.code [Input/Output],eim.input_id,ems.uom_id,constant_value Constant, 
	sdv1.code as Rating
	from
	ems_input_map eim join ems_source_input ems on eim.Input_id=ems.ems_source_input_id
	left join source_uom su on su.source_uom_id=ems.uom_id
	left join static_data_value sdv on sdv.value_id=ems.input_output_id
	left join static_data_value sdv1 on sdv1.value_id = ems.rating_value_id 
	where  eim.source_model_id=@source_model_id

End
else If @flag = 'g' -- Generator Default (Input)
Begin
	select distinct input_id,input_name from ems_input_map eim join ems_source_input ems on eim.Input_id=ems.ems_source_input_id  
	where eim.source_model_id=@source_model_id
	and ems.char_applies='y'
	union all
	select ems.ems_source_input_id,input_name
	 from ems_source_input ems join level_input_map lim
	on ems.ems_source_input_id=lim.ems_source_input_id 
	join rec_generator rg on rg.ems_book_id=lim.group_level_id
	where rg.generator_id=@generator_id	


End
else If @flag = 'm' -- Input/Output detail by Source Model Wise (Input EMS)
Begin

	--select distinct ems_source_input_id [ID],input_name [InputType],
	select distinct ems_source_input_id [ID],dbo.FNAEmissionHyperlink(2,12101300,input_name,ems_source_input_id,NULL) [Input Type],
	char_applies [Char Applies],su.uom_name UOM,sdv.code [Input/Output],ems.uom_id,ems.constant_value Constant,
	input_name
	 from
	ems_source_input ems left join source_uom su on su.source_uom_id=ems.uom_id
	left join static_data_value sdv on sdv.value_id=ems.input_output_id
	join ems_input_map eim on eim.Input_id=ems.ems_source_input_id  
	where eim.source_model_id=@source_model_id
	union all
	select ems.ems_source_input_id,input_name  ,char_applies,su.uom_name UOM,sdv.code [Input/Output],ems.uom_id,
	ems.constant_value Constant ,input_name
	 from ems_source_input ems join level_input_map lim
	on ems.ems_source_input_id=lim.ems_source_input_id 
	join rec_generator rg on rg.ems_book_id=lim.group_level_id
	left join source_uom su on su.source_uom_id=ems.uom_id
	left join static_data_value sdv on sdv.value_id=ems.input_output_id
	where rg.generator_id=@generator_id	

-- 	select distinct ems_source_input_id [ID],dbo.FNAEmissionHyperlink(2,12101300 ,input_name ,ems_source_input_id,NULL ) [InputType],
-- 	char_applies [CharApplies],su.uom_name UOM,sdv.code [Input/Output],ems.uom_id from
-- 	ems_source_input ems left join source_uom su on su.source_uom_id=ems.uom_id
-- 	left join static_data_value sdv on sdv.value_id=ems.input_output_id
-- 	join ems_input_map eim on eim.Input_id=ems.ems_source_input_id  
-- 	where eim.source_model_id=@source_model_id
-- 	union all
-- 	select ems.ems_source_input_id,dbo.FNAEmissionHyperlink(2,12101300 ,input_name ,ems.ems_source_input_id ,NULL) ,char_applies,su.uom_name UOM,sdv.code [Input/Output],ems.uom_id
-- 	 from ems_source_input ems join level_input_map lim
-- 	on ems.ems_source_input_id=lim.ems_source_input_id 
-- 	join rec_generator rg on rg.ems_book_id=lim.group_level_id
-- 	left join source_uom su on su.source_uom_id=ems.uom_id
-- 	left join static_data_value sdv on sdv.value_id=ems.input_output_id
-- 	where rg.generator_id=@generator_id	
		
END
else If @flag = 'w' -- Input/Output detail by Source Model Wise (Input EMS) for what if criteria
Begin

	--select distinct ems_source_input_id [ID],input_name [InputType],
	select distinct ems_source_input_id [ID],dbo.FNAEmissionHyperlink(3,12102013,input_name,ems_source_input_id,@generator_id) [Input Type],
	char_applies [Char Applies],su.uom_name UOM,sdv.code [Input/Output],ems.uom_id,ems.constant_value Constant,
	input_name
	 from
	ems_source_input ems left join source_uom su on su.source_uom_id=ems.uom_id
	left join static_data_value sdv on sdv.value_id=ems.input_output_id
	join ems_input_map eim on eim.Input_id=ems.ems_source_input_id  
	where eim.source_model_id=@source_model_id
	union all
	select ems.ems_source_input_id,input_name  ,char_applies,su.uom_name UOM,sdv.code [Input/Output],ems.uom_id,
	ems.constant_value Constant ,input_name
	 from ems_source_input ems join level_input_map lim
	on ems.ems_source_input_id=lim.ems_source_input_id 
	join rec_generator rg on rg.ems_book_id=lim.group_level_id
	left join source_uom su on su.source_uom_id=ems.uom_id
	left join static_data_value sdv on sdv.value_id=ems.input_output_id
	where rg.generator_id=@generator_id	

-- 	select distinct ems_source_input_id [ID],dbo.FNAEmissionHyperlink(2,12101300 ,input_name ,ems_source_input_id ,NULL) [InputType],
-- 	char_applies [CharApplies],su.uom_name UOM,sdv.code [Input/Output],ems.uom_id from
-- 	ems_source_input ems left join source_uom su on su.source_uom_id=ems.uom_id
-- 	left join static_data_value sdv on sdv.value_id=ems.input_output_id
-- 	join ems_input_map eim on eim.Input_id=ems.ems_source_input_id  
-- 	where eim.source_model_id=@source_model_id
-- 	union all
-- 	select ems.ems_source_input_id,dbo.FNAEmissionHyperlink(2,12101300 ,input_name ,ems.ems_source_input_id ,NULL) ,char_applies,su.uom_name UOM,sdv.code [Input/Output],ems.uom_id
-- 	 from ems_source_input ems join level_input_map lim
-- 	on ems.ems_source_input_id=lim.ems_source_input_id 
-- 	join rec_generator rg on rg.ems_book_id=lim.group_level_id
-- 	left join source_uom su on su.source_uom_id=ems.uom_id
-- 	left join static_data_value sdv on sdv.value_id=ems.input_output_id
-- 	where rg.generator_id=@generator_id	
		
End
else If @flag = 'e' -- List all the Input in Source Model (Input)
Begin
	select ems_source_input_id [ID],input_name [Input Type],
	char_applies [Char Applies],su.uom_name UOM,sdv.code [Input/Output],constant_value Constant from
	ems_source_input ems left join source_uom su on su.source_uom_id=ems.uom_id
	left join static_data_value sdv on sdv.value_id=ems.input_output_id
	where ems_source_input_id not in (select input_id from ems_input_map
	where  source_model_id=@source_model_id)
	order by input_name
End
Else If @flag='i'
Begin
	IF EXISTS (SELECT input_output_id FROM ems_source_input WHERE ems_source_input_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@Input_id)) AND input_output_id > 1050)
	BEGIN
		EXEC spa_print 'nothnig'
--		if exists( select input_output_id from ems_input_map eim join ems_source_input esi on
--		eim.input_id=esi.ems_source_input_id
--		where source_model_id=@source_model_id and esi.input_output_id>1050)
--		begin
--			Exec spa_ErrorHandler -1, 'InputMap', 
--				'spa_ems_input_map', 'DB Error', 
--				'Output is already exists!!<br>You could have ONLY one Output in source model.', ''
--			return
--		end
	END
	

	INSERT INTO ems_input_map
	(source_model_id,Input_id)
	SELECT @source_model_id,item FROM dbo.SplitCommaSeperatedValues(@Input_id)
--	values (@source_model_id,@Input_id)


	SET @errorCode = @@ERROR
	IF @errorCode <> 0
		EXEC spa_ErrorHandler @errorCode, 'StaticDataMgmt', 
				'spa_StaticDataValue', 'DB Error', 
				'Failed to insert static data value.', ''
	ELSE
		EXEC spa_ErrorHandler 0, 'StaticDataMgmt', 
				'spa_StaticDataValue', 'Success', 
				'Static data value inserted.', ''
	END
ELSE IF @flag='d'
BEGIN

	DELETE ems_input_map WHERE source_input_id = @source_input_id

	SET @errorCode = @@ERROR
	IF @errorCode <> 0
	BEGIN
		EXEC spa_ErrorHandler @errorCode, 'StaticDataMgmt', 
				'spa_StaticDataValue', 'DB Error', 
				'Failed to delete static data value.', ''
		RETURN
	END
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 0, 'StaticDataMgmt', 
				'spa_StaticDataValue', 'Success', 
				'Static data value deleted.', ''
		RETURN
	END

END





















