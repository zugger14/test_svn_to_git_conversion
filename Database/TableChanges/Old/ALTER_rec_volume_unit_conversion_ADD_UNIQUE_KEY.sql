--delete duplicate data first
DELETE FROM rec_volume_unit_conversion 
WHERE rec_volume_unit_conversion_id IN (197,201,207,220,233,166,163,215,258,219,198,202,213,217,204,199,242,214,218,205)
GO

--create unique index
ALTER TABLE dbo.rec_volume_unit_conversion ADD CONSTRAINT
	IX_rec_volume_unit_conversion_1 UNIQUE NONCLUSTERED 
	(
	curve_id,
	state_value_id,
	assignment_type_value_id,
	from_source_uom_id,
	to_source_uom_id,
	to_curve_id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

