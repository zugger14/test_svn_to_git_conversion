IF EXISTS (SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_UpdateAutomaticProcessSQLStmt]')AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_UpdateAutomaticProcessSQLStmt]
 ELSE
 	PRINT 'spa_UpdateAutomaticProcessSQLStmt already dropped'   
GO

IF EXISTS (SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_createHTMLReportOnSQLStmt]')AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_createHTMLReportOnSQLStmt]
 ELSE
 	PRINT 'spa_createHTMLReportOnSQLStmt already dropped'   
GO
IF EXISTS (SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_UpdateAutomaticProcess]')AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_UpdateAutomaticProcess]
 ELSE
 	PRINT 'spa_UpdateAutomaticProcess already dropped'   
GO