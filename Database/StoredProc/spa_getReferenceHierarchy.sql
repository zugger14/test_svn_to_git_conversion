
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_getReferenceHierarchy]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_getReferenceHierarchy]


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

/*
	Author : Vishwas Khanal
	Dated  : 02.Sep.2009
	Desc   : For the passed @curve_id this will give you the list of all the curve name and curve ids from the CurveReferenceHierarcy in 
			 Comma Seperated Format.			  
*/	
CREATE PROC [dbo].[spa_getReferenceHierarchy]
@curve_id	INT,
@flag		CHAR(1) = NULL --'i' : outputs the ID. 's' : outputs the curvenames
AS
BEGIN			
			CREATE TABLE #Hierarchy (sno INT IDENTITY,CurveId INT,curve_name varchar(100) COLLATE DATABASE_DEFAULT)
			
			DECLARE @lastfoundcol	  VARCHAR(20)	,		       			
					@return			  VARCHAR(8000)	,
					@sqlString		  VARCHAR(MAX)					

				/*******************************************************************************************
					Get The List of all curvesIDs parent to the @curve_id from CurveReferenceHierarchy
				********************************************************************************************/
				SELECT @lastfoundcol  = 'curveId'  FROM CurveReferenceHierarchy WHERE curveId   = @curve_id 
				SELECT @lastfoundcol  = 'RefID_1'  FROM CurveReferenceHierarchy WHERE RefID_1   = @curve_id
				SELECT @lastfoundcol  = 'RefID_2'  FROM CurveReferenceHierarchy WHERE RefID_2   = @curve_id
				SELECT @lastfoundcol  = 'RefID_3'  FROM CurveReferenceHierarchy WHERE RefID_3   = @curve_id
				SELECT @lastfoundcol  = 'RefID_4'  FROM CurveReferenceHierarchy WHERE RefID_4   = @curve_id
				SELECT @lastfoundcol  = 'RefID_5'  FROM CurveReferenceHierarchy WHERE RefID_5   = @curve_id
				SELECT @lastfoundcol  = 'RefID_6'  FROM CurveReferenceHierarchy WHERE RefID_6   = @curve_id
				SELECT @lastfoundcol  = 'RefID_7'  FROM CurveReferenceHierarchy WHERE RefID_7   = @curve_id
				SELECT @lastfoundcol  = 'RefID_8'  FROM CurveReferenceHierarchy WHERE RefID_8   = @curve_id
				SELECT @lastfoundcol  = 'RefID_9'  FROM CurveReferenceHierarchy WHERE RefID_9   = @curve_id
				SELECT @lastfoundcol  = 'RefID_10' FROM CurveReferenceHierarchy WHERE RefID_10  = @curve_id
										
				SELECT @sqlString = 'DECLARE  @RefID_0_tmp	  INT	,
							   @RefID_1_tmp	  INT	,
							   @RefID_2_tmp	  INT	, 
							   @RefID_3_tmp	  INT	, 
							   @RefID_4_tmp	  INT	, 
							   @RefID_5_tmp	  INT	,
							   @RefID_6_tmp	  INT	, 
							   @RefID_7_tmp	  INT	, 
							   @RefID_8_tmp	  INT	, 
							   @RefID_9_tmp	  INT	, 
							   @RefID_10_tmp  INT

				SELECT @RefID_0_tmp  = curveId	,
					   @RefID_1_tmp  = RefID_1	,
					   @RefID_2_tmp	 = RefID_2	, 
					   @RefID_3_tmp	 = RefID_3	, 
					   @RefID_4_tmp	 = RefID_4	, 
					   @RefID_5_tmp	 = RefID_5	,
					   @RefID_6_tmp	 = RefID_6	, 
					   @RefID_7_tmp	 = RefID_7	, 
					   @RefID_8_tmp	 = RefID_8	, 
					   @RefID_9_tmp	 = RefID_9	, 
					   @RefID_10_tmp = RefID_10
				FROM CurveReferenceHierarchy 
				WHERE '+ @lastfoundcol+' = '+CAST(@curve_id	AS VARCHAR)+' 
				
				IF '''+@lastfoundcol+''' = '+'''curveId'''+' 						
					  SELECT @RefID_1_tmp = NULL,@RefID_2_tmp = NULL, 
							 @RefID_3_tmp = NULL,@RefID_4_tmp = NULL,@RefID_5_tmp = NULL,@RefID_6_tmp  = NULL,
							 @RefID_7_tmp = NULL,@RefID_8_tmp = NULL,@RefID_9_tmp = NULL,@RefID_10_tmp = NULL 
				
				IF '''+@lastfoundcol+''' = '+'''RefID_1'''+' 						
					  SELECT @RefID_2_tmp = NULL,
							 @RefID_3_tmp = NULL,@RefID_4_tmp = NULL,@RefID_5_tmp = NULL,@RefID_6_tmp  = NULL,
							 @RefID_7_tmp = NULL,@RefID_8_tmp = NULL,@RefID_9_tmp = NULL,@RefID_10_tmp = NULL 

				IF '''+@lastfoundcol+''' = '+'''RefID_2'''+' 						
					  SELECT @RefID_3_tmp = NULL,@RefID_4_tmp = NULL,@RefID_5_tmp = NULL,@RefID_6_tmp  = NULL,
							 @RefID_7_tmp = NULL,@RefID_8_tmp = NULL,@RefID_9_tmp = NULL,@RefID_10_tmp = NULL 

				IF '''+@lastfoundcol+''' = '+'''RefID_3'''+' 						
					  SELECT @RefID_4_tmp = NULL,@RefID_5_tmp = NULL,@RefID_6_tmp  = NULL,
							 @RefID_7_tmp = NULL,@RefID_8_tmp = NULL,@RefID_9_tmp = NULL,@RefID_10_tmp = NULL 

				IF '''+@lastfoundcol+''' = '+'''RefID_4'''+' 						
					  SELECT @RefID_5_tmp = NULL,@RefID_6_tmp  = NULL,
							 @RefID_7_tmp = NULL,@RefID_8_tmp = NULL,@RefID_9_tmp = NULL,@RefID_10_tmp = NULL 

				IF '''+@lastfoundcol+''' = '+'''RefID_5'''+' 						
					  SELECT @RefID_6_tmp  = NULL,
							@RefID_7_tmp = NULL,@RefID_8_tmp = NULL,@RefID_9_tmp = NULL,@RefID_10_tmp = NULL 

				IF '''+@lastfoundcol+''' = '+'''RefID_6'''+' 						
					  SELECT @RefID_7_tmp = NULL,@RefID_8_tmp = NULL,@RefID_9_tmp = NULL,@RefID_10_tmp = NULL 

				IF '''+@lastfoundcol+''' = '+'''RefID_7'''+' 						
					  SELECT @RefID_8_tmp = NULL,@RefID_9_tmp = NULL,@RefID_10_tmp = NULL 

				IF '''+@lastfoundcol+''' = '+'''RefID_8'''+' 						
					  SELECT @RefID_9_tmp = NULL,@RefID_10_tmp = NULL 

				IF '''+@lastfoundcol+''' = '+'''RefID_9'''+' 						
					  SELECT @RefID_10_tmp = NULL 
			
				INSERT INTO  #Hierarchy  (curveid) values ( @RefID_0_tmp )
				INSERT INTO  #Hierarchy  (curveid) values ( @RefID_1_tmp )
				INSERT INTO  #Hierarchy  (curveid) values ( @RefID_2_tmp )
				INSERT INTO  #Hierarchy  (curveid) values ( @RefID_3_tmp )
				INSERT INTO  #Hierarchy  (curveid) values ( @RefID_4_tmp )
				INSERT INTO  #Hierarchy  (curveid) values ( @RefID_5_tmp )
				INSERT INTO  #Hierarchy  (curveid) values ( @RefID_6_tmp )
				INSERT INTO  #Hierarchy  (curveid) values ( @RefID_7_tmp )
				INSERT INTO  #Hierarchy  (curveid) values ( @RefID_8_tmp )
				INSERT INTO  #Hierarchy  (curveid) values ( @RefID_9_tmp )
				INSERT INTO  #Hierarchy  (curveid) values ( @RefID_10_tmp)'

				EXEC (@sqlString)
-- Old Logic				
--				UPDATE  #Hierarchy 
--					SET curve_name= spcd.curve_name 
--						FROM dbo.source_price_curve_def spcd
--							WHERE curveid=spcd.source_curve_def_id

-- New Logic
				UPDATE  #Hierarchy 
					SET curve_name= (spcd.curve_name + '.' + ssd.source_system_name) 
						FROM dbo.source_price_curve_def spcd
						inner join source_system_description ssd ON spcd.source_system_id = ssd.source_system_id
							WHERE curveid=spcd.source_curve_def_id

						
				IF	@flag = 'i'				
					SELECT curveId FROM #Hierarchy	WHERE curveid IS NOT NULL			
				ELSE IF	@flag = 'n'				
					SELECT curve_name FROM #Hierarchy WHERE curveid IS NOT NULL
				ELSE
					SELECT curveId ,curve_name FROM #Hierarchy WHERE curveid IS NOT NULL
END
