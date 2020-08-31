/*
Desc   : This will convert the case of first letter of each word on string to upper case
Dated  : 2016-05-20
*/

--SELECT dbo.FNAInitCap('hello! world')
IF OBJECT_ID('dbo.FNAInitCap','FN') IS NOT NULL
	DROP FUNCTION dbo.FNAInitCap
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAInitCap] ( @input_string varchar(4000) ) 
RETURNS VARCHAR(4000)
AS
BEGIN

DECLARE @index          INT
DECLARE @char           CHAR(1)
DECLARE @prev_char       CHAR(1)
DECLARE @output_string   VARCHAR(255)

SET @output_string = LOWER(@input_string)
SET @index = 1

WHILE @index <= LEN(@input_string)
BEGIN
    SET @char     = SUBSTRING(@input_string, @index, 1)
    SET @prev_char = CASE WHEN @index = 1 THEN ' '
                         ELSE SUBSTRING(@input_string, @index - 1, 1)
                    END

    IF @prev_char IN (' ', ';', ':', '!', '?', ',', '.', '_', '-', '/', '&', '''', '(')
    BEGIN
        IF @prev_char != '''' OR UPPER(@char) != 'S'
            SET @output_string = STUFF(@output_string, @index, 1, UPPER(@char))
    END

    SET @index = @index + 1
END

RETURN @output_string

END