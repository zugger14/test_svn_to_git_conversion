
--SELECT dbo.[FNAGetUOMConvertValueWithFactor](1,6,1,6,5)
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetUOMConvertValueWithFactor]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNAGetUOMConvertValueWithFactor]
GO



CREATE FUNCTION [dbo].[FNAGetUOMConvertValueWithFactor](@from_uom_id INT,@to_uom_id INT,@factor_from_uom_id INT,@factor_to_uom_id INT,@factor_value float)

RETURNS FLOAT AS

BEGIN
	
 /*
 declare --@from_uom_id INT=1,@to_uom_id INT=71;	
 
@from_uom_id INT=74,@to_uom_id INT=75,@factor_from_uom_id INT=74,@factor_to_uom_id INT=73,@factor_value float	=6.8
	

 /*
 
	DROP TABLE  #rec_volume_unit_conversion
 
	select from_source_uom_id,to_source_uom_id,conversion_factor,rowid=IDENTITY(INT,1,1) INTO  #rec_volume_unit_conversion from rec_volume_unit_conversion


	DELETE #rec_volume_unit_conversion WHERE rowid NOT IN(1,3,12,23)
 
	update #rec_volume_unit_conversion set conversion_factor=10 WHERE rowid=23 -- NOT IN(1,3,12,23)
 
 
 
	SELECT * FROM #rec_volume_unit_conversion 
 */



 
 
 --*/

	DECLARE @return_value FLOAT
	
	declare @rec_volume_unit_conversion table (
	from_source_uom_id int,to_source_uom_id int,conversion_factor float
	)
	declare @rec_volume_unit_conversion_distinct table (rowid int identity(1,1),
	from_source_uom_id int,to_source_uom_id int,conversion_factor float
	)

	 IF  @from_uom_id=@to_uom_id
 		SET @return_value= 1
	 else if  @from_uom_id=@factor_from_uom_id and  @to_uom_id=@factor_to_uom_id 
		SET @return_value= @factor_value
	  else if  @from_uom_id=@factor_to_uom_id and  @to_uom_id=@factor_from_uom_id
		SET @return_value=1.00/@factor_value
	
	 ELSE
	 BEGIN
		insert into @rec_volume_unit_conversion (
				from_source_uom_id ,to_source_uom_id ,conversion_factor
			)
	 		select from_source_uom_id,to_source_uom_id,conversion_factor  from rec_volume_unit_conversion 
				where not ((from_source_uom_id=@factor_from_uom_id and to_source_uom_id=@factor_to_uom_id) or (from_source_uom_id=@factor_to_uom_id and to_source_uom_id=@factor_from_uom_id))
			union all 
			select @factor_from_uom_id from_source_uom_id,@factor_to_uom_id to_source_uom_id,@factor_value conversion_factor
			union all 
			select @factor_to_uom_id from_source_uom_id,@factor_from_uom_id to_source_uom_id,1.00/@factor_value conversion_factor

			
			
	--select * from @rec_volume_unit_conversion	--where 	from_source_uom_id=73 and to_source_uom_id=75
/*		
			
insert into @rec_volume_unit_conversion (
				from_source_uom_id ,to_source_uom_id ,conversion_factor
			)

			values
			(72,1,0.001),
(83,81,42000),
(73,82,0.001),
(82,73,1000),
(81,73,0.0238095238095238),
(73,81,42),
(84,81,29000),
(82,81,42000),
(81,82,0.0000238095238095238),
(85,81,42000),
(86,81,14500),
(87,81,14500),
(73,83,42),
(75,73,0.0238095238095238),
(88,74,0.001),
(74,88,1000),
(73,75,42),
(75,90,3.78541),
(90,75,0.264172176857989),
(73,90,158.9322),
(90,73,0.0062919911761116),
(74,73,6.8),
(73,74,0.147058823529412)
*/
--select * from @rec_volume_unit_conversion

insert into @rec_volume_unit_conversion_distinct (
				from_source_uom_id ,to_source_uom_id ,conversion_factor
			)
select frm.from_source_uom_id ,frm.to_source_uom_id ,frm.conversion_factor from  @rec_volume_unit_conversion frm
where not exists(select 1 from @rec_volume_unit_conversion t where (frm.from_source_uom_id=t.to_source_uom_id 
		and t.from_source_uom_id=frm.to_source_uom_id))
union all
select frm.from_source_uom_id ,frm.to_source_uom_id ,frm.conversion_factor from  @rec_volume_unit_conversion frm
where  exists(select 1 from @rec_volume_unit_conversion t where (frm.from_source_uom_id=t.to_source_uom_id 
		and t.from_source_uom_id=frm.to_source_uom_id ))
	
	--select * from @rec_volume_unit_conversion_distinct
 		--	select from_source_uom_id,to_source_uom_id,conversion_factor  from rec_volume_unit_conversion 
			--	where not ((from_source_uom_id=@factor_from_uom_id and to_source_uom_id=@factor_to_uom_id) or (from_source_uom_id=@factor_to_uom_id and to_source_uom_id=@factor_from_uom_id))
			--union all 
			--select @factor_from_uom_id from_source_uom_id,@factor_to_uom_id to_source_uom_id,@factor_value conversion_factor
			--union all 
			--select @factor_to_uom_id from_source_uom_id,@factor_from_uom_id to_source_uom_id,1.00/@factor_value conversion_factor


 		IF (
 				EXISTS(SELECT 1 FROM @rec_volume_unit_conversion WHERE from_source_uom_id=@from_uom_id)
 				 or EXISTS(SELECT 1 FROM @rec_volume_unit_conversion WHERE to_source_uom_id=@from_uom_id)
 			)
 			AND 
 			(
 				EXISTS(SELECT 1 FROM @rec_volume_unit_conversion WHERE from_source_uom_id=@to_uom_id)
 					or EXISTS(SELECT 1 FROM @rec_volume_unit_conversion WHERE to_source_uom_id=@to_uom_id)
 			)
 		
 		BEGIN

			WITH uom_conv(hrchy,from_uom_id, to_uom_id,fact, conv_value, mult,lbl,end_status) AS 
			(
				SELECT cast(right('000'+cast(@from_uom_id as varchar),4) as varchar(max)) hrchy , @from_uom_id, @from_uom_id, cast(1.00 AS float) fact, cast(1.00 AS float) conversion_factor, 1 mult,1 lbl, 0 end_status --FOR downward (*)
				UNION
				SELECT cast(right('000'+cast(@to_uom_id as varchar),4) as varchar(max)) hrchy ,@to_uom_id, @to_uom_id, cast(1.00 AS float) fact, cast(1.00 AS float) conversion_factor, 0 mult,1 lbl, 0 end_status -- for upward (/)

				UNION ALL
				SELECT hrchy+','+right('000'+cast(up.from_source_uom_id as varchar),4) hrchy ,from_source_uom_id,to_source_uom_id,conversion_factor fact,conversion_factor/conv_value,0 mult
				, lbl+1  lbl,case when up.to_source_uom_id=@from_uom_id then 1 else 0 end end_status
				FROM @rec_volume_unit_conversion up INNER JOIN uom_conv uc  
				  ON  up.to_source_uom_id=uc.from_uom_id AND uc.mult=0 and lbl<10  and end_status<>1
    
				UNION ALL
				SELECT hrchy+','+right('000'+cast(down.from_source_uom_id as varchar),4) hrchy ,from_source_uom_id,to_source_uom_id,conversion_factor fact,conv_value*conversion_factor,1 mult
					, lbl+1  lbl,case when down.to_source_uom_id=@to_uom_id then 1 else 0 end end_status --   case when to_uom_id=@to_uom_id then -1 else lbl+1 end lbl
				FROM @rec_volume_unit_conversion_distinct down INNER JOIN uom_conv uc  
				  ON  down.from_source_uom_id=uc.to_uom_id  AND uc.mult=1 and lbl<10 
				  and uc.from_uom_id<>down.to_source_uom_id and end_status<>1-- and down.from_source_uom_id not in (hrchy)

			)
			SELECT TOP(1) @return_value=conv_value 
			  FROM uom_conv
			WHERE (mult=1 AND to_uom_id=@to_uom_id  ) and end_status=1
			order by lbl 
			OPTION (MAXRECURSION 32767);
			
	
 		END
 		ELSE
 			SET @return_value= 1
 		
 		
		 --select * from @rec_volume_unit_conversion
	 END
	-- select isnull(@return_value,1)
	return isnull(@return_value,1)
 END