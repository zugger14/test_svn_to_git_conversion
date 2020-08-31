IF  EXISTS 
(
	select 1 from sys.columns where name = 'tier' and object_name(object_id) = 'Gis_product'
) 
AND NOT EXISTS 
(
	select 1 from sys.columns where name = 'tier_id' and object_name(object_id) = 'Gis_product'
)
BEGIN
	EXEC sp_rename '[dbo].[Gis_product].tier', 'tier_id', 'tier'; 
END