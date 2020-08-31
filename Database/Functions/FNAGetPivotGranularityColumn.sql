IF  OBJECT_ID('FNAGetPivotGranularityColumn') IS NOT NULL
    DROP FUNCTION [dbo].[FNAGetPivotGranularityColumn]
GO 

 /**
	Breaksdown the input date range based on the input granularity

	Parameters :
	@term_start : Term Start
	@term_end : Term End
	@granularity : Granularity (Static Data - Type ID = 978)
	@dst_group_value_id : Dst Group Value Id (102200)

	Returns table will term breakdown based in input granularity
 */

CREATE FUNCTION [dbo].[FNAGetPivotGranularityColumn](
	@term_start datetime
	,@term_end  datetime
	,@granularity int=982
	,@dst_group_value_id int =102200
)
returns TABLE
AS	
	RETURN (SELECT * FROM dbo.FNAGetDisplacedPivotGranularityColumn(@term_start,@term_end,@granularity,@dst_group_value_id,0))
		



