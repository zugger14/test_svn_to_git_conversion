IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10164500 AND product_category = 10000000)
BEGIN
	INSERT INTO [dbo].[setup_menu]
           ([function_id]
           ,[window_name]
           ,[display_name]
           ,[default_parameter]
           ,[hide_show]
           ,[parent_menu_id]
           ,[product_category]
           ,[menu_order]
           ,[menu_type])
     VALUES
           (10164500
           ,NULL
           ,'Regulatory Submission'
           ,NULL
           ,1
           ,10160000
           ,10000000
           ,115
           ,0)
END
GO

UPDATE setup_menu SET display_name = 'Nomination EDI' WHERE function_id = 10164300 AND display_name = 'Regulatory Submission'
