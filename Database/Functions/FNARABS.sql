IF OBJECT_ID(N'FNARABS', N'FN') IS NOT NULL
DROP FUNCTION FNARABS
GO
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

CREATE FUNCTION [dbo].[FNARABS](
		@value FLOAT		
	
	)
	RETURNS float AS  
	BEGIN 
	

		RETURN ABS(@value)
	END















