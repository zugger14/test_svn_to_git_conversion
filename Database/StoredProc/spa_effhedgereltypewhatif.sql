IF OBJECT_ID(N'spa_effhedgereltypewhatif', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_effhedgereltypewhatif]
 GO 




CREATE proc [dbo].[spa_effhedgereltypewhatif]

@flag char(1),

@fas_book_id int=NULL,

@eff_test_profile_id int=NULL, 

@eff_test_name varchar(100)=NULL,

@eff_test_description varchar(500)=NULL,

@on_eff_test_approach_value_id int=NULL,

@on_assmt_curve_type_value_id int=NULL,

@on_curve_source_value_id int=NULL,

@on_number_of_curve_points int=NULL,

@force_intercept_zero char(1)=NULL,

@convert_currency_value_id int=NULL,

@convert_uom_value_id int=NULL,

@hedge_test_price_option_value_id int=NULL,

@item_test_price_option_value_id int=NULL,

@use_hedge_as_depend_var char(1)=NULL,
@rel_id int=NULL,
@rel_type varchar(1)=NULL,

@create_user varchar(50)=NULL

as 

DECLARE @sql_stmt varchar(8000)

DECLARE @copy_eff_test_profile_id int



If @flag = 's'

begin

--dbo.FNAHyperLinkText( 114,a.eff_test_profile_id, a.eff_test_profile_id)

	SET @sql_stmt = 'SELECT a.eff_test_profile_id as [Eff Test Profile ID], a.fas_book_id as [Fas Book ID], ' +

			CASE WHEN ( @rel_id IS NOT NULL) THEN 
				' dbo.FNAHyperLinkText( 10232610, a.eff_test_name, a.eff_test_profile_id) as [Eff Test Name],  ' 
		        ELSE
				' a.eff_test_name as [Eff Test Name], '			
			END 
			+ ' a.eff_test_description as [Eff Test Description], a.on_eff_test_approach_value_id as [On Eff Test Approach Value ID],  
			 a.on_assmt_curve_type_value_id as [On Assmt Curve Type Value ID], a.on_curve_source_value_id as [On Curve Source Value ID], a.on_number_of_curve_points as [On Number Of Curve Points], a.force_intercept_zero as [Force Intercept Zero],

                      a.convert_currency_value_id as [Convert Currency Value ID], a.convert_uom_value_id as [Convert Uom Value ID],
                     a.hedge_test_price_option_value_id AS [Hedge Test Price Opt. Value ID], a.item_test_price_option_value_id AS [Item Test Price Opt. Value ID], 

                      a.use_hedge_as_depend_var AS [Use Hedge As Depend Var],  a.create_user AS [Create User], dbo.FNADateTimeFormat(a.create_ts,2) as [Create TS], a.update_user AS [Update User], 

                      dbo.FNADateTimeFormat(a.update_ts,2) AS [Update TS], b.entity_name AS [Entity Name]

FROM         fas_eff_hedge_rel_type_whatif a INNER JOIN

                      portfolio_hierarchy b ON a.fas_book_id = b.entity_id'

		
If @fas_book_id IS NOT NULL
	SET @sql_stmt = @sql_stmt +' and a.fas_book_id = ' + cast(@fas_book_id AS VARCHAR)
		



	If @create_user IS NOT NULL

		SET @sql_stmt = @sql_stmt +  ' and a.Create_User ='''+@create_user +''''

	If @rel_id IS NOT NULL
		SET @sql_stmt = @sql_stmt +  ' and a.rel_id = '+ cast(@rel_id AS VARCHAR) 
	Else
		SET @sql_stmt = @sql_stmt +  ' and a.rel_id IS NULL '

	If @rel_type IS NOT NULL

		SET @sql_stmt = @sql_stmt +  ' and a.rel_type ='''+@rel_type +''''

	

	SET @sql_stmt = @sql_stmt + ' order by  a.eff_test_profile_id desc'

	
EXEC spa_print @sql_stmt
	exec(@sql_stmt)



	If @@ERROR <> 0

		Exec spa_ErrorHandler @@ERROR, 'Effective Hedge Relation Whatif table', 

				'spa_eff_hedge_rel_type_whatif', 'DB Error', 



				'Failed to select effective hedge relation record.', ''

	Else

		Exec spa_ErrorHandler 0, 'Effective Hedge Relation Whatif table', 

				'spa_eff_hedge_rel_type_whatif', 'Success', 

				'Effective hedge relation record successfully selected.', ''

End


Else If @flag = 'a' 

begin

	SELECT       a.eff_test_profile_id, a.fas_book_id, a.eff_test_name, a.eff_test_description, a.on_eff_test_approach_value_id, 

                      a.on_assmt_curve_type_value_id, a.on_curve_source_value_id, a.on_number_of_curve_points, a.force_intercept_zero,
                      a.convert_currency_value_id, a.convert_uom_value_id,a.hedge_test_price_option_value_id, a.item_test_price_option_value_id,

                      a.use_hedge_as_depend_var, a.create_user, dbo.FNADateFormat(a.create_ts) as create_ts, a.update_user, 

                      a.update_ts

	FROM         fas_eff_hedge_rel_type_whatif a 
		where a.eff_test_profile_id = @eff_test_profile_id







	If @@ERROR <> 0

		Exec spa_ErrorHandler @@ERROR, 'Effective Hedge Relation table', 

				'spa_eff_hedge_rel_type', 'DB Error', 

				'Failed to select effective hedge relation record.', ''

	Else

		Exec spa_ErrorHandler 0, 'Effective Hedge Relation table', 

				'spa_eff_hedge_rel_type', 'Success', 

				'Effective hedge relation record successfully selected.', ''

End



Else If @flag = 'c' 

begin

Begin Transaction



	INSERT 	INTO fas_eff_hedge_rel_type_whatif


	SELECT 	@fas_book_id as fas_book_id, ('Copy of ' + eff_test_name) as eff_test_name, 

		('Copy of ' + eff_test_name) as eff_test_description, 

		on_eff_test_approach_value_id, on_assmt_curve_type_value_id, 

                on_curve_source_value_id, on_number_of_curve_points, 

		force_intercept_zero,  convert_currency_value_id, 

                convert_uom_value_id, hedge_test_price_option_value_id, 

                item_test_price_option_value_id, 

		use_hedge_as_depend_var,NULL as rel_id,NULL as rel_type, NULL as create_user, NULL as create_ts, 

		NULL as update_user, NULL as update_ts

		from fas_eff_hedge_rel_type_whatif

		where eff_test_profile_id = @eff_test_profile_id


	SET @copy_eff_test_profile_id = SCOPE_IDENTITY() 



If @@ERROR <> 0

		begin

		Exec spa_ErrorHandler @@ERROR, 'Hedge Relationship Types Whatif', 

				'spa_eff_hedge_rel_type', 'DB Error', 

				'Failed to copy the selected hedging relationship type.', ''

		Rollback transaction

		end

	Else

	Begin



		INSERT INTO fas_eff_hedge_rel_type_whatif_detail

		SELECT 	@copy_eff_test_profile_id as eff_test_profile_id, 

			hedge_or_item, 	source_curve_def_id, strip_month_from, strip_month_to, 

			volume_mix_percentage, uom_conversion_factor, 

			NULL as create_user, NULL as create_ts, 

			NULL as update_user, NULL as update_ts

		FROM 	fas_eff_hedge_rel_type_whatif_detail 

		WHERE 	eff_test_profile_id = @eff_test_profile_id

		



		If @@ERROR <> 0

			begin

			Exec spa_ErrorHandler @@ERROR, 'Hedge Relationship Types Whatif', 

				'spa_eff_hedge_rel_type', 'DB Error', 

				'Failed to copy the selected hedging relationship type detail records.', ''

			Rollback Transaction

			end

		Else

		Begin



			SET @sql_stmt = ('Hedging relationship type copied. New ID: ' 

				+ cast(@copy_eff_test_profile_id AS VARCHAR) 

				+ ' in selected Book ID: ' 

				+ cast(@fas_book_id AS VARCHAR))



			Exec spa_ErrorHandler 0, 'Hedge Relationship Types Whatif', 

				'spa_eff_hedge_rel_type_whatif', 'Success',

				@sql_stmt, ''

			Commit Transaction

		End

	End

End

Else if @flag = 'i'

begin

	insert into fas_eff_hedge_rel_type_whatif

		(fas_book_id,

		eff_test_name,

		eff_test_description,

		on_eff_test_approach_value_id,

		on_assmt_curve_type_value_id,

		on_curve_source_value_id,

		on_number_of_curve_points,

		force_intercept_zero,

		convert_currency_value_id,

		convert_uom_value_id,

		hedge_test_price_option_value_id,

		item_test_price_option_value_id,

		use_hedge_as_depend_var,rel_id,rel_type)

		
	values 

		(@fas_book_id,

		@eff_test_name,

		@eff_test_description,

		@on_eff_test_approach_value_id,

		@on_assmt_curve_type_value_id,

		@on_curve_source_value_id,

		@on_number_of_curve_points,

		@force_intercept_zero,

		@convert_currency_value_id,

		@convert_uom_value_id,

		@hedge_test_price_option_value_id,

		@item_test_price_option_value_id,

		@use_hedge_as_depend_var,@rel_id,@rel_type)



	DECLARE @new_id varchar(100)

	SET @new_id = cast(scope_identity() as varchar)



	If @@ERROR <> 0

		Exec spa_ErrorHandler @@ERROR, 'Effective Hedge Relation Whatif table', 

				'spa_eff_hedge_rel_type_whatif', 'DB Error', 

				'Failed to insert effective hedge relation record.', ''

	Else

		Exec spa_ErrorHandler 0, 'Effective Hedge Relation Whatif table', 

				'spa_eff_hedge_rel_type_whatif', @new_id, 

				'Effective hedge relation record successfully Inserted.', ''

end	

Else if @flag = 'u'

begin

	update fas_eff_hedge_rel_type_whatif

	set	fas_book_id=@fas_book_id,

		eff_test_name=@eff_test_name,

		eff_test_description=@eff_test_description,

		on_eff_test_approach_value_id=@on_eff_test_approach_value_id,

		on_assmt_curve_type_value_id=@on_assmt_curve_type_value_id,

		on_curve_source_value_id=@on_curve_source_value_id,

		on_number_of_curve_points=@on_number_of_curve_points,

		force_intercept_zero=@force_intercept_zero,

		convert_currency_value_id=@convert_currency_value_id,

		convert_uom_value_id=@convert_uom_value_id,

		hedge_test_price_option_value_id=@hedge_test_price_option_value_id,

		item_test_price_option_value_id=@item_test_price_option_value_id,

		use_hedge_as_depend_var=@use_hedge_as_depend_var

		
	where   eff_test_profile_id=@eff_test_profile_id

	

	If @@ERROR <> 0

		Exec spa_ErrorHandler @@ERROR, 'Effective Hedge Relation Whatif table', 

				'spa_eff_hedge_rel_type_whatif', 'DB Error', 

				'Failed to update effective hedge relation record.', ''

	Else

		Exec spa_ErrorHandler 0, 'Effective Hedge Relation Whatif table', 

				'spa_eff_hedge_rel_type_whatif', 'Success', 

				'Effective hedge relation record successfully updated.', ''

end	



Else if @flag = 'd'

begin



	BEGIN TRANSACTION
	
	delete from fas_eff_ass_test_results_profile where
	eff_test_result_id in (select eff_test_result_id from fas_eff_ass_test_results
	where eff_test_profile_id=@eff_test_profile_id and calc_level=3 and link_id=-1)

	delete from fas_eff_ass_test_results_process_detail 
	where eff_test_result_id in (select eff_test_result_id from fas_eff_ass_test_results
	where eff_test_profile_id=@eff_test_profile_id and calc_level=3 and link_id=-1)

	delete from fas_eff_ass_test_results_process_header
	where eff_test_result_id in (select eff_test_result_id from fas_eff_ass_test_results
	where eff_test_profile_id=@eff_test_profile_id and calc_level=3 and link_id=-1)

	delete from fas_eff_ass_test_results
	where eff_test_profile_id=@eff_test_profile_id and calc_level=3 and link_id=-1
	If @@ERROR <> 0
	begin
		Rollback transaction
		Exec spa_ErrorHandler @@ERROR, 'Effective Hedge Relation Whatif table', 
				'spa_eff_hedge_rel_type_whatif', 'DB Error', 
				'Failed to delete effective assessment test results.', ''
		return
	end
	delete from fas_eff_hedge_rel_type_whatif_detail
	Where 	eff_test_profile_id = @eff_test_profile_id

	If @@ERROR = 0
	begin

		delete from fas_eff_hedge_rel_type_whatif
		Where 	eff_test_profile_id = @eff_test_profile_id

		If @@ERROR <> 0
		begin
			Rollback transaction
			Exec spa_ErrorHandler @@ERROR, 'Effective Hedge Relation Whatif table', 
					'spa_eff_hedge_rel_type_whatif', 'DB Error', 
					'Failed to delete effective hedge relation record.', ''
		end
		Else
		begin
			Commit transaction
			Exec spa_ErrorHandler 0, 'Effective Hedge Relation Whatif table', 
					'spa_eff_hedge_rel_type_whatif', 'Success', 
					'Effective hedge relation record successfully deleted.', ''	
		end
	end
	else
	begin
		Rollback transaction
		Exec spa_ErrorHandler @@ERROR, 'Effective Hedge Relation Detail Whatif table', 
					'spa_eff_hedge_rel_type_whatif', 'DB Error', 
					'Failed to delete effective hedge relation detail record.', ''
	end
end









