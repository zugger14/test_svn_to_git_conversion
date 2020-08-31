IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAOTPStatus]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNAOTPStatus]
	
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAOTPStatus] (@client_dir VARCHAR(50))
RETURNS BIT AS  
BEGIN 
	DECLARE @enable_otp INT
		  , @otp_status BIT

	SELECT @enable_otp = enable_otp
	FROM connection_string

	IF @enable_otp = 1 -- Always enable otp if enable_otp is set to 1 in connection_string
	BEGIN
		SET @otp_status = 1
	END
	ELSE IF @client_dir = 'trmcloud' AND ( (2 & @enable_otp) = 2 )
	BEGIN
		SET @otp_status =  1
	END
	ELSE IF @client_dir LIKE 'trmclient%' AND ( (4 & @enable_otp) = 4 )
	BEGIN
		SET @otp_status =  1
	END
	ELSE IF @client_dir LIKE 'fasclient%' AND ( (8 & @enable_otp) = 8 )
	BEGIN
		SET @otp_status =  1
	END
	ELSE IF @client_dir LIKE 'recclient%' AND ( (16 & @enable_otp) = 16 )
	BEGIN
		SET @otp_status =  1
	END 
	ELSE IF @client_dir LIKE 'setclient%' AND ( (32 & @enable_otp) = 32 )
	BEGIN
		SET @otp_status =  1
	END
	ELSE
	BEGIN
		SET @otp_status =  0
	END
	
	RETURN @otp_status
END