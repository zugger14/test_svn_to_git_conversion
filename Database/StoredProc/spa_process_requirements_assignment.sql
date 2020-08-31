IF OBJECT_ID(N'[dbo].[spa_process_requirements_assignment]', N'P') IS NOT NULL
DROP proc [dbo].[spa_process_requirements_assignment]
GO
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go



--spa_process_requirements_assignment

-- 't' for trigger, 'm' for mitigate
CREATE  proc [dbo].[spa_process_requirements_assignment]
 @flag varchar(1), -- 'a' for single retireve, 's' for select all, 'i' for insert, 'u' for update, 'd' for delete
 @flag1 char(1), --'c' for Assignment, 't' trigger, 'm' mitigate
 @requirement_assignment_id INT = null,
 @requirements_id INT = null,
 @process_id  INT = null,
 @perform_role INT = null, 
 @approve_role INT = null,
 @fas_book_id INT = null ,
 @run_date varchar(20) = null,
 @requirements_revision_id int=null,
 @activity_who_for_id int=null

-- DECLARE @flag varchar(1) -- 'a' for single retireve, 's' for select all, 'i' for insert, 'u' for update, 'd' for delete
-- DECLARE @requirement_assignment_id INT 
-- DECLARE @requirements_id INT
-- DECLARE @process_id  INT
-- DECLARE @perform_role INT
-- DECLARE @approve_role INT
-- DECLARE @fas_book_id INT
-- DECLARE @run_date varchar(20)
as

if @flag = 'i'
BEGIN

   declare @temp varchar(5000)
   declare @tmp_fas_book_id varchar(5000)
   declare @tmp_activity_who_for_id varchar(5000)

  -- EXEC spa_print @requirements_id

   select  @temp=requirements_revision_id,@tmp_fas_book_id=fas_book_id,@tmp_activity_who_for_id=activity_who_for_id
            from process_requirements_revisions 
								where (@run_date between run_effective_date and run_end_date)
								and requirements_id=@requirements_id and activity_category_id='1211';

 EXEC spa_print @temp
 
  if exists (select requirements_id from process_requirements_assignment where requirements_revision_id=@temp)
        begin
			Exec spa_ErrorHandler -1, 'process_standard_revisions', 
							'spa_process_standard_revisions', 'Success', 
							'Run Date for Requiement Revision had already inserted', ''
					return
		end



    if @temp is null
				begin
					Exec spa_ErrorHandler -1, 'process_standard_revisions', 
							'spa_process_standard_revisions', 'Success', 
							'Run Date not found in given Date Range ', ''
					return
				end

begin tran

	insert into process_requirements_assignment
	(requirements_id, process_id,perform_role, approve_role, fas_book_id, activity_who_for_id,run_date,requirements_revision_id)
	values (@requirements_id, @process_id,@perform_role, @approve_role, @tmp_fas_book_id, @tmp_activity_who_for_id,@run_date,@temp)
	
	set @requirement_assignment_id=SCOPE_IDENTITY()

	--INSERT TO PROCESS_RISK_CONTROLS
	EXEC spa_print @requirement_assignment_id
	EXEC spa_print @temp
	EXEC spa_print @requirements_id

	exec spa_create_compliance_activities 'i','c',@requirement_assignment_id,@temp,@requirements_id
        
	If @@ERROR <> 0            
	begin
		rollback tran
		Exec spa_ErrorHandler @@ERROR, 'process_requirements_assignment', 
				'spa_process_requirements_assignment', 'DB Error', 
				'Insert of process_requirements_assignment data failed.', ''
	end	
	else
	begin
		commit tran
		Exec spa_ErrorHandler 0, 'process_requirements_assignment', 
				'spa_process_requirements_assignment', 'Success', 
				'process_requirements_assignment data successfully inserted.', ''

	end
	----*********************************************
	--INSERT TO PROCESS_RISK_CONTROLS




END
Else if @flag = 's' 
begin
	select 	requirement_assignment_id AssignID, risk_control_description [Requirement Revision Description],prm.requirements_name [Requirements Name], 
 pch.process_name [Group1 (Process)], 
dbo.FNADateFormat(pra.run_date) [Run Date],
		pr.role_name [Perform Group], ar.role_name [Approve Group], 
		sub.entity_name + '/' + stra.entity_name + '/' + book.entity_name [Org], who.code [Who For]
		 
	from 	process_requirements_assignment pra left outer join
		application_security_role pr on pr.role_id = pra.perform_role left outer join
		application_security_role ar on ar.role_id = pra.approve_role left outer join
		process_control_header pch on pch.process_id = pra.process_id   left outer join
		portfolio_hierarchy book on book.entity_id = pra.fas_book_id left outer join
		portfolio_hierarchy stra on stra.entity_id = book.parent_entity_id left outer join
		portfolio_hierarchy sub on sub.entity_id = stra.parent_entity_id left outer join
		static_data_value who on who.value_id = pra.activity_who_for_id
        inner join process_requirements_revisions prr on prr.requirements_revision_id=pra.requirements_revision_id
        inner join process_requirements_main prm on prm.requirements_id=pra.requirements_id
		where pra.requirements_id=@requirements_id



end

Else if @flag = 'a' 
	SELECT  pra.requirement_assignment_id,  pra.requirements_id, pra.process_id, 
		 pra.perform_role,  pra.approve_role, pra.fas_book_id, pra.activity_who_for_id,
  dbo.FNADateFormat( pra.run_date),pch.process_name
	FROM  process_requirements_assignment pra
    join process_control_header pch on  pra.process_id=pch.process_id
	where requirement_assignment_id = @requirement_assignment_id
	
if @flag = 'u'
BEGIN

   declare @temp1 varchar(5000)

	 select  @temp1=requirements_id from process_requirements_revisions 
								where (@run_date between run_effective_date and run_end_date)
								and requirements_id=@requirements_id and activity_category_id='1211' ;

      if exists (select requirements_id from process_requirements_assignment 
					where requirements_revision_id=@temp1
					)
        begin
			Exec spa_ErrorHandler -1, 'process_standard_revisions', 
							'spa_process_standard_revisions', 'Success', 
							'Run Date for Requiement Revision had already inserted', ''
					return
		end

    if @temp1 is null
				begin
					Exec spa_ErrorHandler -1, 'process_standard_revisions', 
							'spa_process_standard_revisions', 'Success', 
							'Run Date not found in given Date Range ', ''
					return
				end

	update process_requirements_assignment 
	set	requirements_id = @requirements_id,
		process_id = @process_id,
		perform_role = @perform_role,
		approve_role = @approve_role,
		fas_book_id = @fas_book_id,
		activity_who_for_id = @activity_who_for_id,
       run_date=@run_date,
       requirements_revision_id=@temp1
	where requirement_assignment_id = @requirement_assignment_id


	----*********************************************
	--UPdate TO PROCESS_RISK_CONTROLS
	 exec spa_create_compliance_activities 'u','c',@requirement_assignment_id, @temp1,@requirements_id
	
	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'process_requirements_assignment', 
				'process_requirements_assignment', 'DB Error', 
				'Insert of process_requirements_assignment data failed.', ''
	else
		Exec spa_ErrorHandler 0, 'process_requirements_assignment', 
				'process_requirements_assignment', 'Success', 
				'Process process_requirements_assignment Revisions data successfully updated.', ''


END
if @flag = 'd'
BEGIN
  BEGIN TRAN 

	   DELETE FROM process_risk_controls_steps
		FROM process_risk_controls_steps prcs
		INNER JOIN process_risk_controls prc ON prc.risk_control_id = prcs.risk_control_id
		INNER JOIN process_requirements_assignment pra ON prc.requirements_revision_id = pra.requirements_revision_id
		WHERE pra.requirement_assignment_id = @requirement_assignment_id


		DELETE FROM process_risk_controls_dependency
		FROM process_risk_controls_dependency prcd
		INNER JOIN process_risk_controls prc ON prcd.risk_control_id = prc.risk_control_id
		INNER JOIN process_requirements_assignment pra ON prc.requirements_revision_id = pra.requirements_revision_id
		WHERE requirement_assignment_id = @requirement_assignment_id
		
	If @@ERROR <> 0
		BEGIN
				Exec spa_ErrorHandler @@ERROR, 'spa_process_requirements_assignment', 
						'spa_process_requirements_assignment', 'DB Error', 
						'Delete of process risk controls dependency data failed.', ''
				
			ROLLBACK TRAN
		END
	
	ELSE
		BEGIN
			BEGIN TRAN

				DELETE FROM process_risk_controls
				FROM process_risk_controls prc
				INNER JOIN process_requirements_assignment pra ON prc.requirements_revision_id = pra.requirements_revision_id
				WHERE requirement_assignment_id = @requirement_assignment_id
				
				If @@ERROR <> 0
				BEGIN
					Exec spa_ErrorHandler @@ERROR, 'spa_process_requirements_assignment', 
					'spa_process_requirements_assignment', 'DB Error', 
					'Delete of process risk controls data failed.', ''
				
					ROLLBACK TRAN
				END
				
				ELSE
					BEGIN
						DELETE process_requirements_assignment 
						where requirement_assignment_id = @requirement_assignment_id
	    

							If @@ERROR <> 0
								Exec spa_ErrorHandler @@ERROR, 'process_requirements_assignment', 
										'process_requirements_assignment', 'DB Error', 
										'Delete of process requirements assignment data failed.', ''
							else
								Exec spa_ErrorHandler 0, 'process_requirements_assignment', 
										'process_requirements_assignment', 'Success', 
										'process_requirements_assignment data successfully deleted.', ''
							
						END
					COMMIT TRAN
				END
			 COMMIT TRAN
END
	
			


	----*********************************************
	--DELETE FROM PROCESS_RISK_CONTROLS

--END













