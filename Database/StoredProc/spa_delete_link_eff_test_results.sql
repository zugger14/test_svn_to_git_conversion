IF OBJECT_ID(N'spa_delete_link_eff_test_results', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_delete_link_eff_test_results]
 GO 



--Deletes all eff test results for a link 
-- and associated what-if profiles
CREATE proc [dbo].[spa_delete_link_eff_test_results] @link_id VARCHAR(2000)

as 

--drop table #delete_result_ids
select eff_test_result_id 
into #delete_result_ids
	 from 	fas_eff_ass_test_results INNER JOIN
		fas_eff_hedge_rel_type_whatif on fas_eff_hedge_rel_type_whatif.eff_test_profile_id = fas_eff_ass_test_results.eff_test_profile_id
		INNER JOIN dbo.SplitCommaSeperatedValues(@link_id) i on i.item = fas_eff_hedge_rel_type_whatif.rel_id
	 where calc_level=3 and link_id=-1
	UNION
	select eff_test_result_id 
	 from 	fas_eff_ass_test_results
	 INNER JOIN dbo.SplitCommaSeperatedValues(@link_id) i on i.item = fas_eff_ass_test_results.link_id
	 where 	calc_level= 2


	delete from fas_eff_ass_test_results_profile where
	eff_test_result_id in 
	(
		select eff_test_result_id from #delete_result_ids
	)

	delete from fas_eff_ass_test_results_process_detail 
	where eff_test_result_id in 
	(
		select eff_test_result_id from #delete_result_ids
	)

	delete from fas_eff_ass_test_results_process_header
	where eff_test_result_id in 
	(
		select eff_test_result_id from #delete_result_ids
	)


	delete from fas_eff_ass_test_results
	where eff_test_result_id in 
	(
		select eff_test_result_id from #delete_result_ids
	)

	--delete from fas_eff_hedge_rel_type_whatif_detail
	--WHERE eff_test_profile_id IN (select eff_test_profile_id from fas_eff_hedge_rel_type_whatif
	--	where fas_eff_hedge_rel_type_whatif.rel_id = @link_id)


	--delete from fas_eff_hedge_rel_type_whatif
	--WHERE fas_eff_hedge_rel_type_whatif.rel_id = @link_id
	
	delete d 
	from fas_eff_hedge_rel_type_whatif_detail d
	INNER JOIN fas_eff_hedge_rel_type_whatif h ON h.eff_test_profile_id = d.eff_test_profile_id
	INNER JOIN dbo.SplitCommaSeperatedValues(@link_id) i on i.item = h.rel_id


	delete h
	from fas_eff_hedge_rel_type_whatif h
	INNER JOIN dbo.SplitCommaSeperatedValues(@link_id) i on i.item = h.rel_id







