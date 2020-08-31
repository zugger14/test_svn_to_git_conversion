IF OBJECT_ID(N'spa_getfuncurrencysourceid', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_getfuncurrencysourceid]
GO 

--EXEC  spa_getfuncurrencysourceid 1

CREATE procedure [dbo].[spa_getfuncurrencysourceid]
	@flag AS CHAR(1),
	@fas_subsidiary_id INT = NULL
AS 
SET NOCOUNT ON

IF @flag='s'
	BEGIN 
	SELECT  source_currency.source_currency_id AS source_currency_id,  
	        (source_currency.currency_name) AS currency_name
--	        (source_system_description.source_system_name + ' - ' + source_currency.currency_name) AS currency_name
	FROM    source_currency INNER JOIN
	        source_system_description ON 
		source_currency.source_system_id = source_system_description.source_system_id
	ORDER BY source_currency.currency_name
		If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, 'Currency Units', 
					'spa_getfuncurrencysourceid', 'DB Error', 
					'Failed to select currency units.', ''

     END

--source_currency.currency_id AS currency_id,