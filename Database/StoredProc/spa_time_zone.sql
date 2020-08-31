/****** Object:  StoredProcedure [dbo].[spa_time_zone]    Script Date: 04/12/2010 17:24:14 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_time_zone]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_time_zone]
/****** Object:  StoredProcedure [dbo].[spa_time_zone]    Script Date: 04/12/2010 17:24:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_time_zone]
	@flag CHAR(1)

AS
BEGIN


	IF @flag='s'
	BEGIN
		SELECT NULL, NULL		
		UNION ALL		
		SELECT 
			 timezone_id,timezone_name 
		FROM 
			[TIME_ZONES]
	END

END