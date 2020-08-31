IF OBJECT_ID(N'FNAGetAssignmentDesc', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAGetAssignmentDesc]
GO 


--select dbo.FNAGetAssignmentDesc(5146)

--5146 RPS Compliance
--5147 Windsource
CREATE FUNCTION [dbo].[FNAGetAssignmentDesc]
(
	@assignment_type INT
)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @FNAGetAssignmentDesc VARCHAR(50)
	SELECT @FNAGetAssignmentDesc = code
	FROM   static_data_value
	WHERE  value_id = @assignment_type
	
	RETURN (@FNAGetAssignmentDesc)
END