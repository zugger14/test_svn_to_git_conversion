 IF COL_LENGTH('forecast_mapping', 'active') IS NULL
 BEGIN
     ALTER TABLE forecast_mapping ADD active char
 END
 GO
 
 IF COL_LENGTH('forecast_profile', 'granularity') IS NULL
 BEGIN
     ALTER TABLE forecast_profile ADD granularity INT
 END
 GO
