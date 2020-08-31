SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF COL_LENGTH('report_page_chart', 'dataset_id') IS NOT NULL
	EXEC sp_rename 'report_page_chart.dataset_id' , 'root_dataset_id', 'column'	 

IF COL_LENGTH('report_chart_column', 'dataset_id') IS NULL	 
	ALTER TABLE report_chart_column ADD dataset_id INT 

IF COL_LENGTH('report_page_tablix', 'dataset_id') IS NOT NULL
	EXEC sp_rename 'report_page_tablix.dataset_id' , 'root_dataset_id', 'column'	 

IF COL_LENGTH('report_tablix_column', 'dataset_id') IS NULL	 
	ALTER TABLE report_tablix_column ADD dataset_id INT
	
IF COL_LENGTH('data_source', 'report_id') IS NULL	 
	ALTER TABLE data_source ADD report_id INT
GO

IF COL_LENGTH('report_dataset', 'root_dataset_id') IS NULL	 
	ALTER TABLE report_dataset ADD root_dataset_id INT 
	
IF COL_LENGTH('report_dataset', 'is_primary') IS NOT NULL	 
	ALTER TABLE report_dataset DROP COLUMN is_primary 

IF COL_LENGTH('report_dataset', 'is_free_from') IS NULL	 
	ALTER TABLE report_dataset ADD is_free_from BIT	DEFAULT 0

IF COL_LENGTH('report_dataset', 'relationship_sql') IS NULL	 
	ALTER TABLE report_dataset ADD relationship_sql VARCHAR(MAX)		
	
--IF COL_LENGTH('report_dataset', 'join_type') IS NULL	 
--	ALTER TABLE report_dataset ADD join_type INT	

IF COL_LENGTH('report_dataset_relationship', 'join_type') IS NULL	 
	ALTER TABLE report_dataset_relationship ADD join_type INT	

IF OBJECT_ID(N'[dbo].[report_dataset_relationship_detail]', N'U') IS NOT NULL
	DROP TABLE report_dataset_relationship_detail   

IF COL_LENGTH('report_dataset_relationship', 'dataset_id') IS NULL	 
	ALTER TABLE report_dataset_relationship ADD dataset_id INT 
IF COL_LENGTH('report_dataset_relationship', 'from_column_id') IS NULL	 
	ALTER TABLE report_dataset_relationship ADD from_column_id INT 
IF COL_LENGTH('report_dataset_relationship', 'to_column_id') IS NULL	 
	ALTER TABLE report_dataset_relationship ADD to_column_id INT
	
IF COL_LENGTH('report', 'description') IS NOT NULL
BEGIN
    ALTER TABLE report ALTER COLUMN description VARCHAR(8000)
END
GO	

IF COL_LENGTH('report_page_chart', 'order') IS NULL
BEGIN
    ALTER TABLE report_page_chart ADD [order] INT
END
GO
IF COL_LENGTH('report_page_chart', 'top') IS NULL
BEGIN
    ALTER TABLE report_page_chart ADD [top] VARCHAR(45)
END
GO
IF COL_LENGTH('report_page_chart', 'left') IS NULL
BEGIN
    ALTER TABLE report_page_chart ADD [left] VARCHAR(45)
END
GO

IF COL_LENGTH('report_page_tablix', 'order') IS NULL
BEGIN
    ALTER TABLE report_page_tablix ADD [order] INT
END
GO
IF COL_LENGTH('report_page_tablix', 'top') IS NULL
BEGIN
    ALTER TABLE report_page_tablix ADD [top] VARCHAR(45)
END
GO
IF COL_LENGTH('report_page_tablix', 'left') IS NULL
BEGIN
    ALTER TABLE report_page_tablix ADD [left] VARCHAR(45)
END
GO
IF COL_LENGTH('report_tablix_column', 'column_order') IS NULL
BEGIN
    ALTER TABLE report_tablix_column ADD [column_order] INT
END
GO
IF COL_LENGTH('report_page_chart', 'name') IS NOT NULL
BEGIN
    ALTER TABLE report_page_chart ALTER COLUMN name VARCHAR(500)
END
GO

IF OBJECT_ID(N'[dbo].[report_dataset_paramset]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[report_dataset_paramset]
    (
    	[report_dataset_paramset_id]  INT IDENTITY(1, 1) NOT NULL,
    	[paramset_id]                 INT,
    	[root_dataset_id]             INT,
    	[where_part]                  VARCHAR(8000)
    )
END
ELSE
BEGIN
    PRINT 'Table report_dataset_paramset EXISTS'
END
GO

IF COL_LENGTH('report_param', 'report_dataset_paramset_id') IS NOT NULL
 EXEC sp_rename 'report_param.report_dataset_paramset_id' , 'dataset_paramset_id', 'column'

IF COL_LENGTH('report_param', 'paramset_id') IS NOT NULL
 EXEC sp_rename 'report_param.paramset_id' , 'dataset_paramset_id', 'column'
	
IF COL_LENGTH('report_param', 'optional') IS NOT  NULL
BEGIN
    ALTER TABLE report_param ALTER COLUMN optional BIT 
END
GO

-- Table [dbo].`report_widget`
IF OBJECT_ID(N'[dbo].report_widget', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[report_widget] (
		[report_widget_id]		INT ,
		[name] 					VARCHAR(200) NULL ,
		[description] 			VARCHAR(MAX) NULL ,
		[create_user]          	VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]            	DATETIME NULL DEFAULT GETDATE(),
		[update_user]          	VARCHAR(50) NULL,
		[update_ts]            	DATETIME NULL,
		CONSTRAINT [PK_report_widget] PRIMARY KEY CLUSTERED([report_widget_id] ASC)
	  ) ON [PRIMARY]
END 
ELSE
BEGIN
    PRINT 'Table report_widget EXISTS'
END
  
IF NOT EXISTS(SELECT 1 FROM report_widget WHERE report_widget_id = 1)
	INSERT INTO dbo.[report_widget] ([report_widget_id],[name],[description])
	VALUES	(1, 'TEXTBOX', 'TEXTBOX')
	
IF NOT EXISTS(SELECT 1 FROM report_widget WHERE report_widget_id = 2)
	INSERT INTO dbo.[report_widget] ([report_widget_id],[name],[description])
	VALUES (2, 'DROPDOWN', 'DROPDOWN')
	
IF NOT EXISTS(SELECT 1 FROM report_widget WHERE report_widget_id = 3)
	INSERT INTO dbo.[report_widget] ([report_widget_id],[name],[description])
	VALUES (3, 'BSTREE-Subsidiary', 'BSTREE-Subsidiary')
	
IF NOT EXISTS(SELECT 1 FROM report_widget WHERE report_widget_id = 4)
	INSERT INTO dbo.[report_widget] ([report_widget_id],[name],[description])
	VALUES (4, 'BSTREE-Strategy', 'BSTREE-Strategy')
		
IF NOT EXISTS(SELECT 1 FROM report_widget WHERE report_widget_id = 5)
	INSERT INTO dbo.[report_widget] ([report_widget_id],[name],[description])
	VALUES (5, 'BSTREE-Book', 'BSTREE-Book')
		
IF NOT EXISTS(SELECT 1 FROM report_widget WHERE report_widget_id = 6)
	INSERT INTO dbo.[report_widget] ([report_widget_id],[name],[description])
	VALUES (6, 'DATETIME','DATETIME')

IF OBJECT_ID('[dbo].[TRGUPD_report_widget]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_widget]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_widget]
ON [dbo].[report_widget]
FOR  UPDATE
AS
	UPDATE report_widget
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_widget t
	INNER JOIN DELETED u ON  t.report_widget_id = u.report_widget_id
GO

-- Table [dbo].`report_datatype`
IF OBJECT_ID(N'[dbo].report_datatype', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[report_datatype] (
		[report_datatype_id] 	INT,
		[name] 					VARCHAR(200) NULL ,
		[description] 			VARCHAR(MAX) NULL ,
		[create_user]          	VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]            	DATETIME NULL DEFAULT GETDATE(),
		[update_user]          	VARCHAR(50) NULL,
		[update_ts]            	DATETIME NULL,
		CONSTRAINT [PK_report_datatype] PRIMARY KEY CLUSTERED([report_datatype_id] ASC)
	  ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table report_datatype EXISTS'
END

IF NOT EXISTS(SELECT 1 FROM report_datatype WHERE report_datatype_id = 1)  
	INSERT INTO dbo.[report_datatype] ([report_datatype_id],[name],[description])
	VALUES	(1, 'CHAR', 'CHAR')
	
IF NOT EXISTS(SELECT 1 FROM report_datatype WHERE report_datatype_id = 2)  
	INSERT INTO dbo.[report_datatype] ([report_datatype_id],[name],[description])
	VALUES(2, 'DATETIME', 'DATETIME')
		
IF NOT EXISTS(SELECT 1 FROM report_datatype WHERE report_datatype_id = 3)  
	INSERT INTO dbo.[report_datatype] ([report_datatype_id],[name],[description])
	VALUES(3, 'FLOAT', 'FLOAT')
		
IF NOT EXISTS(SELECT 1 FROM report_datatype WHERE report_datatype_id = 4)  
	INSERT INTO dbo.[report_datatype] ([report_datatype_id],[name],[description])
	VALUES(4, 'INT','INT')
		
IF NOT EXISTS(SELECT 1 FROM report_datatype WHERE report_datatype_id = 5)  
	INSERT INTO dbo.[report_datatype] ([report_datatype_id],[name],[description])
	VALUES(5, 'VARCHAR','VARCHAR')
		
IF OBJECT_ID('[dbo].[TRGUPD_report_datatype]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_datatype]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_datatype]
ON [dbo].[report_datatype]
FOR  UPDATE
AS
	UPDATE report_datatype
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_datatype t
	INNER JOIN DELETED u ON  t.report_datatype_id = u.report_datatype_id
GO
IF COL_LENGTH('report_paramset', 'where_part') IS NOT NULL
BEGIN
    ALTER TABLE report_paramset DROP COLUMN where_part  
END

GO	

IF COL_LENGTH('report_tablix_column', 'custom_field') IS NULL
BEGIN
    ALTER TABLE report_tablix_column ADD custom_field BIT 
END
GO

IF COL_LENGTH('report_page_tablix', 'name') IS NOT NULL
BEGIN
    ALTER TABLE report_page_tablix ALTER COLUMN name VARCHAR(500)
END
GO

/** alter table data_source alter col description and tsql varchar length from max to 8000 **/
IF COL_LENGTH('data_source', 'description') IS NOT NULL
BEGIN
    ALTER TABLE data_source ALTER COLUMN description VARCHAR(8000)
END
GO
IF COL_LENGTH('data_source_column', 'param_data_source') IS NOT NULL
BEGIN
    ALTER TABLE data_source_column ALTER COLUMN param_data_source VARCHAR(8000)
END
GO
IF COL_LENGTH('data_source_column', 'param_default_value') IS NOT NULL
BEGIN
    ALTER TABLE data_source_column ALTER COLUMN param_default_value VARCHAR(8000)
END
GO

IF COL_LENGTH('report_tablix_column', 'functions') IS NOT NULL
BEGIN
    ALTER TABLE report_tablix_column ALTER COLUMN functions VARCHAR(1000)
END
GO

/** altering column report_id back to paramset_id for table report_privilege 
* sligal
* 9/25/2012**/
IF COL_LENGTH('report_privilege', 'report_id') IS NOT NULL
BEGIN
	EXEC sp_rename 'report_privilege.[report_id]', 'paramset_id', 'COLUMN'
END
GO

--START :: Added X-Axis/Y-Axis caption columns
IF COL_LENGTH('report_page_chart', 'x_axis_caption') IS NULL
BEGIN
    ALTER TABLE report_page_chart ADD x_axis_caption VARCHAR(200)
END
GO

IF COL_LENGTH('report_page_chart', 'y_axis_caption') IS NULL
BEGIN
    ALTER TABLE report_page_chart ADD y_axis_caption VARCHAR(200)
END
GO
--END :: Added X-Axis/Y-Axis caption columns
GO
IF COL_LENGTH('report_paramset', 'paramset_hash') IS NULL
BEGIN
    ALTER TABLE report_paramset ADD paramset_hash VARCHAR(50)
END
GO


IF COL_LENGTH('report_dataset', 'alias') IS NOT NULL
BEGIN
    ALTER TABLE report_dataset ALTER COLUMN alias VARCHAR(100)
END
GO


IF COL_LENGTH('report_param', 'logical_operator') IS NULL
BEGIN
    ALTER TABLE report_param ADD logical_operator INT
END
GO

IF COL_LENGTH('report_param', 'param_order') IS NULL
BEGIN
    ALTER TABLE report_param ADD param_order INT
END
GO

IF COL_LENGTH('report_param', 'param_depth') IS NULL
BEGIN
    ALTER TABLE report_param ADD param_depth INT
END
GO

IF COL_LENGTH('data_source', 'tsql') IS NOT NULL
BEGIN
    ALTER TABLE data_source ALTER COLUMN [tsql] VARCHAR(MAX)
END
GO

IF COL_LENGTH('report_page', 'layout') IS NOT NULL
BEGIN
    ALTER TABLE report_page DROP COLUMN layout
END
GO

IF COL_LENGTH('report_page_tablix', 'region') IS NOT NULL
BEGIN
    ALTER TABLE report_page_tablix DROP COLUMN region
END
GO

IF COL_LENGTH('report_page_tablix', 'order') IS NOT NULL
BEGIN
    ALTER TABLE report_page_tablix DROP COLUMN [order]
END
GO

IF COL_LENGTH('report_page_tablix', 'hyperlink') IS NOT NULL
BEGIN
    ALTER TABLE report_page_tablix DROP COLUMN hyperlink
END
GO

IF COL_LENGTH('report_page_chart', 'region') IS NOT NULL
BEGIN
    ALTER TABLE report_page_chart DROP COLUMN region
END
GO

IF COL_LENGTH('report_page_chart', 'order') IS NOT NULL
BEGIN
    ALTER TABLE report_page_chart DROP COLUMN [order]
END
GO


IF COL_LENGTH('report_page_tablix', 'group_mode') IS NULL
	ALTER TABLE report_page_tablix ADD group_mode INT

-- Table [dbo].`report_page_textbox`
IF OBJECT_ID(N'[dbo].report_page_textbox', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[report_page_textbox] (
		[report_page_textbox_id] 	INT IDENTITY(1, 1) NOT NULL,
		[page_id] 					INT NULL ,
		[content] 			VARCHAR(8000) NULL ,
		[font] 				VARCHAR(200) NULL ,
		[font_size] 		VARCHAR(200) NULL ,
		[font_style] 		VARCHAR(10) NULL ,
		[width] 			VARCHAR(45) NULL ,
		[height] 			VARCHAR(45) NULL ,
		[top]	 			VARCHAR(45) NULL ,
		[left] 				VARCHAR(45) NULL ,
		[hash]	 			VARCHAR(128) NULL ,
		[create_user]       VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]         DATETIME NULL DEFAULT GETDATE(),
		[update_user]       VARCHAR(50) NULL,
		[update_ts]         DATETIME NULL,
		CONSTRAINT [PK_report_page_textbox] PRIMARY KEY CLUSTERED([report_page_textbox_id] ASC)
	  ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table report_page_textbox EXISTS'
END

IF OBJECT_ID('[dbo].[TRGUPD_report_page_textbox]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_page_textbox]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_page_textbox]
ON [dbo].[report_page_textbox]
FOR  UPDATE
AS
	UPDATE report_page_textbox
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_page_textbox t
	INNER JOIN DELETED u ON  t.report_page_textbox_id = u.report_page_textbox_id
GO

-- Table [dbo].`report_page_image`
IF OBJECT_ID(N'[dbo].report_page_image', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[report_page_image] (
		[report_page_image_id] 	INT IDENTITY(1, 1) NOT NULL,
		[page_id] 					INT NULL ,
		[name] 				VARCHAR(300) NULL ,
		[filename] 			VARCHAR(MAX) NULL ,
		[width] 			VARCHAR(45) NULL ,
		[height] 			VARCHAR(45) NULL ,
		[top]	 			VARCHAR(45) NULL ,
		[left] 				VARCHAR(45) NULL ,
		[hash]	 			VARCHAR(128) NULL ,
		[create_user]       VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]         DATETIME NULL DEFAULT GETDATE(),
		[update_user]       VARCHAR(50) NULL,
		[update_ts]         DATETIME NULL,
		CONSTRAINT [PK_report_page_image] PRIMARY KEY CLUSTERED([report_page_image_id] ASC)
	  ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table report_page_image EXISTS'
END
IF OBJECT_ID('[dbo].[TRGUPD_report_page_image]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_page_image]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_page_image]
ON [dbo].[report_page_image]
FOR  UPDATE
AS
	UPDATE report_page_image
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_page_image t
	INNER JOIN DELETED u ON  t.report_page_image_id = u.report_page_image_id
GO

IF COL_LENGTH('report_page_textbox', 'content') IS NOT NULL
BEGIN
    ALTER TABLE report_page_textbox ALTER COLUMN content VARCHAR(8000)
END
GO

IF COL_LENGTH('report_page_image', 'filename') IS NOT NULL
BEGIN
    ALTER TABLE report_page_image ALTER COLUMN [filename] VARCHAR(MAX)
END
GO

IF COL_LENGTH('report_tablix_column', 'render_as') IS NULL
BEGIN
    ALTER TABLE report_tablix_column ADD render_as INT
END
GO

IF COL_LENGTH('report_param', 'label') IS NULL
BEGIN
    ALTER TABLE report_param ADD label VARCHAR(255)
END
GO

IF COL_LENGTH('data_source_column', 'tooltip') IS NULL
BEGIN
    ALTER TABLE data_source_column ADD tooltip VARCHAR(2000)
END
GO

IF COL_LENGTH('report_page_tablix', 'border_style') IS NULL
BEGIN
    ALTER TABLE report_page_tablix ADD border_style INT
END
GO

-- Table [dbo].`report_tablix_header`
IF OBJECT_ID(N'[dbo].[report_tablix_header]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[report_tablix_header] (
	[report_tablix_header_id] 	INT IDENTITY(1, 1) NOT NULL,
	[tablix_id] 				INT NULL ,
	[column_id] 				INT NULL ,
	[font]						VARCHAR(100) NULL ,
	[font_size] 				VARCHAR(45) NULL ,
	[font_style] 				VARCHAR(45) NULL ,
	[text_align] 				VARCHAR(45) NULL ,
	[text_color] 				VARCHAR(10) NULL ,
	[background] 				VARCHAR(10) NULL ,
	[create_user]          		VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]            		DATETIME NULL DEFAULT GETDATE(),
	[update_user]          		VARCHAR(50) NULL,
	[update_ts]            		DATETIME NULL,
	CONSTRAINT [PK_report_tablix_header] PRIMARY KEY CLUSTERED([report_tablix_header_id] ASC)
  ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table report_tablix_header EXISTS'
END
GO

IF COL_LENGTH('report_tablix_header', 'report_tablix_column_id') IS NULL
BEGIN
    ALTER TABLE report_tablix_header ADD report_tablix_column_id INT
END
GO

IF COL_LENGTH('report_page_tablix', 'page_break') IS NULL
BEGIN
    ALTER TABLE report_page_tablix ADD page_break INT
END
GO

IF COL_LENGTH('report_page_chart', 'page_break') IS NULL
BEGIN
    ALTER TABLE report_page_chart ADD page_break INT
END
GO

-- Table [dbo].`report_status`
IF OBJECT_ID(N'[dbo].report_status', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[report_status] (
		[report_status_id]		INT ,
		[name] 					VARCHAR(200) NULL ,
		[description] 			VARCHAR(MAX) NULL ,
		[create_user]          	VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]            	DATETIME NULL DEFAULT GETDATE(),
		[update_user]          	VARCHAR(50) NULL,
		[update_ts]            	DATETIME NULL,
		CONSTRAINT [PK_report_status] PRIMARY KEY CLUSTERED([report_status_id] ASC)
	  ) ON [PRIMARY]
END 
ELSE
BEGIN
    PRINT 'Table report_status EXISTS'
END
  
IF NOT EXISTS(SELECT 1 FROM report_status WHERE report_status_id = 1)
	INSERT INTO dbo.[report_status] ([report_status_id],[name],[description])
	VALUES	(1, 'Draft', 'Draft')
	
IF NOT EXISTS(SELECT 1 FROM report_status WHERE report_status_id = 2)
	INSERT INTO dbo.[report_status] ([report_status_id],[name],[description])
	VALUES (2, 'Public', 'Public')
	
IF NOT EXISTS(SELECT 1 FROM report_status WHERE report_status_id = 3)
	INSERT INTO dbo.[report_status] ([report_status_id],[name],[description])
	VALUES (3, 'Private', 'Private')

--added later 6/11/2013
IF NOT EXISTS(SELECT 1 FROM report_status WHERE report_status_id = 4)
	INSERT INTO dbo.[report_status] ([report_status_id],[name],[description])
	VALUES (4, 'Hidden', 'Hidden')
	
IF OBJECT_ID('[dbo].[TRGUPD_report_status]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_status]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_status]
ON [dbo].[report_status]
FOR  UPDATE
AS
	UPDATE report_status
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_status t
	INNER JOIN DELETED u ON  t.report_status_id = u.report_status_id
GO

IF COL_LENGTH('report_paramset', 'report_status_id') IS NULL	 
	ALTER TABLE report_paramset ADD report_status_id INT
GO

IF COL_LENGTH('report_tablix_column', 'column_template') IS NULL
BEGIN
    ALTER TABLE report_tablix_column ADD column_template INT
END
GO

IF COL_LENGTH('report_tablix_column', 'negative_mark') IS NULL
BEGIN
    ALTER TABLE report_tablix_column ADD negative_mark INT
END
GO

IF COL_LENGTH('report_tablix_column', 'currency') IS NULL
BEGIN
    ALTER TABLE report_tablix_column ADD currency INT
END
GO

IF COL_LENGTH('report_tablix_column', 'date_format') IS NULL
BEGIN
    ALTER TABLE report_tablix_column ADD date_format INT
END
GO

IF COL_LENGTH('report_page_tablix', 'type_id') IS NULL
BEGIN
    ALTER TABLE report_page_tablix ADD type_id INT
END
GO

IF COL_LENGTH('report_page_tablix', 'cross_summary') IS NULL
BEGIN
    ALTER TABLE report_page_tablix ADD cross_summary INT
END
GO

IF COL_LENGTH('report_tablix_column', 'cross_summary_aggregation') IS NULL
BEGIN
    ALTER TABLE report_tablix_column ADD cross_summary_aggregation INT
END
GO

/* Gauge Tables Creation Start */

-- Table [dbo].`report_page_gauge`
IF OBJECT_ID(N'[dbo].[report_page_gauge]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[report_page_gauge]
    (
    	[report_page_gauge_id]  INT IDENTITY(1, 1) NOT NULL,
    	[page_id]               INT NULL,
    	[root_dataset_id]       INT NULL,
    	[name]                  VARCHAR(500) NULL,
    	[type_id]               INT NULL,
    	[width]                 VARCHAR(45) NULL,
    	[height]                VARCHAR(45) NULL,
    	[top]                   VARCHAR(45) NULL,
    	[left]                  VARCHAR(45) NULL,
    	[create_user]           VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]             DATETIME NULL DEFAULT GETDATE(),
    	[update_user]           VARCHAR(50) NULL,
    	[update_ts]             DATETIME NULL,
    	CONSTRAINT [PK_report_page_gauge] PRIMARY KEY CLUSTERED([report_page_gauge_id] ASC)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table report_page_gauge EXISTS'
END

IF OBJECT_ID('[dbo].[TRGUPD_report_page_gauge]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_page_gauge]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_page_gauge]
ON [dbo].[report_page_gauge]
FOR  UPDATE
AS
	UPDATE report_page_gauge
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_page_gauge t
	INNER JOIN DELETED u ON  t.report_page_gauge_id = u.report_page_gauge_id
GO


-- Table [dbo].`report_gauge_column`
IF OBJECT_ID(N'[dbo].[report_gauge_column]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[report_gauge_column]
    (
    	[report_gauge_column_id]  INT IDENTITY(1, 1) NOT NULL,
    	[gauge_id]                INT NULL,
    	[column_id]               INT NULL,
    	[column_order]            INT NULL,
    	[dataset_id]              INT NULL,
    	[scale_minimum]           INT NULL,
    	[scale_maximum]           INT NULL,
    	[scale_interval]          INT NULL,
    	[create_user]             VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]               DATETIME NULL DEFAULT GETDATE(),
    	[update_user]             VARCHAR(50) NULL,
    	[update_ts]               DATETIME NULL,
    	CONSTRAINT [PK_report_gauge_column] PRIMARY KEY CLUSTERED([report_gauge_column_id] ASC)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table report_gauge_column EXISTS'
END

IF OBJECT_ID('[dbo].[TRGUPD_report_gauge_column]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_gauge_column]
GO

CREATE TRIGGER [dbo].[TRGUPD_report_gauge_column]
ON [dbo].[report_gauge_column]
FOR  UPDATE
AS
	UPDATE report_gauge_column
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_gauge_column t
	INNER JOIN DELETED u ON  t.report_gauge_column_id = u.report_gauge_column_id
GO

-- Table [dbo].`report_gauge_column_scale`
IF OBJECT_ID(N'[dbo].[report_gauge_column_scale]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[report_gauge_column_scale]
    (
    	[report_gauge_column_scale_id]  INT IDENTITY(1, 1) NOT NULL,
    	[report_gauge_column_id]        INT NULL,
    	[placement]                     INT NULL,
    	[scale_start]                   INT NULL,
    	[scale_end]                     INT NULL,
    	[scale_range_color]             VARCHAR(200) NULL,
    	[create_user]                   VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                     DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                   VARCHAR(50) NULL,
    	[update_ts]                     DATETIME NULL,
    	CONSTRAINT [PK_report_gauge_column_scale] PRIMARY KEY CLUSTERED([report_gauge_column_scale_id] ASC)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table report_gauge_column_scale EXISTS'
END

IF OBJECT_ID('[dbo].[TRGUPD_report_gauge_column_scale]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_gauge_column_scale]
GO

CREATE TRIGGER [dbo].[TRGUPD_report_gauge_column_scale]
ON [dbo].[report_gauge_column_scale]
FOR  UPDATE
AS
	UPDATE report_gauge_column_scale
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_gauge_column_scale t
	INNER JOIN DELETED u ON  t.report_gauge_column_scale_id = u.report_gauge_column_scale_id
GO

IF COL_LENGTH('report_gauge_column_scale', 'column_id') IS NULL
BEGIN
    ALTER TABLE report_gauge_column_scale ADD column_id INT
END
GO

IF COL_LENGTH('report_gauge_column', 'alias') IS NULL
BEGIN
    ALTER TABLE report_gauge_column ADD alias VARCHAR(300)
END
GO

IF COL_LENGTH('report_gauge_column', 'scale_minimum') IS NOT NULL
BEGIN
    ALTER TABLE report_gauge_column ALTER COLUMN scale_minimum VARCHAR(200)
END
GO

IF COL_LENGTH('report_gauge_column', 'scale_maximum') IS NOT NULL
BEGIN
    ALTER TABLE report_gauge_column ALTER COLUMN scale_maximum VARCHAR(200)
END
GO

IF COL_LENGTH('report_gauge_column', 'scale_interval') IS NOT NULL
BEGIN
    ALTER TABLE report_gauge_column ALTER COLUMN scale_interval VARCHAR(200)
END
GO

IF COL_LENGTH('report_gauge_column_scale', 'scale_start') IS NOT NULL
BEGIN
    ALTER TABLE report_gauge_column_scale ALTER COLUMN scale_start VARCHAR(200)
END
GO
IF COL_LENGTH('report_gauge_column_scale', 'scale_end') IS NOT NULL
BEGIN
    ALTER TABLE report_gauge_column_scale ALTER COLUMN scale_end VARCHAR(200)
END
GO

/* Gauge Tables Creation End */

IF COL_LENGTH('data_source_column', 'column_template') IS NULL
BEGIN
    ALTER TABLE data_source_column ADD column_template INT
END
GO


IF COL_LENGTH('report_param', 'initial_value') IS NOT NULL
BEGIN
    ALTER TABLE report_param ALTER COLUMN initial_value VARCHAR(4000)
END
GO

IF COL_LENGTH('report_param', 'initial_value2') IS NOT NULL
BEGIN
    ALTER TABLE report_param ALTER COLUMN initial_value2 VARCHAR(4000)
END
GO

--add gauge_label_column_id
IF COL_LENGTH('report_page_gauge', 'gauge_label_column_id') IS NULL
BEGIN
    ALTER TABLE report_page_gauge ADD gauge_label_column_id INT
END
GO

IF COL_LENGTH('report_page_tablix', 'no_header') IS NULL
BEGIN
    ALTER TABLE report_page_tablix ADD no_header INT
END
GO

--Add new fields to report_page_chart and report_chart_column.
--report_page_chart
IF COL_LENGTH('report_page_chart', 'x_axis_style') IS NULL	 
	ALTER TABLE report_page_chart ADD x_axis_style VARCHAR(45)
	
IF COL_LENGTH('report_page_chart', 'y_axis_style') IS NULL	 
	ALTER TABLE report_page_chart ADD y_axis_style VARCHAR(45)

IF COL_LENGTH('report_page_chart', 'x_axis_interval') IS NULL	 
	ALTER TABLE report_page_chart ADD x_axis_interval INT		
	
IF COL_LENGTH('report_page_chart', 'y_axis_interval') IS NULL	 
	ALTER TABLE report_page_chart ADD y_axis_interval INT

IF COL_LENGTH('report_page_chart', 'z_axis_interval') IS NULL	 
	ALTER TABLE report_page_chart ADD z_axis_interval INT		
	
--report_chart_column
IF COL_LENGTH('report_chart_column', 'functions') IS NULL	 
	ALTER TABLE report_chart_column ADD functions VARCHAR(1000)

IF COL_LENGTH('report_chart_column', 'font') IS NULL	 
	ALTER TABLE report_chart_column ADD font VARCHAR(100)
	
IF COL_LENGTH('report_chart_column', 'font_size') IS NULL	 
	ALTER TABLE report_chart_column ADD font_size VARCHAR(45)

IF COL_LENGTH('report_chart_column', 'font_style') IS NULL	 
	ALTER TABLE report_chart_column ADD font_style VARCHAR(45)

IF COL_LENGTH('report_chart_column', 'text_align') IS NULL	 
	ALTER TABLE report_chart_column ADD text_align VARCHAR(45)
	
IF COL_LENGTH('report_chart_column', 'text_color') IS NULL	 
	ALTER TABLE report_chart_column ADD text_color VARCHAR(45)

IF COL_LENGTH('report_chart_column', 'background') IS NULL	 
	ALTER TABLE report_chart_column ADD background VARCHAR(45)
	
IF COL_LENGTH('report_chart_column', 'aggregation') IS NULL	 
	ALTER TABLE report_chart_column ADD aggregation INT	
	
IF COL_LENGTH('report_chart_column', 'rounding') IS NULL	 
	ALTER TABLE report_chart_column ADD rounding INT	

IF COL_LENGTH('report_chart_column', 'thousand_seperation') IS NULL	 
	ALTER TABLE report_chart_column ADD thousand_seperation INT	

IF COL_LENGTH('report_chart_column', 'default_sort_order') IS NULL	 
	ALTER TABLE report_chart_column ADD default_sort_order INT	

IF COL_LENGTH('report_chart_column', 'default_sort_direction') IS NULL	 
	ALTER TABLE report_chart_column ADD default_sort_direction INT	
	
IF COL_LENGTH('report_chart_column', 'custom_field') IS NULL	 
	ALTER TABLE report_chart_column ADD custom_field INT	

IF COL_LENGTH('report_chart_column', 'render_as') IS NULL	 
	ALTER TABLE report_chart_column ADD render_as INT		
	
IF COL_LENGTH('report_chart_column', 'column_template') IS NULL	 
	ALTER TABLE report_chart_column ADD column_template INT	

IF COL_LENGTH('report_chart_column', 'negative_mark') IS NULL	 
	ALTER TABLE report_chart_column ADD negative_mark INT	

IF COL_LENGTH('report_chart_column', 'currency') IS NULL	 
	ALTER TABLE report_chart_column ADD currency INT	

IF COL_LENGTH('report_chart_column', 'date_format') IS NULL	 
	ALTER TABLE report_chart_column ADD date_format INT						
	
--Add functions and aggregation to Gauge table.	
IF COL_LENGTH('report_gauge_column', 'functions') IS NULL	 
	ALTER TABLE report_gauge_column ADD functions VARCHAR(1000)
	
IF COL_LENGTH('report_gauge_column', 'aggregation') IS NULL	 
	ALTER TABLE report_gauge_column ADD aggregation INT	

IF COL_LENGTH('report_gauge_column', 'placement') IS NULL	 
	ALTER TABLE report_gauge_column ADD placement INT	

IF COL_LENGTH('report_dataset_paramset', 'advance_mode') IS NULL
    ALTER TABLE report_dataset_paramset ADD advance_mode INT    
    
IF COL_LENGTH('report_gauge_column', 'placement') IS NOT NULL	 
	ALTER TABLE report_gauge_column DROP COLUMN placement    

IF COL_LENGTH('report_gauge_column', 'font') IS NULL	 
	ALTER TABLE report_gauge_column ADD font VARCHAR(100)
	
IF COL_LENGTH('report_gauge_column', 'font_size') IS NULL	 
	ALTER TABLE report_gauge_column ADD font_size VARCHAR(45)

IF COL_LENGTH('report_gauge_column', 'font_style') IS NULL	 
	ALTER TABLE report_gauge_column ADD font_style VARCHAR(45)
	
IF COL_LENGTH('report_gauge_column', 'text_color') IS NULL	 
	ALTER TABLE report_gauge_column ADD text_color VARCHAR(45)
	
IF COL_LENGTH('report_gauge_column', 'aggregation') IS NULL	 
	ALTER TABLE report_gauge_column ADD aggregation INT	
	
IF COL_LENGTH('report_gauge_column', 'custom_field') IS NULL	 
	ALTER TABLE report_gauge_column ADD custom_field INT	

IF COL_LENGTH('report_gauge_column', 'render_as') IS NULL	 
	ALTER TABLE report_gauge_column ADD render_as INT		
	
IF COL_LENGTH('report_gauge_column', 'column_template') IS NULL	 
	ALTER TABLE report_gauge_column ADD column_template INT	

IF COL_LENGTH('report_gauge_column', 'currency') IS NULL	 
	ALTER TABLE report_gauge_column ADD currency INT	

IF COL_LENGTH('report_gauge_column', 'rounding') IS NULL	 
	ALTER TABLE report_gauge_column ADD rounding INT	

IF COL_LENGTH('report_gauge_column', 'thousand_seperation') IS NULL	 
	ALTER TABLE report_gauge_column ADD thousand_seperation INT	
	
IF COL_LENGTH('report_gauge_column_scale', 'placement') IS NULL	 
	ALTER TABLE report_gauge_column_scale ADD placement INT  	

/**
* START of alter table report_privilege, update report_hash and report_privilege_type, drop old column paramset_id
* sligal
**/
SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
GO

-- alter table report_privilege add columns report_hash, report_privilege_type
IF COL_LENGTH('report_privilege', 'report_hash') IS NULL
BEGIN
	ALTER TABLE report_privilege
	ADD [report_hash] VARCHAR(500)
END

IF COL_LENGTH('report_privilege', 'report_privilege_type') IS NULL
BEGIN
	ALTER TABLE report_privilege
	ADD [report_privilege_type] VARCHAR(500)
END
GO

-- update report_hash, report_privilege_type column for table report_privilege
IF COL_LENGTH('report_privilege', 'paramset_id') IS NOT NULL
BEGIN
	EXEC('
	UPDATE rp
	SET rp.report_hash = r.report_hash, rp.report_privilege_type = ''e''
	FROM report_privilege rp
	INNER JOIN report r ON r.report_id = rp.paramset_id	
	')
END
GO

-- delete paramset_id from table report_privilege
IF COL_LENGTH('report_privilege', 'paramset_id') IS NOT NULL
BEGIN
	ALTER TABLE report_privilege
	DROP COLUMN paramset_id
END
GO

COMMIT;
GO
/**
* END of alter table report_privilege, update report_hash and report_privilege_type, drop old column paramset_id
* sligal
**/	

-- Table [dbo].`report_page_line` till here
IF OBJECT_ID(N'[dbo].report_page_line', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[report_page_line] (
		[report_page_line_id] 	INT IDENTITY(1, 1) NOT NULL,
		[page_id] 					INT NULL ,
		[color] 				VARCHAR(200) NULL ,
		[size]		 		VARCHAR(200) NULL ,
		[style] 		VARCHAR(10) NULL ,
		[width] 			VARCHAR(45) NULL ,
		[height] 			VARCHAR(45) NULL ,
		[top]	 			VARCHAR(45) NULL ,
		[left] 				VARCHAR(45) NULL ,
		[hash]	 			VARCHAR(128) NULL ,
		[create_user]       VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]         DATETIME NULL DEFAULT GETDATE(),
		[update_user]       VARCHAR(50) NULL,
		[update_ts]         DATETIME NULL,
		CONSTRAINT [PK_report_page_line] PRIMARY KEY CLUSTERED([report_page_line_id] ASC)
	  ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table report_page_line EXISTS'
END

IF OBJECT_ID('[dbo].[TRGUPD_report_page_line]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_page_line]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_page_line]
ON [dbo].[report_page_line]
FOR  UPDATE
AS
	UPDATE report_page_line
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_page_line t
	INNER JOIN DELETED u ON  t.report_page_line_id = u.report_page_line_id
GO

IF COL_LENGTH('report_page_chart', 'x_axis_interval') IS NOT NULL	 
	ALTER TABLE report_page_chart DROP COLUMN x_axis_interval
GO

IF COL_LENGTH('report_page_chart', 'y_axis_interval') IS NOT NULL	 
	ALTER TABLE report_page_chart DROP COLUMN y_axis_interval
GO
	
IF COL_LENGTH('report_page_chart', 'z_axis_interval') IS NOT NULL	 
	ALTER TABLE report_page_chart DROP COLUMN z_axis_interval
GO

IF COL_LENGTH('report_page_chart', 'x_axis_style') IS NOT NULL
BEGIN
    ALTER TABLE report_page_chart DROP COLUMN x_axis_style
END
GO	

IF COL_LENGTH('report_page_chart', 'y_axis_style') IS NOT NULL
BEGIN
    ALTER TABLE report_page_chart DROP COLUMN y_axis_style
END
GO	

IF COL_LENGTH('report_page_chart', 'chart_properties') IS NULL	 
	ALTER TABLE report_page_chart ADD chart_properties VARCHAR(8000)
GO

IF COL_LENGTH('report_chart_column', 'render_as_line') IS NULL	 
	ALTER TABLE report_chart_column ADD render_as_line INT	DEFAULT 0
	
-- DROP from report_chart_column	
	
IF COL_LENGTH('report_chart_column', 'font') IS NOT NULL	 
	ALTER TABLE report_chart_column DROP COLUMN font
	
IF COL_LENGTH('report_chart_column', 'font_size') IS NOT NULL	 
	ALTER TABLE report_chart_column DROP COLUMN font_size

IF COL_LENGTH('report_chart_column', 'font_style') IS NOT NULL	 
	ALTER TABLE report_chart_column DROP COLUMN font_style

IF COL_LENGTH('report_chart_column', 'text_align') IS NOT NULL	 
	ALTER TABLE report_chart_column DROP COLUMN text_align
	
IF COL_LENGTH('report_chart_column', 'text_color') IS NOT NULL	 
	ALTER TABLE report_chart_column DROP COLUMN text_color
	
IF COL_LENGTH('report_chart_column', 'background') IS NOT NULL	 
	ALTER TABLE report_chart_column DROP COLUMN background	
	
IF COL_LENGTH('report_chart_column', 'rounding') IS NOT NULL	 
	ALTER TABLE report_chart_column DROP COLUMN rounding

IF COL_LENGTH('report_chart_column', 'thousand_seperation') IS NOT NULL	 
	ALTER TABLE report_chart_column DROP COLUMN thousand_seperation
	
IF COL_LENGTH('report_chart_column', 'render_as') IS NOT NULL	 
	ALTER TABLE report_chart_column DROP COLUMN render_as		
	
IF COL_LENGTH('report_chart_column', 'column_template') IS NOT NULL	 
	ALTER TABLE report_chart_column DROP COLUMN column_template
	
IF COL_LENGTH('report_chart_column', 'negative_mark') IS NOT NULL	 
	ALTER TABLE report_chart_column DROP COLUMN negative_mark	

IF COL_LENGTH('report_chart_column', 'currency') IS NOT NULL	 
	ALTER TABLE report_chart_column DROP COLUMN currency	

IF COL_LENGTH('report_chart_column', 'date_format') IS NOT NULL	 
	ALTER TABLE report_chart_column DROP COLUMN date_format	
	
IF COL_LENGTH('report_tablix_column', 'mark_for_total') IS NULL	 
	ALTER TABLE report_tablix_column ADD mark_for_total INT	DEFAULT 0	

IF COL_LENGTH('report_tablix_column', 'sql_aggregation') IS NULL	 
	ALTER TABLE report_tablix_column ADD sql_aggregation INT		
	
	
-- Table [dbo].`report_starter_template` till here
IF OBJECT_ID(N'[dbo].report_starter_template', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[report_starter_template] (
		[report_starter_template_id] 	INT,
		[name]	 			VARCHAR(300) NULL ,
		[create_user]       VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]         DATETIME NULL DEFAULT GETDATE(),
		[update_user]       VARCHAR(50) NULL,
		[update_ts]         DATETIME NULL,
		CONSTRAINT [PK_report_starter_template] PRIMARY KEY CLUSTERED([report_starter_template_id] ASC)
	  ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table report_starter_template EXISTS'
END

IF OBJECT_ID('[dbo].[TRGUPD_report_starter_template]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_starter_template]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_starter_template]
ON [dbo].[report_starter_template]
FOR  UPDATE
AS
	UPDATE report_starter_template
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_starter_template t
	INNER JOIN DELETED u ON  t.report_starter_template_id = u.report_starter_template_id
GO	


-- Table [dbo].`report_template_component` till here
IF OBJECT_ID(N'[dbo].report_template_component', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[report_template_component] (
		[report_template_component_id] 	INT,
		[template_id]	 			INT NULL ,
		[component_type]	 			INT NULL ,
		[create_user]       VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]         DATETIME NULL DEFAULT GETDATE(),
		[update_user]       VARCHAR(50) NULL,
		[update_ts]         DATETIME NULL,
		CONSTRAINT [PK_report_template_component] PRIMARY KEY CLUSTERED([report_template_component_id] ASC)
	  ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table report_template_component EXISTS'
END

IF OBJECT_ID('[dbo].[TRGUPD_report_template_component]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_template_component]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_template_component]
ON [dbo].[report_template_component]
FOR  UPDATE
AS
	UPDATE report_template_component
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_template_component t
	INNER JOIN DELETED u ON  t.report_template_component_id = u.report_template_component_id
GO	

--Add template data

IF NOT EXISTS(SELECT 1 FROM report_starter_template WHERE report_starter_template_id = 1)
	INSERT INTO dbo.[report_starter_template] ([report_starter_template_id],[name])
	VALUES	(1, 'Simple Tablix')
	
IF NOT EXISTS(SELECT 1 FROM report_starter_template WHERE report_starter_template_id = 2)
	INSERT INTO dbo.[report_starter_template] ([report_starter_template_id],[name])
	VALUES	(2, 'Two Tablixes')	
	
IF NOT EXISTS(SELECT 1 FROM report_starter_template WHERE report_starter_template_id = 3)
	INSERT INTO dbo.[report_starter_template] ([report_starter_template_id],[name])
	VALUES	(3, 'Simple Chart')		
	
IF NOT EXISTS(SELECT 1 FROM report_starter_template WHERE report_starter_template_id = 4)
	INSERT INTO dbo.[report_starter_template] ([report_starter_template_id],[name])
	VALUES	(4, 'Two Charts')	
	
IF NOT EXISTS(SELECT 1 FROM report_starter_template WHERE report_starter_template_id = 5)
	INSERT INTO dbo.[report_starter_template] ([report_starter_template_id],[name])
	VALUES	(5, 'Simple Gauge')	

IF NOT EXISTS(SELECT 1 FROM report_starter_template WHERE report_starter_template_id = 6)
	INSERT INTO dbo.[report_starter_template] ([report_starter_template_id],[name])
	VALUES	(6, 'Two Gauges')			
	
IF NOT EXISTS(SELECT 1 FROM report_starter_template WHERE report_starter_template_id = 7)
	INSERT INTO dbo.[report_starter_template] ([report_starter_template_id],[name])
	VALUES	(7, 'Three Gauges')		
	
IF NOT EXISTS(SELECT 1 FROM report_starter_template WHERE report_starter_template_id = 8)
	INSERT INTO dbo.[report_starter_template] ([report_starter_template_id],[name])
	VALUES	(8, 'Chart and Tablix')		
	
IF NOT EXISTS(SELECT 1 FROM report_starter_template WHERE report_starter_template_id = 9)
	INSERT INTO dbo.[report_starter_template] ([report_starter_template_id],[name])
	VALUES	(9, 'Gauge and Tablix')	
	
IF NOT EXISTS(SELECT 1 FROM report_starter_template WHERE report_starter_template_id = 10)
	INSERT INTO dbo.[report_starter_template] ([report_starter_template_id],[name])
	VALUES	(10, 'Gauge and Chart')		
	
IF NOT EXISTS(SELECT 1 FROM report_starter_template WHERE report_starter_template_id = 11)
	INSERT INTO dbo.[report_starter_template] ([report_starter_template_id],[name])
	VALUES	(11, 'Gauge, Chart and Tablix')						

--Add template component data

IF NOT EXISTS(SELECT 1 FROM report_template_component WHERE report_template_component_id = 1)
	INSERT INTO dbo.[report_template_component] (report_template_component_id, template_id, component_type)
	VALUES	(1, 1, 1)		

IF NOT EXISTS(SELECT 1 FROM report_template_component WHERE report_template_component_id = 2)
	INSERT INTO dbo.[report_template_component] (report_template_component_id, template_id, component_type)
	VALUES	(2, 2, 1)		

IF NOT EXISTS(SELECT 1 FROM report_template_component WHERE report_template_component_id = 3)
	INSERT INTO dbo.[report_template_component] (report_template_component_id, template_id, component_type)
	VALUES	(3, 2, 1)	
	
IF NOT EXISTS(SELECT 1 FROM report_template_component WHERE report_template_component_id = 4)
	INSERT INTO dbo.[report_template_component] (report_template_component_id, template_id, component_type)
	VALUES	(4, 3, 2)	
	
IF NOT EXISTS(SELECT 1 FROM report_template_component WHERE report_template_component_id = 5)
	INSERT INTO dbo.[report_template_component] (report_template_component_id, template_id, component_type)
	VALUES	(5, 4, 2)	
				
IF NOT EXISTS(SELECT 1 FROM report_template_component WHERE report_template_component_id = 6)
	INSERT INTO dbo.[report_template_component] (report_template_component_id, template_id, component_type)
	VALUES	(6, 4, 2)	
	
IF NOT EXISTS(SELECT 1 FROM report_template_component WHERE report_template_component_id = 7)
	INSERT INTO dbo.[report_template_component] (report_template_component_id, template_id, component_type)
	VALUES	(7, 5, 3)				

IF NOT EXISTS(SELECT 1 FROM report_template_component WHERE report_template_component_id = 8)
	INSERT INTO dbo.[report_template_component] (report_template_component_id, template_id, component_type)
	VALUES	(8, 6, 3)		
	
IF NOT EXISTS(SELECT 1 FROM report_template_component WHERE report_template_component_id = 9)
	INSERT INTO dbo.[report_template_component] (report_template_component_id, template_id, component_type)
	VALUES	(9, 6, 3)	
	
IF NOT EXISTS(SELECT 1 FROM report_template_component WHERE report_template_component_id = 10)
	INSERT INTO dbo.[report_template_component] (report_template_component_id, template_id, component_type)
	VALUES	(10, 7, 3)	
	
IF NOT EXISTS(SELECT 1 FROM report_template_component WHERE report_template_component_id = 11)
	INSERT INTO dbo.[report_template_component] (report_template_component_id, template_id, component_type)
	VALUES	(11, 7, 3)		
	
IF NOT EXISTS(SELECT 1 FROM report_template_component WHERE report_template_component_id = 12)
	INSERT INTO dbo.[report_template_component] (report_template_component_id, template_id, component_type)
	VALUES	(12, 7, 3)	
	
IF NOT EXISTS(SELECT 1 FROM report_template_component WHERE report_template_component_id = 13)
	INSERT INTO dbo.[report_template_component] (report_template_component_id, template_id, component_type)
	VALUES	(13, 8, 2)		
	
IF NOT EXISTS(SELECT 1 FROM report_template_component WHERE report_template_component_id = 14)
	INSERT INTO dbo.[report_template_component] (report_template_component_id, template_id, component_type)
	VALUES	(14, 8, 1)			
	
IF NOT EXISTS(SELECT 1 FROM report_template_component WHERE report_template_component_id = 13)
	INSERT INTO dbo.[report_template_component] (report_template_component_id, template_id, component_type)
	VALUES	(13, 9, 3)		
	
IF NOT EXISTS(SELECT 1 FROM report_template_component WHERE report_template_component_id = 14)
	INSERT INTO dbo.[report_template_component] (report_template_component_id, template_id, component_type)
	VALUES	(14, 9, 1)			
	
IF NOT EXISTS(SELECT 1 FROM report_template_component WHERE report_template_component_id = 15)
	INSERT INTO dbo.[report_template_component] (report_template_component_id, template_id, component_type)
	VALUES	(15, 10, 3)		
	
IF NOT EXISTS(SELECT 1 FROM report_template_component WHERE report_template_component_id = 16)
	INSERT INTO dbo.[report_template_component] (report_template_component_id, template_id, component_type)
	VALUES	(16, 10, 2)		
	
IF NOT EXISTS(SELECT 1 FROM report_template_component WHERE report_template_component_id = 17)
	INSERT INTO dbo.[report_template_component] (report_template_component_id, template_id, component_type)
	VALUES	(17, 11, 3)		
	
IF NOT EXISTS(SELECT 1 FROM report_template_component WHERE report_template_component_id = 18)
	INSERT INTO dbo.[report_template_component] (report_template_component_id, template_id, component_type)
	VALUES	(18, 11, 2)			
	
IF NOT EXISTS(SELECT 1 FROM report_template_component WHERE report_template_component_id = 19)
	INSERT INTO dbo.[report_template_component] (report_template_component_id, template_id, component_type)
	VALUES	(19, 11, 1)		
	
IF COL_LENGTH('data_source_column', 'key_column') IS NULL	 
	ALTER TABLE data_source_column ADD key_column INT
GO	

/* Add columns for exporting report to table */

IF COL_LENGTH('report_page_tablix', 'export_table_name') IS NULL
BEGIN
    ALTER TABLE report_page_tablix ADD export_table_name VARCHAR(1000)
END
GO

IF COL_LENGTH('report_page_tablix', 'is_global') IS NULL
BEGIN
    ALTER TABLE report_page_tablix ADD is_global BIT DEFAULT 1
END
GO

/*Add report widget*/
IF NOT EXISTS(SELECT 1 FROM report_widget WHERE report_widget_id = 8)
	INSERT INTO dbo.report_widget ([report_widget_id],[name],[description])
	VALUES	(8, 'BSTREE-SubBook','BSTREE-SubBook')	


/* Add column for tracking report deployment  */
IF COL_LENGTH('report_page', 'is_deployed') IS NULL
BEGIN
    ALTER TABLE report_page ADD is_deployed BIT DEFAULT 0
END
GO


IF COL_LENGTH('report_tablix_column', 'subtotal') IS NULL	
BEGIN 
	ALTER TABLE report_tablix_column ADD subtotal INT	
END
GO

/* Add column for is_mobile and is_excel feature  */
IF COL_LENGTH('report', 'is_mobile') IS NULL
BEGIN
    ALTER TABLE report ADD is_mobile BIT DEFAULT 0
END
GO
IF COL_LENGTH('report', 'is_excel') IS NULL
BEGIN
    ALTER TABLE report ADD is_excel BIT DEFAULT 0
END
GO