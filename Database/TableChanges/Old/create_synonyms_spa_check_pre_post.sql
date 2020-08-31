
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'spa_check_pre_post')
      DROP SYNONYM [dbo].spa_check_pre_post
GO

CREATE SYNONYM dbo.spa_check_pre_post FOR testing.spa_check_pre_post
GO

IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'spa_pre_post_configuration')
      DROP SYNONYM [dbo].spa_pre_post_configuration
GO

CREATE SYNONYM dbo.spa_pre_post_configuration FOR testing.spa_pre_post_configuration
GO

