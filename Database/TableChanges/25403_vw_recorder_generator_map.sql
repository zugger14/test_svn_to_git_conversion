IF OBJECT_ID('[dbo].[vw_recorder_generator_map]') IS NOT NULL
    DROP VIEW [dbo].[vw_recorder_generator_map]
GO
/**
	
*/
CREATE VIEW [dbo].[vw_recorder_generator_map]
AS

	SELECT rgm.id, 
		rgm.generator_id, 
		rgm.meter_id,
		rgm.effective_date,
		mi.recorderid recorder_id, 
		rgm.allocation_per, 
		rgm.from_vol, 
		rgm.to_vol
	FROM recorder_generator_map rgm
	LEFT JOIN meter_id mi 
		ON mi.meter_id = rgm.meter_id
GO


