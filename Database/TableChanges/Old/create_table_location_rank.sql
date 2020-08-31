----DROP table dbo.location_rank


IF object_id('dbo.location_rank') is null
	create table dbo.location_rank
	(
		location_rank_id int identity(1,1) 	,
		location_id int,
		effective_date datetime,
		rank_value_id int ,
		[create_user]						VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]							DATETIME DEFAULT GETDATE(),
		[update_user]						VARCHAR(100) NULL,
		[update_ts]							DATETIME NULL
	 )
