IF NOT EXISTS(SELECT 1 FROM partition_config_info  WHERE table_name = 'delta_report_hourly_position')
BEGIN
INSERT INTO [dbo].[partition_config_info]
           ([table_name]
           ,[no_partitions]
           ,[partition_nature]
           ,[partition_key]
           ,[function_name]
           ,[scheme_name]
           ,[frequency]
           ,[filegroup]
           ,[archive_status]
           ,[stage_table_name]
           ,[archive_table_name]
           ,[archive_db_name]
           ,[archive_server]
           ,[del_flg]
           ,[create_user]
           ,[create_ts]
           ,[update_user]
           ,[update_ts])
     VALUES
           ('delta_report_hourly_position'
           ,12
           ,'DATE'
           ,'term_start'
           ,'PF_position'
           ,'PS_position'
           ,'m'
           ,'FG_DATE'
           ,'Y'
           ,'delta_report_hourly_position'
           ,NULL
           ,NULL
           ,NULL
           ,'N'
           ,'SGUPTA'
           ,GETDATE()
           ,NULL
           ,NULL)
END


