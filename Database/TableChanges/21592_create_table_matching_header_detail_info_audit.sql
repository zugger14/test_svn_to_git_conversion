SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[matching_header_detail_info_audit]', N'U') IS NULL
BEGIN
	CREATE TABLE matching_header_detail_info_audit(
		audit_id INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
		id INT, 
		link_id INT, 
		source_deal_header_id INT, 
		source_deal_detail_id INT, 
		source_deal_header_id_from INT, 
		source_deal_detail_id_from INT,
		assigned_vol INT,
		state_value_id INT,
		tier_value_id INT,
		create_ts DATETIME,
		create_user VARCHAR(50),
		update_ts DATETIME,
		update_user VARCHAR(50),
		user_action VARCHAR(50))
END
ELSE
BEGIN
    PRINT 'Table matching_header_detail_info_audit EXISTS'
END