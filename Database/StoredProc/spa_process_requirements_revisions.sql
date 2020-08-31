IF OBJECT_ID(N'[dbo].[spa_process_requirements_revisions]', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_process_requirements_revisions]
go
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go




--exec spa_process_requirements_revisions 'r',NULL


--spa_process_requirements_revisions 's'
CREATE  PROCEDURE [dbo].[spa_process_requirements_revisions]
	@flag varchar(1)=NULL,
	@requirements_id int = NULL,
	@standard_id int = NULL,
	@requirements_revision_id int = NULL,
	@standard_revision_id int = NULL,
	@run_date varchar(20) = NULL,
	@requirement_no varchar(250) = NULL,
	@risk_control_description varchar(150) = NULL,
	@requirements_url varchar(250) = NULL,
	@perform_role int = NULL,
	@approve_role int = NULL,
	@run_frequency int = NULL,
	@control_type int = NULL,
	@threshold_days int = NULL,
	@requires_approval varchar(1) = NULL,
	@requires_proof varchar(1) = NULL,
	@control_objective int = NULL,
	@internal_function_id int = NULL,
	@activity_category_id int = NULL,
	@activity_who_for_id int = NULL,
	@run_end_date varchar(20) = NULL,
	@where_id int = NULL,
	@activity_area_id int = NULL,
	@activity_sub_area_id int = NULL,
	@activity_action_id int = NULL,
	@monetary_value float = NULL,
	@monetary_value_frequency_id int = NULL,
	@monetary_value_changes varchar(1) = NULL,
	@requires_approval_for_late varchar(1) = NULL,
	@mitigation_plan_required varchar(1) = NULL,
	@requirements_name varchar(255)=null,
	@run_effective_date varchar(20)=null,
    @temp_requirements_id  varchar(500)=null,
    @perform_activity int = NULL,
    @fas_book_id int = NULL
    

AS

declare @sql_stmt varchar(5000)

if @flag = 'r' -- for requirement main table
BEGIN
	set @sql_stmt=' select distinct prm.requirements_id ID, prm.requirements_name RequirementName from process_requirements_main prm 
	where 1=1 '
	if @standard_id is not null
		set @sql_stmt=@sql_stmt + ' and prm.standard_id= '+ cast(@standard_id as varchar)
	exec(@sql_stmt)
END

if @flag = 's' 
BEGIN
set @sql_stmt='
SELECT requirements_revision_id as [Requirements Revision Id],prr.risk_control_description [RequirementRevisionDescription],prm.requirements_name [Requirement Name], risk_control_description as Description, sdv6.code as ActivityCategory,
	sdv3.code as Area, sdv4.code as SubArea, sdv5.code as Action,
 sdv7.code [Frequency],
      prr.threshold_days [Threshold Days],
	dbo.FNADateFormat(prr.run_date) RunDate,
    dbo.FNADateFormat(prr.run_effective_date)  RunEffectiveDate,
   dbo.FNADateFormat(prr.run_end_date)  RunEndDate,
   prr.run_frequency [Frequency ID],
   prr.fas_book_id [Book ID],
   ph.entity_name [Book Name],
	prr.activity_who_for_id [ Who for ID], 
    sdv8.code [Who],prr.requirements_id [Requirements ID]	
	FROM process_requirements_revisions prr 
	left outer join application_security_role asr on asr.role_id=prr.perform_role 
	left outer join static_data_value sdv3 on sdv3.value_id = prr.activity_area_id
	left outer join static_data_value sdv4 on sdv4.value_id = prr.activity_sub_area_id
	left outer join static_data_value sdv5 on sdv5.value_id = prr.activity_action_id
	left outer join static_data_value sdv6 on sdv6.value_id = prr.activity_category_id
    INNER JOIN
          portfolio_hierarchy ph ON ph.entity_id= prr.fas_book_id 
   inner join 
             process_requirements_main prm on prm.requirements_id=prr.requirements_id
   INNER JOIN
             static_data_value sdv7 ON prr.run_frequency = sdv7.value_id
   INNER JOIN
             static_data_value sdv8 ON prr.activity_who_for_id = sdv8.value_id
  

	'
	if @run_date is not null 
     begin
		set @sql_stmt=	@sql_stmt + '
	       join (select standard_revision_id,max(run_date) run_date from process_requirements_revisions
		where '''+ @run_date +'''  between run_effective_date and run_end_date
		group by standard_revision_id ) p on p.standard_revision_id=prr.standard_revision_id '
     end
    
	set @sql_stmt = @sql_stmt + ' where 1=1 ' 
  
  --if @run_date is  null 
    -- set @run_date=	'' 
	if @requirements_id is not null
		set @sql_stmt = @sql_stmt + ' and prr.requirements_id = ' + cast(@requirements_id as varchar)
    
    if @run_date is not null
     begin
		set @sql_stmt = @sql_stmt + ' and '''+ @run_date +'''between run_effective_date and run_end_date'
     end 
   else
     begin 
         set @run_date=	'' 
		  set @sql_stmt = @sql_stmt + ' and run_effective_date>='''+ @run_date +''''
    end
  EXEC spa_print @sql_stmt
	
	if @activity_who_for_id is not null
		set @sql_stmt = @sql_stmt + '  and prr.activity_who_for_id = ' + cast(@activity_who_for_id as varchar)
	
	if @fas_book_id is not null
		set @sql_stmt = @sql_stmt + '  and prr.fas_book_id = ' + cast(@fas_book_id as varchar)


	if @standard_id is not null
		set @sql_stmt = @sql_stmt + ' and prr.standard_revision_id = ' + cast(@standard_id as varchar)

	if @activity_category_id is not null
		set @sql_stmt = @sql_stmt + ' and prr.activity_category_id = ' + cast(@activity_category_id as varchar)
	if @risk_control_description is not null 
		set @sql_stmt = @sql_stmt + ' and prr.risk_control_description like ''' + @risk_control_description + '%'''

	set @sql_stmt=	@sql_stmt + ' ORDER BY prr.requirements_id,prr.run_date'
	exec spa_print @sql_stmt
	exec(@sql_stmt)
END

if @flag = 'a' 
BEGIN
	set @sql_stmt = 'SELECT prr.requirements_revision_id,prr.requirements_id, psr.standard_id ,
prr.standard_revision_id, prr.requirement_no, prr.risk_control_description, prr.requirements_url, prr.perform_role,
	prr.approve_role, prr.run_frequency, prr.control_type, prr.threshold_days, prr.requires_approval, prr.requires_proof, prr.control_objective, prr.internal_function_id, 
	dbo.FNADateFormat(prr.run_date) as run_date, prr.activity_category_id, prr.activity_who_for_id, 
   dbo.FNADateFormat(prr.run_end_date) as run_end_date, 
	prr.where_id, prr.activity_area_id, prr.activity_sub_area_id, prr.activity_action_id, prr.monetary_value,
   prr.monetary_value_frequency_id, prr.monetary_value_changes,
	prr.requires_approval_for_late, prr.mitigation_plan_required,prm.requirements_name,
  dbo.FNADateFormat(prr.run_effective_date) run_effective_date,
  prr.perform_activity,
	prr2.risk_control_description,
    prr2.threshold_days,
    prr2.run_frequency,
	dbo.FNADateFormat(prr2.run_date),
    dbo.FNADateFormat(prr2.run_effective_date),
    dbo.FNADateFormat(prr2.run_end_date),
   prr.fas_book_id,
   ph.entity_name
    FROM process_requirements_revisions prr
	join process_requirements_main prm on prm.requirements_id = prr.requirements_id
    join process_standard_revisions psr on psr.standard_revision_id=prr.standard_revision_id
   left join portfolio_hierarchy ph on prr.fas_book_id=ph.entity_id	
   left join process_requirements_revisions prr2 on prr2.requirements_revision_id=prr.perform_activity
	 where 1=1'

 	if @requirements_revision_id is not null
		set @sql_stmt = @sql_stmt + 'and prr.requirements_revision_id = ' + cast(@requirements_revision_id as varchar)

	set @sql_stmt = @sql_stmt + 'ORDER BY prr.requirements_revision_id'
	exec spa_print @sql_stmt
	exec(@sql_stmt)
END

if @flag = 'i' or @flag='c'
BEGIN
	 if @flag='c'
	  begin
           BEGIN TRAN
           declare @tmp_requirements_revision_id int
			if @activity_category_id=1211
			BEGIN
				if exists (select requirements_id 
								from process_requirements_revisions 
								where (@run_effective_date between run_effective_date and run_end_date 
									or @run_end_date between run_effective_date and run_end_date)
								and requirements_id=@requirements_id)
				begin
					Exec spa_ErrorHandler -1, 'process_standard_revisions', 
							'spa_process_standard_revisions', 'Success', 
							'Run Date is Duplicate found ', ''
					return
				end
			END

			INSERT into process_requirements_revisions
			(requirements_id, standard_revision_id, requirement_no, risk_control_description, requirements_url, perform_role, approve_role, 
			run_frequency, control_type,
			threshold_days, requires_approval, requires_proof, control_objective, internal_function_id, run_date,
			activity_category_id, activity_who_for_id, run_end_date, where_id, activity_area_id, activity_sub_area_id,
			activity_action_id, monetary_value, monetary_value_frequency_id, monetary_value_changes,
			requires_approval_for_late, mitigation_plan_required,run_effective_date,perform_activity,fas_book_id)
			values
			(@requirements_id, @standard_revision_id, @requirement_no, @risk_control_description, @requirements_url, @perform_role, @approve_role,
			@run_frequency,@control_type, @threshold_days, @requires_approval, @requires_proof, @control_objective, @internal_function_id, @run_date,
			@activity_category_id, @activity_who_for_id, @run_end_date, @where_id, @activity_area_id, @activity_sub_area_id,
			@activity_action_id, @monetary_value, @monetary_value_frequency_id, @monetary_value_changes, @requires_approval_for_late, 
			@mitigation_plan_required,@run_effective_date,@perform_activity,@fas_book_id)


			set @tmp_requirements_revision_id=SCOPE_IDENTITY()

			
			--exec spa_create_compliance_activities 'i','c',null,@requirements_revision_id
            
		    
            INSERT into process_risk_control_std_dependency
				(requirements_revision_id,requirements_revision_id_depend_on,requirement_revision_hierarchy_level) 
             VALUES(@tmp_requirements_revision_id,NULL,0)
 		   
         --print @tmp_requirements_revision_id
        -- declare @sql as varchar
     


             
             If @@ERROR <> 0
						BEGIN
							Exec spa_ErrorHandler @@ERROR, 'process requirements revisions', 
							'spa_process_requirements_revisions', 'DB Error', 
							'Error process requirements revisions.', ''
                              ROLLBACK TRAN
						END
			else
				BEGIN
						
				      INSERT INTO process_risk_std_steps
							(
							requirement_revision_id,
							step_sequence,
							step_desc1,
							step_desc2,
							step_reference
							)
						 select @tmp_requirements_revision_id ,step_sequence ,step_desc1,step_desc2,step_reference
						 from process_risk_std_steps where requirement_revision_id=@requirements_revision_id
							Exec spa_ErrorHandler 0, 'process requirements revisions', 
							'spa_process_requirements_revisions', 'Success', 
							'process requirements revisions Detail Copied Successfully.',@tmp_requirements_revision_id
						COMMIT TRAN
				END
          -- set @requirements_id = scope_identity()

 end
 if @flag = 'i'
   begin
		EXEC spa_print @requirements_id
			if @activity_category_id=1211
			BEGIN
				if exists (select requirements_id 
								from process_requirements_revisions 
								where (@run_effective_date between run_effective_date and run_end_date 
									or @run_end_date between run_effective_date and run_end_date)
								and requirements_id=@requirements_id)
				begin
					Exec spa_ErrorHandler -1, 'process_standard_revisions', 
							'spa_process_standard_revisions', 'Success', 
							'Run Date is Duplicate found ', ''
					return
				end
			END

			INSERT into process_requirements_revisions
			(requirements_id, standard_revision_id, requirement_no, risk_control_description, requirements_url, perform_role, approve_role, 
			run_frequency, control_type,
			threshold_days, requires_approval, requires_proof, control_objective, internal_function_id, run_date,
			activity_category_id, activity_who_for_id, run_end_date, where_id, activity_area_id, activity_sub_area_id,
			activity_action_id, monetary_value, monetary_value_frequency_id, monetary_value_changes,
			requires_approval_for_late, mitigation_plan_required,run_effective_date,perform_activity,fas_book_id)
			values
			(@requirements_id, @standard_revision_id, @requirement_no, @risk_control_description, @requirements_url, @perform_role, @approve_role,
			@run_frequency,@control_type, @threshold_days, @requires_approval, @requires_proof, @control_objective, @internal_function_id, @run_date,
			@activity_category_id, @activity_who_for_id, @run_end_date, @where_id, @activity_area_id, @activity_sub_area_id,
			@activity_action_id, @monetary_value, @monetary_value_frequency_id, @monetary_value_changes, @requires_approval_for_late, 
			@mitigation_plan_required,@run_effective_date,@perform_activity,@fas_book_id)


			set @requirements_revision_id=SCOPE_IDENTITY()

			
			--exec spa_create_compliance_activities 'i','c',null,@requirements_revision_id
            
		    
            INSERT into process_risk_control_std_dependency
				(requirements_revision_id,requirements_revision_id_depend_on,requirement_revision_hierarchy_level) 
             VALUES(@requirements_revision_id,NULL,0)
			
           


			If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "Maintain Complaince Requirements", 
						"spa_process_requirements_revisions", "DB Error", 
						"Maintain Complaince Requirements data failed.", ''
			else

				Exec spa_ErrorHandler 0, 'Maintain Complaince Requirements', 
						'spa_process_requirements_revisions', 'Success', 
						'Maintain Complaince Requirements data successfully inserted.',@requirements_revision_id
			end
END


Else if @flag = 'u'
BEGIN

    if @activity_category_id=1211
			BEGIN
				if exists (select requirements_id 
								from process_requirements_revisions 
								where (@run_effective_date between run_effective_date and run_end_date 
									or @run_end_date between run_effective_date and run_end_date)
								and  requirements_id = @requirements_id and  requirements_revision_id <> @requirements_revision_id)
				begin
					Exec spa_ErrorHandler -1, 'process_standard_revisions', 
							'spa_process_standard_revisions', 'Success', 
							'Run Date is Duplicate found ', ''
					return
				end
			END
	
	UPDATE process_requirements_revisions
	set
	requirements_id = @requirements_id,
	standard_revision_id = @standard_revision_id,
	requirement_no = @requirement_no,
	requirements_url = @requirements_url,
	risk_control_description = @risk_control_description,
	perform_role = @perform_role,
	approve_role = @approve_role,
	run_frequency = @run_frequency,
	control_type = @control_type,
	threshold_days = @threshold_days,
	requires_approval = @requires_approval,
	requires_proof = @requires_proof,
	control_objective = @control_objective,
	internal_function_id = @internal_function_id,
	run_date = @run_date,
	activity_category_id = @activity_category_id,
	activity_who_for_id = @activity_who_for_id,
	run_end_date = @run_end_date,
	where_id = @where_id,
	activity_area_id = @activity_area_id,
	activity_sub_area_id = @activity_sub_area_id,
	activity_action_id = @activity_action_id,
	monetary_value = @monetary_value,
	monetary_value_frequency_id = @monetary_value_frequency_id,
	monetary_value_changes = @monetary_value_changes,
	requires_approval_for_late = @requires_approval_for_late,
	mitigation_plan_required = @mitigation_plan_required,
	run_effective_date=@run_effective_date,
    perform_activity=@perform_activity,
    fas_book_id=@fas_book_id
	where
	requirements_revision_id = @requirements_revision_id

    
	--exec spa_create_compliance_activities 'u','c',null,@requirements_revision_id

	

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Maintain Compliance Activity Detail", 
				"spa_process_risk_controls", "DB Error", 
				"Update of Maintain Compliance Activity Detail data failed.", ''
	else
		Exec spa_ErrorHandler 0, 'Maintain Compliance Activity Detail', 
				'spa_process_risk_controls', 'Success', 
				'Maintain Compliance Activity Detail data successfully updated.', ''
END

Else if @flag = 'd'
BEGIN

	--exec spa_create_compliance_activities 'd','c',null,@requirements_revision_id


	delete process_requirements_revisions
	where requirements_revision_id=@requirements_revision_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Maintain Complaince Requirements", 
				"spa_process_requirements_revisions", "DB Error", 
				"Maintain Complaince Requirements data failed.", ''
	else
		Exec spa_ErrorHandler 0, 'Maintain Complaince Requirements', 
				'spa_process_requirements_revisions', 'Success', 
				'Maintain Complaince Requirements data successfully delete.', ''
END


ELSE IF @flag = 'p'
BEGIN

	set @sql_stmt = 'SELECT requirements_revision_id as Id, prm.requirements_name [Requirement Name], 
    risk_control_description as Description, sdv6.code as ActivityCategory,
	sdv3.code as Area, sdv4.code as SubArea, sdv5.code as Action,
	dbo.FNADateFormat(prr.run_date) RunDate,dbo.FNADateFormat(prr.run_effective_date) 
    RunEffectiveDate,dbo.FNADateFormat(prr.run_end_date) RunEndDate
    --,fas_book_id,activity_who_for_id
	FROM process_requirements_revisions prr 
	left outer join application_security_role asr on asr.role_id=prr.perform_role 
	left outer join static_data_value sdv3 on sdv3.value_id = prr.activity_area_id
	left outer join static_data_value sdv4 on sdv4.value_id = prr.activity_sub_area_id
	left outer join static_data_value sdv5 on sdv5.value_id = prr.activity_action_id
	left outer join static_data_value sdv6 on sdv6.value_id = prr.activity_category_id	
   inner join 
             process_requirements_main prm on prm.requirements_id=prr.requirements_id
	where 1=1 
     '
if @activity_category_id is not null
 set @sql_stmt = @sql_stmt + 'and prr.activity_category_id='+cast(@activity_category_id as varchar)

if @temp_requirements_id is not null
set @sql_stmt = @sql_stmt +'
	and requirements_revision_id NOT IN ('+@temp_requirements_id+') '

if @requirements_revision_id is not null
set @sql_stmt = @sql_stmt +'and  fas_book_id in 
     (select fas_book_id from  process_requirements_revisions where  requirements_revision_id
     ='+cast(@requirements_revision_id as varchar)+') and activity_who_for_id in (select activity_who_for_id from  process_requirements_revisions where  requirements_revision_id
     ='+cast(@requirements_revision_id as varchar)+') '
--case when @risk_description_id is not null then 
--' AND prc.risk_description_id='+cast(@risk_description_id as varchar) else '' end	
	
	set @sql_stmt = @sql_stmt + 'ORDER BY requirements_revision_id'
	exec spa_print @sql_stmt
	exec(@sql_stmt)

END



