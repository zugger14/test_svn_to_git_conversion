
IF OBJECT_ID(N'spa_fas_eff_ass_test_results_profile', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_fas_eff_ass_test_results_profile]
 GO 




--exec spa_fas_eff_ass_test_results_profile 'i', 691, 3, -1, 155, 375, '1/31/2003'
--exec spa_fas_eff_ass_test_results_profile 's', 691

--exec spa_fas_eff_ass_test_results_profile 'i', 147, 1, -1, 21, 375, '1/31/2003'
--exec spa_fas_eff_ass_test_results_profile 's', 147

create PROCEDURE [dbo].[spa_fas_eff_ass_test_results_profile]  @flag varchar(1),
						@eff_test_result_id int,
						@calc_level int = null,
						@link_id int = null,
						@eff_test_profile_id int = null,
						@assessmentPriceType Int = null, 
						@runDate Datetime = null
AS


If @flag = 's' 
BEGIN

	Select eff_test_result_id AS [Result ID], CASE WHEN (hedge_or_item = 'h') then  'Hedge' else 'Item' end As [Hedge/Item], 
			spcd.curve_name [Curve Index], dbo.FNADateFormat(month_from) [Contract From], 
			dbo.FNADateFormat(month_to) [Contract To], 
			cast(round(volume_mix_percentage, 2) as varchar) AS [Mix %], 
			cast(round(uom_conversion_factor, 2) as varchar)  [Conv Factor]
	from fas_eff_ass_test_results_profile inner join
	source_price_curve_def spcd on spcd.source_curve_def_id = fas_eff_ass_test_results_profile.source_curve_def_id
	where eff_test_result_id = @eff_test_result_id
	order by hedge_or_item

END
Else If @flag = 'i' 
BEGIN

create table #temp_h
(
eff_test_profile_detail_id int,
eff_test_profile_id int,
hedge_or_item varchar(1) COLLATE DATABASE_DEFAULT,
book_deal_type_map_id int,
source_deal_type_id int,
deal_sub_type_id int,
fixed_float_flag varchar(1) COLLATE DATABASE_DEFAULT,
deal_sequence_number  int, 
source_curve_def_id int,
month_from datetime,
month_to datetime,  
strip_year_overlap int,
roll_forward_year int,
volume_mix_percentage float,
uom_conversion_factor float,
deal_xfer_source_book_map_id int,
source_currency_id int,
currency_name varchar(250) COLLATE DATABASE_DEFAULT,
source_uom_id int,
uom_name varchar(250) COLLATE DATABASE_DEFAULT,
curve_name varchar(250) COLLATE DATABASE_DEFAULT,
conversion_factor float
) ON [PRIMARY]

create table #temp_i
(
eff_test_profile_detail_id int,
eff_test_profile_id int,
hedge_or_item varchar(1) COLLATE DATABASE_DEFAULT,
book_deal_type_map_id int,
source_deal_type_id int,
deal_sub_type_id int,
fixed_float_flag varchar(1) COLLATE DATABASE_DEFAULT,
deal_sequence_number  int, 
source_curve_def_id int,
month_from datetime,
month_to datetime,  
strip_year_overlap int,
roll_forward_year int,
volume_mix_percentage float,
uom_conversion_factor float,
deal_xfer_source_book_map_id int,
source_currency_id int,
currency_name varchar(250) COLLATE DATABASE_DEFAULT,
source_uom_id int,
uom_name varchar(250) COLLATE DATABASE_DEFAULT,
curve_name varchar(250) COLLATE DATABASE_DEFAULT,
conversion_factor float
) ON [PRIMARY]

	INSERT 	#temp_h
	EXEC 	spa_get_assmt_rel_type_detail @calc_level, @link_id, @eff_test_profile_id, 'h', 
		@assessmentPriceType, @runDate
	
	INSERT 	#temp_i
	EXEC 	spa_get_assmt_rel_type_detail @calc_level, @link_id, @eff_test_profile_id, 'i', 
		@assessmentPriceType, @runDate
	
	
	INSERT INTO  fas_eff_ass_test_results_profile
	select 	@eff_test_result_id eff_test_result_id, 'h' as hedge_or_item, 
		source_curve_def_id, month_from, month_to, volume_mix_percentage, uom_conversion_factor,
		null, null
	from #temp_h
	UNION
	select 	@eff_test_result_id eff_test_result_id, 'i' as hedge_or_item, 
		source_curve_def_id, month_from, month_to, volume_mix_percentage, uom_conversion_factor,
		null,  null
	from #temp_i

END










