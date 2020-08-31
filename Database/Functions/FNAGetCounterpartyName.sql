/*
Description: To retrieve counterparty name to avoid multiple join with source counterparty in CVA/DVA calculation
Created DT: 2018-05-21
Owner: sbohara@pioneersolutionsglobal.com
*/
IF OBJECT_ID(N'FNAGetCounterpartyName', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAGetCounterpartyName]
GO 

CREATE FUNCTION [dbo].[FNAGetCounterpartyName]
(
	@source_counterparty_id INT
)
RETURNS NVARCHAR(200)
AS
BEGIN
	DECLARE @counterparty_id AS NVARCHAR(200)
	
	SELECT @counterparty_id = counterparty_id FROM source_counterparty WHERE source_counterparty_id = @source_counterparty_id
	
	RETURN @counterparty_id
END	