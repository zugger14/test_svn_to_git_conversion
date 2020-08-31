IF OBJECT_ID(N'FNARLocationGrid', N'FN') IS NOT NULL
DROP FUNCTION dbo.FNARLocationGrid
GO 
-- SELECT dbo.FNARLocationGrid(NULL,18,19002)
CREATE FUNCTION dbo.FNARLocationGrid
(
	@source_deal_header_id  INT,
	@source_deal_detail_id  INT,
	@aggregation_level      INT
)
RETURNS FLOAT
AS
	
BEGIN 
	DECLARE @grid_id INT
	
	IF @aggregation_level=19000
	BEGIN
	
			SELECT @grid_id =	MAX(grid_value_id)
			FROM
				source_deal_header sdh inner join
				source_deal_detail sdd on sdd.source_deal_header_id = sdh.source_deal_header_id 
				INNER JOIN source_minor_location sml ON sml.source_minor_location_id=sdd.location_id
			WHERE
				sdh.source_deal_header_id = @source_deal_header_id
		END
	ELSE IF @aggregation_level=19002
		BEGIN
			SELECT @grid_id =	MAX(grid_value_id)
			FROM
				source_deal_header sdh inner join
				source_deal_detail sdd on sdd.source_deal_header_id = sdh.source_deal_header_id 
				INNER JOIN source_minor_location sml ON sml.source_minor_location_id=sdd.location_id
			WHERE
				sdd.source_deal_detail_id = @source_deal_detail_id
		
		END		
		
	RETURN isnull(@grid_id, 0)
END




