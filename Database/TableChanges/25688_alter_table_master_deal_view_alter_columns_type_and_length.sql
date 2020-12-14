IF COL_LENGTH('master_deal_view', 'deal_id') IS NOT NULL
BEGIN
	ALTER FULLTEXT INDEX ON  master_deal_view DROP (deal_id)
	ALTER TABLE master_deal_view 
	/**
		Parameter
		deal_id: Deal ID
	*/
	ALTER COLUMN deal_id NVARCHAR(200)
	ALTER FULLTEXT INDEX ON  master_deal_view ADD (deal_id)
END
GO

IF COL_LENGTH('master_deal_view', 'ext_deal_id') IS NOT NULL
BEGIN 
	ALTER FULLTEXT INDEX ON  master_deal_view DROP (ext_deal_id)
    ALTER TABLE master_deal_view 
	/**
		Parameter
		ext_deal_id:Ext Deal ID
	*/
	ALTER COLUMN ext_deal_id NVARCHAR(200)
	ALTER FULLTEXT INDEX ON  master_deal_view ADD (ext_deal_id)
END
GO

IF COL_LENGTH('master_deal_view', 'structured_deal_id') IS NOT NULL
BEGIN 
	ALTER FULLTEXT INDEX ON  master_deal_view DROP (structured_deal_id)
    ALTER TABLE master_deal_view 
	/**
		Parameter
		structured_deal_id:Structured Deal ID
	*/
	ALTER COLUMN structured_deal_id NVARCHAR(50)
	ALTER FULLTEXT INDEX ON  master_deal_view ADD (structured_deal_id)
END
GO


IF COL_LENGTH('master_deal_view', 'assigned_user') IS NOT NULL
BEGIN 
	ALTER FULLTEXT INDEX ON  master_deal_view DROP (assigned_user)
    ALTER TABLE master_deal_view 
	/**
		Parameter
		assigned_user : Assigned User
	*/
	ALTER COLUMN assigned_user NVARCHAR(50)
	ALTER FULLTEXT INDEX ON  master_deal_view ADD (assigned_user)
END
GO

IF COL_LENGTH('master_deal_view', 'parent_counterparty') IS NOT NULL
BEGIN 
	ALTER FULLTEXT INDEX ON  master_deal_view DROP (parent_counterparty)
    ALTER TABLE master_deal_view 
	/**
		Parameter
		parent_counterparty : Parent Counterparty Name
	*/
	ALTER COLUMN parent_counterparty NVARCHAR(250)
	ALTER FULLTEXT INDEX ON  master_deal_view ADD (parent_counterparty)
END
GO

IF COL_LENGTH('master_deal_view', 'deal_type') IS NOT NULL
BEGIN 
	ALTER FULLTEXT INDEX ON  master_deal_view DROP (deal_type)
    ALTER TABLE master_deal_view 
	/**
		Parameter
		deal_type : Deal Type
	*/
	ALTER COLUMN deal_type NVARCHAR(50)
	ALTER FULLTEXT INDEX ON  master_deal_view ADD (deal_type)
END
GO

IF COL_LENGTH('master_deal_view', 'deal_sub_type') IS NOT NULL
BEGIN 
	ALTER FULLTEXT INDEX ON  master_deal_view DROP (deal_sub_type)
    ALTER TABLE master_deal_view 
	/**
		Parameter
		deal_sub_type : Deal Sub Type
	*/
	ALTER COLUMN deal_sub_type VARCHAR(50)
	ALTER FULLTEXT INDEX ON  master_deal_view ADD (deal_sub_type)
END
GO

IF COL_LENGTH('master_deal_view', 'source_system_book_id1') IS NOT NULL
BEGIN 
	ALTER FULLTEXT INDEX ON  master_deal_view DROP (source_system_book_id1)
    ALTER TABLE master_deal_view 
	/**
		Parameter
		source_system_book_id1:Source System book id
	*/
	ALTER COLUMN source_system_book_id1  NVARCHAR(50)
	ALTER FULLTEXT INDEX ON  master_deal_view ADD (source_system_book_id1)
END
GO

IF COL_LENGTH('master_deal_view', 'source_system_book_id2') IS NOT NULL
BEGIN 
	ALTER FULLTEXT INDEX ON  master_deal_view DROP (source_system_book_id2)
    ALTER TABLE master_deal_view 
	/**
		Parameter
		source_system_book_id2 : Source System book id
	*/
	ALTER COLUMN source_system_book_id2  NVARCHAR(50)
	ALTER FULLTEXT INDEX ON  master_deal_view ADD (source_system_book_id2)
END
GO

IF COL_LENGTH('master_deal_view', 'source_system_book_id3') IS NOT NULL
BEGIN 
	ALTER FULLTEXT INDEX ON  master_deal_view DROP (source_system_book_id3)	
    ALTER TABLE master_deal_view 
	/**
		Parameter
		source_system_book_id3 : Source System book id
	*/
	ALTER COLUMN source_system_book_id3  NVARCHAR(50)
	ALTER FULLTEXT INDEX ON  master_deal_view ADD (source_system_book_id3)
END
GO

IF COL_LENGTH('master_deal_view', 'source_system_book_id4') IS NOT NULL
BEGIN 
	ALTER FULLTEXT INDEX ON  master_deal_view DROP (source_system_book_id4)
    ALTER TABLE master_deal_view 
	/**
		Parameter
		source_system_book_id4 : Source System book id
	*/
	ALTER COLUMN source_system_book_id4  NVARCHAR(50)
	ALTER FULLTEXT INDEX ON  master_deal_view ADD (source_system_book_id4)
END
GO

IF COL_LENGTH('master_deal_view', 'subsidiary') IS NOT NULL
BEGIN 
	ALTER FULLTEXT INDEX ON  master_deal_view DROP (subsidiary)
    ALTER TABLE master_deal_view 
	/**
		Parameter
		subsidiary : subsidiary
	*/
	ALTER COLUMN subsidiary NVARCHAR(100)
	ALTER FULLTEXT INDEX ON  master_deal_view ADD (subsidiary)
END
GO

IF COL_LENGTH('master_deal_view', 'strategy') IS NOT NULL
BEGIN 
	ALTER FULLTEXT INDEX ON  master_deal_view DROP (strategy)
    ALTER TABLE master_deal_view 
	/**
		Parameter
		strategy : strategy
	*/
	ALTER COLUMN strategy NVARCHAR(100)
	ALTER FULLTEXT INDEX ON  master_deal_view ADD (strategy)
END
GO

IF COL_LENGTH('master_deal_view', 'Book') IS NOT NULL
BEGIN 
	ALTER FULLTEXT INDEX ON  master_deal_view DROP (Book)
    ALTER TABLE master_deal_view 
	/**
		Parameter
		Book : Book
	*/
	ALTER COLUMN Book NVARCHAR(100)
	ALTER FULLTEXT INDEX ON  master_deal_view ADD (Book)
END
GO

IF COL_LENGTH('master_deal_view', 'trader') IS NOT NULL
BEGIN	
	ALTER FULLTEXT INDEX ON  master_deal_view DROP (trader)
    ALTER TABLE master_deal_view 
	/**
		Parameter
		trader : trader name
	*/
	ALTER COLUMN trader NVARCHAR(400)
	ALTER FULLTEXT INDEX ON  master_deal_view ADD (trader)
END
GO

IF COL_LENGTH('master_deal_view', 'trader2') IS NOT NULL
BEGIN
    ALTER TABLE master_deal_view 
	/**
		Parameter
		trader2 : traders name
	*/
	ALTER COLUMN trader2 NVARCHAR(400)
END
GO

IF COL_LENGTH('master_deal_view', 'template') IS NOT NULL
BEGIN 
	ALTER FULLTEXT INDEX ON  master_deal_view DROP (template)
    ALTER TABLE master_deal_view 
	/**
		Parameter
		template : template
	*/
	ALTER COLUMN template NVARCHAR(250)
	ALTER FULLTEXT INDEX ON  master_deal_view ADD (template)
END
GO

IF COL_LENGTH('master_deal_view', 'create_user') IS NOT NULL
BEGIN 
	ALTER FULLTEXT INDEX ON  master_deal_view DROP (create_user)
    ALTER TABLE master_deal_view 
	/**
		Parameter
		create_user : User name
	*/
	ALTER COLUMN create_user NVARCHAR(100)
	ALTER FULLTEXT INDEX ON  master_deal_view ADD (create_user)
END
GO

IF COL_LENGTH('master_deal_view', 'update_user') IS NOT NULL
BEGIN 
	ALTER FULLTEXT INDEX ON  master_deal_view DROP (update_user)
    ALTER TABLE master_deal_view 
	/**
		Parameter
		update_user : User name
	*/
	ALTER COLUMN update_user  NVARCHAR(100)
	ALTER FULLTEXT INDEX ON  master_deal_view ADD (update_user)
END
GO

IF COL_LENGTH('master_deal_view', 'location_group') IS NOT NULL
BEGIN 
	ALTER FULLTEXT INDEX ON  master_deal_view DROP (location_group)
    ALTER TABLE master_deal_view 
	/**
		Parameter
		location_group : location group
	*/
	ALTER COLUMN location_group NVARCHAR(100)
	ALTER FULLTEXT INDEX ON  master_deal_view ADD (location_group)
END
GO

IF COL_LENGTH('master_deal_view', 'forecast_profile') IS NOT NULL
BEGIN 
	ALTER FULLTEXT INDEX ON  master_deal_view DROP (forecast_profile)
    ALTER TABLE master_deal_view 
	/**
		Parameter
		forecast_profile : forecast profile
	*/
	ALTER COLUMN forecast_profile NVARCHAR(250)
	ALTER FULLTEXT INDEX ON  master_deal_view ADD (forecast_profile)
END
GO

IF COL_LENGTH('master_deal_view', 'forecast_proxy_profile') IS NOT NULL
BEGIN 
	ALTER FULLTEXT INDEX ON  master_deal_view DROP (forecast_proxy_profile)
    ALTER TABLE master_deal_view 
	/**
		Parameter
		forecast_proxy_profile : forecast proxy profile
	*/
	ALTER COLUMN forecast_proxy_profile NVARCHAR(250)
	ALTER FULLTEXT INDEX ON  master_deal_view ADD (forecast_proxy_profile)
END
GO

IF COL_LENGTH('master_deal_view', 'scheduler') IS NOT NULL
BEGIN
    ALTER TABLE master_deal_view 
	/**
		Parameter
		scheduler : scheduler
	*/
	ALTER COLUMN scheduler NVARCHAR(200)
END
GO

IF COL_LENGTH('master_deal_view', 'batch_id') IS NOT NULL
BEGIN
    ALTER TABLE master_deal_view 
	/**
		Parameter
		batch_id : Batch ID
	*/
	ALTER COLUMN batch_id  NVARCHAR(100)
END
GO

IF COL_LENGTH('master_deal_view', 'product_description') IS NOT NULL
BEGIN
    ALTER TABLE master_deal_view 
	/**
		Parameter
		product_description : product description
	*/
	ALTER COLUMN product_description  NVARCHAR(2000)
END
GO