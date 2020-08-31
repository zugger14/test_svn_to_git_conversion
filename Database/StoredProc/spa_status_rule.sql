IF OBJECT_ID(N'[dbo].[spa_status_rule]', N'P') IS NOT NULL
DROP PROC [dbo].[spa_status_rule]
GO

CREATE PROC [dbo].[spa_status_rule]
@flag VARCHAR(1),
@type_id INT = null

AS

IF @flag = 's'
BEGIN
	SELECT status_rule_id,status_rule_name FROM status_rule_header WHERE status_rule_type = @type_id

END

IF @flag = 'b'
BEGIN
	SELECT srd.status_rule_detail_id,sdv.code FROM status_rule_header srh INNER JOIN status_rule_detail srd
	ON srh.status_rule_id = srd.status_rule_id 
	INNER JOIN static_data_value sdv ON sdv.value_id = srd.event_id

END

