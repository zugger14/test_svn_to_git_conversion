IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_update_and_get_unprocessed_partition_id]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].spa_update_and_get_unprocessed_partition_id
GO
-- ===============================================================================================================  
-- Create date: 20111-02-04 05:00PM  
-- Description: Updates partition_log table and returns one unprocessed partition_id  
-- Params:  
-- ===============================================================================================================  
CREATE PROCEDURE dbo.spa_update_and_get_unprocessed_partition_id  
 @table_name VARCHAR(150),  
 @partition_id INT OUTPUT  
AS  
BEGIN  
 SET NOCOUNT ON;  
   
 CREATE TABLE #tmp_partition (partition_id INT)  
   
 UPDATE TOP(1) dbo.log_partition WITH (ROWLOCK)   
 SET start_time = GETDATE()  
    OUTPUT INSERTED.partition_id INTO #tmp_partition  
 WHERE start_time IS NULL AND tbl_name = @table_name  
   
 SELECT @partition_id = partition_id FROM #tmp_partition  
  
END  