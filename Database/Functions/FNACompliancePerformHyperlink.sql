/*
Author		: Vishwas Khanal
Dated		: 25.June.2009
Description : Compliance Renovation
*/

IF OBJECT_ID('[dbo].[FNACompliancePerformHyperlink]', 'fn') IS NOT NULL
    DROP FUNCTION [dbo].[FNACompliancePerformHyperlink]
GO

CREATE FUNCTION [dbo].[FNACompliancePerformHyperlink] (
	@label          VARCHAR(500),
	@arg1           VARCHAR(50),
	@arg2           VARCHAR(50),
	@arg3           VARCHAR(50),
	@approved       INT = NULL,
	@process_table  VARCHAR(400) = NULL,
	@action_type	INT = NULL,
	@source_column  VARCHAR(300) = NULL,
	@source_id		INT = NULL
)
RETURNS VARCHAR(2000)
AS
BEGIN
	-- FNAHyperLinkText6 changed to FNACompliancePerformHyperlink
	IF @action_type IS NULL
		SET @action_type = 1
	
	DECLARE @hyper_text VARCHAR(2000)

	SET @hyper_text='<span style=cursor:hand onClick=CompliancePerformHyperlink('+ @arg1+ ',''' + @arg2 + ''',' + ISNULL('''' + @arg3 + '''', 'NULL') + ',' + cast(@approved AS VARCHAR) +',''r'',' + ISNULL('''' + @process_table + '''', 'NULL') + ',' + CAST(@action_type AS VARCHAR(10)) + ',' + ISNULL('''' + @source_column + '''', 'NULL') + ',' + COALESCE(CAST(@source_id AS VARCHAR(10)), 'NULL') + ')><font color=#0000ff><u><l>'+ @label +'<l></u></font></span>'
	RETURN @hyper_text
END

