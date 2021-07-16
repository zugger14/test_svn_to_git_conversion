
IF NOT EXISTS (SELECT 1  FROM sys.indexes  
               WHERE name='IX_optimizer_detail_hour_hr' 
                 AND object_id = OBJECT_ID('[dbo].[optimizer_detail_hour]'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_optimizer_detail_hour_hr
		ON [dbo].optimizer_detail_hour ([hr],[flow_date],[up_down_stream],[source_deal_detail_id]) 
		INCLUDE ([volume_used])


END

IF NOT EXISTS (SELECT 1  FROM sys.indexes  
               WHERE name='IX_optimizer_detail_flow' 
                 AND object_id = OBJECT_ID('[dbo].[optimizer_detail]'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_optimizer_detail_flow
	ON [dbo].[optimizer_detail] ([flow_date],[up_down_stream],[source_deal_detail_id])

END

IF NOT EXISTS (SELECT 1  FROM sys.indexes  
               WHERE name='IX_optimizer_detail_downstream_hour_hr' 
                 AND object_id = OBJECT_ID('[dbo].[optimizer_detail_downstream_hour]'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_optimizer_detail_downstream_hour_hr
	ON [dbo].[optimizer_detail_downstream_hour] ([hr],[flow_date],[source_deal_detail_id])
	INCLUDE ([deal_volume])
END
GO


