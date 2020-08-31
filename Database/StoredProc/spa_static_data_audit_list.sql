
IF OBJECT_ID(N'spa_static_data_audit_list', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_static_data_audit_list]
GO 

-- ============================================================================================================================
-- Author: Pawan Adhikari
-- Create date: 2012-05-09 00:00AM
-- Description: Static Data Audit Log List.
--              
-- Params:
-- @flag -- s
-- ============================================================================================================================
CREATE PROC [dbo].[spa_static_data_audit_list]
	@flag AS CHAR(1)
AS

IF @flag = 's'
BEGIN
	CREATE TABLE #static_data_audit_list
	(
		[type_id]        [int] NOT NULL,
		[value_id]       [int] NOT NULL,
		[Code]           [varchar](500) COLLATE DATABASE_DEFAULT NULL,
		[Description]    [varchar](500) COLLATE DATABASE_DEFAULT NULL,
		[entity_id]      [int] NULL,
		[category_id]    [int] NULL,
		[category_name]  [varchar](50) COLLATE DATABASE_DEFAULT NULL
	)
	
	INSERT INTO #static_data_audit_list
	EXEC spa_StaticDataValues 's', 19900
	
	SELECT [type_id],
	       [value_id],
	       [Code],
	       [Description],
	       [entity_id],
	       [category_id],
	       [category_name]
	FROM   #static_data_audit_list
	WHERE value_id NOT IN (19913,19914)  
	ORDER BY value_id
END

--spa_static_data_audit_list 's'
