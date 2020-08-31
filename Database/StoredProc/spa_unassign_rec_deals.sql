IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_unassign_rec_deals]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_unassign_rec_deals]
GO 



-- exec spa_unassign_rec_deals '53935, 53936'


CREATE PROCEDURE [dbo].[spa_unassign_rec_deals] @deal_id_unassign varchar(5000)
AS

---==================================unassign deals=====================
---------------------------------------------------------------------------

--find deals that need to unassigned
CREATE TABLE #temp1
(
source_deal_header_id  int
)

EXEC (
'insert into #temp1
select source_deal_header_id from source_deal_header where
source_deal_header_id IN (' + @deal_id_unassign + ')'
)


delete from deal_rec_assignment_audit where source_deal_header_id IN (
select source_deal_header_id from source_deal_header 
where ext_deal_id in (select cast(source_deal_header_id as varchar) from #temp1)
)

delete from deal_rec_properties where source_deal_header_id IN (
select source_deal_header_id from source_deal_header 
where ext_deal_id in (select cast(source_deal_header_id as varchar)  from #temp1)
)

delete from  source_deal_detail where source_deal_header_id IN (
select source_deal_header_id from source_deal_header 
where ext_deal_id in (select cast(source_deal_header_id as varchar)  from #temp1))

delete source_deal_header 
where ext_deal_id in (select cast(source_deal_header_id as varchar)  from #temp1)


-- delete from deal_rec_assignment_audit
-- where source_deal_header_id in (select source_deal_header_id from #temp1)


update deal_rec_properties 
set 	assignment_type_value_id = null,
	compliance_year = null, 
	state_value_id = null, 
	assigned_date = null, 
	assigned_by = null
where source_deal_header_id  in (select source_deal_header_id from #temp1)



---==================================delete sale deals=====================
---------------------------------------------------------------------------
--find deals that need to be deleted



--SELECT * FROM #temp1








