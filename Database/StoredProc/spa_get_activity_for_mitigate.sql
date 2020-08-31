IF OBJECT_ID(N'[dbo].[spa_get_activity_for_mitigate]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_activity_for_mitigate]
GO 

-- EXEC spa_get_activity_for_mitigate 1

create proc [dbo].[spa_get_activity_for_mitigate] 
	@risk_control_id int
as
--declare @requirements_revision_id int


select prd.process_id, prc.perform_role, prc.approve_role, prc.fas_book_id, prc.activity_who_for_id,
	prm.requirements_id,	prm.requirements_name, prc.requirements_revision_id
from process_risk_controls prc inner join
process_risk_description prd on prd.risk_description_id = prc.risk_description_id left outer join
process_requirements_revisions prr on prr.requirements_revision_id = prc.requirements_revision_id left outer join
process_requirements_main prm on prm.requirements_id = prr.requirements_id
where prc.risk_control_id = @risk_control_id










