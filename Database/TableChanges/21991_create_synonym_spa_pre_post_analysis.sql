IF  EXISTS (SELECT 1 FROM sys.synonyms WHERE name = N'spa_pre_post_analysis')
      DROP SYNONYM [dbo].spa_pre_post_analysis
GO
CREATE SYNONYM [dbo].[spa_pre_post_analysis] FOR [testing].[spa_pre_post_analysis]
GO