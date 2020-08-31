IF OBJECT_ID(N'spa_getAllSystemDealTypes', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_getAllSystemDealTypes]
GO 

--This procedure gets all deal types by all systems

-- EXEC spa_getAllSystemDealTypes 'y'
-- DROP PROC spa_getAllSystemDealTypes

CREATE PROCEDURE [dbo].[spa_getAllSystemDealTypes]
@deal_sub_type NCHAR(1) = NULL
AS
IF @deal_sub_type='y'
BEGIN
	SELECT  sdt.source_deal_type_id AS source_deal_type_id
			,sdt.source_deal_type_name + 
				CASE WHEN ssd.source_system_name='farrms' THEN '' 
				ELSE  '.' + ssd.source_system_name   END source_deal_type_name 
			,ssd.source_system_name 
	FROM source_deal_type sdt
		INNER JOIN source_system_description  ssd ON sdt.source_system_id = ssd.source_system_id
	WHERE sub_type='y'
	ORDER BY ssd.source_system_name,sdt.source_deal_type_name
END
ELSE
BEGIN
	SELECT  sdt.source_deal_type_id AS source_deal_type_id
			,sdt.source_deal_type_name + 
				CASE WHEN ssd.source_system_name='farrms' THEN '' 
				ELSE  '.' + ssd.source_system_name   END source_deal_type_name 
			,ssd.source_system_name 
	FROM source_deal_type sdt
		INNER JOIN source_system_description  ssd ON sdt.source_system_id = ssd.source_system_id		
	WHERE (sub_type='n' or sub_type is null )
	ORDER BY ssd.source_system_name,sdt.source_deal_type_name
END