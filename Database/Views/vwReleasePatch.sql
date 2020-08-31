IF EXISTS (SELECT * FROM sys.views WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[vwReleasePatch]'))
    DROP VIEW [dbo].[vwReleasePatch]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwReleasePatch] AS 
SELECT rp.[release_patch_id]
       ,[description] [patch_description]
       ,SUBSTRING([description],CHARINDEX('Hotfix', [description]) + LEN('Hotfix_'),LEN([description])) [version]
       ,[patch_executor]
       ,[create_user]
	   ,cast(convert(VARCHAR(10),[create_ts] , 21) AS DATETIME) [applied_date]
       ,[create_ts]
       ,[filename] 
       ,[executed] 
       ,[copied]   
       ,[error]    
       ,[sequence]
       , CASE WHEN ISNULL([error],'') = '' THEN 1 ELSE 0 END [success]   FROM release_patch rp
       INNER JOIN release_patch_detail rpd ON rp.release_patch_id = rpd.release_patch_id