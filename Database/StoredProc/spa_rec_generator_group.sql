
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_rec_generator_group]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_rec_generator_group]
GO

CREATE PROCEDURE dbo.spa_rec_generator_group
@flag CHAR(1),
@generator_group_id INT =NULL,
@generator_group_name VARCHAR(50)=NULL,
@generator_type INT=null

AS

IF @flag='s'
BEGIN
	SELECT generator_group_id,generator_group_name,generator_type FROM dbo.rec_generator_group
END