
IF OBJECT_ID('log_partition') IS NOT NULL
DROP TABLE dbo.log_partition
GO
CREATE TABLE dbo.log_partition(
	partition_id INT,
	partition_from INT,
	partition_to INT,
	start_time DATETIME,
	end_time DATETIME,
	sp_start_time DATETIME,
	sp_end_time DATETIME,
	process_id varchar(50),
	tbl_name varchar(100),
	data_found_status BIT,
	error_found_status bit
)

go

DECLARE @i INT,@part_size int,@st varchar(1000)
SET @i=1
SET @part_size=1500
WHILE @i<=150
BEGIN
	INSERT into dbo.log_partition
	SELECT @i partition_id ,
		(@part_size*(@i-1))+1 partition_from ,
		@part_size*@i partition_to ,null	start_time,null	end_time,null	sp_start_time,null	sp_end_time,
NULL process_id,'deal_detail_hour' tbl_name,null data_found_status,null
	SET @i=@i+1
END

--SELECT * FROM dbo.log_partition