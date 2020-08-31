IF EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[transportation_rate_schedule]') 
					AND name = N'IDX_transportation_rate_schedule')
 
BEGIN
	DROP INDEX IDX_transportation_rate_schedule ON dbo.transportation_rate_schedule
	CREATE UNIQUE INDEX IDX_transportation_rate_schedule ON transportation_rate_schedule(rate_type_id, effective_date,rate_schedule_id)
END
