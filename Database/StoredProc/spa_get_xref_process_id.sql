IF OBJECT_ID(N'spa_get_xref_process_id', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_get_xref_process_id]
 GO 

-- exec spa_get_xref_process_id 's', 5080

CREATE PROCEDURE [dbo].[spa_get_xref_process_id]
	@type VARCHAR(50),
	@id VARCHAR(50)
AS

IF @type = 'c'
	SELECT	rcpr.process_id as [process_id], 
		isnull(source_counterparty.counterparty_name, '') as [name]
	FROM    risk_control_process_references rcpr left outer join
	        source_counterparty ON rcpr.id = source_counterparty.source_counterparty_id
	WHERE   rcpr.type = @type and
		rcpr.id = @id
ELSE
	SELECT	rcpr.process_id as [process_id], 
		isnull(sdv.code, '') as [name]
	FROM    risk_control_process_references rcpr left outer join
	        static_data_value sdv ON rcpr.id = sdv.value_id 
	WHERE   rcpr.type = @type and
		rcpr.id = @id