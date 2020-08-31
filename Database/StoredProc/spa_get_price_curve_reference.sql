IF OBJECT_ID('[dbo].[spa_get_price_curve_reference]','p') IS NOT NULL
	DROP PROC [dbo].[spa_get_price_curve_reference]
GO
/****** Object:  StoredProcedure [dbo].[spa_get_price_curve_reference]    Script Date: 06/23/2009 15:28:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************
Created By: Anal Shrestha
Created On: march 25 2009
Description: This SP returns the references to any curves in a process table
************************************************/
CREATE PROC [dbo].[spa_get_price_curve_reference]
			@table_name VARCHAR(100),
			@curve_id VARCHAR(100)=NULL
AS 
BEGIN

	DEClARE @sql_stmt VARCHAR(MAX)


	CREATE TABLE #temp_reference (
				[id] INT Identity, curveid INT,curveid1 INT,curveid2 INT,curveid3 INT,curveid4 INT,curveid5 INT,curveid6 INT,curveid7 INT,curveid8 INT,curveid9 INT,curveid10 INT,
				factor1 FLOAT,factor2 FLOAT,factor3 FLOAT,factor4 FLOAT,factor5 FLOAT,factor6 FLOAT,factor7 FLOAT,factor8 FLOAT,factor9 FLOAT,factor10 FLOAT
	
			)


-----###### Get the reference curves	
		SET @sql_stmt='
			INSERT INTO #temp_reference(
						curveid ,curveid1 ,curveid2 ,curveid3 ,curveid4 ,curveid5 ,curveid6 ,curveid7 ,curveid8 ,curveid9 ,curveid10, 
						factor1 ,factor2 ,factor3 ,factor4 ,factor5 ,factor6 ,factor7 ,factor8 ,factor9 ,factor10 )
			SELECT 
					curveid,cr.REFID_1 curveid1,cr.REFID_2 curveid2,cr.REFID_3 curveid3,cr.REFID_4 curveid4,cr.REFID_5 curveid5,cr.REFID_6 curveid6,cr.REFID_7 curveid7,cr.REFID_8 curveid8,cr.REFID_9 curveid9,cr.REFID_10 curveid10,
					cr.Factor_1 factor1,cr.Factor_2 factor2,cr.Factor_3 factor3,cr.Factor_4 factor4,cr.Factor_5 factor5,cr.Factor_6 factor6,cr.Factor_7 factor7,cr.Factor_8 factor8,cr.Factor_9 factor9,cr.Factor_10 factor10
					
			FROM
				CurveReferenceHierarchy cr
			WHERE 1=1 AND
				REFID_1 IS NOT NULL	'+
			CASE WHEN @curve_id IS NOT NULL THEN ' AND cr.curveid in('+@curve_id+')' ELSE '' END
		
		EXEC(@sql_stmt)
			

--#### now get the reference and add in table in each row


	SET @sql_stmt='

	SELECT DISTINCT
		a.Curve_ID,a.Curve_ref_id,ISNULL(b.factor,1) factor
	INTO
		'+@table_name+'
	FROM
		
		(SELECT 
					row_number() OVER (PARTITION BY [id] order by [id]) as [ID],curve_id Curve_ID,refrence_id Curve_ref_id
				 FROM 
						(

						SELECT 
								[id], curveid,curveid1,
								(curveid1) curve_id
						   FROM 
								#temp_reference

						) p
				
						UNPIVOT
						   (refrence_id FOR curves IN 
							  (curveid,curveid1)
							
						)AS unpvt

			UNION
				SELECT 
					row_number() OVER (PARTITION BY [id] order by [id]) as [ID],curve_id Curve_ID,refrence_id Curve_ref_id
				 FROM 
						(

						SELECT 
								[id], curveid,curveid1,curveid2,
								(curveid2) curve_id
						   FROM 
								#temp_reference

						) p
				
						UNPIVOT
						   (refrence_id FOR curves IN 
							  (curveid,curveid1,curveid2)
							
						)AS unpvt
			UNION	

				SELECT 
					row_number() OVER (PARTITION BY [id] order by [id]) as [ID],curve_id Curve_ID,refrence_id Curve_ref_id
				 FROM 
						(

						SELECT 
								[id], curveid,curveid1,curveid2,curveid3,
								(curveid3) curve_id
						   FROM 
								#temp_reference where curveid3 IS NOT NULL

						) p
				
						UNPIVOT
						   (refrence_id FOR curves IN 
							  (curveid,curveid1,curveid2,curveid3)
							
						)AS unpvt
			UNION	

				SELECT 
					row_number() OVER (PARTITION BY [id] order by [id]) as [ID],curve_id Curve_ID,refrence_id Curve_ref_id
				 FROM 
						(

						SELECT 
								[id], curveid,curveid1,curveid2,curveid3,curveid4,
								(curveid4) curve_id
						   FROM 
								#temp_reference where curveid4 IS NOT NULL

						) p
				
						UNPIVOT
						   (refrence_id FOR curves IN 
							  (curveid,curveid1,curveid2,curveid3,curveid4)
							
						)AS unpvt
			UNION	

				SELECT 
					row_number() OVER (PARTITION BY [id] order by [id]) as [ID],curve_id Curve_ID,refrence_id Curve_ref_id
				 FROM 
						(

						SELECT 
								[id], curveid,curveid1,curveid2,curveid3,curveid4,curveid5,
								(curveid5) curve_id
						   FROM 
								#temp_reference where curveid5 IS NOT NULL

						) p
				
						UNPIVOT
						   (refrence_id FOR curves IN 
							  (curveid,curveid1,curveid2,curveid3,curveid4,curveid5)
							
						)AS unpvt
			UNION	

				SELECT 
					row_number() OVER (PARTITION BY [id] order by [id]) as [ID],curve_id Curve_ID,refrence_id Curve_ref_id
				 FROM 
						(

						SELECT 
								[id], curveid,curveid1,curveid2,curveid3,curveid4,curveid5,curveid6,
								(curveid6) curve_id
						   FROM 
								#temp_reference where curveid5 IS NOT NULL

						) p
				
						UNPIVOT
						   (refrence_id FOR curves IN 
							  (curveid,curveid1,curveid2,curveid3,curveid4,curveid5,curveid6)
							
						)AS unpvt
			UNION	

				SELECT 
					row_number() OVER (PARTITION BY [id] order by [id]) as [ID],curve_id Curve_ID,refrence_id Curve_ref_id
				 FROM 
						(

						SELECT 
								[id], curveid,curveid1,curveid2,curveid3,curveid4,curveid5,curveid6,curveid7,
								(curveid7) curve_id
						   FROM 
								#temp_reference where curveid7 IS NOT NULL

						) p
				
						UNPIVOT
						   (refrence_id FOR curves IN 
							  (curveid,curveid1,curveid2,curveid3,curveid4,curveid5,curveid6,curveid7)
							
						)AS unpvt

			UNION	

				SELECT 
					row_number() OVER (PARTITION BY [id] order by [id]) as [ID],curve_id Curve_ID,refrence_id Curve_ref_id
				 FROM 
						(

						SELECT 
								[id], curveid,curveid1,curveid2,curveid3,curveid4,curveid5,curveid6,curveid7,curveid8,
								(curveid8) curve_id
						   FROM 
								#temp_reference where curveid8 IS NOT NULL

						) p
				
						UNPIVOT
						   (refrence_id FOR curves IN 
							  (curveid,curveid1,curveid2,curveid3,curveid4,curveid5,curveid6,curveid7,curveid8)
							
						)AS unpvt
			UNION	

				SELECT 
					row_number() OVER (PARTITION BY [id] order by [id]) as [ID],curve_id Curve_ID,refrence_id Curve_ref_id
				 FROM 
						(

						SELECT 
								[id], curveid,curveid1,curveid2,curveid3,curveid4,curveid5,curveid6,curveid7,curveid8,curveid9,
								(curveid9) curve_id
						   FROM 
								#temp_reference where curveid9 IS NOT NULL

						) p
				
						UNPIVOT
						   (refrence_id FOR curves IN 
							  (curveid,curveid1,curveid2,curveid3,curveid4,curveid5,curveid6,curveid7,curveid8,curveid9)
							
						)AS unpvt

			UNION	

				SELECT 
					row_number() OVER (PARTITION BY [id] order by [id]) as [ID],curve_id Curve_ID,refrence_id Curve_ref_id
				 FROM 
						(

						SELECT 
								[id], curveid,curveid1,curveid2,curveid3,curveid4,curveid5,curveid6,curveid7,curveid8,curveid9,curveid10,
								(curveid10) curve_id
						   FROM 
								#temp_reference where curveid10 IS NOT NULL

						) p
				
						UNPIVOT
						   (refrence_id FOR curves IN 
							  (curveid,curveid1,curveid2,curveid3,curveid4,curveid5,curveid6,curveid7,curveid8,curveid9,curveid10)
							
						)AS unpvt
		) a

		LEFT join
		
		(SELECT 
			row_number() OVER (PARTITION BY [id] order by [id]) as [ID],curve_id Curve_ID,factors factor
		 FROM 
				   (

				SELECT 
						[id],curveid,factor1,factor2,factor3,factor4,factor5,factor6,factor7,factor8,factor9,factor10,
						COALESCE(curveid10,curveid9,curveid8,curveid7,curveid6,curveid5,curveid4,curveid3,curveid2,curveid1) curve_id
				   FROM 
						#temp_reference

				) p
				
				UNPIVOT
				   (factors FOR factor IN 
					  (factor1,factor2,factor3,factor4,factor5,factor6,factor7,factor8,factor9,factor10)
					
				)AS unpvt
		) b
		on a.[id]=b.[id] and a.Curve_ID=b.Curve_ID
	'
	--print 	@sql_stmt
	EXEC(@sql_stmt)
END