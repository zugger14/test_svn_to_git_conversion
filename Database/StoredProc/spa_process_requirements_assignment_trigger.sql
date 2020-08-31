IF OBJECT_ID(N'[dbo].[spa_process_requirements_assignment_trigger]', N'P') IS NOT NULL
DROP procedure [dbo].[spa_process_requirements_assignment_trigger]
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go





--exec spa_process_requirements_assignment_trigger 'i', NULL, 22, 144, 6, 6, 264, '2008-12-05', 'm', 93, 5377,1221
-- exec spa_process_requirements_assignment_trigger 'i', NULL, NULL, NULL, 6, 6, 194, '2007-02-09', 't', 26
-- spa_process_requirements_assignment_trigger 's',null,null,null,null,null,null,null,'t',26
CREATE  procedure [dbo].[spa_process_requirements_assignment_trigger]
@flag char(1),
@requirement_assignment_id int=NULL,
@requirements_revision_id int=NULL,
@process_id int=NULL,
@perform_role int=NULL,
@approve_role VARCHAR(50)=NULL,
@fas_book_id int=NULL,
@run_date varchar(20)=NULL,
@tri_type char(1)=NULL,
@requirements_id int=null,
@activity_who_for_id int=null,
@perform_activity int=null

AS

SET NOCOUNT ON

DECLARE @sql  VARCHAR(5000)

IF @flag='s'
	BEGIN
	
			SELECT 	pra.requirement_assignment_id AssignID, pra.requirements_revision_id [RevisionID], pch.process_number [Group1 (Process)], 
				pr.role_name [Perform Role], ar.role_name [Approve Role], 
				sub.entity_name + '/' + stra.entity_name + '/' + book.entity_name [Org],
				who.code [Who For],
				dbo.FNADateFormat(pra.run_date) RunDate
			FROM 	process_requirements_assignment_trigger pra 
			LEFT OUTER JOIN application_security_role pr ON pr.role_id = pra.perform_role 
			LEFT OUTER JOIN	application_security_role ar ON ar.role_id = pra.approve_role 
			LEFT OUTER JOIN process_control_header pch ON pch.process_id = pra.process_id 
			LEFT OUTER JOIN	portfolio_hierarchy book ON book.entity_id = pra.fas_book_id 
			LEFT OUTER JOIN	portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id 
			LEFT OUTER JOIN	portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id 
					   JOIN process_requirements_revisions prr ON prr.requirements_revision_id=pra.requirements_revision_id
			LEFT OUTER JOIN static_data_value who ON who.value_id = pra.activity_who_for_id
			WHERE prr.requirements_id=@requirements_id 
			AND type=@tri_type

	END

if @flag='a'
	begin
		Select  requirement_assignment_id, 
			requirements_revision_id, 
			process_id,
			perform_role,
			approve_role,
			fas_book_id,
			run_date,
			type,
			activity_who_for_id
		From process_requirements_assignment_trigger
		where requirement_assignment_id=@requirement_assignment_id
	end

ELSE IF @flag='i'
	BEGIN

			DECLARE @tmp_requirement_assignment_id INT
				
			SELECT @requirements_revision_id=requirements_revision_id 
			FROM process_requirements_revisions prr 
 			JOIN (SELECT requirements_id,max(run_effective_date) run_date 
				  FROM process_requirements_revisions
				  WHERE run_effective_date<=@run_date and requirements_id=@requirements_id
				  GROUP BY requirements_id ) p ON p.requirements_id=prr.requirements_id
											   AND p.run_date=prr.run_effective_date

			EXEC spa_print '****'
			EXEC spa_print @requirements_revision_id
			EXEC spa_print @requirements_id
			EXEC spa_print '****'
			


				INSERT INTO process_requirements_assignment_trigger(
						requirements_revision_id,
						requirements_id, 
						process_id,
						perform_role,
						approve_role,
						fas_book_id,
						run_date,
						type,
						activity_who_for_id
					)
				VALUES(
						@requirements_revision_id,
						@requirements_id,
						@process_id,
						@perform_role,
						@approve_role,
						@fas_book_id,
						@run_date,
						@tri_type,
						@activity_who_for_id
					)
					
				

				SET @tmp_requirement_assignment_id=SCOPE_IDENTITY()
			
				
				
					
				SET	@sql = 	'exec spa_create_compliance_activities i'+ ',' +''''+@tri_type+''''+ ',' 
					+CAST(@tmp_requirement_assignment_id AS VARCHAR) +',' 
					+CAST(@requirements_revision_id AS VARCHAR) + ',' 
					+ CAST(@requirements_id AS VARCHAR) +','
					+ cast(@process_id AS VARCHAR) +','
					+cast(@perform_role AS VARCHAR)+','''+
					cast(ISNULL(@approve_role, '') AS VARCHAR) +''','+
--					cast(@approve_role AS VARCHAR) +''','+
					cast(@fas_book_id AS VARCHAR) +',' +
					''''+@run_date+''''+ ',' +
					cast(@activity_who_for_id AS VARCHAR)+','+
					cast(@perform_activity AS VARCHAR)
				
				exec spa_print @sql
				EXEC(@sql)
				
			IF @@ERROR <> 0
					EXEC spa_ErrorHandler @@ERROR, "process_requirements_assignment_trigger", 
							"spa_process_requirements_assignment_trigger", "DB Error", 
							"Insert of process requirements assignment trigger Failed.", ''
			ELSE
					EXEC spa_ErrorHandler 0, 'process_requirements_assignment_trigger', 
							'spa_process_requirements_assignment_trigger', 'Success', 
							'process requirements assignment trigger successfully Inserted', ''
END

Else if @flag='u'
	begin
		Update process_requirements_assignment_trigger
		set 	requirements_revision_id=@requirements_revision_id,
			process_id=@process_id,
			perform_role=@perform_role,
			approve_role=@approve_role,
			fas_book_id=@fas_book_id,
			run_date=@run_date,
			activity_who_for_id=@activity_who_for_id
			
		where 
			requirement_assignment_id=@requirement_assignment_id
		
			
		exec spa_create_compliance_activities 'u',@tri_type,null,@requirements_revision_id,null,@process_id,@perform_role,
			@approve_role,
			@fas_book_id,
			@run_date, @activity_who_for_id

		If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "process_requirements_assignment_trigger", 
					"spa_process_requirements_assignment_trigger", "DB Error", 
					"Update of process requirements assignment trigger failed.", ''
		else
			Exec spa_ErrorHandler 0, 'process_requirements_assignment_trigger', 
					'spa_process_requirements_assignment_trigger', 'Success', 
					'process requirements assignment trigger successfully updated.', ''
	end

Else if @flag='d'
	begin
		delete process_requirements_assignment_trigger
		where 
			requirement_assignment_id=@requirement_assignment_id

		If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "process_requirements_assignment_trigger", 
					"spa_process_requirements_assignment_trigger", "DB Error", 
					"Update of process requirements assignment trigger failed.", ''
		else
			Exec spa_ErrorHandler 0, 'process_requirements_assignment_trigger', 
					'spa_process_requirements_assignment_trigger', 'Success', 
					'process requirements assignment trigger successfully updated.', ''
	end












