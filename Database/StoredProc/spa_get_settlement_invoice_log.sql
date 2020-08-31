/****** Object:  StoredProcedure [dbo].[spa_get_settlement_invoice_log]    Script Date: 12/01/2009 20:53:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_settlement_invoice_log]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_settlement_invoice_log]
/****** Object:  StoredProcedure [dbo].[spa_get_settlement_invoice_log]    Script Date: 12/01/2009 20:53:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_get_settlement_invoice_log]
@process_id varchar(50),
@user_login_id VARCHAR(100)=NULL
AS
IF @user_login_id IS NULL
	SET @user_login_id=dbo.FNADBUser()
	
SELECT  
		MAX(code) AS Code, 
		MAX([module]) AS Module, 
		ISNULL([description],'') AS [Description],
		MAX(nextsteps) AS NextSteps, 
		(a.process_id) AS ProcessId
FROM    
		process_settlement_invoice_log a
WHERE 
		a.process_id = @process_id
GROUP BY 
	(a.process_id),[description]
--order by log_id







