IF OBJECT_ID(N'spa_effhedgereltypewhatifdetail', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_effhedgereltypewhatifdetail]
 GO 





CREATE proc [dbo].[spa_effhedgereltypewhatifdetail]
@flag char(1),
@flag2 char(1),
@eff_test_profile_id int=NULL, 
@eff_test_profile_detail_id int=NULL,
@hedge_or_item char(1)=NULL,
@source_curve_def_id int=NULL,
@strip_month_from datetime=NULL,
@strip_month_to datetime=NULL,
@volume_mix_percentage float=NULL,
@uom_conversion_factor float=NULL

AS

If @flag = 's' 
begin
DECLARE @sql_stmt AS Varchar(5000)

SET @sql_stmt = 'SELECT     source_price_curve_def.curve_name AS [Curve Index], dbo.FNADateFormat( fas_eff_hedge_rel_type_whatif_detail.strip_month_from) AS [Strip Month From], 
                      dbo.FNADateFormat( fas_eff_hedge_rel_type_whatif_detail.strip_month_to) AS [Strip Month To],
		      Cast(round(fas_eff_hedge_rel_type_whatif_detail.volume_mix_percentage, 2) as varchar) AS [Volume Mix], 
                      Cast(round(fas_eff_hedge_rel_type_whatif_detail.uom_conversion_factor, 2) as varchar) AS [UOM Conversion Factor], 
		      fas_eff_hedge_rel_type_whatif_detail.create_user AS [Created By], dbo.FNADateTimeFormat(source_price_curve_def.create_ts,2) AS [Create TS], 
                      fas_eff_hedge_rel_type_whatif_detail.update_user AS [Updated By], dbo.FNADateTimeFormat(source_price_curve_def.update_ts,2) AS [Update TS], 
                      fas_eff_hedge_rel_type_whatif_detail.eff_test_profile_id as [Assesment Type ID], 
		      fas_eff_hedge_rel_type_whatif_detail.eff_test_profile_detail_id as [Assesment Detail Type ID]
			FROM source_price_curve_def RIGHT OUTER JOIN
                      fas_eff_hedge_rel_type_whatif_detail ON 
                     source_price_curve_def.source_curve_def_id = fas_eff_hedge_rel_type_whatif_detail.source_curve_def_id'
		If  @eff_test_profile_id is NULL
		    SET @sql_stmt = @sql_stmt + ' WHERE eff_test_profile_id is NULL ' 
		else
			SET @sql_stmt = @sql_stmt + ' WHERE eff_test_profile_id = ' + CAST(@eff_test_profile_id  AS VARCHAR)

	IF upper(@hedge_or_item) = 'H'
		SET @sql_stmt = @sql_stmt + ' and upper(hedge_or_item) = ''H'''

	IF upper(@hedge_or_item) = 'I'
		SET @sql_stmt = @sql_stmt + ' and upper(hedge_or_item) = ''I'' ' 


	SET @sql_stmt = @sql_stmt + ' ORDER BY fas_eff_hedge_rel_type_whatif_detail.eff_test_profile_id'

	EXEC(@sql_stmt)



	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Effective Hedge Relation Whatif detail table', 
				'spa_effhedgereltypedetail', 'DB Error', 
				'Effective hedge relation detail record of Hedge Type successfully selected.', ''
				
End

Else If @flag = 'a' 
begin
	select  b.eff_test_profile_detail_id, b.eff_test_profile_id, b.hedge_or_item, 
		 b.source_curve_def_id, dbo.FNADateFormat( b.strip_month_from), dbo.FNADateFormat( b.strip_month_to), 
              	cast(round(b.volume_mix_percentage, 2) as varchar) as volume_mix_percentage, 
		cast(round(b.uom_conversion_factor, 2) as varchar) as uom_conversion_factor, 
		 b.create_user,
                 dbo.FNADateFormat(b.create_ts) , b.update_user, dbo.FNADateFormat( b.update_ts)
	from fas_eff_hedge_rel_type_whatif_detail b where b.eff_test_profile_detail_id = @eff_test_profile_detail_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Effective Hedge Relation Whatif detail table', 
				'spa_effhedgereltypedetail', 'DB Error', 
				'Failed to select effective hedge relation detail record of Item type.', ''
	Else
		Exec spa_ErrorHandler 0, 'Effective Hedge Relation detail Whatif table', 
				'spa_effhedgereltypedetail', 'Success', 
				'Effective hedge relation detail record of Item Type successfully selected.', ''
End

else if @flag = 'i'
begin
	insert into fas_eff_hedge_rel_type_whatif_detail
		(eff_test_profile_id,
		hedge_or_item,
		source_curve_def_id,
		strip_month_from,
		strip_month_to,
		volume_mix_percentage,
		uom_conversion_factor)
	values 
		(@eff_test_profile_id,
		@hedge_or_item,
		@source_curve_def_id,
		@strip_month_from,
		@strip_month_to,
		@volume_mix_percentage,
		@uom_conversion_factor)

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Effective Hedge Relation Whatif DETAIL table', 
				'spa_effhedgereltypewhatifdetail', 'DB Error', 
				'Failed to insert effective hedge detail relation record.', ''
	Else
		Exec spa_ErrorHandler 0, 'Effective Hedge Relation Whatif detail table', 
				'spa_effhedgereltypewhatifdetail', 'Success', 
				'Effective hedge relation detail record successfully Inserted.', ''
end	

Else if @flag = 'u'
begin
	update fas_eff_hedge_rel_type_whatif_detail
	set	eff_test_profile_id=@eff_test_profile_id,
		hedge_or_item=@hedge_or_item,
		source_curve_def_id=@source_curve_def_id,
		strip_month_from=@strip_month_from,
		strip_month_to=@strip_month_to,
		volume_mix_percentage=@volume_mix_percentage,
		uom_conversion_factor=@uom_conversion_factor
	where   eff_test_profile_detail_id=@eff_test_profile_detail_id
	
	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Effective Hedge Relation Whatif detail table', 
				'spa_effhedgereltypeWhatifdetail', 'DB Error', 
				'Failed to update effective hedge relation Whatif detailrecord.', ''
	Else
		Exec spa_ErrorHandler 0, 'Effective Hedge Relation detail table', 
				'spa_effhedgereltypeWhatifdetail', 'Success', 
				'Effective hedge relation Whatif detail record successfully updated.', ''
end	

Else if @flag = 'v'
begin
	update fas_eff_hedge_rel_type_whatif_detail
	set	strip_month_from=@strip_month_from,
		strip_month_to=@strip_month_to
	where   eff_test_profile_id=@eff_test_profile_id and hedge_or_item=@hedge_or_item
	
	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Effective Hedge Relation Whatif detail table', 
				'spa_effhedgereltypeWhatifdetail', 'DB Error', 
				'Failed to update effective hedge relation Whatif detailrecord.', ''
	Else
		Exec spa_ErrorHandler 0, 'Effective Hedge Relation detail table', 
				'spa_effhedgereltypeWhatifdetail', 'Success', 
				'Effective hedge relation Whatif detail record successfully updated.', ''
end

Else if @flag = 'd'
begin
	delete from fas_eff_hedge_rel_type_whatif_detail
	Where 	eff_test_profile_detail_id=@eff_test_profile_detail_id
		
	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Effective Hedge Relation whatif detail table', 
				'spa_effhedgereltypewhatifdetail', 'DB Error', 
				'Failed to delete effective hedge relation whatif detail record.', ''
	Else
		Exec spa_ErrorHandler 0, 'Effective Hedge Relation whatif detail table', 
				'spa_effhedgereltypewhatifdetail', 'Success', 
				'Effective hedge relation detail record successfully deleted.', ''

end





