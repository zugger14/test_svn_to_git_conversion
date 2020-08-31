Declare 
 @company_name varchar(100) = 'Release' --TODO Change Company Name
,@address1 varchar(250) = NULL
,@address2 varchar(250) = NULL
,@contactphone varchar(250) = NULL
,@city varchar(250) = NULL
,@state varchar(250) = NULL
,@zipcode varchar(250)= NULL
,@country varchar(250)= NULL
,@company_code  varchar(64) = 'RELEASE' --TODO Change Company Code
,@phone_format char = '0' --TODO Change phone format
,@decimal_separator char ='.' --TODO Change decimal seperator character
,@group_separator char =','--TODO Change decimal group separator character
,@price_rounding INT = 4 --TODO Change price rouding value
,@volume_rounding INT = 4 --TODO Change volume rouding value
,@amount_rounding INT = 4 --TODO Change amount rouding value
,@number_rounding INT = 4 --TODO Change number rouding value


IF EXISTS (SELECT 1 FROM company_info)
BEGIN
	
	UPDATE company_info
		SET company_name   = @company_name
		,address1		   = @address1
		,address2		   = @address2
		,contactphone	   = @contactphone
		,city			   = @city
		,[state]		   = @state
		,zipcode		   = @zipcode
		,country		   = @country
		,company_code	   = @company_code
		,phone_format	   = @phone_format
		,decimal_separator = @decimal_separator
		,group_separator   = @group_separator
		,price_rounding	   = @price_rounding
		,volume_rounding   = @volume_rounding
		,amount_rounding   = @amount_rounding
		,number_rounding   = @number_rounding
END
ELSE
BEGIN
	Insert into company_info
	(company_name,address1,address2,contactphone,city,state,zipcode,country,company_code,phone_format,decimal_separator,group_separator,price_rounding,volume_rounding,amount_rounding,number_rounding)
	values 
	(@company_name,@address1,@address2,@contactphone,@city,@state,@zipcode,@country,@company_code,@phone_format,@decimal_separator,@group_separator,@price_rounding,@volume_rounding,@amount_rounding,@number_rounding)
END
GO



