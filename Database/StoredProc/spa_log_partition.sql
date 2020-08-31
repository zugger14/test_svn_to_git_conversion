IF OBJECT_ID(N'dbo.spa_log_partition', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_log_partition]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================================================================
-- Create date: 2011-02-15 02:37PM
-- Description:	Data interaction with log_partition table
-- Params:
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_log_partition]
	@flag CHAR(1),
	@table_name VARCHAR(150) = NULL,
	@partition_id INT = NULL,
	@data_found BIT = NULL,
	@EANNos VARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF @flag = 'u'
	--Updates partition_log table to mark end of processing of one partition (loading to staging table)
	BEGIN
		UPDATE dbo.log_partition WITH (TABLOCK) 
		SET end_time = GETDATE(), data_found_status = @data_found
		WHERE partition_id = @partition_id AND tbl_name = @table_name
	END
	ELSE IF @flag = 'e' --get partition id for given EAN nos.
	BEGIN
		SELECT scsv.Item AS EANNo, fp.profile_id, partition_id, partition_from, partition_to, lg.start_time, lg.end_time, lg.process_id, lg.tbl_name, lg.data_found_status
		FROM dbo.log_partition lg
		INNER JOIN forecast_profile fp ON fp.profile_id BETWEEN lg.partition_from AND lg.partition_to
		INNER JOIN dbo.SplitCommaSeperatedValues(@EANNos) scsv ON scsv.Item = fp.external_id
		WHERE tbl_name = @table_name
		ORDER BY lg.partition_id
	END
	
END
GO