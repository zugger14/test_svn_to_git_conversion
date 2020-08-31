
-------------------------------------------------------------------------------------------

DECLARE @i INT,@part_size int,@st varchar(1000)
SET @i=1
SET @part_size=1000
WHILE @i<=150
BEGIN
		
	set @st='ALTER DATABASE TRMTracker_Essent ADD FILEGROUP [FG_Farrms_'+RIGHT('00'+CAST(@i AS VARCHAR),3) +']	'
	print @st
	exec(@st)
	set @st='	
		ALTER DATABASE TRMTracker_Essent    
			ADD FILE      
			   (NAME =''FG_Farrms_'+RIGHT('00'+CAST(@i AS VARCHAR),3)+''' ,
					FILENAME = N''D:\file_group\FG_Farrms_'+RIGHT('00'+CAST(@i AS VARCHAR),3) +'.ndf'',
				   SIZE = 100MB,
					MAXSIZE = 35GB,
			  FILEGROWTH = 1GB) 
			TO FILEGROUP [FG_Farrms_'+RIGHT('00'+CAST(@i AS VARCHAR),3) +']'
	print @st
	exec(@st)
	SET @i=@i+1
END

---------------------------------------------------------------------
if exists(SELECT 1 FROM sys.partition_schemes WHERE [name]='PS_Farrms')
	drop PARTITION SCHEME [PS_Farrms]

if exists(SELECT * FROM sys.partition_functions WHERE [name]='PF_Farrms')
	drop PARTITION FUNCTION [PF_Farrms]

DECLARE @st1 varchar(max)

select @st1=ISNULL(@st1+',','')+cast(partition_to as varchar) from dbo.log_partition
set @st1='CREATE PARTITION FUNCTION [PF_Farrms](INT) AS RANGE LEFT FOR VALUES (
' +@st1+'
)'
print(@st1)
exec(@st1)
set @st1=null
select @st1=ISNULL(@st1+',','')+'FG_Farrms_'+RIGHT('00'+cast(partition_id as varchar),3) from dbo.log_partition
set @st1='CREATE PARTITION SCHEME [PS_Farrms] AS PARTITION [PF_Farrms] TO  (
	' +@st1+',[Primary]
	)'
print(@st1)
exec(@st1)
-----------------------------------------------------------------------------------------------
/*
CREATE PARTITION FUNCTION [PF_Farrms](INT) AS RANGE LEFT FOR VALUES (
1000,2000,3000,4000,5000,6000,7000,8000,9000,10000,11000,12000,13000,14000,15000,16000,17000,18000,19000,20000
,21000,22000,23000,24000,25000,26000,27000,28000,29000,30000,31000,32000,33000,34000,35000,36000,37000,38000,39000,40000
,41000,42000,43000,44000,45000,46000,47000,48000,49000,50000,51000,52000,53000,54000,55000,56000,57000,58000,59000,60000
,61000,62000,63000,64000,65000,66000,67000,68000,69000,70000,71000,72000,73000,74000,75000,76000,77000,78000,79000,80000
,81000,82000,83000,84000,85000,86000,87000,88000,89000,90000,91000,92000,93000,94000,95000,96000,97000,98000,99000,100000
,101000,102000,103000,104000,105000,106000,107000,108000,109000,110000,111000,112000,113000,114000,115000,116000,117000,118000,119000,120000
,121000,122000,123000,124000,125000,126000,127000,128000,129000,130000,131000,132000,133000,134000,135000,136000,137000,138000,139000,140000
,141000,142000,143000,144000,145000,146000,147000,148000,149000,150000
)
CREATE PARTITION SCHEME [PS_Farrms] AS PARTITION [PF_Farrms] TO  (
	FG_Farrms_001,FG_Farrms_002,FG_Farrms_003,FG_Farrms_004,FG_Farrms_005,FG_Farrms_006,FG_Farrms_007,FG_Farrms_008,FG_Farrms_009,FG_Farrms_010
	,FG_Farrms_011,FG_Farrms_012,FG_Farrms_013,FG_Farrms_014,FG_Farrms_015,FG_Farrms_016,FG_Farrms_017,FG_Farrms_018,FG_Farrms_019,FG_Farrms_020
	,FG_Farrms_021,FG_Farrms_022,FG_Farrms_023,FG_Farrms_024,FG_Farrms_025,FG_Farrms_026,FG_Farrms_027,FG_Farrms_028,FG_Farrms_029,FG_Farrms_030
	,FG_Farrms_031,FG_Farrms_032,FG_Farrms_033,FG_Farrms_034,FG_Farrms_035,FG_Farrms_036,FG_Farrms_037,FG_Farrms_038,FG_Farrms_039,FG_Farrms_040
	,FG_Farrms_041,FG_Farrms_042,FG_Farrms_043,FG_Farrms_044,FG_Farrms_045,FG_Farrms_046,FG_Farrms_047,FG_Farrms_048,FG_Farrms_049,FG_Farrms_050
	,FG_Farrms_051,FG_Farrms_052,FG_Farrms_053,FG_Farrms_054,FG_Farrms_055,FG_Farrms_056,FG_Farrms_057,FG_Farrms_058,FG_Farrms_059,FG_Farrms_060
	,FG_Farrms_061,FG_Farrms_062,FG_Farrms_063,FG_Farrms_064,FG_Farrms_065,FG_Farrms_066,FG_Farrms_067,FG_Farrms_068,FG_Farrms_069,FG_Farrms_070
	,FG_Farrms_071,FG_Farrms_072,FG_Farrms_073,FG_Farrms_074,FG_Farrms_075,FG_Farrms_076,FG_Farrms_077,FG_Farrms_078,FG_Farrms_079,FG_Farrms_080
	,FG_Farrms_081,FG_Farrms_082,FG_Farrms_083,FG_Farrms_084,FG_Farrms_085,FG_Farrms_086,FG_Farrms_087,FG_Farrms_088,FG_Farrms_089,FG_Farrms_090
	,FG_Farrms_091,FG_Farrms_092,FG_Farrms_093,FG_Farrms_094,FG_Farrms_095,FG_Farrms_096,FG_Farrms_097,FG_Farrms_098,FG_Farrms_099,FG_Farrms_100
	,FG_Farrms_101,FG_Farrms_102,FG_Farrms_103,FG_Farrms_104,FG_Farrms_105,FG_Farrms_106,FG_Farrms_107,FG_Farrms_108,FG_Farrms_109,FG_Farrms_110
	,FG_Farrms_111,FG_Farrms_112,FG_Farrms_113,FG_Farrms_114,FG_Farrms_115,FG_Farrms_116,FG_Farrms_117,FG_Farrms_118,FG_Farrms_119,FG_Farrms_120
	,FG_Farrms_121,FG_Farrms_122,FG_Farrms_123,FG_Farrms_124,FG_Farrms_125,FG_Farrms_126,FG_Farrms_127,FG_Farrms_128,FG_Farrms_129,FG_Farrms_130
	,FG_Farrms_131,FG_Farrms_132,FG_Farrms_133,FG_Farrms_134,FG_Farrms_135,FG_Farrms_136,FG_Farrms_137,FG_Farrms_138,FG_Farrms_139,FG_Farrms_140
	,FG_Farrms_141,FG_Farrms_142,FG_Farrms_143,FG_Farrms_144,FG_Farrms_145,FG_Farrms_146,FG_Farrms_147,FG_Farrms_148,FG_Farrms_149,FG_Farrms_150
	,[Primary]
	)

GO
*/

