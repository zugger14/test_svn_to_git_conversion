SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/*Data Source Tables*/
-- Table: data_source 
IF OBJECT_ID(N'[dbo].[data_source]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[data_source] (
	[data_source_id] 		INT IDENTITY(1, 1) NOT NULL,
	[type_id] 				INT NOT NULL ,
	[name] 					VARCHAR(200) NOT NULL ,
	[alias] 				VARCHAR(100) NOT NULL ,
	[description] 			VARCHAR(8000) NULL ,
	[tsql] 					VARCHAR(8000) NULL ,
	[report_id]				INT,
	[create_user]        	VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]            	DATETIME NULL DEFAULT GETDATE(),
	[update_user]          	VARCHAR(50) NULL,
	[update_ts]            	DATETIME NULL,
	CONSTRAINT [PK_data_source] PRIMARY KEY CLUSTERED([data_source_id] ASC)
  ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table data_source EXISTS'
END

GO

IF OBJECT_ID('[dbo].[TRGUPD_data_source]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_data_source]
GO 
CREATE TRIGGER [dbo].[TRGUPD_data_source]
ON [dbo].[data_source]
FOR  UPDATE
AS
	UPDATE data_source
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   data_source t
	INNER JOIN DELETED u ON  t.data_source_id = u.data_source_id
GO

-- Table [dbo].`data_source_column`
IF OBJECT_ID(N'[dbo].[data_source_column]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[data_source_column] (
    [data_source_column_id]	INT IDENTITY(1, 1) NOT NULL,
	[source_id] 			INT NOT NULL ,
	[name] 					VARCHAR(100) NOT NULL ,
	[alias] 				VARCHAR(100) NOT NULL ,
	[reqd_param] 			BIT NOT NULL ,
	[widget_id] 			INT NULL ,
	[datatype_id] 			INT NULL ,
	[param_data_source] 	VARCHAR(8000) NULL ,
	[param_default_value] 	VARCHAR(8000) NULL ,
	[append_filter]		 	BIT NULL ,
	[create_user]          	VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]            	DATETIME NULL DEFAULT GETDATE(),
	[update_user]          	VARCHAR(50) NULL,
	[update_ts]            	DATETIME NULL,
	CONSTRAINT [PK_data_source_column] PRIMARY KEY CLUSTERED([data_source_column_id] ASC)
  ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table data_source_column EXISTS'
END

GO

IF OBJECT_ID('[dbo].[TRGUPD_data_source_column]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_data_source_column]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_data_source_column]
ON [dbo].[data_source_column]
FOR  UPDATE
AS
	UPDATE data_source_column
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   data_source_column t
	INNER JOIN DELETED u ON  t.data_source_column_id = u.data_source_column_id
GO

-- Table [dbo].`report_widget`
IF OBJECT_ID(N'[dbo].[report_widget]', N'U') IS NULL 
BEGIN
	CREATE TABLE [dbo].[report_widget] (
		[report_widget_id]		INT ,
		[name] 					VARCHAR(200) NULL ,
		[description] 			VARCHAR(8000) NULL ,
		[create_user]          	VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]            	DATETIME NULL DEFAULT GETDATE(),
		[update_user]          	VARCHAR(50) NULL,
		[update_ts]            	DATETIME NULL,
		CONSTRAINT [PK_report_widget] PRIMARY KEY CLUSTERED([report_widget_id] ASC)
	  ) ON [PRIMARY]
	  
	INSERT INTO dbo.[report_widget] ([report_widget_id],[name],[description])
	VALUES	(1, 'TEXTBOX', 'TEXTBOX'),
			(2, 'DROPDOWN', 'DROPDOWN'),
			(3, 'BSTREE-Subsidiary', 'BSTREE-Subsidiary'),
			(4, 'BSTREE-Strategy', 'BSTREE-Strategy'),
			(5, 'BSTREE-Book', 'BSTREE-Book'),
			(6, 'DATETIME','DATETIME')
END

GO

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
IF OBJECT_ID(N'[dbo].[report_datatype]', N'U') IS NULL 
BEGIN
	CREATE TABLE [dbo].[report_datatype] (
		[report_datatype_id] 	INT,
		[name] 					VARCHAR(200) NULL ,
		[description] 			VARCHAR(8000) NULL ,
		[create_user]          	VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]            	DATETIME NULL DEFAULT GETDATE(),
		[update_user]          	VARCHAR(50) NULL,
		[update_ts]            	DATETIME NULL,
		CONSTRAINT [PK_report_datatype] PRIMARY KEY CLUSTERED([report_datatype_id] ASC)
	  ) ON [PRIMARY]
	  
	INSERT INTO dbo.[report_datatype] ([report_datatype_id],[name],[description])
	VALUES	(1, 'CHAR', 'CHAR'), 
			(2, 'DATETIME', 'DATETIME'),
			(3, 'FLOAT', 'FLOAT'),
			(4, 'INT','INT'),
			(5, 'VARCHAR','VARCHAR')
			
END

GO

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

/*--------------------Data Source Tables*/


/*Report Tables*/
GO

-- Table [dbo].`report`
IF OBJECT_ID(N'[dbo].[report]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[report] (
	[report_id] 			INT IDENTITY(1, 1) NOT NULL,
	[name] 					VARCHAR(200) NULL ,
	[owner]					VARCHAR(45) NULL ,
	[is_system] 			BIT NULL ,
	[report_hash] 			VARCHAR(128) NULL ,
	[description]			VARCHAR(8000) NULL ,
	[category_id] 			INT NULL ,
	[create_user]          	VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]            	DATETIME NULL DEFAULT GETDATE(),
	[update_user]          	VARCHAR(50) NULL,
	[update_ts]            	DATETIME NULL,
	CONSTRAINT [PK_report] PRIMARY KEY CLUSTERED([report_id] ASC)
  ) ON [PRIMARY]
END
ELSE
BEGIN
	PRINT 'Table report EXISTS'
END

GO

IF OBJECT_ID('[dbo].[TRGUPD_report]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report]
ON [dbo].[report]
FOR  UPDATE
AS
	UPDATE report
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report t
	INNER JOIN DELETED u ON  t.report_id = u.report_id
GO


-- Table [dbo].`report_page`
IF OBJECT_ID(N'[dbo].[report_page]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[report_page] (
	[report_page_id] 		INT IDENTITY(1, 1) NOT NULL,
	[report_id] 			INT NULL ,
	[layout] 				INT NULL ,
	[name] 					VARCHAR(200) NULL ,
	[report_hash] 			VARCHAR(128) NULL ,
	[width] 				VARCHAR(45) NULL ,
	[height] 				VARCHAR(45) NULL ,
	[create_user]          	VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]            	DATETIME NULL DEFAULT GETDATE(),
	[update_user]          	VARCHAR(50) NULL,
	[update_ts]            	DATETIME NULL,
	CONSTRAINT [PK_report_page] PRIMARY KEY CLUSTERED([report_page_id] ASC)
  ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table PK_report_page EXISTS'
END
IF OBJECT_ID('[dbo].[TRGUPD_report_page]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_page]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_page]
ON [dbo].[report_page]
FOR  UPDATE
AS
	UPDATE report_page
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_page t
	INNER JOIN DELETED u ON  t.report_page_id = u.report_page_id
GO


-- Table [dbo].`report_dataset`
IF OBJECT_ID(N'[dbo].[report_dataset]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[report_dataset] (
	[report_dataset_id] 	INT IDENTITY(1, 1) NOT NULL,
	[source_id] 			INT NULL ,
	[report_id] 			INT NULL ,
	[alias] 				VARCHAR(100) NULL ,
	[root_dataset_id]		INT,
	[create_user]          	VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]            	DATETIME NULL DEFAULT GETDATE(),
	[update_user]          	VARCHAR(50) NULL,
	[update_ts]            	DATETIME NULL,
	CONSTRAINT [PK_report_dataset] PRIMARY KEY CLUSTERED([report_dataset_id] ASC)
  ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table report_dataset EXISTS'
END

IF OBJECT_ID('[dbo].[TRGUPD_report_dataset]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_dataset]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_dataset]
ON [dbo].[report_dataset]
FOR  UPDATE
AS
	UPDATE report_dataset
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_dataset t
	INNER JOIN DELETED u ON  t.report_dataset_id = u.report_dataset_id
GO


-- Table [dbo].`report_dataset_relationship`
IF OBJECT_ID(N'[dbo].[report_dataset_relationship]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[report_dataset_relationship] (
	[report_dataset_relationship_id] 	INT IDENTITY(1, 1) NOT NULL,
	[dataset_id] 						INT NULL ,
	[from_dataset_id]					INT NULL,
	[to_dataset_id]						INT NULL,
	[from_column_id]					INT NULL,
	[to_column_id]						INT NULL,
	[create_user]          				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]            				DATETIME NULL DEFAULT GETDATE(),
	[update_user]          				VARCHAR(50) NULL,
	[update_ts]            				DATETIME NULL,
	CONSTRAINT [PK_report_dataset_relationship] PRIMARY KEY CLUSTERED([report_dataset_relationship_id] ASC)
  ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table report_dataset_relationship EXISTS'
END

IF OBJECT_ID('[dbo].[TRGUPD_report_dataset_relationship]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_dataset_relationship]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_dataset_relationship]
ON [dbo].[report_dataset_relationship]
FOR  UPDATE
AS
	UPDATE report_dataset_relationship
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_dataset_relationship t
	INNER JOIN DELETED u ON  t.report_dataset_relationship_id = u.report_dataset_relationship_id
GO


/*--------------------Report Tables*/


/*Chart Tables*/


-- Table [dbo].`report_page_chart`
IF OBJECT_ID(N'[dbo].[report_page_chart]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[report_page_chart] (
	[report_page_chart_id] 		INT IDENTITY(1, 1) NOT NULL,
	[page_id] 					INT NULL ,
	[root_dataset_id] 			INT NULL ,
	[name] 						VARCHAR(500) NULL ,
	[type_id] 					INT NULL ,
	[width] 					VARCHAR(45) NULL ,
	[height] 					VARCHAR(45) NULL ,
	[top] 						VARCHAR(45) NULL ,
	[left] 						VARCHAR(45) NULL ,
	[create_user]          		VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]            		DATETIME NULL DEFAULT GETDATE(),
	[update_user]          		VARCHAR(50) NULL,
	[update_ts]            		DATETIME NULL,
	CONSTRAINT [PK_report_page_chart] PRIMARY KEY CLUSTERED([report_page_chart_id] ASC)
  ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table report_page_chart EXISTS'
END

IF OBJECT_ID('[dbo].[TRGUPD_report_page_chart]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_page_chart]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_page_chart]
ON [dbo].[report_page_chart]
FOR  UPDATE
AS
	UPDATE report_page_chart
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_page_chart t
	INNER JOIN DELETED u ON  t.report_page_chart_id = u.report_page_chart_id
GO


-- Table [dbo].`report_chart_column`
IF OBJECT_ID(N'[dbo].[report_chart_column]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[report_chart_column] (
	[report_chart_column_id] 	INT IDENTITY(1, 1) NOT NULL,
	[chart_id] 					INT NULL ,
	[column_id] 				INT NULL ,
	[placement] 				INT NULL ,
	[column_order] 				INT NULL ,
	[dataset_id] 				INT NULL ,
	[alias]          			VARCHAR(100),
	[create_user]          		VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]            		DATETIME NULL DEFAULT GETDATE(),
	[update_user]          		VARCHAR(50) NULL,
	[update_ts]            		DATETIME NULL,
	CONSTRAINT [PK_report_chart_column] PRIMARY KEY CLUSTERED([report_chart_column_id] ASC)
  ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table report_chart_column EXISTS'
END

IF OBJECT_ID('[dbo].[TRGUPD_report_chart_column]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_chart_column]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_chart_column]
ON [dbo].[report_chart_column]
FOR  UPDATE
AS
	UPDATE report_chart_column
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_chart_column t
	INNER JOIN DELETED u ON  t.report_chart_column_id = u.report_chart_column_id
GO

/*--------------------Chart Tables*/



/*Tablix Tables*/



-- Table [dbo].`report_page_tablix`
IF OBJECT_ID(N'[dbo].[report_page_tablix]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[report_page_tablix] (
	[report_page_tablix_id] 	INT IDENTITY(1, 1) NOT NULL,
	[page_id] 					INT NULL ,
	[root_dataset_id] 			INT NULL ,
	[name] 						VARCHAR(8000) NULL ,
	[width] 					VARCHAR(45) NULL ,
	[height] 					VARCHAR(45) NULL ,
	[top]	 					VARCHAR(45) NULL ,
	[left] 						VARCHAR(45) NULL ,
	[create_user]          		VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]            		DATETIME NULL DEFAULT GETDATE(),
	[update_user]          		VARCHAR(50) NULL,
	[update_ts]            		DATETIME NULL,
	CONSTRAINT [PK_report_page_tablix] PRIMARY KEY CLUSTERED([report_page_tablix_id] ASC)
  ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table report_page_tablix EXISTS'
END

IF OBJECT_ID('[dbo].[TRGUPD_report_page_tablix]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_page_tablix]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_page_tablix]
ON [dbo].[report_page_tablix]
FOR  UPDATE
AS
	UPDATE report_page_tablix
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_page_tablix t
	INNER JOIN DELETED u ON  t.report_page_tablix_id = u.report_page_tablix_id
GO


-- Table [dbo].`report_tablix_column`
IF OBJECT_ID(N'[dbo].[report_tablix_column]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[report_tablix_column] (
	[report_tablix_column_id] 	INT IDENTITY(1, 1) NOT NULL,
	[tablix_id] 				INT NULL ,
	[column_id] 				INT NULL ,
	[placement] 				INT NULL ,
	[aggregation] 				INT NULL ,
	[functions] 				VARCHAR(100) NULL ,
	[alias] 					VARCHAR(100) NULL ,
	[sortable]					INT NULL ,
	[rounding]					INT NULL ,
	[thousand_seperation] 		INT NULL ,
	[font]						VARCHAR(100) NULL ,
	[font_size] 				VARCHAR(45) NULL ,
	[font_style] 				VARCHAR(45) NULL ,
	[text_align] 				VARCHAR(45) NULL ,
	[text_color] 				VARCHAR(10) NULL ,
	[default_sort_order]		INT NULL ,
	[default_sort_direction]	INT NULL ,
	[background] 				VARCHAR(10) NULL ,
	[dataset_id]				INT NULL,
	[column_order]				INT NULL,
	[custom_field]				BIT NULL,
	[create_user]          		VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]            		DATETIME NULL DEFAULT GETDATE(),
	[update_user]          		VARCHAR(50) NULL,
	[update_ts]            		DATETIME NULL,
	CONSTRAINT [PK_report_tablix_column] PRIMARY KEY CLUSTERED([report_tablix_column_id] ASC)
  ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table report_tablix_column EXISTS'
END

IF OBJECT_ID('[dbo].[TRGUPD_report_tablix_column]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_tablix_column]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_tablix_column]
ON [dbo].[report_tablix_column]
FOR  UPDATE
AS
	UPDATE report_tablix_column
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_tablix_column t
	INNER JOIN DELETED u ON  t.report_tablix_column_id = u.report_tablix_column_id
GO

-- Table [dbo].`report_column_link`
IF OBJECT_ID(N'[dbo].[report_column_link]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[report_column_link] (
	[report_column_link_id] 	INT IDENTITY(1, 1) NOT NULL,
	[tablix_column_id] 			INT NULL ,
	[page_id] 					INT NULL ,
	[paramset_id]				INT NULL ,
	[parameter_pair] 			VARCHAR(100) NULL ,
	[create_user]          		VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]            		DATETIME NULL DEFAULT GETDATE(),
	[update_user]          		VARCHAR(50) NULL,
	[update_ts]            		DATETIME NULL,
	CONSTRAINT [PK_report_column_link] PRIMARY KEY CLUSTERED([report_column_link_id] ASC)
  ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table report_column_link EXISTS'
END

IF OBJECT_ID('[dbo].[TRGUPD_report_column_link]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_column_link]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_column_link]
ON [dbo].[report_column_link]
FOR  UPDATE
AS
	UPDATE report_column_link
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_column_link t
	INNER JOIN DELETED u ON  t.report_column_link_id = u.report_column_link_id
GO


/*--------------------Tablix Tables*/


/*Parameters Tables*/


-- Table: report_param_operator 
IF OBJECT_ID(N'[dbo].[report_param_operator]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[report_param_operator] (
	[report_param_operator_id]	INT  ,
	[description]				VARCHAR(250) ,
	[sql_code]					VARCHAR(20),
	[create_user]        		VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]            		DATETIME NULL DEFAULT GETDATE(),
	[update_user]          		VARCHAR(50) NULL,
	[update_ts]					DATETIME NULL,
	CONSTRAINT [PK_report_param_operator_id] PRIMARY KEY CLUSTERED([report_param_operator_id] ASC)
  ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table report_param_operator EXISTS'
END

IF OBJECT_ID('[dbo].[TRGUPD_report_param_operator]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_param_operator]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_param_operator]
ON [dbo].[report_param_operator]
FOR  UPDATE
AS
	UPDATE report_param_operator
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_param_operator t
	INNER JOIN DELETED u ON  t.report_param_operator_id = u.report_param_operator_id
GO


-- Table [dbo].`report_paramset`
IF OBJECT_ID(N'[dbo].[report_paramset]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[report_paramset] (
	[report_paramset_id] 	INT IDENTITY(1, 1) NOT NULL,
	[page_id] 				INT NULL ,
	[name] 					VARCHAR(100) NULL ,
	[create_user]          	VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]            	DATETIME NULL DEFAULT GETDATE(),
	[update_user]          	VARCHAR(50) NULL,
	[update_ts]            	DATETIME NULL,
	CONSTRAINT [PK_report_paramset] PRIMARY KEY CLUSTERED([report_paramset_id] ASC)
  ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table report_paramset EXISTS'
END

IF OBJECT_ID('[dbo].[TRGUPD_report_paramset]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_paramset]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_paramset]
ON [dbo].[report_paramset]
FOR  UPDATE
AS
	UPDATE report_paramset
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_paramset t
	INNER JOIN DELETED u ON  t.report_paramset_id = u.report_paramset_id
GO


-- Table [dbo].`report_dataset_paramset`
IF OBJECT_ID(N'[dbo].[report_dataset_paramset]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[report_dataset_paramset]
    (
    [report_dataset_paramset_id]  INT IDENTITY(1, 1) NOT NULL,
    [paramset_id]			INT,
    [root_dataset_id]		INT,
    [where_part]			VARCHAR(8000),
    [create_user]          	VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]            	DATETIME NULL DEFAULT GETDATE(),
	[update_user]          	VARCHAR(50) NULL,
	[update_ts]            	DATETIME NULL,
    )
END
ELSE
BEGIN
    PRINT 'Table report_dataset_paramset EXISTS'
END
IF OBJECT_ID('[dbo].[TRGUPD_report_dataset_paramset]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_dataset_paramset]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_dataset_paramset]
ON [dbo].[report_dataset_paramset]
FOR  UPDATE
AS
	UPDATE report_dataset_paramset
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_dataset_paramset t
	INNER JOIN DELETED u ON  t.report_dataset_paramset_id = u.report_dataset_paramset_id
GO

-- Table [dbo].`report_param`
-- -----------------------------------------------------
IF OBJECT_ID(N'[dbo].[report_param]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[report_param] (
	[report_param_id] 		INT IDENTITY(1, 1) NOT NULL,
	[dataset_paramset_id] 	INT NULL ,
	[dataset_id] 			INT NULL ,
	[column_id] 			INT NULL ,
	[operator] 				INT NULL ,
	[initial_value] 		VARCHAR(45) NULL ,
	[initial_value2] 		VARCHAR(45) NULL ,
	[optional] 				BIT NULL ,
	[hidden] 				BIT NULL ,
	[create_user]          	VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]            	DATETIME NULL DEFAULT GETDATE(),
	[update_user]          	VARCHAR(50) NULL,
	[update_ts]            	DATETIME NULL,
	CONSTRAINT [PK_report_param] PRIMARY KEY CLUSTERED([report_param_id] ASC)
  ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table report_param EXISTS'
END

IF OBJECT_ID('[dbo].[TRGUPD_report_param]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_param]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_param]
ON [dbo].[report_param]
FOR  UPDATE
AS
	UPDATE report_param
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_param t
	INNER JOIN DELETED u ON  t.report_param_id = u.report_param_id
GO



/*--------------------Parameters Tables*/


/*Privilege Tables*/


-- Table [dbo].`report_manager_view_users`
IF OBJECT_ID(N'[dbo].[report_manager_view_users]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[report_manager_view_users](
	[functional_users_id]	INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[data_source_id]		INT NOT NULL CONSTRAINT fk_report_manager_view_users_data_source REFERENCES dbo.data_source(data_source_id),
	[role_id]				INT NULL CONSTRAINT fk_report_manager_view_users_application_security_role REFERENCES dbo.application_security_role(role_id),
	[login_id]				VARCHAR(50) NULL CONSTRAINT fk_report_manager_view_users_application_users REFERENCES dbo.application_users(user_login_id),
	[entity_id]				INT NULL CONSTRAINT fk_report_manager_view_users_portfolio_hierarchy REFERENCES dbo.portfolio_hierarchy(entity_id),
	[create_user]			VARCHAR(100) NOT NULL CONSTRAINT DF_report_manager_view_users_create_user DEFAULT dbo.FNADBUser(),
	[create_ts]				DATETIME NULL CONSTRAINT DF_report_manager_view_users_create_ts DEFAULT GETDATE(),
	[update_user]			VARCHAR(100) NULL,
	[update_ts]				DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table report_manager_view_users EXISTS'
END
GO


IF OBJECT_ID('[dbo].[TRGUPD_report_manager_view_users]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_manager_view_users]
GO

CREATE TRIGGER [dbo].[TRGUPD_report_manager_view_users]
ON [dbo].[report_manager_view_users]
FOR  UPDATE
AS
	UPDATE report_manager_view_users
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_manager_view_users rmvu
	       INNER JOIN DELETED u
	       ON  rmvu.functional_users_id = u.functional_users_id
GO


-- Table [dbo].`report_privilege`
IF OBJECT_ID(N'[dbo].[report_privilege]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[report_privilege] (
	[report_privilege_id]		INT IDENTITY(1,1) NOT NULL,
	[user_id]					VARCHAR(100) NULL,
	[role_id]					INT NULL,
	[report_hash]				VARCHAR(5000) NULL,
	[report_privilege_type]		CHAR(1) NULL,
	[create_user]          		VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]            		DATETIME NULL DEFAULT GETDATE(),
	[update_user]          		VARCHAR(50) NULL,
	[update_ts]            		DATETIME NULL,
	CONSTRAINT [PK_report_privilege] PRIMARY KEY CLUSTERED([report_privilege_id] ASC)
  ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table report_privilege EXISTS'
END

IF OBJECT_ID('[dbo].[TRGUPD_report_privilege]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_report_privilege]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_privilege]
ON [dbo].[report_privilege]
FOR  UPDATE
AS
	UPDATE report_privilege
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	FROM   report_privilege t
	INNER JOIN DELETED u ON  t.report_privilege_id = u.report_privilege_id
GO

/**
* table creation 'report_paramset_privilege' for paramset level privileges.
**/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[report_paramset_privilege]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[report_paramset_privilege]
    (
    [report_paramset_privilege_id]      INT IDENTITY(1, 1) PRIMARY KEY,
    [report_paramset_privilege_type]	CHAR(1) NULL,
    [user_id]							VARCHAR(100) NULL,
    [role_id]							INT NULL,
    [paramset_hash]						VARCHAR(5000) NULL,
    [create_user]    					VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]      					DATETIME NULL DEFAULT GETDATE(),
    [update_user]    					VARCHAR(50) NULL,
    [update_ts]      					DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table table_name EXISTS'
END
 
GO

-- adding update trigger for above table
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_report_paramset_privilege]'))
    DROP TRIGGER [dbo].[TRGUPD_report_paramset_privilege]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_report_paramset_privilege]
ON [dbo].[report_paramset_privilege]
FOR UPDATE
AS
BEGIN
    --this check is required to prevent recursive trigger
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE report_paramset_privilege
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM report_paramset_privilege rpp
        INNER JOIN DELETED d ON d.report_paramset_privilege_id = rpp.report_paramset_privilege_id
    END
END
GO
/*--------------------Privilege Tables*/