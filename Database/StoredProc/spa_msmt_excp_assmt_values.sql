IF OBJECT_ID(N'spa_msmt_excp_assmt_values', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_msmt_excp_assmt_values]
GO 

--select charindex('/', '571/86', 1)
--declare @s varchar(20)
--set @s = '571/86'
----set @s = '571/86'
--SELECT substring(@s, 1, charindex('/', @s, 1) -1) 
--SELECT charindex('/', @s, 1)
----select 1 + len(@s) - charindex('/', @s, 1)
----1 + len(@s) - charindex('/', @s, 1))


--exec spa_msmt_excp_assmt_values '661BEA59_597C_4812_898B_A6DAC78F4A0B'


--drop proc spa_msmt_excp_assmt_values

--select * from msmt_excp_assmt_values where process_id = '661BEA59_597C_4812_898B_A6DAC78F4A0B'
CREATE PROCEDURE [dbo].[spa_msmt_excp_assmt_values] 
	@process_id VARCHAR(50)
AS


SELECT  dbo.FNADateFormat(msmt_excp_assmt_values.as_of_date) AsOfDate, 
	CASE when (msmt_excp_assmt_values.calc_type = 'd') then 'De-Designation' else 'Designation' end as Type, 
	sub.entity_name AS Subsidiary, 
	stra.entity_name AS Strategy, 
    book.entity_name AS Book, 
	case when (charindex('/', msmt_excp_assmt_values.use_eff_test_profile_id, 1) = 0) then
	dbo.FNAHyperLinkText(10232000, (msmt_excp_assmt_values.use_eff_test_profile_id + '. ' + fas_eff_hedge_rel_type.eff_test_name),
				substring(msmt_excp_assmt_values.use_eff_test_profile_id, 
					charindex('/', msmt_excp_assmt_values.use_eff_test_profile_id, 1) + 1, 
					1 + len(msmt_excp_assmt_values.use_eff_test_profile_id) - 
					charindex('/', msmt_excp_assmt_values.use_eff_test_profile_id, 1)) 
				)

	else

	dbo.FNAHyperLinkText(10233710, (msmt_excp_assmt_values.use_eff_test_profile_id + '. ' + fas_eff_hedge_rel_type.eff_test_name),
				substring(msmt_excp_assmt_values.use_eff_test_profile_id, 1,
					charindex('/', msmt_excp_assmt_values.use_eff_test_profile_id, 1) - 1))

	end as RelType, 

    sv.code AS TestApproach, 
	msmt_excp_assmt_values.missing_assmt_value AS MissingAssmtValue1, 
        msmt_excp_assmt_values.missing_add_assmt_value AS MissingAssmtValue2, 
        msmt_excp_assmt_values.missing_add_assmt_value2 AS MissingAssmtValue3, 
	msmt_excp_assmt_values.create_user AS CreatedUser, 
	dbo.FNADateFormat(msmt_excp_assmt_values.create_ts) AS CreatedTS
FROM    msmt_excp_assmt_values INNER JOIN
        portfolio_hierarchy sub ON msmt_excp_assmt_values.fas_subsidiary_id = sub.entity_id INNER JOIN
	portfolio_hierarchy stra ON msmt_excp_assmt_values.fas_strategy_id = stra.entity_id INNER JOIN
        portfolio_hierarchy book ON msmt_excp_assmt_values.fas_book_id = book.entity_id LEFT OUTER JOIN
	fas_eff_hedge_rel_type ON 
		cast(substring(msmt_excp_assmt_values.use_eff_test_profile_id, 
				charindex('/', msmt_excp_assmt_values.use_eff_test_profile_id, 1) + 1, 
				1 + len(msmt_excp_assmt_values.use_eff_test_profile_id) - 
				charindex('/', msmt_excp_assmt_values.use_eff_test_profile_id, 1)) as int) = fas_eff_hedge_rel_type.eff_test_profile_id LEFT OUTER JOIN
	static_data_value sv ON sv.value_id = msmt_excp_assmt_values.on_eff_test_approach_value_id
WHERE   process_id = @process_id
ORDER By sub.entity_name, stra.entity_name, book.entity_name, msmt_excp_assmt_values.use_eff_test_profile_id    --, fas_eff_hedge_rel_type.eff_test_name










