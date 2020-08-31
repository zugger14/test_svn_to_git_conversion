/*
	Author:			Poojan Shrestha
	Date:			06/22/2010
	Description:	Replace tags to handle dynamic content. e.g. The timestamp in the messageboard is surrounded by <time></time> tags 
					and server time is saved. This function is then called in spa_message_board to display user time dynamically within 
					the messageboard text. (Currently limited to a single replacement within the text.)
*/

IF OBJECT_ID('[dbo].[FNAReplaceTagInText]','fn') IS NOT NULL 
DROP FUNCTION [dbo].[FNAReplaceTagInText] 
GO 

CREATE FUNCTION [dbo].[FNAReplaceTagInText] 
(
	@tag VARCHAR(100),
	@text VARCHAR(8000),
	@with_date CHAR(1) = 'y'
)
RETURNS VARCHAR(8000)
AS 
BEGIN

--DECLARE @tag VARCHAR(100),
--@text VARCHAR(8000)
--
--SET @tag = 'time'
--SET @text = 'Deal ID # <span style=cursor:hand onClick=TRMHyperlink(10131010,14111)><font color=#0000ff><u><l>14111<l></u></font></span> (June17-AEP1) has been created by  Kathmandu User at  10:47 AM.'

	DECLARE @tag_start INT, @tag_end INT, @tag_length INT 
	DECLARE @tag_value_length INT 
	DECLARE @new_text VARCHAR(8000)

	DECLARE @front VARCHAR(8000), @back VARCHAR(8000)

	SELECT	@tag_length = LEN('<'+@tag+'>')
	SELECT	@tag_start = PATINDEX('%<'+@tag+'>%',@text),
			@tag_end = PATINDEX('%</'+@tag+'>%',@text)
			
	IF @tag_start = 0 OR @tag_end = 0
	BEGIN
		SET @tag_start = 0
		SET @tag_end = 0
		SET @tag_length = 0
	END
		
		
	SET @tag_start = @tag_start + @tag_length
					
	SET		@tag_value_length = @tag_end - @tag_start

	IF @tag = 'time'
	BEGIN 
		DECLARE @server_time DATETIME 
		DECLARE @local_time		DATETIME,
				@formatted_tag_value	VARCHAR(50)	 


		SELECT @server_time = SUBSTRING(@text,@tag_start,@tag_value_length)
		
		SELECT @local_time = dbo.FNAConvertTZAwareDateFormat(@server_time,3)
		
		IF @with_date = 'y'
		SELECT @formatted_tag_value = @local_time
		ELSE
		SELECT @formatted_tag_value = SUBSTRING(SUBSTRING(CONVERT(VARCHAR,@local_time,100),12,LEN(@local_time)),1,LEN(SUBSTRING(CONVERT(VARCHAR,@local_time,100),12,LEN(@local_time)))-2)+' ' +RIGHT(@local_time,2)
	END 

	SELECT @front = SUBSTRING(@text,0,@tag_start-@tag_length)
	SELECT @back = SUBSTRING(@text,@tag_end+@tag_length+1,LEN(@text))

	SELECT @new_text = ISNULL(@front,'') + ISNULL(@formatted_tag_value,'') + ISNULL(@back,'')


	RETURN @new_text 

END 