IF COL_LENGTH('source_deal_header_audit ', 'reporting_group1') IS NULL
BEGIN
	 
	 ALTER TABLE 
	 /**
	  Add column reporting_group1
	*/
	source_deal_header_audit  ADD reporting_group1 NVARCHAR(1000) 
END
GO

IF COL_LENGTH('source_deal_header_audit ', 'reporting_group2') IS NULL
BEGIN
	 
	 ALTER TABLE 
	 /**
	  Add column reporting_group2
	*/
	source_deal_header_audit  ADD reporting_group2 NVARCHAR(1000) 
END
GO

IF COL_LENGTH('source_deal_header_audit ', 'reporting_group3') IS NULL
BEGIN
	 ALTER TABLE 
	 /**
	  Add column reporting_group3
	*/
	source_deal_header_audit  ADD reporting_group3 NVARCHAR(1000) 
END
GO

IF COL_LENGTH('source_deal_header_audit ', 'reporting_group4') IS NULL
BEGIN
	 
	 ALTER TABLE 
	 /**
	  Add column reporting_group4
	*/
	source_deal_header_audit  ADD reporting_group4 NVARCHAR(1000) 
END
GO

IF COL_LENGTH('source_deal_header_audit ', 'reporting_group5') IS NULL
BEGIN
	 
	 ALTER TABLE 
	 /**
	  Add column reporting_group5
	*/
	source_deal_header_audit  ADD reporting_group5 NVARCHAR(1000) 
END
GO


