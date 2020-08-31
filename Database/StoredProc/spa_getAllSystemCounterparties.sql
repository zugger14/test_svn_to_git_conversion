IF OBJECT_ID(N'spa_getAllSystemCounterparties', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_getAllSystemCounterparties]
GO 

--This procedure gets all counterparties by all systems

-- drop proc spa_getAllSystemCounterparties
-- exec spa_getAllSystemCounterparties

CREATE PROCEDURE [dbo].[spa_getAllSystemCounterparties]
AS

SELECT  sc.source_counterparty_id AS source_counterparty_id
		,sc.counterparty_name + 
			CASE WHEN ssd.source_system_name='farrms' THEN '' 
			ELSE  '.' + ssd.source_system_name   END counterparty_name 		
		,ssd.source_system_name
FROM source_counterparty sc 
	INNER JOIN source_system_description  ssd ON sc.source_system_id = ssd.source_system_id
ORDER BY sc.counterparty_name