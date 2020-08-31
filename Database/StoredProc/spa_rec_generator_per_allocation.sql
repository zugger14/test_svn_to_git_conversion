IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_rec_generator_per_allocation]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_rec_generator_per_allocation]
GO 

create proc [dbo].[spa_rec_generator_per_allocation]
@contract_id int
as
select 
cg.contract_name Contract,
rg.Name [Generator Name]
,cast(contract_allocation * 100 as varchar) +' %' Allocation from rec_generator rg 
join contract_group cg on rg.ppa_contract_id=cg.contract_id
where ppa_contract_id=@contract_id




