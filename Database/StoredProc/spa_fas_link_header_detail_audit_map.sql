
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].spa_fas_link_header_detail_audit_map') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].spa_fas_link_header_detail_audit_map

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_fas_link_header_detail_audit_map]
	@link_id VARCHAR(8000),
	@changed_by	VARCHAR(10) = NULL,
	@user_action VARCHAR(50) = NULL
	
AS


/*
Declare 
	@link_id VARCHAR(8000)
	,@changed_by	VARCHAR(10)
	,@source_deal_header_id  VARCHAR(8000)


SET @link_id = '323'
SET @source_deal_header_id = '138,139,253,314'
SET @changed_by ='d'
*/


INSERT INTO fas_link_header_detail_audit_map
SELECT	
	ISNULL(MAX(flha.audit_id),0) header_id
	,ISNULL(MAX(
		CASE @changed_by
			WHEN 'd' THEN flda.audit_id
			ELSE 0
		END 
	),0) detail_id
	,dbo.FNADBUser()
	,GETDATE()
	,dbo.FNADBUser()
	,GETDATE()
	,@changed_by
	,@user_action
FROM fas_link_header_audit flha
	LEFT JOIN fas_link_detail_audit flda ON flha.link_id = flda.link_id
	WHERE flha.link_id IN (SELECT item FROM  dbo.SplitCommaSeperatedValues(@link_id))
GROUP BY flha.link_id 
	




/*
SELECT 
	IDENTITY(INT ,1,1) id
	,item AS link_id
INTO #link
FROM dbo.SplitCommaSeperatedValues(@link_id)


SELECT 
	IDENTITY(INT ,1,1) id
	,item AS source_deal_header_id
INTO #deal
FROM dbo.SplitCommaSeperatedValues(@source_deal_header_id)


INSERT INTO fas_link_header_detail_audit_map
SELECT 
	heder_audit_id
	,detail_audit_id
	,dbo.FNADBUser()
	,GETDATE()
	,dbo.FNADBUser()
	,GETDATE()
	,@changed_by
FROM 
	(
		SELECT 
			L1.link_id
			,D1.source_deal_header_id
			,ISNULL(MAX(COALESCE(D2.heder_audit_id,L2.heder_audit_id)),0) heder_audit_id
			,ISNULL(MAX(COALESCE(D2.detail_audit_id,L2.detail_audit_id)),0) detail_audit_id
		FROM #link L1
			LEFT JOIN (
						SELECT	
							flha.link_id link_id
							,MAX(flha.audit_id) heder_audit_id
							,MAX(flda.audit_id) detail_audit_id
						FROM #link l
						INNER JOIN fas_link_header_audit flha ON l.link_id = flha.link_id
						LEFT JOIN fas_link_detail_audit flda ON flha.link_id = flda.link_id
						GROUP BY flha.link_id
			) L2 ON L1.link_id = L2.link_id		
		 
		LEFT JOIN #deal D1 ON L1.id = D1.id
		LEFT JOIN (
					SELECT	
						flda.source_deal_header_id source_deal_header_id
						,MAX(flha.audit_id) heder_audit_id
						,MAX(flda.audit_id) detail_audit_id	
					FROM #deal d
					INNER JOIN fas_link_detail_audit flda ON d.source_deal_header_id = flda.source_deal_header_id
					LEFT JOIN fas_link_header_audit flha ON flha.link_id = flda.link_id 
					GROUP BY flda.source_deal_header_id
				)D2 ON D1.source_deal_header_id = D2.source_deal_header_id
		GROUP BY L1.link_id,D1.source_deal_header_id
	) TMP
*/