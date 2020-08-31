/****** Object:  StoredProcedure [dbo].[spa_ems_source_formula]    Script Date: 06/26/2009 14:40:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_source_formula]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ems_source_formula]
GO

/****** Object:  StoredProcedure [dbo].[spa_ems_source_formula]    Script Date: 06/26/2009 14:40:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--[spa_ems_source_formula] s

CREATE procedure [dbo].[spa_ems_source_formula]
@flag char(1),
@ems_source_formula_id int=null,
@ems_source_model_id int=null,
@sequence_order int=null,
@curve_id int=null,
@forecast_type int=null,
@formula_id int=null,
@formula_reduction int=null,
@after_seq int=null,
@default_inventory char(1)=null,
@ems_source_model_detail_id int=null
as

DECLARE @errorCode Int

DECLARE @update_order int
DECLARE @deleted_order int
DECLARE @loop int
DECLARE @tot_row int
DECLARE @error_no int

SET ANSI_WARNINGS OFF
if(@flag='s')
begin	
	select f.ems_source_formula_id [Emission Source Formula Id], m.ems_source_model_name [Emission Source Model],
	c.curve_des [Emission Type],
	f.sequence_order [Sequence Order], 
	s.Code [Series Type],
	case when e.formula_type='n' and e.formula is null then 'Nested Formula' else dbo.FNAFormulaFormat(e.formula, 'r') end as [Inventory Formula] , 
	--case when fe.formula_type='n' and fe.formula is null then 'Nested Formula' else dbo.FNAFormulaFormat(fe.formula,'r') end as[Reduction Formula],
	case when default_inventory='y' then 'Yes' else 'No' end as [Default Inventory],f.forecast_type forecast_type_id,f.ems_source_model_detail_id
	from ems_source_formula f left join ems_source_model m on f.ems_source_model_id=m.ems_source_model_id
	left join source_price_curve_def c on c.source_curve_def_id=f.curve_id
	left join static_data_value s on f.forecast_type=s.value_id
	left join formula_editor e on f.formula_id=e.formula_id
	left join formula_editor fe on f.formula_reduction=fe.formula_id

	where f.ems_source_model_detail_id=@ems_source_model_detail_id
	order by f.sequence_order,s.Code
end



else if(@flag='a')
begin
	select ems_source_formula_id [Emission Source Formula Id],
	ems_source_model_id [Emission Source Model],sequence_order,curve_id [Emission Type], 
	forecast_type [Forecast Type],
	esf.formula_id [Inventory], 
	formula_reduction [Reduction] ,	
	case when f.formula_type='n' and f.formula is null then 'Nested Formula' else 
	dbo.FNAFormulaFormat(f.formula,'r') end  Formula_inventory,
	case when f1.formula_type='n' and f1.formula is null then 'Nested Formula' else 
	dbo.FNAFormulaFormat(f1.formula,'r') end  Formula_reduction,
	default_inventory,
	ems_source_model_detail_id

	from ems_source_formula esf left join formula_editor f on f.formula_id=esf.formula_id
		left join formula_editor f1 on f1.formula_id=formula_reduction
	where ems_source_formula_id=@ems_source_formula_id
	
end

else if(@flag='i')
BEGIN
	/* --old logic

	if exists(select ems_source_formula_id from ems_source_formula 
			where ems_source_model_id=@ems_source_model_id and curve_id=@curve_id and isnull(default_inventory,'n')='y' and @default_inventory='y')
	BEGIN
		Exec spa_ErrorHandler 1,'Formula cannot have more than one default inventory', 
		"spa_ems_source_formula", "DB Error", 
		"Formula cannot have more than one default inventory.", 'Formula cannot have more than one default inventory'
		return
	END

	IF (@after_seq IS NULL)
		SELECT @sequence_order = ISNULL(MAX(sequence_order), 0) + 1 
		FROM ems_source_formula 
		WHERE ems_source_model_id = @ems_source_model_id
			AND curve_id = @curve_id
	ELSE
	BEGIN	
		DECLARE @update_tmp_id int
		
		SET @sequence_order = @after_seq + 1
		SET @loop = 0

		SELECT @tot_row = COUNT(*) 
		FROM ems_source_formula 
		WHERE ems_source_model_id = @ems_source_model_id AND curve_id=@curve_id 
			AND sequence_order > @after_seq 
		
		WHILE (@loop < @tot_row)
		BEGIN
			SELECT @update_tmp_id = ems_source_formula_id 
			FROM ems_source_formula 
			WHERE ems_source_model_id = @ems_source_model_id AND curve_id = @curve_id 
			AND sequence_order = (@sequence_order + @loop)	

			UPDATE ems_source_formula SET sequence_order = sequence_order + 1
			WHERE ems_source_formula_id = @update_tmp_id
			
			SET @loop = @loop + 1
		END				
	END
	

	insert into ems_source_formula (ems_source_model_id,
									sequence_order,
									curve_id, 
									forecast_type, 
									formula_id, 
									formula_reduction,
									default_inventory,
									ems_source_model_detail_id)
							values (@ems_source_model_id,
									@sequence_order,
									@curve_id, 
									@forecast_type, 
									@formula_id, 
									@formula_reduction,
									@default_inventory,
									@ems_source_model_detail_id)

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "ems_source_formula", 
		"spa_ems_source_formula", "DB Error", 
		"Error Inserting ems_source_formula.", ''
	else
		Exec spa_ErrorHandler 0, 'ems_source_formula', 
		'spa_ems_source_formula', 'Success', 
		'ems_source_formula successfully inserted.',''
	*/

	IF EXISTS(SELECT ems_source_formula_id FROM ems_source_formula 
				WHERE ems_source_model_detail_id = @ems_source_model_detail_id AND ISNULL(default_inventory, 'n') = 'y' 
				AND @default_inventory = 'y')
	BEGIN
		EXEC spa_ErrorHandler 1,'Formula cannot have more than one default inventory', 
		"spa_ems_source_formula", "DB Error", 
		"Formula cannot have more than one default inventory.", 'Formula cannot have more than one default inventory'
		RETURN
	END

	IF EXISTS(SELECT ems_source_formula_id FROM ems_source_formula 
				WHERE ems_source_model_detail_id = @ems_source_model_detail_id AND forecast_type = @forecast_type)
	BEGIN
		EXEC spa_ErrorHandler 1,'Formula cannot have duplicate forcast type', 
		"spa_ems_source_formula", "DB Error", 
		"Formula cannot have duplicate forcast type.", 'Formula cannot have duplicate forcast type'
		RETURN
	END
	
	BEGIN TRY
		BEGIN TRAN

		-- if @after_seq is null, append formula at last
		IF (@after_seq IS NULL)
		BEGIN
			SELECT @after_seq = ISNULL(MAX(sequence_order), 0)
			FROM ems_source_formula 
			WHERE ems_source_model_detail_id = @ems_source_model_detail_id
		END
		ELSE
		BEGIN	
			UPDATE ems_source_formula SET sequence_order = sequence_order + 1
			FROM ems_source_formula esf
			WHERE esf.sequence_order > @after_seq
				AND ems_source_model_detail_id = @ems_source_model_detail_id
		END
			
		INSERT INTO ems_source_formula 
								(
									ems_source_model_id,
									sequence_order,
									curve_id, 
									forecast_type, 
									formula_id, 
									formula_reduction,
									default_inventory,
									ems_source_model_detail_id
								)
							VALUES 
								(
									@ems_source_model_id,
									@after_seq + 1,
									@curve_id, 
									@forecast_type, 
									@formula_id, 
									@formula_reduction,
									@default_inventory,
									@ems_source_model_detail_id
								)

		EXEC spa_ErrorHandler 0, 'ems_source_formula', 
		'spa_ems_source_formula', 'Success', 
		'ems_source_formula successfully inserted.', ''

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF  @@TRANCOUNT > 0
			ROLLBACK TRAN

		SELECT @error_no = ERROR_NUMBER()
		EXEC spa_print '@error_no: ', @error_no

		EXEC spa_ErrorHandler @error_no, "ems_source_formula", 
		"spa_ems_source_formula", "DB Error", 
		"Error Inserting ems_source_formula.", ''
			
	END CATCH
	
	
END
ELSE IF (@flag = 'u')
BEGIN
/*
	
		 if exists(select ems_source_formula_id from ems_source_formula 
				where ems_source_model_id=@ems_source_model_id and curve_id=@curve_id and isnull(default_inventory,'n')='y' and @default_inventory='y' and ems_source_formula_id<>@ems_source_formula_id)
			BEGIN
				Exec spa_ErrorHandler 1, "ems_source_formula", 
				"spa_ems_source_formula", "DB Error", 
				"Formula cannot have more than one default inventory.", 'Formula cannot have more than one default inventory'
				return
			END


	declare @new_seq int,@update_id int
	if not exists (select sequence_order  from ems_source_formula where ems_source_model_id=@ems_source_model_id and curve_id=@curve_id and ems_source_formula_id=@ems_source_formula_id)
	begin
		select @sequence_order=isNUll(max(sequence_order),0)+1 from ems_source_formula where ems_source_model_id=@ems_source_model_id and curve_id=@curve_id
		set @after_seq=null
	end
	select @sequence_order=sequence_order from ems_source_formula where ems_source_formula_id=@ems_source_formula_id
	
	if @after_seq is null
	begin
		set @new_seq=1
		select @update_id=ems_source_formula_id from ems_source_formula where sequence_order=@new_seq 
		and ems_source_model_id=@ems_source_model_id and curve_id=@curve_id
	end
	if @after_seq is not null
	begin
		if(select max(sequence_order) from ems_source_formula where ems_source_model_id=@ems_source_model_id and curve_id=@curve_id)=@after_seq
			set @new_seq=@after_seq
		else
			set @new_seq=@after_seq+1
		select @update_id=ems_source_formula_id from ems_source_formula where sequence_order=@new_seq and ems_source_model_id=@ems_source_model_id and curve_id=@curve_id
	end

--	EXEC spa_print '@update_id: ' + CAST(@update_id AS varchar)
--	EXEC spa_print '@sequence_order: ' + CAST(@sequence_order AS varchar)
--	EXEC spa_print '@new_seq: ' + CAST(@new_seq AS varchar)

	if @update_id is not NULL
		IF @sequence_order <> (SELECT sequence_order FROM ems_source_formula WHERE ems_source_formula_id = @update_id) 
			update ems_source_formula 
			set sequence_order=@sequence_order 
			where ems_source_formula_id=@update_id



			update ems_source_formula
			set ems_source_model_id=@ems_source_model_id,
				sequence_order=@new_seq, 
				curve_id=@curve_id, 
				forecast_type=@forecast_type, 
				formula_id=@formula_id, 
				formula_reduction=@formula_reduction,
				default_inventory=@default_inventory,
				ems_source_model_detail_id=@ems_source_model_detail_id
			where ems_source_formula_id=@ems_source_formula_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "ems_source_formula", 
		"spa_ems_source_formula", "DB Error", 
		"Error Updating ems_source_formula.", ''
	else
		Exec spa_ErrorHandler 0, 'ems_source_formula', 
		'spa_ems_source_formula', 'Success', 
		'ems_source_formula successfully Updated.',''


*/

	IF EXISTS(SELECT ems_source_formula_id FROM ems_source_formula 
				WHERE ems_source_model_detail_id = @ems_source_model_detail_id AND ISNULL(default_inventory, 'n') = 'y' 
				AND @default_inventory = 'y' AND ems_source_formula_id <> @ems_source_formula_id)
	BEGIN
		EXEC spa_ErrorHandler 1,'Formula cannot have more than one default inventory', 
		"spa_ems_source_formula", "DB Error", 
		"Formula cannot have more than one default inventory.", 'Formula cannot have more than one default inventory'
		RETURN
	END

	IF EXISTS(SELECT ems_source_formula_id FROM ems_source_formula 
				WHERE ems_source_model_detail_id = @ems_source_model_detail_id AND forecast_type = @forecast_type
				AND ems_source_formula_id <> @ems_source_formula_id)
	BEGIN
		EXEC spa_ErrorHandler 1,'Formula cannot have duplicate forcast type', 
		"spa_ems_source_formula", "DB Error", 
		"Formula cannot have duplicate forcast type.", 'Formula cannot have duplicate forcast type'
		RETURN
	END

	DECLARE @direction	int -- 0: moving downward, 1: moving upward
	DECLARE @old_seq	int		
			
	SET @direction = 0

	IF (@after_seq IS NULL)
	BEGIN
		SELECT @after_seq = ISNULL(MAX(sequence_order), 0)
		FROM ems_source_formula 
		WHERE ems_source_model_detail_id = @ems_source_model_detail_id
	END

	
	SELECT @old_seq = sequence_order
	FROM ems_source_formula WHERE ems_source_formula_id = @ems_source_formula_id

	BEGIN TRY
		BEGIN TRAN

		IF (@old_seq <> @after_seq) --if sequence not updated, no need to do shifting
		BEGIN 
			
			IF (@old_seq > @after_seq)
				SET @direction = 1
					
			IF (@direction = 0) --edited item being moved downward, so need to shift other effected items upward
			BEGIN
				/*
				eg. @old_seq = 2, @after_seq = 5 i.e. item at 2nd index is to be put after 5th item (or at 6th index).
				So indexes between 3 to 5 has to be shifted upward to make room for old 2nd indexed item.
				The new index of that item will be 5
				*/
				UPDATE ems_source_formula
				SET sequence_order = sequence_order - 1
				WHERE ems_source_model_detail_id = @ems_source_model_detail_id
				AND sequence_order BETWEEN @old_seq + 1 AND @after_seq
			END
			ELSE  --edited item being moved upward, so need to shift other effected items downward
			BEGIN
				/*
				eg. @old_seq = 5, @after_seq = 1 i.e. item at 5th index is to be put after 1th item (or at2nd index).
				So indexes between 2 to 4 has to be shifted downward to make room for old 5th indexed item.
				The new index of that item will be 2
				*/
				UPDATE ems_source_formula
				SET sequence_order = sequence_order + 1
				WHERE ems_source_model_detail_id = @ems_source_model_detail_id
				AND sequence_order BETWEEN @after_seq + 1 AND @old_seq - 1 
			END
		END

		UPDATE ems_source_formula
		SET ems_source_model_id = @ems_source_model_id,
				sequence_order = CASE @direction WHEN 0 THEN @after_seq ELSE @after_seq + 1 END, 
				curve_id = @curve_id, 
				forecast_type = @forecast_type, 
				formula_id = @formula_id, 
				formula_reduction = @formula_reduction,
				default_inventory = @default_inventory,
				ems_source_model_detail_id = @ems_source_model_detail_id
		WHERE ems_source_formula_id = @ems_source_formula_id

		EXEC spa_ErrorHandler 0, 'ems_source_formula', 
		'spa_ems_source_formula', 'Success', 
		'ems_source_formula successfully Updated.',''

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF  @@TRANCOUNT > 0
			ROLLBACK TRAN
		
		SELECT @error_no = ERROR_NUMBER()
		EXEC spa_print '@error_no:', @error_no

		EXEC spa_ErrorHandler @error_no, "ems_source_formula", 
		"spa_ems_source_formula", "DB Error", 
		"Error Updating ems_source_formula.", ''
			
	END CATCH
	
END
ELSE IF(@flag='d')
BEGIN
	
/*
	select @deleted_order = sequence_order from ems_source_formula where ems_source_formula_id=@ems_source_formula_id

	delete from ems_source_formula 
		where ems_source_formula_id=@ems_source_formula_id	

	set @loop = 1

	
	select @tot_row = count(*) from ems_source_formula 
	where ems_source_model_id=@ems_source_model_id and curve_id=@curve_id and sequence_order > @deleted_order 



	while(@loop <= @tot_row)
	begin
		select  @update_order = (sequence_order-1) from ems_source_formula 
		where ems_source_model_id=@ems_source_model_id and curve_id=@curve_id and sequence_order > @deleted_order 
		and sequence_order = (@deleted_order + @loop)

		update ems_source_formula set
			sequence_order = @update_order
		where ems_source_model_id=@ems_source_model_id and curve_id=@curve_id and sequence_order > @deleted_order 
		and sequence_order = (@deleted_order + @loop)

		set @loop = @loop + 1
	end



	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "ems_source_formula", 
		"spa_ems_source_formula", "DB Error", 
		"Error Deleting ems_source_formula.", ''
	else
		Exec spa_ErrorHandler 0, 'ems_source_formula', 
		'spa_ems_source_formula', 'Success', 
		'ems_source_formula successfully Deleted.',''
*/

	BEGIN TRY
		BEGIN TRAN
		
		--read sequence of to-be-deleted item
		SELECT @after_seq = sequence_order
		FROM ems_source_formula
		WHERE ems_source_formula_id = @ems_source_formula_id

		UPDATE ems_source_formula SET sequence_order = sequence_order - 1
		FROM ems_source_formula esf
		WHERE esf.sequence_order > @after_seq
			AND ems_source_model_detail_id = @ems_source_model_detail_id

		--delete from ems_source_formula only as other related tables are deleted by a trigger
		DELETE FROM ems_source_formula 
		WHERE ems_source_formula_id = @ems_source_formula_id

		EXEC spa_ErrorHandler 0, 'ems_source_formula', 
		'spa_ems_source_formula', 'Success', 
		'ems_source_formula successfully Deleted.',''
		
		COMMIT TRAN

	END TRY
	BEGIN CATCH
		IF  @@TRANCOUNT > 0
			ROLLBACK TRAN

		SELECT @error_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @error_no, "ems_source_formula", 
		"spa_ems_source_formula", "DB Error", 
		"Error Deleting ems_source_formula.", ''
			
	END CATCH

END
-----Added by Pawan KC------
else if (@flag='c')
begin
	declare @new_sequence_order int
		
	select @new_sequence_order=(max(sequence_order)+1) 
		from ems_source_formula 
		where ems_source_model_id=@ems_source_model_id
		and forecast_type=@forecast_type
			
		
	----------			
	insert into ems_source_formula(ems_source_model_id,sequence_order,curve_id,forecast_type,formula_id,
					formula_reduction,default_inventory,ems_source_model_detail_id,create_user,create_ts,update_user,update_ts)
    select distinct(ems_source_model_id),@new_sequence_order,curve_id,forecast_type,formula_id,
					formula_reduction,default_inventory,ems_source_model_detail_id,create_user,create_ts,update_user,update_ts 
           from ems_source_formula 
			where ems_source_model_id=@ems_source_model_id 
			and forecast_type= @forecast_type
	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "ems_source_formula", 
		"spa_ems_source_formula", "DB Error", 
		"Error Copying ems_source_formula.", ''
	else
		Exec spa_ErrorHandler 0, 'ems_source_formula', 
		'spa_ems_source_formula', 'Success', 
		'ems_source_formula successfully Copied.',''
end

else if (@flag='p')
begin
Declare @selectStr Varchar(5000)
select sequence_order,sequence_order [#ID] from ems_source_formula 
	where ems_source_model_id=@ems_source_model_id 
	and curve_id=@curve_id			
	and ems_source_formula_id not in(@ems_source_formula_id)
	order by sequence_order

	Set @errorCode = @@ERROR
	If @errorCode <> 0 
		
		Exec spa_ErrorHandler @errorCode, 'ems_source_formula', 
				'spa_ems_source_formula', 'DB Error', 
				'Select of all Emission source formula Values Failed.', ''
 
	 	
end





















