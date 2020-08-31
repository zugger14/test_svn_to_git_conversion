/****** Object:  UserDefinedFunction [dbo].[FNARPriorCurve]    Script Date: 01/05/2010 15:12:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARPriorCurve]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARPriorCurve]
/****** Object:  UserDefinedFunction [dbo].[FNARPriorCurve]    Script Date: 01/05/2010 15:12:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
--select dbo.FNARPriorCurve('3/2/2004', 99, 14)  
CREATE FUNCTION [dbo].[FNARPriorCurve] (
    
  @maturity_date datetime,   
  @as_of_date DATETIME,  
  @he INT,  
  @curve_source_value_id int,  
  @curve_id INT,  
  @relative_year int,   
  @relative_month int,   
  @relative_day int,  
  @same_as_of_date INT,  
  @use_same_as_of_date INT  
 )  
RETURNS float AS    
BEGIN   
 declare @x as float  
 declare @maturity DATETIME  
  
 set @x = NULL  
 IF @he IS NULL  
  SET @he=1  
  IF @he>0
 set @he=@he-1  
  
   
  set @maturity_date = dateadd(yy, @relative_year, @maturity_date)  
  set @maturity_date = dateadd(mm, @relative_month, @maturity_date)  
  set @maturity_date = dateadd(dd, @relative_day, @maturity_date)  
   
  
 SET @maturity = CAST(dbo.FNAGetSQLStandardDate(@maturity_date) + ' ' +   
   case when (@he < 10) then '0' else '' end +  
   cast(@he as varchar) + ':00:00' AS DATETIME)   
  
 IF @same_as_of_date=1  
 BEGIN  
  set @as_of_date = dateadd(yy, @relative_year, @as_of_date)  
  set @as_of_date = dateadd(mm, @relative_month, @as_of_date)  
  set @as_of_date = dateadd(dd, @relative_day, @as_of_date)  
 END  
  
 select @x = curve_value   
 from source_price_curve  
 where  source_curve_def_id = @curve_id and  
  as_of_date = @as_of_date and  
  assessment_curve_type_value_id = 77 and --spot daily  
  curve_source_value_id = @curve_source_value_id   
  and (maturity_date) = @maturity  
  
 IF @x IS NULL AND @use_same_as_of_date=1  
 BEGIN  
  SELECT @as_of_date=MAX(as_of_date)   
  FROM source_price_curve  
   where  source_curve_def_id = @curve_id and  
   assessment_curve_type_value_id = 77 and --spot daily  
   curve_source_value_id = @curve_source_value_id  
   and (maturity_date) = @maturity   
   --and MONTH(as_of_date) = MONTH(@as_of_date)  
   AND as_of_date<=@as_of_date  
  
  select @x = curve_value   
  from source_price_curve  
  where  source_curve_def_id = @curve_id and  
   as_of_date = @as_of_date and  
   assessment_curve_type_value_id = 77 and --spot daily  
   curve_source_value_id = @curve_source_value_id   
   and (maturity_date) = @maturity  
 END   
  
 return @x  
END  
  