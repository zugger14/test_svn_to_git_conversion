IF OBJECT_ID('UC_location_id_rank_id') IS NULL
BEGIN
	ALTER TABLE [dbo].location_ranking WITH NOCHECK ADD CONSTRAINT [UC_location_id_rank_id] UNIQUE(location_id,rank_id)
	PRINT 'Unique Constraints added on location_ranking.'
END
ELSE
BEGIN
	PRINT 'Unique Constraints on location_ranking already exists.'
END