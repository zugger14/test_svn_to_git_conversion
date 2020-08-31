if NOT EXISTS(SELECT 'X' FROM workflow_schedule_task WHERE [id]=-999)
BEGIN
	set identity_insert workflow_schedule_task ON
	insert into workflow_schedule_task([id],text,start_date,workflow_id_type,system_defined)
	SELECT -999,'Internal','2015-01-01',0,3
END