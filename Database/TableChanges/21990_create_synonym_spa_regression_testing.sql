IF  EXISTS (SELECT 1 FROM sys.synonyms WHERE name = N'spa_regression_testing')
      DROP SYNONYM [dbo].spa_regression_testing
GO

CREATE SYNONYM [dbo].[spa_regression_testing] FOR [testing].[spa_regression_testing]
GO
