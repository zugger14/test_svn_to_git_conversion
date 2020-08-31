IF EXISTS (SELECT name from sys.indexes  
           WHERE name = N'IDX_transportation_rate_schedule')   
  DROP INDEX IDX_transportation_rate_schedule ON transportation_rate_schedule
GO
 
CREATE UNIQUE INDEX IDX_transportation_rate_schedule   
   ON transportation_rate_schedule (rate_type_id, effective_date, rate_schedule_id, rate_schedule_type, begin_date, end_date) 
GO