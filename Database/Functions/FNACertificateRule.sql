/****** Object:  UserDefinedFunction [dbo].[FNACertificateRule]    Script Date: 11/03/2009 14:47:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNACertificateRule]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNACertificateRule]
/****** Object:  UserDefinedFunction [dbo].[FNACertificateRule]    Script Date: 11/03/2009 14:47:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNACertificateRule](@certformat varchar(500),@facility_id varchar(100),@number int,@DATE DATETIME)
RETURNS VARCHAR(1000)
BEGIN
		DECLARE @year varchar(10)
		DECLARE @month varchar(10)
		DECLARE @numberformat varchar(100)
----		DECLARE @facility_id varchar(100)
----		DECLARE @resource_type varchar(100)
----
----		select @facility_id=ISNULL([ID],''),@resource_type=ISNULL(resource_type,'') from rec_generator where generator_id=@generator_id
		declare @fac_len int
		set @fac_len=len(@facility_id)
		
		IF ISNULL(LTRIM(RTRIM(@certformat)),'')=''
			BEGIN
				SET @certformat=CAST(@number as VARCHAR)
				RETURN @certformat
			END
		
		SET @certformat=replace(@certformat,'<yy#2>',cast(RIGHT(YEAR(@DATE),2) as varchar))
		SET @certformat=replace(@certformat,'<yyyy#4>',cast(RIGHT(YEAR(@DATE),4) as varchar))
		SET @certformat=replace(@certformat,'<mm#2>',RIGHT('0'+cast(month(@DATE) as varchar ),2))
		SET @certformat=replace(@certformat,'<qq#2>',RIGHT('0'+cast(datepart(quarter,@DATE) as varchar ),2))
		SET @certformat=replace(@certformat,'<FACID#4>',REPLICATE('0',4-len(left(@facility_id,4)))+ left(@facility_id,4))
		SET @certformat=replace(@certformat,'<FACID#5>',REPLICATE('0',5-len(left(@facility_id,5)))+ left(@facility_id,5))
 		SET @certformat=replace(@certformat,'<FACID#6>',REPLICATE('0',6-len(left(@facility_id,6)))+ left(@facility_id,6))
		SET @certformat=replace(@certformat,'<FACID#7>',REPLICATE('0',7-len(left(@facility_id,7)))+ left(@facility_id,7))
 		SET @certformat=replace(@certformat,'<FACID#8>',REPLICATE('0',8-len(left(@facility_id,8)))+ left(@facility_id,8))
 		SET @certformat=replace(@certformat,'<FACID#9>',REPLICATE('0',9-len(left(@facility_id,9)))+ left(@facility_id,9))
 		SET @certformat=replace(@certformat,'<FACID#10>',REPLICATE('0',10-len(left(@facility_id,10)))+ left(@facility_id,10))
		SET @certformat=replace(@certformat,'<q#1>',cast(datepart(q,@DATE) as varchar))
		SET @certformat=replace(@certformat,'<i#4>',REPLACE(cast(@number*0.001 as varchar),'.',''))
		SET @certformat=replace(@certformat,'<i#5>',REPLACE(cast(@number*0.0001 as varchar),'.',''))
		SET @certformat=replace(@certformat,'<i#6>',REPLACE(cast(@number*0.00001 as varchar),'.',''))
		SET @certformat=replace(@certformat,'<i#7>',REPLACE(cast(@number*0.000001 as varchar),'.',''))
		SET @certformat=replace(@certformat,'<i#8>',REPLACE(cast(@number*0.0000001 as varchar),'.',''))
		SET @certformat=replace(@certformat,'<i#9>',REPLACE(cast(@number*0.00000001 as varchar),'.',''))
		SET @certformat=replace(@certformat,'<i#10>',REPLACE(cast(@number*0.00000001 as varchar),'.',''))
	RETURN @certformat
END






