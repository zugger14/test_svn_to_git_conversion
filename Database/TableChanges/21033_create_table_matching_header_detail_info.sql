SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[matching_header_detail_info]', N'U') IS NULL
BEGIN
	CREATE TABLE matching_header_detail_info(
		id INT IDENTITY(1, 1), 
		link_id INT, 
		source_deal_header_id INT, 
		source_deal_detail_id INT, 
		source_deal_header_id_from INT, 
		source_deal_detail_id_from INT,
		assigned_vol INT,
		state_value_id INT,
		tier_value_id INT)
END
ELSE
BEGIN
    PRINT 'Table matching_header_detail_info EXISTS'
END