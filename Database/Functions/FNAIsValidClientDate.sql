IF OBJECT_ID('dbo.FNAIsValidClientDate', 'FN') IS NOT NULL
    DROP FUNCTION dbo.FNAIsValidClientDate
GO

CREATE FUNCTION dbo.FNAIsValidClientDate
(
	@userDate VARCHAR(10)
)
RETURNS BIT

BEGIN
	DECLARE @userDateFormat  VARCHAR(10),
	        @date            VARCHAR(4),
	        @month           VARCHAR(4),
	        @year            VARCHAR(4),
	        @splitCharacter  CHAR(1)

	DECLARE @tmp             TABLE(sno INT IDENTITY(1, 1), item VARCHAR(4))
	
	SELECT @splitCharacter = CASE 
	                              WHEN CHARINDEX('-', @userDate) > 0 THEN '-'
	                              WHEN CHARINDEX('/', @userDate) > 0 THEN '/'
	                              ELSE '.'
	                         END
	
	SELECT @userDateFormat = date_format
	FROM   APPLICATION_USERS AU
	       INNER JOIN REGION r
	            ON  r.region_id = AU.region_id
	            AND AU.user_login_id = dbo.FNADBUser()
	
	INSERT INTO @tmp
	  (
	    item
	  )
	SELECT item
	FROM   dbo.FNASplit(@userDate, @splitCharacter)
	
	SELECT @date = item FROM @tmp WHERE  sno = 1
	SELECT @month = item FROM   @tmp WHERE  sno = 2
	SELECT @year = item FROM   @tmp WHERE  sno = 3
	
	RETURN 
	CASE 
	     WHEN @userDateFormat IN ('mm/dd/yyyy', 'mm-dd-yyyy') THEN ISDATE(@year + '-' + @date + '-' + @month)
	     ELSE ISDATE(@year + '-' + @month + '-' + @date)
	END
END 
