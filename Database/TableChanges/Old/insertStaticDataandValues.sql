
INSERT INTO [dbo].[static_data_type]
           ([type_id]
           ,[type_name]
           ,[internal]
           ,[description]
)
     VALUES
           (12000
           ,'Block Type'
           ,1
           ,'Block Type'

)
go	

 
SET IDENTITY_INSERT dbo.[static_data_value] on

	INSERT INTO [static_data_value]
			   ([value_id],[type_id],[code],[description])
		 VALUES
			   (4030,4000 ,'Major_location','Major Location')

	INSERT INTO [static_data_value]
			   ([value_id],[type_id],[code],[description])
		 VALUES
			   (4031,4000 ,'minor_location','Minor Location')

	INSERT INTO [static_data_value]
			   ([value_id],[type_id],[code],[description])
		 VALUES
			   (12000,12000 ,'OnPeak','OnPeak')

	INSERT INTO [static_data_value]
			   ([value_id],[type_id],[code],[description])
		 VALUES
			   (12001,12000 ,'OffPeak','OffPeak')

	INSERT INTO [static_data_value]
			   ([value_id],[type_id],[code],[description])
		 VALUES
			   (12002,12000 ,'Baseload','Baseload')
	INSERT INTO [static_data_value]
			   ([value_id],[type_id],[code],[description])
		 VALUES
			   (12003,12000 ,'CustomBlock','CustomBlock')

	INSERT INTO [static_data_value]
			   ([value_id],[type_id],[code],[description])
		 VALUES
			   (12004,12000 ,'Custom','Custom')
	SET IDENTITY_INSERT dbo.[static_data_value] off
