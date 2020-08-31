IF COL_LENGTH('delete_source_deal_header ', 'reporting_group1') IS NULL
BEGIN
	 
	 ALTER TABLE 
	 /**
	  Add column reporting_group1
	*/
	delete_source_deal_header  ADD reporting_group1 NVARCHAR(1000) 
END
GO

IF COL_LENGTH('delete_source_deal_header ', 'reporting_group2') IS NULL
BEGIN
	 
	 ALTER TABLE 
	 /**
	  Add column reporting_group2
	*/
	delete_source_deal_header  ADD reporting_group2 NVARCHAR(1000) 
END
GO

IF COL_LENGTH('delete_source_deal_header ', 'reporting_group3') IS NULL
BEGIN
	 
	 ALTER TABLE 
	 /**
	  Add column reporting_group3
	*/
	delete_source_deal_header  ADD reporting_group3 NVARCHAR(1000) 
END
GO

IF COL_LENGTH('delete_source_deal_header ', 'reporting_group4') IS NULL
BEGIN
	 
	 ALTER TABLE 
	 /**
	  Add column reporting_group4
	*/
	delete_source_deal_header  ADD reporting_group4 NVARCHAR(1000) 
END
GO

IF COL_LENGTH('delete_source_deal_header ', 'reporting_group5') IS NULL
BEGIN
	 
	 ALTER TABLE 
	 /**
	  Add column reporting_group5
	*/
	delete_source_deal_header  ADD reporting_group5 NVARCHAR(1000) 
END
GO


