IF NOT EXISTS(SELECT 'x' FROM manual_partition_config_info WHERE [archive_type_value_id] = 2155)

INSERT INTO manual_partition_config_info
           ([archive_type_value_id]
           ,[curve_id]
           ,[period]
           ,[del_flg])
     VALUES
           (2155
           ,'82,133,134,135,132,139,140,141,142,23,168,161,197,143,83,84,107,93,95,156,145,155'
           ,60
           ,1)
GO


