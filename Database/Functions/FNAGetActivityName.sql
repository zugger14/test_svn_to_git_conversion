IF OBJECT_ID(N'FNAGetActivityName', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAGetActivityName]
GO 

CREATE FUNCTION [dbo].[FNAGetActivityName]
(
	@risk_control_id INT
)
RETURNS VARCHAR(250)
AS
BEGIN

DECLARE @control_activity varchar(250)

SELECT @control_activity = 
	isnull(area.code + ' > ', '') + isnull(sarea.code + ' > ', '')  + 
		isnull([action].code, '') +
		isnull(' > ' + prc.risk_control_description, '')  

FROM process_risk_controls prc  LEFT OUTER JOIN
static_data_value area on area.value_id = prc.activity_area_id LEFT OUTER JOIN
static_data_value sarea on sarea.value_id = prc.activity_sub_area_id LEFT OUTER JOIN
static_data_value [action] on [action].value_id = prc.activity_action_id 

WHERE risk_control_id = @risk_control_id

RETURN isnull(@control_activity, 'UNKNOWN ACTIVITY')

END