SET NOCOUNT ON
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/**
	Returns job's description and creator's name.

	Parameters
	@job_id : Job ID
	
*/

CREATE OR ALTER FUNCTION dbo.FNAGetJobDescription
(
	@job_id NVARCHAR(200)
)
RETURNS @items TABLE (
		job_id NVARCHAR(200),
		[description] NVARCHAR(MAX),
		[user_login_id] NVARCHAR(MAX)
)
AS
BEGIN
    INSERT INTO @items(job_id, [description], [user_login_id])
	SELECT 
		sj.job_id
		,CASE 
			WHEN CHARINDEX(CHAR(13), sj.description,0) <> 0 THEN LTRIM(RTRIM(i.clm2)) 
			ELSE sj.description 
		END [desciption]
		,CASE 
			WHEN CHARINDEX(CHAR(13), sj.description,0) <> 0 THEN REPLACE(LTRIM(RTRIM(i.clm1)),'Created by: ', '')
			ELSE '' 
		END [user_name]
	FROM  msdb.dbo.sysjobs sj
	OUTER APPLY (SELECT clm1,clm2 FROM dbo.FNASplitAndTranspose(sj.description, CHAR(13))) i
	WHERE sj.job_id = @job_id
	
	RETURN
END
GO

