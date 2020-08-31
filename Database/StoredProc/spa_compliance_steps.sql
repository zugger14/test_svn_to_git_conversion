
IF OBJECT_ID('[dbo].[spa_compliance_steps]', 'p') IS NOT NULL
    DROP PROC [dbo].[spa_compliance_steps]
GO

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



--exec spa_compliance_steps 'i',NULL,935,7


--DROP proc [dbo].[spa_compliance_steps]
/*
 exec spa_compliance_steps 'u',6, 32,1
 
 	SELECT risk_control_step_id FROM process_risk_controls_steps 
     where risk_control_step_id != 6 and  step_sequence=1
     select * from process_risk_controls_steps

 
*/


CREATE PROC [dbo].[spa_compliance_steps]	@flag AS CHAR(1),
                        @risk_control_step_id INT = NULL,
                        @risk_control_id INT = NULL,
                        @step_sequence INT = NULL,
						@step_desc1 VARCHAR(250) = NULL,
                        @step_desc2 VARCHAR(250) = NULL,
						@step_reference VARCHAR(100) = NULL,				
						@user_name VARCHAR(50) = NULL
AS 


SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET NOCOUNT ON
SET CONCAT_NULL_YIELDS_NULL ON



DECLARE @sql                  VARCHAR(5000)
DECLARE @tmp_risk_control_id  INT



IF @flag = 'i'
BEGIN
    SELECT @tmp_risk_control_id = risk_control_id
    FROM   process_risk_controls_steps
    WHERE  risk_control_id = @risk_control_id
           AND step_sequence = @step_sequence
    
    IF (@tmp_risk_control_id IS NOT NULL)
    BEGIN
        EXEC spa_ErrorHandler 1,
             'Sequence number already exists.',
             'spa_compliance_steps',
             'DB Error',
             'Sequence must be unique.',
             ''
    END
    ELSE
    BEGIN
        INSERT INTO process_risk_controls_steps
          (
            risk_control_id,
            step_sequence,
            step_desc1,
            step_desc2,
            step_reference,
            create_user,
            create_ts,
            update_user,
            update_ts
          )
        VALUES
          (
            @risk_control_id,
            @step_sequence,
            @step_desc1,
            @step_desc2,
            @step_reference,
            @user_name,
            GETDATE(),
            @user_name,
            GETDATE()
          )
        
        IF @@Error <> 0
            EXEC spa_ErrorHandler @@Error,
                 'EmissionSourceModel',
                 'spa_ems_source_model_program',
                 'DB Error',
                 'Failed to insert definition value.',
                 ''
        ELSE
            EXEC spa_ErrorHandler 0,
                 'EmissionSourceModel',
                 'spa_ems_source_model_program',
                 'Success',
                 'Definition data value inserted.',
                 ''
    END
END

IF @flag = 'u'
BEGIN
    SELECT @tmp_risk_control_id = risk_control_step_id
    FROM   process_risk_controls_steps
    WHERE  risk_control_step_id != @risk_control_step_id
           AND risk_control_id = @risk_control_id
           AND step_sequence = @step_sequence 
    
    
    IF (@tmp_risk_control_id IS NOT NULL)
    BEGIN
        EXEC spa_ErrorHandler 1,
             'Sequence number already exists.',
             'spa_compliance_steps',
             'DB Error',
             'Sequence number already exists.',
             ''
    END
    ELSE
    BEGIN
        UPDATE process_risk_controls_steps
        SET    risk_control_id = @risk_control_id,
               step_sequence = @step_sequence,
               step_desc1 = @step_desc1,
               step_desc2 = @step_desc2,
               step_reference = @step_reference,
               create_user = @user_name,
               create_ts = GETDATE(),
               update_user = @user_name,
               update_ts = GETDATE()
        WHERE  risk_control_step_id = CAST(@risk_control_step_id AS VARCHAR)
        
        IF @@Error <> 0
            EXEC spa_ErrorHandler @@Error,
                 'EmissionSourceModel',
                 'spa_ems_source_model_program',
                 'DB Error',
                 'Failed to update definition value.',
                 ''
        ELSE
            EXEC spa_ErrorHandler 0,
                 'EmissionSourceModel',
                 'spa_ems_source_model_program',
                 'Success',
                 'Definition data value updated.',
                 ''
    END
END


IF @flag = 's'
BEGIN
    SET @sql = 
        '	select risk_control_step_id [Risk Control Step Id],
				DBO.FNAGetActivityName(risk_control_id) [Control Activities],								
				step_sequence [Step Sequence],
				step_desc1 [Step Desc 1],
				step_desc2 [Step Desc 2],
				step_reference,
				create_user [Create User],
				create_ts [Created],
				update_user [Update User],
				update_ts [Updated] from process_risk_controls_steps where 1=1 '
    
    IF (@risk_control_step_id IS NOT NULL)
        SET @sql = @sql + ' AND risk_control_step_id =' + CAST(@risk_control_step_id AS VARCHAR)
    
    IF (@risk_control_id IS NOT NULL)
        SET @sql = @sql + ' AND risk_control_id =' + CAST(@risk_control_id AS VARCHAR)
    
    EXEC (@sql)
END

IF @flag = 'a'
BEGIN
    SET @sql = 
        '	select risk_control_step_id [Risk Control Step Id],				
				risk_control_id [Control Activities],
				step_sequence [Step Sequence],
				step_desc1 [Step Desc 1],
				step_desc2 [Step Desc 2],
				step_reference,
				create_user [Create User],
				create_ts [Created],
				update_user [Update User],
				update_ts [Updated] from process_risk_controls_steps where 1=1 '
    
    IF (@risk_control_step_id IS NOT NULL)
        SET @sql = @sql + ' AND risk_control_step_id =' + CAST(@risk_control_step_id AS VARCHAR)    
    
    EXEC (@sql)
END


IF @flag = 'd'
BEGIN
    DELETE 
    FROM   process_risk_controls_steps
    WHERE  risk_control_step_id = CAST(@risk_control_step_id AS VARCHAR)
    
    IF @@Error <> 0
        EXEC spa_ErrorHandler @@Error,
             'Compliance Activity Steps',
             'spa_compliance_steps',
             'DB Error',
             'Failed to delete compliance activity step.',
             ''
    ELSE
        EXEC spa_ErrorHandler 0,
             'Compliance Activity Steps',
             'spa_compliance_steps',
             'Success',
             'Compliance activity step deleted.',
             ''
END