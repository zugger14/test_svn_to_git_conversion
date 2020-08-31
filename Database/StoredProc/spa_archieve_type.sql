IF OBJECT_ID('[dbo].[spa_archieve_type]')  IS NOT NULL
DROP proc [dbo].[spa_archieve_type]
GO 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Shyam Mishra
-- Create date: September 24, 2010
-- Description:	Gets Archieve Type.
-- =============================================
CREATE PROCEDURE [dbo].[spa_archieve_type] 
@flag CHAR(1)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF @flag = 's'
	BEGIN
		SELECT value_id,code FROM static_data_value WHERE [type_id]=2150
	END
END
GO