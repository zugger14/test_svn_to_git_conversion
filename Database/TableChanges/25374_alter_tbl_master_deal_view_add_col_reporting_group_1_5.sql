IF COL_LENGTH('master_deal_view ', 'reporting_group1') IS NULL
BEGIN
	 ALTER TABLE 
	 /**
	  Add column reporting_group1
	*/
	master_deal_view  ADD reporting_group1 NVARCHAR(1000) 
END
GO

IF COL_LENGTH('master_deal_view ', 'reporting_group2') IS NULL
BEGIN
	 
	 ALTER TABLE 
	 /**
	  Add column reporting_group2
	*/
	master_deal_view  ADD reporting_group2 NVARCHAR(1000) 
END
GO

IF COL_LENGTH('master_deal_view ', 'reporting_group3') IS NULL
BEGIN
	 
	 ALTER TABLE /**
	  Add column reporting_group3
	*/
	master_deal_view  ADD reporting_group3 NVARCHAR(1000) 
END
GO

IF COL_LENGTH('master_deal_view ', 'reporting_group4') IS NULL
BEGIN
	 ALTER TABLE /**
	  Add column reporting_group4
	*/
	master_deal_view  ADD reporting_group4 NVARCHAR(1000) 
END
GO

IF COL_LENGTH('master_deal_view ', 'reporting_group5') IS NULL
BEGIN
	 ALTER TABLE 
	 /**
	  Add column reporting_group5
	*/
	master_deal_view  ADD reporting_group5 NVARCHAR(1000) 
END
GO

