
/*---------------------------------Data Patch---------------------------------------*/
/*Author	  : Vishwas Khanal														*/
/*Description : On the creation of the PriceCurve the entry is made in the			*/	
/*			  : curveReferenceHierarchy table regardless of the reference given.	*/
/*			  : Hence, creating the entry for the already existing curve.			*/
-------------------------------------------------------------------------------------
--DELETE FROM curveReferenceHierarchy
BEGIN TRAN
	INSERT  INTO curveReferenceHierarchy(curveId,factor) 
		SELECT source_curve_def_id,1 FROM
			   source_price_curve_def 
			LEFT OUTER JOIN curveReferenceHierarchy
	ON source_curve_def_id  = curveId
	WHERE curveid IS NULL
COMMIT TRAN


