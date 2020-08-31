/****** Object:  StoredProcedure [dbo].[spa_process_risk_controls]    Script Date: 10/24/2008 11:49:38 ******/
IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'[dbo].[spa_process_risk_controls]')
                    AND type IN ( N'P', N'PC' ) ) 
    DROP PROCEDURE [dbo].[spa_process_risk_controls]

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go



--spa_process_risk_controls 's'

/*
	Modified By Pawan KC
	Date:September 8, 2008
	Added the flag p
	Motive for adding P flag: selecting the Risk Control ID from table process_risk_controls leaving the 
							  data which are in the hierarchy of selection cretriea.
*/

-- exec spa_process_risk_controls 'a',1155

CREATE PROCEDURE [dbo].[spa_process_risk_controls]
	@flag VARCHAR(1) = NULL, --Added 'p' flag to papulate ths data in the dependency grid
	@risk_control_id INT = NULL,
	@risk_description_id INT = NULL,
	@risk_control_description VARCHAR(150) = NULL,
	@perform_role INT = NULL,
	@approve_role INT = NULL,
	@run_frequency INT = NULL,
	@control_type INT = NULL,
	@threshold_days INT = NULL,
	@requires_approval VARCHAR(1) = NULL,
	@requires_proof VARCHAR(1) = NULL,
	@control_objective INT = NULL,
	@internal_function_id INT = NULL,
	@run_date VARCHAR(20) = NULL,
	@activity_category_id INT = NULL,
	@activity_who_for_id INT = NULL,
	@run_end_date VARCHAR(20) = NULL,
	@where_id INT = NULL,
	@activity_area_id INT = NULL,
	@activity_sub_area_id INT = NULL,
	@activity_action_id INT = NULL,
	@monetary_value FLOAT = NULL,
	@monetary_value_frequency_id INT = NULL,
	@monetary_value_changes VARCHAR(1) = NULL,
	@requires_approval_for_late VARCHAR(1) = NULL,
	@fas_book_id INT = NULL,
	@requirements_revision_id INT = NULL,
	@mitigation_Plan_required CHAR(1) = NULL,
	@run_effective_date DATETIME = NULL,
	@temp_risk_control_id VARCHAR(500) = NULL,
	@frequency_type CHAR(1) = NULL,
	@perform_user VARCHAR(50) = NULL,
	@approve_user VARCHAR(50) = NULL,
	@mitigationActivity INT = NULL,
	@triggerExists CHAR(1) = NULL,
	@triggerActivity INT = NULL,
	@notificationOnly CHAR(1) = NULL,
	@working_days_value_id INT = NULL,
	@process_id INT = NULL,
	@strategy_id INT = NULL,
	@sub_id INT = NULL,
	@holiday_calendar_value_id INT = NULL,
	@no_of_days INT = NULL,
	@days_start_from CHAR(1) = NULL,
	@activity_type INT = NULL,
	@action_type_on_approve INT = NULL,
	@action_label_on_approve VARCHAR(100) = NULL,
	@action_type_on_complete INT = NULL,
	@action_label_on_complete VARCHAR(100) = NULL,
	@action_type_secondary INT = NULL,
	@action_label_secondary VARCHAR(100) = NULL,
	@document_template INT = NULL,
	@trigger_primary INT = NULL,
	@trigger_secondary INT = NULL  
AS 

    DECLARE @sql_stmt VARCHAR(5000)
    DECLARE @sql_stmt1 VARCHAR(5000)
	DECLARE @lastInstanceDate_MAX DATETIME
	DECLARE @lastInstanceDate_MIN DATETIME
	DECLARe @error int     
	DECLARE @errorExists CHAR(1)
	DECLARE @errorMsg VARCHAR(8000),
			@run_date_tmp DATETIME

	SELECT @errorMsg = ''	
	SELECT @errorExists = 'n'
/*
declare @tmp_new_risk_control_id int
create table #hierarchy_Data
		(
			ID int,
			risk_control_id int
		)
*/


	
DECLARE @user_name AS VARCHAR(50)

if @frequency_type = 'o'
	select @run_frequency = null

SET @user_name = dbo.FNADBUser()

    CREATE TABLE #tmp_hierarchy_Data
        (
          tmp_risk_control_id INT
        )
        
if @triggerExists is null
	set @triggerExists = 'n'     

if @notificationOnly is null
	set @notificationOnly = 'n'   

    IF @flag = 's' 
        BEGIN
            SET @sql_stmt = 'SELECT risk_control_id [ID],
                            prc.risk_control_description [Activity],           
                            asrA.role_name +''->''+ prc.approve_user[Approver],
							case  when((prc.perform_user is not  NULL)  and(asr.role_name is not NULL)) then  
								asr.role_name +''->''+ prc.perform_user
							 when((asr.role_name is NULL) and (prc.perform_user is not  NULL)) then 
								  prc.perform_user 
							 when((prc.perform_user is  NULL)  and (asr.role_name is not NULL)) then 
									asr.role_name
							else   asr.role_name  end [Performer],
                            case when (rf.code is NULL) then ''One Time'' else rf.code end [Run Frequency],
                            ct.code [Control Type],
	                        threshold_days [Threshold Days],
                            case when (requires_approval = ''n'') then  ''No'' else ''Yes'' end [Requires Approval],
                            case when (requires_proof = ''n'') then ''No'' else ''Yes'' end [Requires Proof],
                            ct2.code [Why],
                            dbo.FNADateFormat(run_date) [Run Date],
							dbo.FNADateFormat(run_effective_date) [Run Start Date],
                            dbo.FNADateFormat(run_end_date) [Run End Date], 
	                        ct1.code [Activity Category],
                            ct8.code [Who For ID],                            
                            ct3.code [Where], 
                            ct4.code [Activity Area],
                            ct5.code [Activity Sub Area],
							ct6.code [Activity Action], 
							monetary_value [Monetary Value],
							ct7.code [Monetary Value Frequency] , 
							ph.entity_name [Book Name],
							case when (monetary_value_changes = ''n'') then  ''No'' else ''Yes'' end [Monetary Value]
							/*
							case when (requires_approval_for_late = ''n'') then ''No'' else ''Yes'' end [Requires Approval For Late],
							prc.run_frequency [Frequency ID],
							prc.fas_book_id [Book ID],
							internal_function_id [Internal Function Id],
							prc.perform_user [Perform User],
							prc.approve_user [Approve User],
							CASE WHEN  notificationOnly = ''y'' THEN ''Yes'' ELSE ''No'' END [Is Notification]
							*/
						FROM 
							process_risk_controls prc 
							LEFT join process_risk_description  prd 
							on prc.risk_description_id=prd.risk_description_id
                            LEFT OUTER JOIN process_control_header pch on pch.process_id= prd.process_id
							left outer join application_security_role asr on asr.role_id=prc.perform_role
							LEFT OUTER JOIN
									 application_security_role asrA ON prc.approve_role = asrA.role_id
							LEFT OUTER JOIN
									 static_data_value rf ON prc.run_frequency = rf.value_id
						   LEFT OUTER JOIN             
								 static_data_value ct ON ct.value_id = prc.control_type
						   LEFT OUTER  JOIN             
								 static_data_value ct1 ON ct1.value_id = prc.activity_category_id
						   LEFT OUTER JOIN             
								 static_data_value ct2 ON ct2.value_id = prc.control_objective
							LEFT OUTER  JOIN             
								 static_data_value ct3 ON ct3.value_id = prc.where_id
							LEFT OUTER  JOIN             
								 static_data_value ct4 ON ct4.value_id = prc.activity_area_id
							LEFT OUTER  JOIN             
								 static_data_value ct5 ON ct5.value_id = prc.activity_sub_area_id
							LEFT OUTER  JOIN             
								 static_data_value ct6 ON ct6.value_id = prc.activity_action_id
							LEFT OUTER JOIN             
								 static_data_value ct7 ON ct7.value_id = prc.monetary_value_frequency_id
							LEFT OUTER JOIN             
								 static_data_value ct8 ON ct8.value_id = prc.activity_who_for_id
							LEFT OUTER JOIN
								  portfolio_hierarchy ph ON ph.entity_id= prc.fas_book_id  
							
							
							where 1=1 '

/*										+ CASE WHEN @risk_description_id IS NOT NULL
											   THEN ' AND prc.risk_description_id='
													+ CAST(@risk_description_id AS VARCHAR)
											   ELSE ''
										  END	

*/						    
									IF @activity_category_id IS NOT NULL 
										SET @sql_stmt = @sql_stmt + 'and prc.activity_category_id='
											+ CAST(@activity_category_id AS VARCHAR)

						--print (@mitigation_Plan_required)
									IF @mitigation_Plan_required IS NOT NULL 
										SET @sql_stmt = @sql_stmt
											+ 'and prc.mitigation_Plan_required='''
											+ @mitigation_Plan_required + '''' 

						          IF @risk_description_id IS NOT NULL 
										SET @sql_stmt = @sql_stmt + 'and prc.risk_description_id='
											+ CAST(@risk_description_id AS VARCHAR)
								   
								   IF @fas_book_id IS NOT NULL 
										SET @sql_stmt = @sql_stmt + 'and ph.entity_id='
											+ CAST(@fas_book_id AS VARCHAR)
									IF @strategy_id IS NOT NULL 
										SET @sql_stmt = @sql_stmt + 'and ph.parent_entity_id='
											+ CAST(@strategy_id AS VARCHAR)
									

								   IF @process_id IS NOT NULL 
										SET @sql_stmt = @sql_stmt + 'and prd.process_id='
											+ CAST(@process_id AS VARCHAR)

									IF @temp_risk_control_id IS NOT NULL 
										SET @sql_stmt = @sql_stmt + 'and risk_control_id NOT IN ('
											+ @temp_risk_control_id + ') and risk_control_id NOT IN(SELECT risk_control_id
				  FROM process_risk_controls WHERE mitigationActivity IN(SELECT mitigationActivity
				  FROM process_risk_controls WHERE mitigationActivity IS NOT NULL))'
							
									SET @sql_stmt = @sql_stmt + '  ORDER BY [Activity] ASC'
									exec spa_print  @sql_stmt 
									EXEC ( @sql_stmt
										)
        END

    IF @flag = 'a' 
        BEGIN
            SET @sql_stmt = 'SELECT prc.risk_control_id,
                                    prd.process_id,
                                    prc.risk_description_id,
                                    prc.risk_control_description,
                                    prc.perform_role,
                                    prc.approve_role,
                                    prc.run_frequency,
                                    prc.control_type,
                                    prc.threshold_days,
                                    prc.requires_approval,
                                    prc.requires_proof,
                                    prc.control_objective,
                                    prc.internal_function_id,
                                    dbo.FNADateFormat(prc.run_date) AS run_date,
                                    prc.activity_category_id,
                                    prc.activity_who_for_id,
                                    dbo.FNADateFormat(prc.run_end_date) AS 
                                    run_end_date,
                                    prc.where_id,
                                    prc.activity_area_id,
                                    prc.activity_sub_area_id,
                                    prc.activity_action_id,
                                    prc.monetary_value,
                                    prc.monetary_value_frequency_id,
                                    prc.monetary_value_changes,
                                    prc.requires_approval_for_late,
                                    prc.fas_book_id,
                                    prc.requirements_revision_id,
                                    prc.mitigation_plan_required,
                                    dbo.fnadateformat(prc.run_effective_date),
                                    ph.entity_name,
                                    prr.requirements_url,
                                    prr.requirement_no,
                                    prc2.risk_control_description,
                                    prc2.threshold_days,
                                    prc2.run_frequency,
                                    dbo.FNADateFormat(prc2.run_date),
                                    dbo.FNADateFormat(prc2.run_effective_date),
                                    dbo.FNADateFormat(prc2.run_end_date),
                                    prc.frequency_type,
                                    prc.perform_user,
                                    prc.approve_user,
                                    prc.mitigationActivity 
                                    [MitigationActivityId],
                                    prc2.risk_control_description 
                                    [MitigationActivity],
                                    prc.triggerExists,
                                    prc.triggerActivity [TriggerActivityId],
                                    prc3.risk_control_description 
                                    [TriggerActivity],
                                    prc.notificationOnly,
                                    prc.working_days_value_id,
                                    prc.holiday_calendar_value_id,
                                    prc.no_of_days,
                                    prc.days_start_from,
                                    prc.activity_type,
                                    prc.action_type_on_approve,
                                    prc.action_label_on_approve,
                                    prc.action_type_on_complete,
                                    prc.action_label_on_complete,
                                    prc.action_type_secondary,
                                    prc.action_label_secondary,
                                    prc.document_template,
                                    prc.trigger_primary,
                                    prc.trigger_secondary
                             FROM   process_risk_controls prc
                             JOIN process_risk_description prd ON  prd.risk_description_id = prc.risk_description_id
                             LEFT JOIN portfolio_hierarchy ph ON  prc.fas_book_id = ph.entity_id
                             LEFT OUTER JOIN process_requirements_revisions prr ON  prr.requirements_revision_id = prc.requirements_revision_id
                             LEFT JOIN process_risk_controls prc2 ON  prc2.risk_control_id = prc.mitigationActivity
                             LEFT JOIN process_risk_controls prc3 ON  prc3.risk_control_id = prc.triggerActivity
                             WHERE  1 = 1'

            IF @risk_control_id IS NOT NULL 
                SET @sql_stmt = @sql_stmt + 'and prc.risk_control_id = ' + CAST(@risk_control_id AS VARCHAR)

            SET @sql_stmt = @sql_stmt + 'ORDER BY prc.risk_control_id'
            exec spa_print @sql_stmt 
            EXEC(@sql_stmt)
        END

    ELSE 
        IF @flag = 'i' 
            BEGIN
				BEGIN TRAN 
                INSERT  INTO dbo.process_risk_controls
                        (
                          risk_description_id,
                          risk_control_description,
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
                          fas_book_id,
                          requirements_revision_id,
                          mitigation_plan_required,
                          run_effective_date,
                          frequency_type,
                          perform_user,
                          approve_user,
						  triggerExists,
                          triggerActivity,
                          mitigationActivity,
                          notificationOnly,
						  working_days_value_id,
						  holiday_calendar_value_id,
						  no_of_days,
						  days_start_from,
						  activity_type, 
						  action_type_on_approve, 
						  action_label_on_approve,
						  action_type_on_complete, 
						  action_label_on_complete,
						  action_type_secondary, 
						  action_label_secondary,
						  document_template,
						  trigger_primary,
                          trigger_secondary
						)
                VALUES  (
                          @risk_description_id,
                          @risk_control_description,
                          @perform_role,
                          @approve_role,
                          @run_frequency,
                          --ISNULL(@control_type, 291327),
						  @control_type,
                          @threshold_days,
                          @requires_approval,
                          @requires_proof,
                          @control_objective,
                          @internal_function_id,
                          @run_date,
                          @activity_category_id,
                          @activity_who_for_id,
                          @run_end_date,
                          @where_id,
                          @activity_area_id,
                          @activity_sub_area_id,
                          @activity_action_id,
                          @monetary_value,
                          @monetary_value_frequency_id,
                          @monetary_value_changes,
                          @requires_approval_for_late,
                          @fas_book_id,
                          @requirements_revision_id,
                          @mitigation_plan_required,
                          @run_effective_date,
                          @frequency_type,
                          @perform_user,
                          @approve_user,
                          @triggerExists,
                          @triggerActivity,
                          @mitigationActivity,
                          @notificationOnly,
						  @working_days_value_id,
						  @holiday_calendar_value_id,
						  @no_of_days,
						  @days_start_from,
						  @activity_type,
						  @action_type_on_approve,
						  @action_label_on_approve,
						  @action_type_on_complete,
						  @action_label_on_complete,
						  @action_type_secondary,
						  @action_label_secondary,
						  @document_template,
						  @trigger_primary,
						  @trigger_secondary
                        )

                SET @risk_control_id = SCOPE_IDENTITY() 
    
                INSERT  INTO dbo.process_risk_controls_dependency
                        (
                          risk_control_id,
                          risk_control_id_depend_on,
                          risk_hierarchy_level
                        )
                VALUES  (
                          @risk_control_id,
                          NULL,
                          0
                        )
                        
--                 SELECT * FROM process_risk_controls WHERE risk_control_id = @risk_control_id
--                 
--                SELECT dbo.FNANextInstanceCreationDate(@risk_control_id) 
--				
				 
				SELECT @errorMsg = 
					CASE @frequency_type WHEN 'o' THEN 
						'The run date is invalid. Please make sure that the selected date is not a past date or does not fall on a holiday.'
					ELSE
						'The date range is invalid for the selected criteria.'
					END 

				IF dbo.FNANextInstanceCreationDate(@risk_control_id) IS NULL
				BEGIN
					
				        EXEC dbo.spa_ErrorHandler -1,
                        "Maintain Compliance Activity Detail",
                        "spa_process_risk_controls", "DB Error",
                        @errorMsg,
                        ''
						ROLLBACK TRAN 
				END				
				ELSE
				BEGIN
					IF @@ERROR <> 0 
					
						EXEC dbo.spa_ErrorHandler @@ERROR,
							"Maintain Compliance Activity Detail",
							"spa_process_risk_controls", "DB Error",
							"Insert of Maintain Compliance Activity Detail data failed.",
							''
					ELSE 
					BEGIN 
						EXEC dbo.spa_ErrorHandler 0,
							'Maintain Compliance Activity Detail',
							'spa_process_risk_controls', 'Success',
							'Activity saved succesfully.',
							@risk_control_id
						COMMIT TRAN
						
						
						
					END 
				END
            END

-----Added the flag 'c' for copying the new Process Risk Control  by Pawan KC Date:17/08/2008
        ELSE 
            IF @flag = 'c' 
                BEGIN
                    BEGIN TRAN 
                    DECLARE @tmp_risk_control_id INT
		
                    INSERT  INTO dbo.process_risk_controls
                            (
                              risk_description_id,
                              risk_control_description,
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
                              fas_book_id,
                              requirements_revision_id,
                              
                              run_effective_date,
                              frequency_type,
                              perform_user,
                              approve_user,
                              
							  
							  notificationOnly,
							  working_days_value_id,
							  holiday_calendar_value_id,
							  no_of_days,
							  days_start_from,
							  activity_type,
							  action_type_on_approve,
							  action_label_on_approve,
							  action_type_on_complete,
							  action_label_on_complete,
							  action_type_secondary,
							  action_label_secondary,
							  document_template,
							  trigger_primary,
                              trigger_secondary
							  	
                            )
                            SELECT  process_risk_controls.risk_description_id,
                                    'Copy of ' + process_risk_controls.risk_control_description,
                                    process_risk_controls.perform_role,
                                    process_risk_controls.approve_role,
                                    process_risk_controls.run_frequency,
                                    process_risk_controls.control_type,
                                    process_risk_controls.threshold_days,
                                    process_risk_controls.requires_approval,
                                    process_risk_controls.requires_proof,
                                    process_risk_controls.control_objective,
                                    process_risk_controls.internal_function_id,
                                    process_risk_controls.run_date,
                                    process_risk_controls.activity_category_id,
                                    process_risk_controls.activity_who_for_id,
                                    process_risk_controls.run_end_date,
                                    process_risk_controls.where_id,
                                    process_risk_controls.activity_area_id,
                                    process_risk_controls.activity_sub_area_id,
                                    process_risk_controls.activity_action_id,
                                    process_risk_controls.monetary_value,
                                    process_risk_controls.monetary_value_frequency_id,
                                    process_risk_controls.monetary_value_changes,
                                    process_risk_controls.requires_approval_for_late,
                                    process_risk_controls.fas_book_id,
                                    process_risk_controls.requirements_revision_id,
                                    
                                    process_risk_controls.run_effective_date,
                                    process_risk_controls.frequency_type,
                                    process_risk_controls.perform_user,
                                    process_risk_controls.approve_user,
									
									process_risk_controls.notificationOnly,
									process_risk_controls.working_days_value_id,
									process_risk_controls.holiday_calendar_value_id,
									process_risk_controls.no_of_days,
									process_risk_controls.days_start_from,
									process_risk_controls.activity_type,
									process_risk_controls.action_type_on_approve,
									process_risk_controls.action_label_on_approve,
									process_risk_controls.action_type_on_complete,
									process_risk_controls.action_label_on_complete,
									process_risk_controls.action_type_secondary,
									process_risk_controls.action_label_secondary,
									process_risk_controls.document_template,
									process_risk_controls.trigger_primary,
                                    process_risk_controls.trigger_secondary
							FROM    dbo.process_risk_controls
                            WHERE   process_risk_controls.risk_control_id = @risk_control_id

                    SET @tmp_risk_control_id = SCOPE_IDENTITY()
                    EXEC spa_print @tmp_risk_control_id

                   

				
                    INSERT  INTO dbo.process_risk_controls_steps
                            (
                              risk_control_id,
                              step_sequence,
                              step_desc1,
                              step_desc2,
                              step_reference
                            )
                            SELECT  @tmp_risk_control_id,
                                    process_risk_controls_steps.step_sequence,
                                    process_risk_controls_steps.step_desc1,
                                    process_risk_controls_steps.step_desc2,
                                    process_risk_controls_steps.step_reference
                            FROM    dbo.process_risk_controls_steps
                            WHERE   process_risk_controls_steps.risk_control_id = @risk_control_id

		
		
                    IF @@ERROR <> 0 
                        BEGIN
                            EXEC dbo.spa_ErrorHandler @@ERROR,
                                "Maintain Compliance Activity Detail",
                                "spa_process_risk_controls", "DB Error",
                                "Copying of Activity failed.",
                                ''
                            ROLLBACK TRAN 
                        END
                    ELSE 
                        BEGIN
--			
--                      
                                INSERT  INTO dbo.process_risk_controls_email
                                        (
                                          risk_control_id,
                                          control_status,
                                          inform_role,
                                          inform_user,
                                          communication_type,
                                          no_of_days
                                        )
                                        SELECT  @tmp_risk_control_id,
                                                process_risk_controls_email.control_status,
                                                process_risk_controls_email.inform_role,
                                                process_risk_controls_email.inform_user,
                                                process_risk_controls_email.communication_type,
                                                process_risk_controls_email.no_of_days
                                        FROM    dbo.process_risk_controls_email
                                        WHERE   process_risk_controls_email.risk_control_id = @risk_control_id
					
--                            IF @@ERROR <> 0 
--                                EXEC dbo.spa_ErrorHandler @@ERROR,
--                                    'Process Risk Control Email',
--                                    'spa_process_risk_controls', 'DB Error',
--                                    'Error Copying Process Risk Control Email.',
--                                    ''
--                            ELSE 
--                                EXEC dbo.spa_ErrorHandler 1,
--                                    'Process Risk Control Email',
--                                    'spa_process_risk_controls', 'Success',
--                                    'Process Risk Control Emai Detail Copied Successfully.',
--                                    @tmp_risk_control_id
						
                           -- COMMIT TRAN
                       -- END
                         
							INSERT  INTO dbo.process_risk_controls_dependency
                            (
                              risk_control_id,
                              risk_control_id_depend_on,
                              risk_hierarchy_level
                            )
                            VALUES  (
                              @tmp_risk_control_id,
                              NULL,
                              '0'
                            )
							 IF @@ERROR <> 0 
                                EXEC dbo.spa_ErrorHandler @@ERROR,
                                    'Maintain Compliance Activity',
                                    'spa_process_risk_controls', 'DB Error',
                                    'Error copying activity.',
                                    ''
                            ELSE 
                                EXEC dbo.spa_ErrorHandler 0,
                                    'Maintain Compliance Activity',
                                    'spa_process_risk_controls', 'Success',
                                    'Activity copied succesfully.',
                                    @tmp_risk_control_id
						
                            COMMIT TRAN
                        END			
		
                END
------
            ELSE 
                IF @flag = 'u' 
                BEGIN
					BEGIN TRAN 
					
					
					SELECT @run_date_tmp = run_date 
						FROM dbo.process_risk_controls 
							WHERE process_risk_controls.risk_control_id = @risk_control_id

                    UPDATE  dbo.process_risk_controls
                    SET     process_risk_controls.risk_description_id = @risk_description_id,
                            process_risk_controls.risk_control_description = @risk_control_description,
                            process_risk_controls.perform_role = @perform_role,
                            process_risk_controls.approve_role = @approve_role,
                            process_risk_controls.run_frequency = @run_frequency,
                            process_risk_controls.control_type = @control_type, --ISNULL(@control_type, 291327),
                            process_risk_controls.threshold_days = @threshold_days,
                            process_risk_controls.requires_approval = @requires_approval,
                            process_risk_controls.requires_proof = @requires_proof,
                            process_risk_controls.control_objective = @control_objective,
                            process_risk_controls.internal_function_id = @internal_function_id,
                            process_risk_controls.run_date = @run_date,
                            process_risk_controls.activity_category_id = @activity_category_id,
                            process_risk_controls.activity_who_for_id = @activity_who_for_id,
                            process_risk_controls.run_end_date = @run_end_date,
                            process_risk_controls.where_id = @where_id,
                            process_risk_controls.activity_area_id = @activity_area_id,
                            process_risk_controls.activity_sub_area_id = @activity_sub_area_id,
                            process_risk_controls.activity_action_id = @activity_action_id,
                            process_risk_controls.monetary_value = @monetary_value,
                            process_risk_controls.monetary_value_frequency_id = @monetary_value_frequency_id,
                            process_risk_controls.monetary_value_changes = @monetary_value_changes,
                            process_risk_controls.requires_approval_for_late = @requires_approval_for_late,
                            process_risk_controls.fas_book_id = @fas_book_id,
                            process_risk_controls.requirements_revision_id = @requirements_revision_id,
                            process_risk_controls.mitigation_plan_required = @mitigation_plan_required,
                            process_risk_controls.run_effective_date = @run_effective_date,
                            dbo.process_risk_controls.frequency_type = @frequency_type,
                            process_risk_controls.perform_user = @perform_user,
                            process_risk_controls.approve_user = @approve_user,
                            process_risk_controls.triggerExists = @triggerExists,
							process_risk_controls.triggerActivity = @triggerActivity,
							process_risk_controls.mitigationActivity = @mitigationActivity,
							process_risk_controls.notificationOnly = @notificationOnly,
							process_risk_controls.working_days_value_id =@working_days_value_id,
							process_risk_controls.holiday_calendar_value_id=@holiday_calendar_value_id,
							process_risk_controls.no_of_days = @no_of_days,
							process_risk_controls.days_start_from = @days_start_from,
							action_type_on_approve = @action_type_on_approve,
							action_label_on_approve = @action_label_on_approve,
							action_type_on_complete = @action_type_on_complete,
							action_label_on_complete = @action_label_on_complete,
							action_type_secondary = @action_type_secondary,
							action_label_secondary = @action_label_secondary,
							document_template = @document_template,
							trigger_primary = @trigger_primary,
							trigger_secondary = @trigger_secondary
							
						
                    WHERE   process_risk_controls.risk_control_id = @risk_control_id
						
					SELECT @error = @@ERROR
					
																				
					SELECT @errorMsg =
						CASE @frequency_type WHEN 'o' THEN 'Instance exists for this activity. Failed to update.'					
							ELSE 'The date range is invalid for the selected criteria.' END					

					IF @run_end_date<@run_effective_date						
						SELECT @errorExists = 'y'
																					
					IF EXISTS (SELECT 'x' FROM dbo.process_risk_controls_activities WHERE risk_control_id = @risk_control_id)
					BEGIN
					
						IF (@frequency_type = 'o')  AND (dbo.FNAGetSQLStandardDate(@run_date)<>dbo.FNAGetSQLStandardDate(@run_date_tmp))		
								SELECT @errorExists = 'y'							

						SELECT @lastInstanceDate_MAX = MAX(actualRunDate)
							FROM dbo.process_risk_controls_activities (nolock)
								WHERE risk_control_id = @risk_control_id

						SELECT @lastInstanceDate_MIN = MIN(actualRunDate)
							FROM dbo.process_risk_controls_activities (nolock)
								WHERE risk_control_id = @risk_control_id
						
						IF (@run_effective_date > @lastInstanceDate_MIN) OR (@run_end_date < @lastInstanceDate_MAX)					  	
							SELECT @errorExists = 'y'
					END
					ELSE
					BEGIN							
						IF dbo.FNANextInstanceCreationDate(@risk_control_id) IS NULL
							SELECT @errorExists = 'y'

						IF @frequency_type = 'o' 
								SELECT @errorMsg = 'The run date is invalid. Please make sure that the selected date is not a past date or does not fall on a holiday.'
					END
										
					IF @error <> 0 
						EXEC dbo.spa_ErrorHandler @error ,
							"Maintain Compliance Activity Detail",
							"spa_process_risk_controls", "DB Error",
							"Update of Maintain Compliance Activity Detail data failed.",
							''
					ELSE	
					BEGIN							
						IF @errorExists = 'y'
						BEGIN
							EXEC dbo.spa_ErrorHandler -1,
							"Maintain Compliance Activity Detail",
							"spa_process_risk_controls", "DB Error",
							@errorMsg,
							''
							ROLLBACK TRAN
						END
						ELSE
						BEGIN
							EXEC dbo.spa_ErrorHandler 0,
								'Maintain Compliance Activity Detail',
								'spa_process_risk_controls', 'Success',
								'Activity saved succesfully.',
								''			
							COMMIT TRAN 
						END
					END				
                END
                ELSE 
                IF @flag = 'd' 
				BEGIN
					BEGIN TRY							
						BEGIN TRAN
						   DECLARE @msg VARCHAr(1000)
																																					
							SELECT @msg = 'Delete of Process Risk Control Reminders data failed.'
							DELETE  FROM dbo.process_risk_controls_reminders
							WHERE   process_risk_controls_reminders.risk_control_id = @risk_control_id

							SELECT @msg = 'Delete of Process Risk Control Email data failed.'
							DELETE  FROM dbo.process_risk_controls_email
						    WHERE   process_risk_controls_email.risk_control_id = @risk_control_id

							-- Delete the steps under the Activity
							SELECT @msg = 'Deletion Failed.'
							DELETE FROM dbo.process_risk_controls_steps
							WHERE risk_control_id = @risk_control_id

							-- Delete the dependent activity
							SELECT @msg = 'Dependent activity exists.Deletion failed.'	

							IF NOT EXISTS(SELECT 'x' FROM dbo.process_risk_controls_dependency WHERE risk_control_id_depend_on IN (Select risk_control_dependency_id from process_risk_controls_dependency where risk_control_id= @risk_control_id))
							BEGIN
							/* If the activity has not been referred by any other activity, delete the entry of that activity from the 
							  process_risk_controls_dependency. On creation of every activity an entry is made to this table with the 
							  risk_control_id_depend_on as NULL*/
								DELETE FROM process_risk_controls_dependency 
								WHERE risk_control_id = @risk_control_id AND risk_control_id_depend_on IS NULL
							END

							DELETE  dbo.process_risk_controls
							WHERE   process_risk_controls.risk_control_id = @risk_control_id
							
							COMMIT TRAN

							EXEC dbo.spa_ErrorHandler 0,
                                'Maintain Compliance Activity Detail',
                                'spa_process_risk_controls',
                                'Success',
                                'Activity deleted successfully.',''
					END TRY
					BEGIN CATCH

							EXEC dbo.spa_ErrorHandler -1,
                            '',
                            "spa_process_risk_controls",
                            "DB Error",
                            @msg,''

							ROLLBACK TRAN										
					END CATCH				
			END


                    ELSE 
                        IF @flag = 'p' 
                            BEGIN

                                SET @sql_stmt = 'SELECT risk_control_id [ID],
                            prc.risk_control_description [Activity],
                            asr.role_name [Perform Role],
                            asrA.role_name  [Approve Role],
                            rf.code [Frequency],
                            ct.code [Control Type],
	                        threshold_days [Threshold Days],
                            case when (requires_approval = ''n'') then  ''No'' else ''Yes'' end [Requires Approval],
                            case when (requires_proof = ''n'') then ''No'' else ''Yes'' end [Requires Proof],
                            ct2.code [Control Objective],
                            ph.entity_name [Book Name],
                            dbo.FNADateFormat(run_date) [Run Date],
	                        ct1.code [Activity Category],
                            prc.activity_who_for_id[Who for ID],
                            dbo.FNADateFormat(run_end_date) as run_end_date, 
							ct3.code [Where], ct4.code [Activity Area],ct5.code [Activity Sub Area],
							ct6.code [Activity Action], monetary_value [Momentary Value],ct7.code [Monetary Value Frequency] , 
							case when (monetary_value_changes = ''n'') then  ''No'' else ''Yes'' end [Monetary Value],
							case when (requires_approval_for_late = ''n'') then ''No'' else ''Yes'' end [Requires Approval For Late]
FROM 
	process_risk_controls prc join process_risk_description  prd 
	on prc.risk_description_id=prd.risk_description_id
	left outer join application_security_role asr on asr.role_id=prc.perform_role
    left outer JOIN
             application_security_role asrA ON prc.approve_role = asrA.role_id
    LEFT OUTER JOIN
             static_data_value rf ON prc.run_frequency = rf.value_id
	LEft OUTER JOIN
             static_data_value rf1 ON  prc.activity_who_for_id=rf1.value_id
    LEft OUTER JOIN             
	     static_data_value ct ON ct.value_id = prc.control_type
	LEft OUTER JOIN
          portfolio_hierarchy ph ON ph.entity_id= prc.fas_book_id 
	LEft OUTER JOIN             
	     static_data_value ct1 ON ct1.value_id = prc.activity_category_id
    LEft OUTER JOIN             
	     static_data_value ct2 ON ct2.value_id = prc.control_objective
    LEft OUTER JOIN             
	     static_data_value ct3 ON ct3.value_id = prc.where_id
    LEft OUTER JOIN             
	     static_data_value ct4 ON ct4.value_id = prc.activity_area_id
    LEft OUTER JOIN             
	     static_data_value ct5 ON ct5.value_id = prc.activity_sub_area_id
    LEft OUTER JOIN             
	     static_data_value ct6 ON ct6.value_id = prc.activity_action_id
    LEft OUTER JOIN             
	     static_data_value ct7 ON ct7.value_id = prc.monetary_value_frequency_id
	
	where 1=1 
     '
     
--     SET @sql_stmt = @sql_stmt + ' AND ISNULL(prc.perform_user,'''') = 
--						CASE WHEN prc.perform_user IS NOT NULL THEN ''' + CAST(@user_name AS VARCHAR) + ''' ELSE '''' END '
						
                                IF @activity_category_id IS NOT NULL 
                                    SET @sql_stmt = @sql_stmt
                                        + 'and prc.activity_category_id='
                                        + CAST(@activity_category_id AS VARCHAR)

									IF @risk_description_id IS NOT NULL 
										SET @sql_stmt = @sql_stmt + 'and prc.risk_description_id='
											+ CAST(@risk_description_id AS VARCHAR)
								   
								   IF @fas_book_id IS NOT NULL 
										SET @sql_stmt = @sql_stmt + 'and ph.entity_id='
											+ CAST(@fas_book_id AS VARCHAR)
									IF @strategy_id IS NOT NULL 
										SET @sql_stmt = @sql_stmt + 'and ph.parent_entity_id='
											+ CAST(@strategy_id AS VARCHAR)
									

								   IF @process_id IS NOT NULL 
										SET @sql_stmt = @sql_stmt + 'and prd.process_id='
											+ CAST(@process_id AS VARCHAR)

                                IF @risk_control_id IS NOT NULL 
                                    SET @sql_stmt = @sql_stmt
                                        + 'and  prc.fas_book_id in 
     (select fas_book_id from  process_risk_controls where  risk_control_id
     =' + CAST(@risk_control_id AS VARCHAR)
                                        + ') and prc.activity_who_for_id in 
      (select activity_who_for_id from  process_risk_controls where  risk_control_id
     =' + CAST(@risk_control_id AS VARCHAR) + ') '

                                SET @sql_stmt = @sql_stmt + '
	and risk_control_id NOT IN (' + @temp_risk_control_id + ')'
                                    + CASE WHEN @risk_description_id IS NOT NULL
                                           THEN ' AND prc.risk_description_id='
                                                + CAST(@risk_description_id AS VARCHAR)
                                           ELSE ''
                                      END	

                                SET @sql_stmt = @sql_stmt
                                    + ' and risk_control_id IN(select distinct prcd0.risk_control_id from process_risk_controls_dependency prcd0
							where prcd0.risk_control_id not in 
							(
								select prcd.risk_control_id  
								from process_risk_controls_dependency  prcd 
								inner join process_risk_controls_dependency  prcd1  
								on prcd.risk_control_dependency_id=prcd1.risk_control_id_depend_on 

								union

								select prcd1.risk_control_id  
								from process_risk_controls_dependency  prcd 
								inner join process_risk_controls_dependency  prcd1  
								on prcd.risk_control_dependency_id=prcd1.risk_control_id_depend_on 
							)

							and prcd0.risk_control_id_depend_on is null) '
                                SET @sql_stmt = @sql_stmt
                                    + 'ORDER BY prc.risk_control_description'

  
                                exec spa_print  @sql_stmt 
                                EXEC ( @sql_stmt
                                    )

                            END









