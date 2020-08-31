IF OBJECT_ID(N'[dbo].[FNAREscalation]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAREscalation]
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================================================
-- Author: navaraj@pioneersolutionsglobal.com
-- Create date: 2014-09-02
-- Description: Function to calculate escalation value using deal_escalation and deal_actual tables
 
-- Params:
-- returns FLOAT Escalation value
-- ===========================================================================================================

CREATE  FUNCTION [dbo].[FNAREscalation] (
	@source_deal_detail_id		INT, 
	@quality					INT
)
RETURNS FLOAT AS
BEGIN	
	DECLARE @return_value	FLOAT
	
	SELECT @return_value = [escalation_value]
	FROM (
		SELECT 
			CASE WHEN daq.value < de.range_from  AND de.operator = 37902 THEN de.cost_increment
			ELSE
				CASE WHEN daq.value > de.range_from  AND de.operator = 37903 THEN de.cost_increment
				ELSE
					CASE WHEN (daq.value BETWEEN de.range_from AND de.range_to) AND de.operator = 37901
					THEN 
						CASE WHEN de.reference = 38100 THEN ABS((de.range_to - daq.value) / de.increment) * de.cost_increment
						ELSE ABS((daq.value - de.range_from) / de.increment) * de.cost_increment
						END				
					END
				END
			END [escalation_value]						
		FROM [dbo].[deal_escalation] de
		INNER JOIN [dbo].[deal_actual_quality] daq ON daq.source_deal_detail_id = de.source_deal_detail_id
			AND daq.quality = de.quality
		WHERE de.source_deal_detail_id = @source_deal_detail_id
		AND de.quality = @quality
	) esc_val
	WHERE [esc_val].escalation_value IS NOT NULL	
 	
	RETURN @return_value
END
GO