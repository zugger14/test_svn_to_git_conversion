
/****** Object:  UserDefinedFunction [dbo].[FNACurveIDOfSimpleFormula]    Script Date: 06/08/2011 16:00:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNACurveIDOfSimpleFormula]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNACurveIDOfSimpleFormula]
GO
/****** Object:  UserDefinedFunction [dbo].[[FNACurveIDOfSimpleFormula]]    Script Date: 06/08/2011 23:43:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 ---select * from formula_editor where formula like '%CurveH%'   118, 736
 -- select dbo.FNACurveIDOfSimpleFormula(3)
 
create FUNCTION [dbo].[FNACurveIDOfSimpleFormula] (@formula_id INT)
RETURNS int AS  
BEGIN 

	--declare @formula_id int = 9109
	
	declare @fs varchar(1000),@tmp_curve_id varchar(10)
	
	select @fs = formula from formula_editor where formula_id = @formula_id
	
	--set @fs = '   dbo.FNACurveH( 124 )  * 2 '
	--SET  @fs='1+1.7*dbo.FNACurveM(124,3,44545)'
	
	
	declare @i INT, @n_i INT,  @curve_id INT, @count INT 
	set @fs = replace(@fs, ' ', '')
	declare @comma_found int 
	set @comma_found = 0
--SELECT @fs
	SELECT @i = CHARINDEX('dbo.FNAGetCurveValue(', @fs, 1)
	If @i = 0
	BEGIN 
	SELECT @i = CHARINDEX('dbo.FNACurveY(', @fs, 1)
	If @i = 0
	BEGIN 
		SELECT @i = CHARINDEX('dbo.FNACurveQ(', @fs, 1)
		If @i = 0
		BEGIN 
			SELECT @i = CHARINDEX('dbo.FNACurveM(', @fs, 1)
			If @i = 0
			BEGIN 
				SELECT @i = CHARINDEX('dbo.FNACurveD(', @fs, 1)
				If @i = 0
				BEGIN 
					SELECT @i = CHARINDEX('dbo.FNACurveH(', @fs, 1)
					If @i = 0
					BEGIN 
						SELECT @i = CHARINDEX('dbo.FNACurve15(', @fs, 1)
						If @i = 0
						BEGIN 
							SELECT @i = CHARINDEX('dbo.FNACurve(', @fs, 1)
							If @i = 0
								set @curve_id = NULL
							ELSE  
							BEGIN 
								SET @n_i = CHARINDEX(',', @fs, LEN('dbo.FNACurve(')+@i)
								IF @n_i = 0 
									SET @n_i = CHARINDEX(')', @fs, LEN('dbo.FNACurve(')+@i)
									
								set @i=@i+LEN('dbo.FNACurve(')
							END
							
						END  
						ELSE  
						BEGIN 
							SET @n_i = CHARINDEX(',', @fs, LEN('dbo.FNACurve15(')+@i)
							IF @n_i = 0 
								SET @n_i = CHARINDEX(')', @fs, LEN('dbo.FNACurve15(')+@i)
								
							set @i=@i+LEN('dbo.FNACurve15(')
						END 							
							
					END  
					ELSE  
					BEGIN 
						SET @n_i = CHARINDEX(',', @fs, LEN('dbo.FNACurveH(')+@i)
						IF @n_i = 0 
							SET @n_i = CHARINDEX(')', @fs, LEN('dbo.FNACurveH(')+@i)
							
						set @i=@i+LEN('dbo.FNACurveH(')
					END 
				END 	
				ELSE  
				BEGIN  
					SET @n_i = CHARINDEX(',', @fs, LEN('dbo.FNACurveD(')+@i)
					IF @n_i = 0 
						SET @n_i = CHARINDEX(')', @fs, LEN('dbo.FNACurveD(')+@i)
					
					set @i=@i+LEN('dbo.FNACurveD(')
				END
			END 
			ELSE 
			BEGIN 
				SET @n_i = CHARINDEX(',', @fs, LEN('dbo.FNACurveM(')+@i)
				IF @n_i = 0 
					SET @n_i = CHARINDEX(')', @fs, LEN('dbo.FNACurveM(')+@i)
					
				set @i=@i+LEN('dbo.FNACurveM(')
			END 
		END 	
		ELSE 
		BEGIN 
			SET @n_i = CHARINDEX(',', @fs, LEN('dbo.FNACurveQ(')+@i)
			IF @n_i = 0 
				SET @n_i = CHARINDEX(')', @fs, LEN('dbo.FNACurveQ(')+@i)
			
			set @i=@i+LEN('dbo.FNACurveQ(')
		END
	END 
	ELSE  
	BEGIN 
		SET @n_i = CHARINDEX(',', @fs, LEN('dbo.FNACurveY(')+@i)
		IF @n_i = 0 
			SET @n_i = CHARINDEX(')', @fs, LEN('dbo.FNACurveY(')+@i)
		
		set @i=@i+LEN('dbo.FNACurveY(')
	END 
	end
	ELSE  
	BEGIN 
		SET @n_i = CHARINDEX(',', @fs, LEN('dbo.FNAGetCurveValue(')+@i)
		IF @n_i = 0 
			SET @n_i = CHARINDEX(')', @fs, LEN('dbo.FNAGetCurveValue(')+@i)
		
		set @i=@i+LEN('dbo.FNAGetCurveValue(')
	END 

	IF @i = 0 
		set @curve_id = NULL
	ELSE 
	BEGIN 
		SET  @tmp_curve_id = SUBSTRING(@fs, @i, @n_i-@i)
		IF isnumeric(@tmp_curve_id)=1
			SET @curve_id=@tmp_curve_id
		ELSE
			set @curve_id = NULL
	END 
	--select @i,@n_i,@tmp_curve_id,@fs,@curve_id

	RETURN @curve_id

END