IF  EXISTS (SELECT 1 FROM sys.synonyms WHERE name = N'spa_test_regression_rule')
      DROP SYNONYM [dbo].spa_test_regression_rule
GO

CREATE SYNONYM [dbo].[spa_test_regression_rule] FOR [testing].[spa_test_regression_rule]
GO