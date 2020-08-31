


IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.explain_mtm') AND name = N'indx_explain_mtm1')
BEGIN
	
	CREATE INDEX indx_explain_position1 ON explain_position (as_of_date_from,as_of_date_to)
	CREATE INDEX indx_explain_position2 ON explain_position (source_deal_header_id)
	CREATE INDEX indx_explain_position3 ON explain_position (curve_id)
	CREATE INDEX indx_explain_position4 ON explain_position (expiration_date)
	CREATE INDEX indx_explain_position5 ON explain_position (term_start,hr)

	CREATE INDEX indx_explain_mtm1 ON explain_mtm (as_of_date_from,as_of_date_to)
	CREATE INDEX indx_explain_mtm2 ON explain_mtm (source_deal_header_id)
	CREATE INDEX indx_explain_mtm3 ON explain_mtm (curve_id)
	CREATE INDEX indx_explain_mtm4 ON explain_mtm (term_start,hr)END
ELSE
BEGIN
	PRINT 'The Indexes ON TABLE explain_mtm AND explain_position are already exists.'
END
GO

