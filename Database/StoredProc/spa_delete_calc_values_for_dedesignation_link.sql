IF OBJECT_ID(N'spa_delete_calc_values_for_dedesignation_link', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_delete_calc_values_for_dedesignation_link]
 GO 






--exec spa_delete_calc_values_for_dedesignation_link 507
create proc [dbo].[spa_delete_calc_values_for_dedesignation_link] @link_id int
AS

--@link_id ==> pass the original hedge link id and NOT DEDEISGNATED LINK_ID (pass 507)
declare @st_where varchar(1000)
set @st_where='link_id = '+cast(@link_id as varchar)+' and link_type = ''link'''
exec spa_delete_ProcessTable 'calcprocess_deals',@st_where
--exec spa_delete_ProcessTable 'calcprocess_deals',
--	delete     
--	--select * from 
--	calcprocess_deals
--	WHERE     (link_id = @link_id)
--	and link_type = 'link'
	
	
	delete        
	--select * from
	calcprocess_amortization
	WHERE     (link_id = @link_id)
	and link_deal_flag = 'l'
	


	delete
	calcprocess_rep_msmt_vals
	WHERE     (link_id = @link_id)
	and link_deal_flag = 'l'
	

	set @st_where='link_id = '+cast(@link_id as varchar)+' and link_deal_flag = ''l'''
	exec spa_delete_ProcessTable 'report_measurement_values',@st_where

--	delete
--	--select * from
--	report_measurement_values
--	WHERE     (link_id = @link_id)
--	and link_deal_flag = 'l'
	
	delete       
	--select * from
	fas_link_detail_dedesignation
	WHERE     (dedesignated_link_id = @link_id)
	
	update fas_link_header set fully_dedesignated = 'n'
	where link_id = @link_id
	
	
	delete       
	--select * from 
	fas_dedesignated_locked_aoci
	WHERE     (link_id = @link_id)
	set @st_where='link_id = '+cast(@link_id as varchar)+' and link_type = ''link'''
	exec spa_delete_ProcessTable 'calcprocess_aoci_release',@st_where

--	delete     calcprocess_aoci_release
--	WHERE     (link_id = @link_id) AND (link_deal_flag = 'l')








