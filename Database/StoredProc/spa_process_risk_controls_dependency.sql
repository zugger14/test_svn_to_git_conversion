IF OBJECT_ID('[dbo].[spa_process_risk_controls_dependency]','p') IS NOT NULL
DROP PROC [dbo].[spa_process_risk_controls_dependency]
GO
CREATE PROCEDURE [dbo].[spa_process_risk_controls_dependency]
@flag varchar(1)=NULL,
@risk_control_dependency_id int=NULL,
@risk_control_id int=NULL,
@risk_control_id_depend_on int=NULL,
@risk_hierarchy_level int=NULL,
@parent_risk_control_dependency_id int=NULL


AS
DECLARE @tmp_hierarchy_level INT
DECLARE @error INT
SELECT @error = 0

IF @flag='i'
BEGIN
	
		
	SELECT @tmp_hierarchy_level=risk_hierarchy_level FROM process_risk_controls_dependency
	WHERE risk_control_dependency_id=@risk_control_id_depend_on
	 
	
		
	set @tmp_hierarchy_level=@tmp_hierarchy_level+1
	EXEC spa_print @tmp_hierarchy_level

	INSERT INTO process_risk_controls_dependency
		(risk_control_id,risk_control_id_depend_on,risk_hierarchy_level)
	VALUES
		(@risk_control_id,@risk_control_id_depend_on,@tmp_hierarchy_level)

	If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "process_risk_controls_dependency", 
					"spa_process_risk_controls_dependency", "DB Error", 
					"Insert of Process Risk rontrols Dependency Failed.", ''
	else
			Exec spa_ErrorHandler 0, 'process_risk_controls_dependency', 
					'spa_process_risk_controls_dependency', 'Success', 
					'Process Risk rontrols Dependency successfully Inserted', ''
END
/*
ELSE IF @flag='u'
	BEGIN
					
			SELECT @tmp_hierarchy_level=risk_hierarchy_level FROM process_risk_controls_dependency
			WHERE risk_control_dependency_id=@risk_control_id_depend_on
			
			set @tmp_hierarchy_level=@tmp_hierarchy_level+1
			
			EXEC spa_print @tmp_hierarchy_level
		
			UPDATE process_risk_controls_dependency
			SET
					risk_control_id=@risk_control_id,
					risk_control_id_depend_on=@risk_control_id_depend_on,
					risk_hierarchy_level=@tmp_hierarchy_level
								
			WHERE risk_control_dependency_id=@risk_control_dependency_id 
			
			If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "process_risk_controls_dependency", 
					"spa_process_risk_controls_dependency", "DB Error", 
					"Update of Process Risk rontrols Dependency Failed.", ''
			else
			Exec spa_ErrorHandler 0, 'process_risk_controls_dependency', 
					'spa_process_risk_controls_dependency', 'Success', 
					'Process Risk rontrols Dependency successfully Updated', ''
				
	END
*/
ELSE IF @flag='d'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			DELETE FROM process_risk_controls_dependency 
				WHERE risk_control_dependency_id=@risk_control_dependency_id
		COMMIT
	END TRY
	BEGIN CATCH	
		SELECT @error = @@ERROR 
		ROLLBACK							
	END CATCH	
	
	IF @error <> 0
		EXEC spa_ErrorHandler 1, 'Dependent activity exists! Please delete the dependent Activity first.', 
				'spa_process_risk_controls_dependency', 'DB Error', 
				'Dependency exists for the activity. Deletion Failed.', ''
	ELSE
		EXEC spa_ErrorHandler 0, 'process_risk_controls_dependency', 
				'spa_process_risk_controls_dependency', 'Success', 
				'Dependency successfully deleted', ''	
END




