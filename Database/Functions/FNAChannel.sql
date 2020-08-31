IF OBJECT_ID(N'FNAChannel', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAChannel]
 GO 


CREATE FUNCTION [dbo].[FNAChannel]
(
	@channel          INT,
	@block_define_id  INT
)
RETURNS FLOAT
AS
BEGIN
	RETURN 1
END