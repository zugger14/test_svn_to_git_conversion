IF OBJECT_ID(N'FNAGeneratorMxHour', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAGeneratorMxHour]
GO
 
CREATE FUNCTION [dbo].[FNAGeneratorMxHour]
(
	@row INT
)
RETURNS FLOAT AS
BEGIN
	RETURN 1
END