IF OBJECT_ID(N'FNACurveH', N'FN') IS NOT NULL
DROP FUNCTION FNACurveH
 GO 


CREATE FUNCTION FNACurveH (@curve_id VARCHAR(100), @volume_mult float)
RETURNS float AS  
BEGIN 
	return 1
END



