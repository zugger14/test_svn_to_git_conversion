/****** Object:  UserDefinedFunction [dbo].[FNASplitAndTranspose]    Script Date: 11/23/2010 15:15:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNASplitAndTranspose]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNASplitAndTranspose]

GO

--select * from [dbo].[FNASplitAndTranspose]('23,1,3,23,4,0')

CREATE FUNCTION [dbo].[FNASplitAndTranspose]
(@List AS VARCHAR(8000), @delimeter CHAR(1))
RETURNS @Items TABLE(clm1 varchar(8000), clm2 varchar(8000), clm3 varchar(8000), clm4 varchar(8000), clm5 varchar(8000),
			clm6 varchar(8000), clm7 varchar(8000), clm8 varchar(8000), clm9 varchar(8000), clm10 varchar(8000),
			clm11 varchar(8000), clm12 varchar(8000), clm13 varchar(8000), clm14 varchar(8000), clm15 varchar(8000))
AS
BEGIN

	DECLARE @Item AS VARCHAR(8000)
	DECLARE @Pos AS INT
	DECLARE @clm1 varchar(8000), @clm2 varchar(8000), @clm3 varchar(8000), @clm4 varchar(8000), @clm5 varchar(8000),
		    @clm6 varchar(8000), @clm7 varchar(8000), @clm8 varchar(8000), @clm9 varchar(8000), @clm10 varchar(8000),
			@clm11 varchar(8000), @clm12 varchar(8000), @clm13 varchar(8000), @clm14 varchar(8000), @clm15 varchar(8000)

	SET @clm1=NULL
	SET @clm2=NULL
	SET @clm3=NULL
	SET @clm4=NULL
	SET @clm5=NULL
	SET @clm6=NULL
	SET @clm7=NULL
	SET @clm8=NULL
	SET @clm9=NULL
	SET @clm10=NULL
	SET @clm11=NULL
	SET @clm12=NULL
	SET @clm13=NULL
	SET @clm14=NULL
	SET @clm15=NULL

	DECLARE @next int
	set @next=1
	WHILE DATALENGTH(@List)>0
	BEGIN
		SET @Pos=CHARINDEX(@delimeter,@List)
			
		IF @Pos=0 SET @Pos=DATALENGTH(@List)+1
			SET @Item =  LTRIM(RTRIM(LEFT(@List,@Pos-1)))

		IF @Item<>'' 
		BEGIN
			If @next=1 set @clm1 = @Item
			If @next=2 set @clm2 = @Item
			If @next=3 set @clm3 = @Item
			If @next=4 set @clm4 = @Item
			If @next=5 set @clm5 = @Item
			If @next=6 set @clm6 = @Item
			If @next=7 set @clm7 = @Item
			If @next=8 set @clm8 = @Item
			If @next=9 set @clm9 = @Item
			If @next=10 set @clm10 = @Item
			If @next=11 set @clm11 = @Item
			If @next=12 set @clm12 = @Item
			If @next=13 set @clm13 = @Item
			If @next=14 set @clm14 = @Item
			If @next=15 set @clm15 = @Item
		END
			set @next = @next+1
			SET @List=SUBSTRING(@List,@Pos+DATALENGTH(@delimeter),8000)
	END

	INSERT INTO @Items values(@clm1,@clm2,@clm3,@clm4,@clm5,@clm6,@clm7,@clm8,@clm9,@clm10,@clm11,@clm12,@clm13,@clm14,@clm15)

	RETURN
END







