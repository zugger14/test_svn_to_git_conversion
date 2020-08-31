IF OBJECT_ID('testing.pre_post_configuration') is null
CREATE TABLE [testing].pre_post_configuration 
(
      row_id INT IDENTITY(1, 1)
      , module_value_id INT REFERENCES dbo.static_data_value (value_id)
      , tbl_name VARCHAR(150)
      , descrptn VARCHAR(1000)
      , unique_clms VARCHAR(500)
      , compare_clms VARCHAR(500)
      , display_clms VARCHAR(500)
      , exec_sp  VARCHAR(8000)
      , re_calc_sp VARCHAR(8000)
      , as_of_date_filter_clm VARCHAR(50)
      , deal_filter_clm VARCHAR(100)
      , order_by_clm_index VARCHAR(50)
      , create_user VARCHAR(50) DEFAULT dbo.FNADBUser()
      , create_ts DATETIME DEFAULT GETDATE()
      , update_user VARCHAR(50)
      , update_ts DATETIME
)

go

--creating synonyms will allow to access objects in testing schema without specifying schema name (same as objects under dbo schema)
IF  EXISTS (SELECT * FROM sys.synonyms WHERE name = N'pre_post_configuration')
      DROP SYNONYM [dbo].[pre_post_configuration]
GO

CREATE SYNONYM [dbo].[pre_post_configuration] FOR [testing].[pre_post_configuration]
GO

IF COL_LENGTH(N'testing.pre_post_configuration', N'regression_group_value_id') IS NULL
	ALTER TABLE testing.pre_post_configuration ADD regression_group_value_id INT  