set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		<Author,,Gyan>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
IF OBJECT_ID(N'dbo.FNALPad', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNALPad] 
GO

CREATE FUNCTION [dbo].[FNALPad] 
(
	-- Add the parameters for the function here
	@valuePad varchar(30),@NoPad tinyint=0,@CharPad char(1)='0'
)
RETURNS varchar(30)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @retValue varchar(30)
if @NoPad=0 or len(@valuePad)>=@NoPad
	set @retValue= @valuePad
else
 set @retValue=replicate(@CharPad,@NoPad-len(@valuePad))+@valuePad
RETURN @retValue
END






