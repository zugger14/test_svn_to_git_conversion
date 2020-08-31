if object_id('[dbo].[spa_get_import_process_status_from_ass_log]') IS NOT NULL
	DROP PROC [dbo].[spa_get_import_process_status_from_ass_log]
go

CREATE PROCEDURE [dbo].[spa_get_import_process_status_from_ass_log] @process_id varchar(50)
AS
exec spa_get_eff_ass_test_run_log @process_id 