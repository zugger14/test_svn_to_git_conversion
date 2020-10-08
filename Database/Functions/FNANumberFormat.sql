SET NOCOUNT ON

IF OBJECT_ID(N'[dbo].FNANumberFormat', N'FN') IS NOT NULL 
	DROP FUNCTION [dbo].FNANumberFormat
GO

/**
	Converts SQL number to user number format.

	Parameters
	@num	:	SQL number to convert into user number
	@num_type: Number Type 
				v = Volume
				n = Number
				a = amount
				p = price
				o = no rounding
				w = without rounding and tralling zeros
*/

CREATE FUNCTION [dbo].[FNANumberFormat](@num NUMERIC(38,10),@num_type NCHAR(1))
RETURNS NVARCHAR(50)
AS
/*
DECLARE @num NUMERIC(38,10) = 1234.2678
,@num_type NCHAR(1) = 'v'

--*/
BEGIN
	DECLARE @num_format AS NVARCHAR(50),@decimal_separator AS NCHAR(1),@group_separator AS NCHAR(1), @num_rounding NVARCHAR(3), @user_login_id NVARCHAR(200) = dbo.FNADBUser()

	SELECT 
		@decimal_separator = ISNULL(au.decimal_separator,ci.decimal_separator),
		@group_separator = ISNULL(au.group_separator,ci.group_separator),
		@num_rounding = CAST(ISNULL(CASE @num_type WHEN 'v' THEN ci.volume_rounding
									   WHEN 'a' THEN ci.amount_rounding
									   WHEN 'p' THEN ci.price_rounding
									   WHEN 'o' THEN 0
									   WHEN 'w' THEN -1
									   ELSE ci.number_rounding END,0) AS NVARCHAR(2))
	FROM company_info ci
	LEFT JOIN application_users au 
		ON au.user_login_id = @user_login_id

	IF  @num IS NULL
		SET @num_format=''
	ELSE
	BEGIN
		SET @num_format =	REPLACE(
							REPLACE(
							REPLACE(
							REPLACE(IIF( @num_rounding = -1, dbo.FNAAddThousandSeparator(dbo.FNARemoveTrailingZero(@num)), FORMAT(@num, 'N' + @num_rounding))
								, ',', '<#GS#>')
								, '.', '<#DS#>') 
								, '<#GS#>', '' + @group_separator + '')
								, '<#DS#>', '' + @decimal_separator + '')
	END
	
	--select @num_format
	RETURN(@num_format)
END




GO
