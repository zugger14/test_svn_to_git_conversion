
--SELECT dbo.[FNAGetUOMConvertValue](1,6)
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetUOMConvertValue]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAGetUOMConvertValue]
GO



CREATE FUNCTION [dbo].[FNAGetUOMConvertValue](@from_uom_id INT,@to_uom_id INT)

RETURNS FLOAT AS

BEGIN
	
 /*
 declare @from_uom_id INT=1,@to_uom_id INT=71;	
 
	
	

 /*
 
	DROP TABLE  #rec_volume_unit_conversion
 
	select from_source_uom_id,to_source_uom_id,conversion_factor,rowid=IDENTITY(INT,1,1) INTO  #rec_volume_unit_conversion from rec_volume_unit_conversion


	DELETE #rec_volume_unit_conversion WHERE rowid NOT IN(1,3,12,23)
 
	update #rec_volume_unit_conversion set conversion_factor=10 WHERE rowid=23 -- NOT IN(1,3,12,23)
 
 
 
	SELECT * FROM #rec_volume_unit_conversion 
 */

 
 --*/

	DECLARE @return_value FLOAT
	
	 IF  @from_uom_id=@to_uom_id
	 BEGIN
 		SET @return_value= 1
	 END
	 ELSE
	 BEGIN
 	
 		IF (
 			EXISTS(SELECT 1 FROM rec_volume_unit_conversion WHERE from_source_uom_id=@from_uom_id)
 			 or EXISTS(SELECT 1 FROM rec_volume_unit_conversion WHERE to_source_uom_id=@from_uom_id)
 			)
 			AND 
 			(
 			EXISTS(SELECT 1 FROM rec_volume_unit_conversion WHERE from_source_uom_id=@to_uom_id)
 				or EXISTS(SELECT 1 FROM rec_volume_unit_conversion WHERE to_source_uom_id=@to_uom_id)
 			)
 		
 		BEGIN

		 WITH uom_conv(hrchy,from_uom_id, to_uom_id,fact, conv_value, mult,lbl,end_status) AS 
			(
				SELECT cast(right('000'+cast(@from_uom_id as varchar),4) as varchar(max)) hrchy , @from_uom_id, @from_uom_id, cast(1.00 AS float) fact, cast(1.00 AS float) conversion_factor, 1 mult,1 lbl, 0 end_status --FOR downward (*)
				UNION
				SELECT cast(right('000'+cast(@to_uom_id as varchar),4) as varchar(max)) hrchy ,@to_uom_id, @to_uom_id, cast(1.00 AS float) fact, cast(1.00 AS float) conversion_factor, 0 mult,1 lbl, 0 end_status -- for upward (/)

				UNION ALL
				SELECT hrchy+','+right('000'+cast(up.from_source_uom_id as varchar),4) hrchy ,from_source_uom_id,to_source_uom_id,cast(conversion_factor as float) fact,conversion_factor/conv_value,0 mult
				, lbl+1  lbl,case when up.to_source_uom_id=@from_uom_id then 1 else 0 end end_status
				FROM rec_volume_unit_conversion up INNER JOIN uom_conv uc  
					ON  up.to_source_uom_id=uc.from_uom_id AND uc.mult=0 and lbl<10  and end_status<>1
    
				UNION ALL
				SELECT hrchy+','+right('000'+cast(down.from_source_uom_id as varchar),4) hrchy ,from_source_uom_id,to_source_uom_id,cast(conversion_factor as float) fact,conv_value*conversion_factor,1 mult
					, lbl+1  lbl,case when down.to_source_uom_id=@to_uom_id then 1 else 0 end end_status --   case when to_uom_id=@to_uom_id then -1 else lbl+1 end lbl
				FROM rec_volume_unit_conversion down INNER JOIN uom_conv uc  
					ON  down.from_source_uom_id=uc.to_uom_id  AND uc.mult=1 and lbl<10 
					and uc.from_uom_id<>down.to_source_uom_id and end_status<>1-- and down.from_source_uom_id not in (hrchy)

			)
			SELECT TOP(1) @return_value=conv_value FROM uom_conv
			WHERE (mult=1 AND to_uom_id=@to_uom_id  ) and end_status=1
			order by lbl 
			OPTION (MAXRECURSION 32767);
 		END
 		ELSE
 			SET @return_value= 1
 		
 		
		 --select * from rec_volume_unit_conversion
	 END
	 
	 RETURN isnull(@return_value,1)
 END

