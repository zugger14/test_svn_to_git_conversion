IF OBJECT_ID(N'[dbo].[spa_storage]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_storage]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: Dewanand Manandhar
-- Create date: 2018-05-01
-- Description: Returns back only storage location from group of locations.
 
-- Params:
-- @location_id VARCHAR(3000) 

-- ===============================================================================================================

CREATE PROCEDURE [dbo].[spa_storage]
    @location_id VARCHAR(3000)
AS
SET NOCOUNT ON
/* test 
SET NOCOUNT ON
DECLARE @location_id VARCHAR(3000) = '2687,1567,1337,2687,1605,1611,1312,2679,2651,2637'
--*/
DECLARE @storage_location_id VARCHAR(3000)
DECLARE @storage_group_id INT
SELECT  @storage_location_id = ISNULL(@storage_location_id + ',', '') +  CAST(a.source_minor_location_id AS VARCHAR(10)), @storage_group_id = a.source_major_location_ID
FROM (
	SELECT DISTINCT sml.source_minor_location_id, sml.source_major_location_ID
	FROM dbo.SplitCommaSeperatedValues(@location_id) t
	INNER JOIN source_minor_location sml
		ON t.item = sml.source_minor_location_id
	INNER JOIN source_major_location smj
		ON sml.source_major_location_ID = smj.source_major_location_ID
	WHERE smj.location_name = 'Storage'
) a


DECLARE @pool_location_id VARCHAR(3000)
DECLARE @pool_group_id INT
SELECT  @pool_location_id = ISNULL(@pool_location_id + ',', '') +  CAST(a.source_minor_location_id AS VARCHAR(10)), @pool_group_id = a.source_major_location_ID
FROM (
	SELECT DISTINCT sml.source_minor_location_id, sml.source_major_location_ID
	FROM dbo.SplitCommaSeperatedValues(@location_id) t
	INNER JOIN source_minor_location sml
		ON t.item = sml.source_minor_location_id
	INNER JOIN source_major_location smj
		ON sml.source_major_location_ID = smj.source_major_location_ID
	WHERE smj.location_name = 'Pool'
) a

SELECT @storage_location_id storage_location_id, @pool_location_id pool_location_id, @storage_group_id storage_group_id, @pool_group_id pool_group_id

GO
