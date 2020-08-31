
IF OBJECT_ID(N'[dbo].[spa_create_compliance_activities]', N'P') IS NOT NULL
DROP proc [dbo].[spa_create_compliance_activities]
go
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go







--exec spa_process_requirements_assignment 'i', 'c', NULL, 24, 145, 6, 6, NULL, '2008-12-26', NULL, NULL
--exec spa_create_compliance_activities i,'m',null,96,24,145,6,6,262,'2008-12-29',5377,1253
--select * from process_risk_description

CREATE proc [dbo].[spa_create_compliance_activities]
@flag varchar(1), -- 'i' for insert, 'u' for update, 'd' for delete 
@flag1 varchar(1),--'c' for Assignment, 't' trigger, 'm' mitigate ,'r' requirement revision
@requirement_assignment_id int=null,
@requirements_revision_id INT =null,
@requirements_id INT=null,
@process_id  INT=null,
@perform_role INT=null,
@approve_role INT=null,
@fas_book_id INT=null,
@run_date varchar(20)=null,
@activity_who_for_id INT=NULL,
@triggerActivity INT =NULL

AS

CREATE TABLE #tempControls1 (
	[requirements_revision_dependency_id] [int]  NOT NULL ,
	[entity_name] [varchar] (5000) COLLATE DATABASE_DEFAULT   NULL ,
	[have_rights] [int] NOT NULL ,
	[level] [int] NOT NULL ,
	[requirements_revision_id_depend_on] [int]  NULL ,
	[requirements_revision_id] [int] NOT NULL 
)

--select 'requirements_revision_id',@requirements_revision_id
INSERT #tempControls1 
 exec spa_getReqRevisionDependencyHierarchy s,@requirements_revision_id
--print 'i m here'
--select @requirements_revision_id
--select * from  #tempControls1


CREATE TABLE #temp_reqs(
	requirements_revision_id int null,
	requirements_id int null, 
	standard_revision_id int null, 
	requirement_no int null,
	risk_control_description varchar(255) COLLATE DATABASE_DEFAULT null, 
	requirements_url varchar(255) COLLATE DATABASE_DEFAULT null, 
	perform_role int null, 
	approve_role int null, 
	run_frequency int null, 
	control_type int null,
	threshold_days int null, 
	requires_approval varchar(255) COLLATE DATABASE_DEFAULT null , 
	requires_proof varchar(255) COLLATE DATABASE_DEFAULT null,
	control_objective varchar(255) COLLATE DATABASE_DEFAULT null,
	internal_function_id int null, 
	run_date  varchar(255) COLLATE DATABASE_DEFAULT null ,
	activity_category_id int null, 
	activity_who_for_id int null ,
	run_end_date  varchar(255) COLLATE DATABASE_DEFAULT null, 
	where_id int null, 
	activity_area_id int null, 
	activity_sub_area_id int null,
	activity_action_id int null, 
	monetary_value  varchar(255) COLLATE DATABASE_DEFAULT null, 
	monetary_value_frequency_id  varchar(255) COLLATE DATABASE_DEFAULT null, 
	monetary_value_changes  varchar(255) COLLATE DATABASE_DEFAULT null,
	requires_approval_for_late  varchar(255) COLLATE DATABASE_DEFAULT null, 
	mitigation_plan_required  varchar(255) COLLATE DATABASE_DEFAULT null,
	run_effective_date  varchar(255) COLLATE DATABASE_DEFAULT null,
	triggerActivity int null
)


INSERT INTO #temp_reqs 
SELECT 	prr.requirements_revision_id,
		requirements_id, 
		standard_revision_id, 
	    requirement_no, 
		risk_control_description, 
		requirements_url,
		perform_role, 
		approve_role, 
		run_frequency, 
		control_type,
		threshold_days, 
		requires_approval, 
		requires_proof,
		control_objective,
		internal_function_id, 
		run_date,
		activity_category_id, 
		activity_who_for_id,
		run_end_date, 
		where_id, 
		activity_area_id, 
		activity_sub_area_id,
		activity_action_id, 
		monetary_value,
		monetary_value_frequency_id, 
		monetary_value_changes,
		requires_approval_for_late, 
		mitigation_plan_required,
		run_effective_date,
		perform_activity 
FROM 	process_requirements_revisions prr 
JOIN #tempControls1 tc ON tc.requirements_revision_id=prr.requirements_revision_id
--inner join	process_standard_revisions psr on psr.standard_revision_id = prr.standard_revision_id 
--inner join	process_standard_main psm on psm.standard_id = psr.standard_id
WHERE prr.requirements_id = @requirements_id 
AND   tc.requirements_revision_id=prr.requirements_revision_id


/*
SELECT 	psm.standard_id, psm.standard_name, psr.standard_revision_id, psr.standard_category_id,
		psr.standard_description, psr.standard_url, psr.standard_priority, psr.standard_owner, 
		psr.effective_date, prr.requirements_id
INTO #temp_stds
FROM 	process_requirements_revisions prr 
INNER JOIN	process_standard_revisions psr ON psr.standard_revision_id = prr.standard_revision_id 
INNER JOIN	process_standard_main psm ON psm.standard_id = psr.standard_id
WHERE prr.requirements_revision_id = isnull(@requirements_revision_id, requirements_revision_id) 
AND   prr.requirements_id = isnull(@requirements_id, requirements_id)
*/

SELECT 	prm.requirements_id,prm.requirements_name,psm.standard_id, psm.standard_name, psr.standard_revision_id, 
		psr.standard_category_id,psr.standard_description, psr.standard_url, psr.standard_priority, 
		psr.standard_owner,psr.effective_date
INTO #temp_stds
FROM process_requirements_main prm
INNER JOIN process_requirements_revisions prr ON prr.requirements_id=prm.requirements_id
INNER JOIN process_standard_revisions psr ON psr.standard_revision_id=prm.standard_revision_id
INNER JOIN process_standard_main psm ON psm.standard_id=psr.standard_id
AND  prr.requirements_revision_id = isnull(@requirements_revision_id, requirements_revision_id)



--select '#temp_stds',* from #temp_stds


IF  @flag1 ='c' -- Assignment
BEGIN
IF @flag = 'i' 
BEGIN
	DECLARE @tmp_risk_control_id INT
    DECLARE @tmp_risk_description_id INT
    DECLARE @tmp_requirements_revision_id INT
	DECLARE @tmp_risk_desc_id INT
	--process_risk_descriptions
	--a. First update existing ones

     DECLARE @temp INT
     SET @temp=0;
     SELECT @temp= risk_control_id FROM  process_risk_controls 
			WHERE requirements_revision_id=@requirements_revision_id
				
 
     --print @temp

     IF @temp = 0
       BEGIN
			 
		SELECT @tmp_risk_desc_id=risk_description_id 
		FROM process_risk_description 
			WHERE requirements_id=(SELECT ts.requirements_id 
									FROM #temp_stds ts
									INNER JOIN process_requirements_assignment pra ON pra.requirements_id=ts.requirements_id
									WHERE pra.requirement_assignment_id=@requirement_assignment_id) 

			
			
--				select '#temp_reqs',* from #temp_reqs
--				select '#tempControls1',* from #tempControls1
--				select 'process_requirements_assignment',* from process_requirements_assignment
--				EXEC spa_print 'tmp_risk_desc_id'
--				EXEC spa_print @tmp_risk_desc_id
			
												     
						 
			IF(@tmp_risk_desc_id IS NOT NULL)
				BEGIN
					
						 INSERT INTO process_risk_controls(
																risk_description_id,risk_control_description,perform_role, 
																approve_role,run_frequency,control_type, 
																threshold_days,requires_approval,requires_proof, 
																control_objective,internal_function_id,run_date, 
																activity_category_id,activity_who_for_id,run_end_date, 
																where_id,activity_area_id,activity_sub_area_id, 
																activity_action_id,monetary_value,monetary_value_frequency_id, 
																monetary_value_changes,requires_approval_for_late,fas_book_id, 
																requirements_revision_id,mitigation_plan_required,run_effective_date,
																triggerActivity,frequency_type
																)
								SELECT
	 								@tmp_risk_desc_id, tr.risk_control_description, isnull(pra.perform_role,tr.perform_role), 
									isnull(pra.approve_role, tr.approve_role), tr.run_frequency,tr.control_type,
									tr.threshold_days, tr.requires_approval, tr.requires_proof, 
									tr.control_objective,tr.internal_function_id, tr.run_date ,
									tr.activity_category_id,coalesce(pra.activity_who_for_id,tr.activity_who_for_id) activity_who_for_id,tr.run_end_date, 
									tr.where_id, tr.activity_area_id,tr.activity_sub_area_id, 
									tr.activity_action_id, tr.monetary_value,tr.monetary_value_frequency_id,
									tr.monetary_value_changes,tr.requires_approval_for_late,pra.fas_book_id, 
									tr.requirements_revision_id, tr.mitigation_plan_required,tr.run_effective_date,
									tr.perform_activity,'o'
								FROM #temp_reqs tr 
								JOIN #tempControls1 tc1 ON tc1.requirements_revision_id=tr.requirements_revision_id 
								INNER JOIN process_risk_description prd ON prd.requirements_id = tr.requirements_id 
										AND prd.risk_description_id=@tmp_risk_desc_id
								JOIN process_requirements_assignment pra ON pra.requirements_revision_id=tr.requirements_revision_id
										--AND pra.fas_book_id=prd.fas_book_id 
										--AND pra.activity_who_for_id=prd.activity_who_for_id
								WHERE 	pra.requirement_assignment_id = isnull(@requirement_assignment_id, pra.requirement_assignment_id)


							SET @tmp_risk_control_id = SCOPE_IDENTITY()
						
				END
			ELSE
				BEGIN

					INSERT INTO process_risk_description
							(process_id,risk_description, risk_priority, risk_owner,requirements_id,fas_book_id,activity_who_for_id)
					
					SELECT  pra.process_id, isNUll(ts.requirements_name,'') [Description],ts.standard_priority,ts.standard_owner, ts.requirements_id,
							pra.fas_book_id,pra.activity_who_for_id
					FROM  
						(
							SELECT DISTINCT requirements_name, standard_priority, standard_owner, requirements_id 
							FROM #temp_stds
						 ) ts 
					INNER JOIN process_requirements_assignment pra ON pra.requirements_id=ts.requirements_id
					WHERE pra.requirement_assignment_id=@requirement_assignment_id 
	               
								SET @tmp_risk_description_id = SCOPE_IDENTITY()	 
	                                      
								--(ts.standard_revision_id not in (select distinct standard_revision_id from process_risk_description where standard_revision_id is not null)
								--or pra.fas_book_id not in(select distinct fas_book_id from process_risk_description where fas_book_id is not null)
								--or pra.activity_who_for_id not in(select distinct activity_who_for_id from process_risk_description where activity_who_for_id is not null)
								--)
					          
								--and  pra.requirement_assignment_id = isnull(@requirement_assignment_id, pra.requirement_assignment_id)
						  
						--print 'desc'	
					   --print 'tmp_risk_description_id==>'+CAST(@tmp_risk_description_id as varchar)
		
						   INSERT INTO process_risk_controls(
																risk_description_id,risk_control_description,perform_role, 
																approve_role,run_frequency,control_type, 
																threshold_days,requires_approval,requires_proof, 
																control_objective,internal_function_id,run_date, 
																activity_category_id,activity_who_for_id,run_end_date, 
																where_id,activity_area_id,activity_sub_area_id, 
																activity_action_id,monetary_value,monetary_value_frequency_id, 
																monetary_value_changes,requires_approval_for_late,fas_book_id, 
																requirements_revision_id,mitigation_plan_required,run_effective_date,
																triggerActivity,frequency_type
																)
								SELECT
	 								prd.risk_description_id, tr.risk_control_description, isnull(pra.perform_role,tr.perform_role), 
									isnull(pra.approve_role, tr.approve_role), tr.run_frequency,tr.control_type,
									tr.threshold_days, tr.requires_approval, tr.requires_proof, 
									tr.control_objective,tr.internal_function_id, tr.run_date ,
									tr.activity_category_id,coalesce(pra.activity_who_for_id,tr.activity_who_for_id) activity_who_for_id,tr.run_end_date, 
									tr.where_id, tr.activity_area_id,tr.activity_sub_area_id, 
									tr.activity_action_id, tr.monetary_value,tr.monetary_value_frequency_id,
									tr.monetary_value_changes,tr.requires_approval_for_late,pra.fas_book_id, 
									tr.requirements_revision_id, tr.mitigation_plan_required,tr.run_effective_date,
									tr.perform_activity,'o'
								FROM #temp_reqs tr 
								JOIN #tempControls1 tc1 ON tc1.requirements_revision_id=tr.requirements_revision_id 
								INNER JOIN process_risk_description prd ON prd.requirements_id = tr.requirements_id 
										AND prd.risk_description_id=@tmp_risk_description_id
								JOIN process_requirements_assignment pra ON pra.fas_book_id=prd.fas_book_id 
										AND pra.activity_who_for_id=prd.activity_who_for_id
								WHERE 	pra.requirement_assignment_id = isnull(@requirement_assignment_id, pra.requirement_assignment_id)


							SET @tmp_risk_control_id = SCOPE_IDENTITY()	
							
							 --print 'tmp_risk_control_id==>'+ CAST(@tmp_risk_control_id as varchar)
                END          
                          
				DECLARE @sql_stmt varchar(5000)
				DECLARE @count_level_depth int
				DECLARE @level_depth int
				DECLARE @risk_control_dependency_id int
				DECLARE @temp1_risk_control_id int
				SET @level_depth=0

				CREATE TABLE #tempControls_test (
						[risk_control_id] [int] NOT NULL ,
						[level] [int]   NOT NULL ,
						[requirements_revision_id] [int]   NOT NULL       
				)
				INSERT #tempControls_test  
				   Select  prc.risk_control_id, tc.level,tc.requirements_revision_id from 
				  #tempControls1 tc ,process_risk_controls prc
				  where tc.requirements_revision_id=prc.requirements_revision_id


				---select  * from #tempControls_test 
				select @count_level_depth=max(tct.level) from #tempControls_test tct
				--select @count_level_depth=tct.level from #tempControls_test tct where tct.requirements_revision_id=@requirements_revision_id 

				--Print @count_level_depth
				 while @count_level_depth >= @level_depth
				 begin
						Select   @tmp_risk_control_id=risk_control_id ,@tmp_requirements_revision_id=tct.requirements_revision_id
									 from #tempControls_test tct where tct.level=@level_depth 
					
						INSERT INTO process_risk_controls_dependency
							(risk_control_id,risk_control_id_depend_on,risk_hierarchy_level)
							VALUES	(@tmp_risk_control_id,NULL,'0')	
						
					     INSERT INTO process_risk_controls_steps
						  (risk_control_id,step_sequence,step_desc1,step_desc2,step_reference)
						  select prc.risk_control_id,prss.step_sequence,prss.step_desc1,prss.step_desc2, prss.step_reference
							 from   process_risk_std_steps prss ,process_risk_controls prc
						 -- join process_risk_std_steps prss on  tct.requirements_revision_id=prss.requirements_revision_id
						 where  prc.risk_control_id=@tmp_risk_control_id and prc.requirements_revision_id=prss.requirement_revision_id
						-- EXEC spa_print 'here'
						-- EXEC spa_print @tmp_risk_control_id
                        -- EXEC spa_print @tmp_requirements_revision_id

						   DECLARE @temp_triggerActivity int
						   DECLARE @count int 
						   set @count=0	  
                       	   select @count=Count(requirements_revision_id)
                           from process_requirements_revisions where perform_activity=@tmp_requirements_revision_id 
                       
                          while @count !=0
                           BEGIN
											 
						         
									 set @tmp_risk_control_id=NULL
							
										select @temp_triggerActivity=a.requirements_revision_id from 
										(
											 select prr.requirements_revision_id  from process_requirements_revisions prr									
												where prr.perform_activity=@tmp_requirements_revision_id 
										) a 
										where a.requirements_revision_id NOT IN 
										(Select requirements_revision_id from process_risk_controls 
									    where requirements_revision_id is not null )

												
											
										--print 'here1'
										--	EXEC spa_print @count
										--	EXEC spa_print @tmp_requirements_revision_id 
										--	EXEC spa_print @temp_triggerActivity
                                  
								   INSERT into process_risk_controls
											(risk_description_id, risk_control_description, perform_role, 
											approve_role, run_frequency, 
											control_type, threshold_days, requires_approval, requires_proof, control_objective, 
											internal_function_id, run_date, activity_category_id, activity_who_for_id, run_end_date, 
											where_id, activity_area_id, activity_sub_area_id, activity_action_id, monetary_value, 
											monetary_value_frequency_id, monetary_value_changes,
											requires_approval_for_late, fas_book_id, requirements_revision_id, mitigation_plan_required, 
											run_effective_date,triggerActivity,frequency_type)
									select
	 										prd.risk_description_id, tr.risk_control_description, isnull(pra.perform_role,tr.perform_role), 
											isnull(pra.approve_role, tr.approve_role), tr.run_frequency, 
													tr.control_type, tr.threshold_days, tr.requires_approval, tr.requires_proof, tr.control_objective, 
											tr.internal_function_id, tr.run_date , tr.activity_category_id, 
											coalesce(pra.activity_who_for_id, tr.activity_who_for_id) activity_who_for_id, 
											tr.run_end_date, 
											tr.where_id, tr.activity_area_id, tr.activity_sub_area_id, tr.activity_action_id, tr.monetary_value, 
											tr.monetary_value_frequency_id, tr.monetary_value_changes, 
											tr.requires_approval_for_late, pra.fas_book_id, tr.requirements_revision_id, tr.mitigation_plan_required,
											tr.run_effective_date,prc.risk_control_id,'o'
										from process_requirements_revisions tr 
										inner join process_risk_controls prc on prc.requirements_revision_id= tr.perform_activity
									    inner join process_risk_description prd on prd.requirements_id = tr.requirements_id  and prd.risk_description_id=@tmp_risk_description_id
										join process_requirements_assignment pra on 1=1
										and pra.fas_book_id=prd.fas_book_id and pra.activity_who_for_id=prd.activity_who_for_id
										where 	
											tr.requirements_revision_id=@temp_triggerActivity and
											pra.requirement_assignment_id = isnull(@requirement_assignment_id, pra.requirement_assignment_id)

                                          SET @tmp_risk_control_id = SCOPE_IDENTITY()

											EXEC spa_print 'risk control id'
											EXEC spa_print @tmp_risk_control_id
											EXEC spa_print @temp_triggerActivity
										  INSERT INTO process_risk_controls_dependency
											(risk_control_id,risk_control_id_depend_on,risk_hierarchy_level)
											 VALUES
											(@tmp_risk_control_id,NULL,'0')	
											set @count=@count-1	
				

                           END 

				    set @level_depth=@level_depth+1
				   end


				set @level_depth=0

				if @count_level_depth !=0
					begin
				              
						 while @count_level_depth > @level_depth
						  begin 
							
				              

									select @risk_control_dependency_id=prcd.risk_control_dependency_id                               
												from #tempControls_test tct,process_risk_controls_dependency prcd
												where tct.risk_control_id=prcd.risk_control_id 
												and tct.level=@level_depth 
				 
										
									set  @level_depth=@level_depth+1
				           
									--print 'hereis'
				                  
										
											 					
									set @temp1_risk_control_id =''
									select  @temp1_risk_control_id=tct.risk_control_id 
													from #tempControls_test tct,process_risk_controls_dependency prcd
													where tct.risk_control_id=prcd.risk_control_id 
													and tct.level=@level_depth 
						                
									   
									-- EXEC spa_print @temp1_risk_control_id
									-- EXEC spa_print @risk_control_dependency_id
									-- EXEC spa_print @level_depth
									if @temp1_risk_control_id !=0
										  begin
											  INSERT into process_risk_controls_dependency
												 (risk_control_id,risk_control_id_depend_on,risk_hierarchy_level) Values
												 (@temp1_risk_control_id,@risk_control_dependency_id,@level_depth)
										  end
									else
										begin
											set  @level_depth=@count_level_depth
										end
						  end -- end while loop	
				             
				    
				     
				 
				       
				   end -- end if loop




end -- end loop @temp
/*else          begin
					Exec spa_ErrorHandler -1, 'process_requirements_assignment', 
							'spa_process_requirements_assignment', 'Error', 
							'Data Already inserted in process risk control ', ''
					return
				end
*/


 /*  If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "process_requirements_assignment_trigger", 
					"spa_process_requirements_assignment_trigger", "DB Error", 
					"Insert of process requirements assignment trigger Failed.", ''
		else
			Exec spa_ErrorHandler 0, 'process_requirements_assignment_trigger', 
					'spa_process_requirements_assignment_trigger', 'Success', 
					'process requirements assignment trigger successfully Inserted', ''*/
end		

end


/*
CREATE TABLE #tempControls (
	[requirements_revision_dependency_id] [int]  NOT NULL ,
	[entity_name] [varchar] (100) COLLATE DATABASE_DEFAULT   NULL ,
	[have_rights] [int] NOT NULL ,
	[level] [int] NOT NULL ,
	[requirements_revision_id_depend_on] [int]  NULL ,
	[requirements_revision_id] [int] NOT NULL 
)
INSERT #tempControls 
 exec spa_getReqRevisionDependencyHierarchy s,@requirements_revision_id

--select * from #tempControls

declare @sql_stmt varchar(5000)
Declare @count_level_depth int
Declare @level_depth int
declare @risk_control_dependency_id int
declare @temp1_risk_control_id int
set @level_depth=0

CREATE TABLE #tempControls_test (
        [risk_control_id] [int] NOT NULL ,
		[level] [int]   NOT NULL ,
        [requirements_revision_id] [int]   NOT NULL       
)
INSERT #tempControls_test  
   Select  prc.risk_control_id, tc.level,tc.requirements_revision_id from 
  #tempControls tc ,process_risk_controls prc
  where tc.requirements_revision_id=prc.requirements_revision_id


--select  * from #tempControls_test 

select @count_level_depth=tct.level from #tempControls_test tct where tct.requirements_revision_id=@requirements_revision_id 

--Print @count_level_depth

if @count_level_depth !=0
	begin
              
         while @count_level_depth > @level_depth
		  begin 
				      select @risk_control_dependency_id=prcd.risk_control_dependency_id                               
								from #tempControls_test tct,process_risk_controls_dependency prcd
								where tct.risk_control_id=prcd.risk_control_id 
								and tct.level=@level_depth 

						
					set  @level_depth=@level_depth+1
           
					
						
							 					
	                set @temp1_risk_control_id =''
					select  @temp1_risk_control_id=tct.risk_control_id 
									from #tempControls_test tct,process_risk_controls_dependency prcd
									where tct.risk_control_id=prcd.risk_control_id 
									and tct.level=@level_depth 
		                
					   
					  -- EXEC spa_print @temp1_risk_control_id
					  --print @risk_control_dependency_id
					  --print @level_depth
                    if @temp1_risk_control_id !=0
						  begin
							  INSERT into process_risk_controls_dependency
								 (risk_control_id,risk_control_id_depend_on,risk_hierarchy_level) Values
								 (@temp1_risk_control_id,@risk_control_dependency_id,@level_depth)
						  end
					else
                        begin
							set  @level_depth=@count_level_depth
                        end
          end -- end while loop	
             
    
     
 
       
   end -- end if loop




*/


/*
if @flag = 'u' 
begin
	--process_risk_descriptions
	--a. First update existing ones

	update  process_risk_description 
	set 	process_id = pra.process_id,
		risk_description = isNUll(ts.standard_name,''), 
		risk_priority = ts.standard_priority,
		risk_owner = ts.standard_owner
	from 	process_risk_description prd inner join
	   	(Select distinct standard_name, standard_priority, standard_owner, standard_revision_id, requirements_id,standard_description  from #temp_stds) ts 
		on ts.standard_revision_id = prd.standard_revision_id
	join process_requirements_assignment pra on pra.requirements_id=ts.requirements_id
	and  pra.requirement_assignment_id = isnull(@requirement_assignment_id, pra.requirement_assignment_id)


	update  process_risk_controls
	set 	risk_control_description=tr.risk_control_description, perform_role=isnull(pra.perform_role,tr.perform_role), 
		approve_role=isnull(pra.approve_role, tr.approve_role), run_frequency=tr.run_frequency, 
		control_type=tr.control_type, threshold_days=tr.threshold_days, requires_approval=tr.requires_approval, 
		requires_proof=tr.requires_proof, control_objective=tr.control_objective, 
		internal_function_id=tr.internal_function_id, run_date=tr.run_date, 
		activity_category_id=tr.activity_category_id, 
		activity_who_for_id= coalesce(pra.activity_who_for_id, tr.activity_who_for_id), 
		run_end_date=tr.run_end_date, 
		where_id=tr.where_id, activity_area_id=tr.activity_area_id, activity_sub_area_id=tr.activity_sub_area_id, 
		activity_action_id=tr.activity_action_id, monetary_value=tr.monetary_value, 
		monetary_value_frequency_id=tr.monetary_value_frequency_id, monetary_value_changes=tr.monetary_value_changes,
		requires_approval_for_late=tr.requires_approval_for_late, fas_book_id=pra.fas_book_id, 
		requirements_revision_id=tr.requirements_revision_id, mitigation_plan_required=tr.mitigation_plan_required, 
		run_effective_date=tr.run_effective_date
	from    process_risk_controls prc inner join
		#temp_reqs tr  on tr.requirements_revision_id = prc.requirements_revision_id		
		join process_requirements_assignment pra on pra.requirements_id=tr.requirements_id
		where  pra.requirement_assignment_id = isnull(@requirement_assignment_id, pra.requirement_assignment_id)
			AND isnull(prc.activity_category_id, 1211) NOT IN (1212,1213)

 If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "process_requirements_assignment_trigger", 
					"spa_process_requirements_assignment_trigger", "DB Error", 
					"Insert of process requirements assignment trigger Failed.", ''
		else
			Exec spa_ErrorHandler 0, 'process_requirements_assignment_trigger', 
					'spa_process_requirements_assignment_trigger', 'Success', 
					'process requirements assignment trigger successfully Inserted', ''


end
end
*/
IF  @flag1 ='t' or @flag1 ='m' -- trigger
	BEGIN
		IF @flag = 'i' 
			DECLARE @tmp_risk_discription VARCHAR(100)
			
			
			SELECT @tmp_risk_discription=risk_control_description 
			FROM process_risk_controls 
			WHERE risk_control_id=@triggerActivity

			--print @requirements_revision_id
			EXEC spa_print @requirements_id
			EXEC spa_print @requirement_assignment_id


			SELECT * INTO #temp_reqs1
			FROM process_requirements_revisions
			WHERE requirements_revision_id = isnull(@requirements_revision_id, requirements_revision_id) 
			AND  requirements_id = isnull(@requirements_id, requirements_id)
		
			
				/*select '#temp_reqs1', * from #temp_reqs1 
					select '#temp_stds', * from #temp_stds */
			

			BEGIN
				--process_risk_descriptions
				--a. First update existing ones
				BEGIN

					SELECT @tmp_risk_desc_id=risk_description_id 
					FROM process_risk_description 
					WHERE requirements_id=(SELECT ts.requirements_id 
									FROM #temp_stds ts
									INNER JOIN process_requirements_assignment_trigger prat ON prat.requirements_id=ts.requirements_id
									WHERE prat.requirement_assignment_id=@requirement_assignment_id) 
					
					
					
					IF(@tmp_risk_desc_id IS NOT NULL)
						BEGIN
						
						INSERT INTO process_risk_controls(
									risk_description_id,risk_control_description,perform_role,approve_role, run_frequency,control_type,
									threshold_days,requires_approval,requires_proof,control_objective,internal_function_id,
									run_date,activity_category_id,activity_who_for_id,run_end_date,where_id,
									activity_area_id,activity_sub_area_id,activity_action_id, monetary_value,monetary_value_frequency_id,
									monetary_value_changes,requires_approval_for_late,fas_book_id,requirements_revision_id,
									mitigation_plan_required,run_effective_date,triggerActivity,frequency_type
									)

								SELECT	@tmp_risk_desc_id,
									CASE 
										WHEN (@flag1 ='t') THEN 'Trigger_'+@tmp_risk_discription 	
										WHEN (@flag1 ='m') THEN 'Mitigate_'+@tmp_risk_discription 
									ELSE
										 tr.risk_control_description 
									END risk_control_description,
									isnull(@perform_role,tr.perform_role),isnull(@approve_role, tr.approve_role),700 AS run_frequency, 
									tr.control_type, 
									CASE
										WHEN (@flag1 = 'm') THEN 0 
									ELSE tr.threshold_days 
									END threshold_days,tr.requires_approval, tr.requires_proof, tr.control_objective,tr.internal_function_id, 
									tr.run_date [Run Date],	
									CASE 
										WHEN (@flag1 ='t') THEN 1212 
										WHEN (@flag1 ='m') THEN 1213 
									ELSE 1211 
									END activity_category_id,isnull(@activity_who_for_id, tr.activity_who_for_id) activity_who_for_id, 
									tr.run_end_date,tr.where_id, 
									tr.activity_area_id, tr.activity_sub_area_id, tr.activity_action_id, tr.monetary_value,tr.monetary_value_frequency_id,
									tr.monetary_value_changes,tr.requires_approval_for_late, @fas_book_id, tr.requirements_revision_id,
									CASE 
										WHEN (@flag1='m')THEN 'n' 
									ELSE tr.mitigation_plan_required 
									END,tr.run_effective_date,@triggerActivity,'o'
						FROM #temp_reqs1 tr  
						INNER JOIN process_risk_description prd ON prd.requirements_id = tr.requirements_id
						/*AND prd.fas_book_id=@fas_book_id 
						  AND prd.activity_who_for_id=@activity_who_for_id*/

						SET @tmp_risk_control_id = SCOPE_IDENTITY()	
						--select '@tmp_risk_control_id',@tmp_risk_control_id
							
					END
				ELSE
					BEGIN
						
						INSERT INTO process_risk_description
								(process_id,risk_description, risk_priority, risk_owner,requirements_id)
						SELECT  prat.process_id, isNUll(ts.requirements_name,'') [Description],ts.standard_priority,ts.standard_owner, ts.requirements_id
						FROM  
							(
								SELECT DISTINCT requirements_name, standard_priority, standard_owner, requirements_id 
								FROM #temp_stds
							 ) ts 
						INNER JOIN process_requirements_assignment_trigger prat ON prat.requirements_id=ts.requirements_id
						WHERE prat.requirement_assignment_id=@requirement_assignment_id 
	               
						SET @tmp_risk_discription = SCOPE_IDENTITY()	
						BEGIN
							INSERT INTO process_risk_controls(
										risk_description_id,risk_control_description,perform_role,approve_role, run_frequency,control_type,
										threshold_days,requires_approval,requires_proof,control_objective,internal_function_id,
										run_date,activity_category_id,activity_who_for_id,run_end_date,where_id,
										activity_area_id,activity_sub_area_id,activity_action_id, monetary_value,monetary_value_frequency_id,
										monetary_value_changes,requires_approval_for_late,fas_book_id,requirements_revision_id,
										mitigation_plan_required,run_effective_date,triggerActivity,frequency_type
										)

									SELECT	@tmp_risk_discription,
										CASE 
											WHEN (@flag1 ='t') THEN 'Trigger_'+@tmp_risk_discription 	
											WHEN (@flag1 ='m') THEN 'Mitigate_'+@tmp_risk_discription 
										ELSE
											 tr.risk_control_description 
										END risk_control_description,
										isnull(@perform_role,tr.perform_role),isnull(@approve_role, tr.approve_role),700 AS run_frequency, 
										tr.control_type, 
										CASE
											WHEN (@flag1 = 'm') THEN 0 
										ELSE tr.threshold_days 
										END threshold_days,tr.requires_approval, tr.requires_proof, tr.control_objective,tr.internal_function_id, 
										tr.run_date [Run Date],	
										CASE 
											WHEN (@flag1 ='t') THEN 1212 
											WHEN (@flag1 ='m') THEN 1213 
										ELSE 1211 
										END activity_category_id,isnull(@activity_who_for_id, tr.activity_who_for_id) activity_who_for_id, 
										tr.run_end_date,tr.where_id, 
										tr.activity_area_id, tr.activity_sub_area_id, tr.activity_action_id, tr.monetary_value,tr.monetary_value_frequency_id,
										tr.monetary_value_changes,tr.requires_approval_for_late, @fas_book_id, tr.requirements_revision_id,
										CASE 
											WHEN (@flag1='m')THEN 'n' 
										ELSE tr.mitigation_plan_required 
										END,tr.run_effective_date,@triggerActivity,'o'
							FROM #temp_reqs1 tr  
							INNER JOIN process_risk_description prd ON prd.requirements_id = tr.requirements_id
							/*AND prd.fas_book_id=@fas_book_id and prd.activity_who_for_id=@activity_who_for_id*/
						
							SET @tmp_risk_control_id = SCOPE_IDENTITY() 
						END	
						
					END
				
					INSERT INTO process_risk_controls_dependency(
																risk_control_id,
																risk_control_id_depend_on,
																risk_hierarchy_level
																)
							VALUES (@tmp_risk_control_id,NULL,'0')

					IF @@ERROR <> 0
						EXEC spa_ErrorHandler @@ERROR, "process_requirements_assignment_trigger", 
						"spa_process_requirements_assignment_trigger", "DB Error", 
						"Insert of process requirements assignment trigger Failed.", ''
					ELSE
						Exec spa_ErrorHandler 0, 'process_requirements_assignment_trigger', 
						'spa_process_requirements_assignment_trigger', 'Success', 
						'process requirements assignment trigger successfully Inserted', ''
			END		
		END
END

if @flag = 'u' 
begin
	--process_risk_descriptions
	--a. First update existing ones

	update  process_risk_description 
	set 	process_id =@process_id,
		risk_description = isNUll(ts.standard_name,'') , 
		risk_priority = ts.standard_priority,
		risk_owner = ts.standard_owner
	from 	process_risk_description prd inner join
	   	#temp_stds ts on ts.standard_revision_id = prd.standard_revision_id

	update  process_risk_controls
	set 	--risk_control_description=tr.risk_control_description, 
		perform_role=isnull(@perform_role,tr.perform_role), 
		approve_role=isnull(@approve_role, tr.approve_role), 
		--run_frequency=tr.run_frequency, 
		control_type=tr.control_type, 
		threshold_days=case when (@flag1 = 'm') then 0 else tr.threshold_days end, 
		requires_approval=tr.requires_approval, 
		requires_proof=tr.requires_proof, control_objective=tr.control_objective, 
		internal_function_id=tr.internal_function_id, run_date= isnull(@run_date,tr.run_date), 
		--activity_category_id=tr.activity_category_id, 
		activity_who_for_id= isnull(@activity_who_for_id, tr.activity_who_for_id), 
		run_end_date=tr.run_end_date, 
		where_id=tr.where_id, activity_area_id=tr.activity_area_id, activity_sub_area_id=tr.activity_sub_area_id, 
		activity_action_id=tr.activity_action_id, monetary_value=tr.monetary_value, 
		monetary_value_frequency_id=tr.monetary_value_frequency_id, monetary_value_changes=tr.monetary_value_changes,
		requires_approval_for_late=tr.requires_approval_for_late, fas_book_id=@fas_book_id, 
		requirements_revision_id=tr.requirements_revision_id, mitigation_plan_required=tr.mitigation_plan_required, 
		run_effective_date=tr.run_effective_date
	from    process_risk_controls prc inner join
		#temp_reqs tr  on tr.requirements_revision_id = prc.requirements_revision_id		
		
end 





















