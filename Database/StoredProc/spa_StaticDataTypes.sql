IF OBJECT_ID(N'spa_StaticDataTypes', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_StaticDataTypes]
GO

--===========================================================================================
--This Procedure returns all external static data types that user can see
--Input Parameters:


--===========================================================================================

CREATE PROCEDURE [dbo].[spa_StaticDataTypes]  	
	@type_id VARCHAR(100) = NULL
AS

SET NOCOUNT ON
IF @type_id is null
	SELECT  type_id, type_name 'Type Name', description 'Description' from static_data_type
			WHERE internal = 0 ORDER BY type_name
ELSE
	SELECT  sdt.type_id, sdt.type_name 'Type Name', description 'Description' FROM static_data_type sdt
	INNER JOIN (SELECT item FROM dbo.splitcommaseperatedvalues(@type_id)) scsv ON sdt.type_id = scsv.item
	ORDER BY sdt.type_name