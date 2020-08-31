
USE [msdb]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('spa_email_server_health') IS NOT NULL
DROP proc [dbo].[spa_email_server_health]
go

CREATE PROCEDURE [dbo].[spa_email_server_health]
  (
  	@database_name VARCHAR(100)
  )

/*

exec EmailSQLServerHealth  @database_name = 'TRMTRACKER_ESSENT''

*/

AS    
BEGIN

SET NOCOUNT ON


--DECLARE @ServerIP VARCHAR(100) = 'langtang\instance2008'  -- SQL Server 2005 Database Server IP Address
DECLARE @Project VARCHAR(100) -- Name of project or cleint 
DECLARE @Recepients VARCHAR(2000) -- Recepient(s) of this email (; separated in case of multiple recepients).
DECLARE @MailProfile VARCHAR(100) -- Mail profile name which exists on the target database server
DECLARE @Owner VARCHAR(200) -- Owner, basically name/email of the DBA responsible for the server
--DECLARE @database_name VARCHAR(100) = 'Trmtracker_essent'
DECLARE @sql_stmt VARCHAR(500)
DECLARE @sql_stmt1 VARCHAR(500)
SET @project = 'DB Health CHECK Alert'


IF EXISTS (SELECT 1 FROM sysobjects WHERE name = '#mailprofile')    
BEGIN    
	DROP TABLE #mailprofile    
END 
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = '#recep')    
BEGIN    
	DROP TABLE #recep   
END 
CREATE TABLE #mailprofile
(
	email VARCHAR(500) COLLATE DATABASE_DEFAULT 
	
)

CREATE TABLE #recep
(
	recep VARCHAR(1500) COLLATE DATABASE_DEFAULT 
	
)
SET @sql_stmt = ' INSERT INTO   #recep   select   description
		FROM  ' + @database_name + '.dbo.adiha_default_codes_values_possible
		WHERE default_code_id = 44 '
EXEC (@sql_stmt)

SET @sql_stmt1  = 'INSERT INTO   #mailprofile   SELECT email_profile
FROM  ' + @database_name + '.dbo.connection_string'

EXEC  (@sql_stmt1)

SELECT @mailprofile = email FROM #mailprofile
SELECT @recepients = recep FROM #recep

/* Drop all the temp tables(not necessary at all as local temp tables get dropped as soon as session is released, 
however, good to follow this practice). */
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = '#jobs_status')    
BEGIN    
	DROP TABLE #jobs_status    
END    

IF EXISTS (SELECT 1 FROM sysobjects WHERE name = '#diskspace')    
BEGIN    
	DROP TABLE #diskspace
END    
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = '#cpu')    
BEGIN    
	DROP TABLE #cpu
END 

IF EXISTS (SELECT NAME FROM sysobjects WHERE name = '#url')    
BEGIN    
	DROP TABLE #url
END    

IF EXISTS (SELECT NAME FROM sysobjects WHERE name = '#dirpaths')    
BEGIN    
	DROP TABLE #dirpaths
END    

IF EXISTS (SELECT NAME FROM sysobjects WHERE name = '#LogLines')    
BEGIN    
	DROP TABLE #LogLines
END    
IF EXISTS (SELECT NAME FROM sysobjects WHERE name = '#hitratio')    
BEGIN    
	DROP TABLE #hitratio
END   

IF EXISTS (SELECT NAME FROM sysobjects WHERE name = '#networkerr')    
BEGIN    
	DROP TABLE #networkerr
END   

IF EXISTS (SELECT NAME FROM sysobjects WHERE name = '#num_conn')    
BEGIN    
	DROP TABLE #num_conn
END  
-- Create the temp tables which will be used to hold the data. 
Create table #LogLines (Logdate datetime,
                         ProcessInfo varchar(200) COLLATE DATABASE_DEFAULT,
                         Msg_Text varchar(2000) COLLATE DATABASE_DEFAULT)
                         
CREATE TABLE #url
(
	idd INT IDENTITY (1,1), 
	url VARCHAR(1000) COLLATE DATABASE_DEFAULT
)

CREATE TABLE #dirpaths 
(
	files VARCHAR(2000) COLLATE DATABASE_DEFAULT
)

CREATE TABLE #diskspace
(
	drive VARCHAR(200) COLLATE DATABASE_DEFAULT, 
	diskspace INT
)

CREATE TABLE #cpu
(
	cputime INT, 
	cpu_stat VARCHAR(50) COLLATE DATABASE_DEFAULT
)
CREATE TABLE #hitratio
(
	hit_ratio INT, 
	hit_status VARCHAR(50) COLLATE DATABASE_DEFAULT
)
CREATE TABLE #networkerr
(
	net_error INT, 
	net_status VARCHAR(50) COLLATE DATABASE_DEFAULT
)

CREATE TABLE #num_conn
(
	cntconn INT, 
	conn_status VARCHAR(50) COLLATE DATABASE_DEFAULT
)

-- This table will hold data from sp_help_job (System sp in MSDB database)
CREATE TABLE #jobs_status    
(    
	job_id UNIQUEIDENTIFIER,    
	originating_server NVARCHAR(30) COLLATE DATABASE_DEFAULT,    
	name SYSNAME,    
	enabled TINYINT,    
	description NVARCHAR(512) COLLATE DATABASE_DEFAULT,    
	start_step_id INT,    
	category SYSNAME,    
	owner SYSNAME,    
	notify_level_eventlog INT,    
	notify_level_email INT,    
	notify_level_netsend INT,    
	notify_level_page INT,    
	notify_email_operator SYSNAME,    
	notify_netsend_operator SYSNAME,    
	notify_page_operator SYSNAME,    
	delete_level INT,    
	date_created DATETIME,    
	date_modified DATETIME,    
	version_number INT,    
	last_run_date INT,    
	last_run_time INT,    
	last_run_outcome INT,    
	next_run_date INT,    
	next_run_time INT,    
	next_run_schedule_id INT,    
	current_execution_status INT,    
	current_execution_step SYSNAME,    
	current_retry_attempt INT,    
	has_step INT,    
	has_schedule INT,    
	has_target INT,    
	type INT    
)    

-- To insert data in couple of temp tables created above.
--INSERT #diskspace(drive, diskspace) EXEC xp_fixeddrives     
Insert into #LogLines Exec sys.xp_readErrorLog
DECLARE @cpu INT
DECLARE @cpu_stat VARCHAR(50)
--PRINT 'SANTOH'
SELECT @cpu = @@CPU_BUSY
IF @cpu < 30000 
	SET @cpu_stat = 'NORMAL'
ELSE
	SET @cpu_stat = 'Error:******** CPU BUSY OVERLOAD DETECTED! *******'

INSERT INTO #cpu (
	cputime,
	cpu_stat
) VALUES ( 
	@cpu,
	@cpu_stat ) 


DECLARE	@def_hit_ratio INT 
DECLARE	@hit_ratio INT
DECLARE @hit_status VARCHAR(50)
SET @def_hit_ratio = 90

select @hit_ratio = 100.0 * (select avg(cntr_value) x 
              from sys.dm_os_performance_counters
                   where counter_name = 'Buffer cache hit ratio') /
               (select avg(cntr_value) y 
              from sys.dm_os_performance_counters
                   where counter_name = 'Buffer cache hit ratio base')
IF @hit_ratio > @hit_ratio	
	SET	@hit_status = 'Error:****** cache hit ratio problem....'
ELSE 
	SET @hit_status = 'Cache Hit Ratio is Normal'
INSERT INTO #hitratio (
	hit_ratio,
	hit_status
) VALUES ( 
	@hit_ratio,
	@hit_status ) 

DECLARE @net_err INT
DECLARE @net_status VARCHAR(50)
SELECT @net_err = @@PACKET_ERRORS
IF @net_err > 0
	SET	@net_status = 'Error:******** NETWORK PACKET ERRORS DETECTED! *******'
ELSE 
	SET @net_status = 'No Network Packet Error'
	
INSERT INTO #networkerr (
	net_error,
	net_status
) VALUES ( 
	@net_err,
	@net_status ) 




DECLARE @cntconn INT
DECLARE @conn_status VARCHAR(50)
select @cntconn = count(*) from MASTER.dbo.sysprocesses 
IF @cntconn > 0
	SET	@conn_status = 'Error: ******** Num connection exceeded threshold '
ELSE 
	SET @conn_status = 'Normal'
	
INSERT INTO #num_conn (
	cntconn,
	conn_status
) VALUES ( 
	@cntconn,
	@conn_status )



INSERT #jobs_status EXEC msdb.dbo.sp_help_job  

-- Variable declaration   
DECLARE @TableHTML  VARCHAR(MAX),    
		@StrSubject VARCHAR(100),    
		@Oriserver VARCHAR(100),
		@Version VARCHAR(250),
		@Edition VARCHAR(100),
		@ISClustered VARCHAR(100),
		@SP VARCHAR(100),
		@ServerCollation VARCHAR(100),
		@SingleUser VARCHAR(5),
		@LicenseType VARCHAR(100),
		@StartDate DATETIME,
		@EndDate DATETIME,
		@Cnt int,
		@URL varchar(1000),
		@Str varchar(1000)
		
-- Variable Assignment
SELECT @Version = @@version
SELECT @Edition = CONVERT(VARCHAR(100), serverproperty('Edition'))
SELECT @StartDate = CAST(CONVERT(VARCHAR(4), DATEPART(yyyy, GETDATE())) + '-' + CONVERT(VARCHAR(2), DATEPART(mm, GETDATE())) + '-01' AS DATETIME)
SELECT @StartDate = @StartDate - 1
SELECT @EndDate = CAST(CONVERT(VARCHAR(5),DATEPART(yyyy, GETDATE() + 1)) + '-' + CONVERT(VARCHAR(2),DATEPART(mm, GETDATE() + 1)) + '-' + CONVERT(VARCHAR(2), DATEPART(dd, GETDATE() + 1)) AS DATETIME)  
SET @Cnt = 0

IF serverproperty('IsClustered') = 0 
BEGIN
	SELECT @ISClustered = 'No'
END
ELSE
BEGIN
	SELECT @ISClustered = 'YES'
END

SELECT @SP = CONVERT(VARCHAR(100), SERVERPROPERTY ('productlevel'))
SELECT @ServerCollation = CONVERT(VARCHAR(100), SERVERPROPERTY ('Collation')) 
SELECT @LicenseType = CONVERT(VARCHAR(100), SERVERPROPERTY ('LicenseType')) 
SELECT @SingleUser = CASE SERVERPROPERTY ('IsSingleUser')
						WHEN 1 THEN 'Yes'
						WHEN 0 THEN 'No'
						ELSE
						'null' END
SELECT @OriServer = CONVERT(VARCHAR(50), SERVERPROPERTY('servername'))  
SELECT @strSubject = 'DB Server Daily Health Checks ('+ CONVERT(VARCHAR(50), SERVERPROPERTY('servername')) + ')'    
  
 -- <td width="27%" height="22" bgcolor="#A9A9A9"><b>  
	--<font face="Verdana" size="2" color="#FFFFFF">Server IP</font></b></td> 
--<td width="27%" height="27"><font face="Verdana" size="2">'+@ServerIP+'</font></td> 
SET @TableHTML =    
	'<font face="Verdana" size="4">Server Info</font>  
	<table border="1" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" width="47%" id="AutoNumber1" height="50">  
	<tr>  
	 
	<td width="39%" height="22" bgcolor="#A9A9A9"><b>  
	<font face="Verdana" size="2" color="#FFFFFF">Server Name</font></b></td>  
	<td width="90%" height="22" bgcolor="#A9A9A9"><b>  
	<font face="Verdana" size="2" color="#FFFFFF">Project/Client</font></b></td>  
	</tr>  
	<tr>  
	 
	<td width="39%" height="27"><font face="Verdana" size="2">' + @OriServer +'</font></td>  
	<td width="90%" height="27"><font face="Verdana" size="2">'+@Project+'</font></td>  
	</tr>  
	</table> 

	<table id="AutoNumber1" style="BORDER-COLLAPSE: collapse" borderColor="#111111" height="40" cellSpacing="0" cellPadding="0" width="933" border="1">
	<tr>
	<td width="50%" bgColor="#A9A9A9" height="15"><b>
	<font face="Verdana" color="#ffffff" size="1">Version</font></b></td>
	<td width="17%" bgColor="#A9A9A9" height="15"><b>
	<font face="Verdana" color="#ffffff" size="1">Edition</font></b></td>
	<td width="18%" bgColor="#A9A9A9" height="15"><b>
	<font face="Verdana" color="#ffffff" size="1">Service Pack</font></b></td>
	<td width="93%" bgColor="#A9A9A9" height="15"><b>
	<font face="Verdana" color="#ffffff" size="1">Collation</font></b></td>
	<td width="93%" bgColor="#A9A9A9" height="15"><b>
	<font face="Verdana" color="#ffffff" size="1">LicenseType</font></b></td>
	<td width="30%" bgColor="#A9A9A9" height="15"><b>
	<font face="Verdana" color="#ffffff" size="1">SingleUser</font></b></td>
	<td width="93%" bgColor="#A9A9A9" height="15"><b>
<font face="Verdana" color="#ffffff" size="1">Clustered</font></b></td>
	</tr>
	<tr>
	<td width="50%" height="27"><font face="Verdana" size="1">'+@version +'</font></td>
	<td width="17%" height="27"><font face="Verdana" size="1">'+@edition+'</font></td>
	<td width="18%" height="27"><font face="Verdana" size="1">'+@SP+'</font></td>
	<td width="17%" height="27"><font face="Verdana" size="1">'+@ServerCollation+'</font></td>
	<td width="25%" height="27"><font face="Verdana" size="1">'+@LicenseType+'</font></td>
	<td width="25%" height="27"><font face="Verdana" size="1">'+@SingleUser+'</font></td>
	<td width="93%" height="27"><font face="Verdana" size="1">'+@isclustered+'</font></td>
	</tr>
	</table>

	<p style="margin-top: 0; margin-bottom: 0">&nbsp;</p>' +    
	' <font face="Verdana" size="4">Job Status</font><table style="BORDER-COLLAPSE: collapse" borderColor="#111111" cellPadding="0" width="933" bgColor="#ffffff" borderColorLight="#000000" border="1">  
	
	<tr>  
	<th align="left" width="432" bgColor="#A9A9A9">  
	<font face="Verdana" size="1" color="#FFFFFF">Job Name</font></th>  
	<th align="left" width="91" bgColor="#A9A9A9">  
	<font face="Verdana" size="1" color="#FFFFFF">Enabled</font></th>  
	<th align="left" width="85" bgColor="#A9A9A9">  
	<font face="Verdana" size="1" color="#FFFFFF">Last Run</font></th>  
	<th align="left" width="183" bgColor="#A9A9A9">  
	<font face="Verdana" size="1" color="#FFFFFF">Category</font></th>  
	<th align="left" width="136" bgColor="#A9A9A9">  
	<font face="Verdana" size="1" color="#FFFFFF">Last Run Date</font></th>  
	<th align="left" width="136" bgColor="#A9A9A9">  
	<font face="Verdana" size="1" color="#FFFFFF">Execution Time (Mi)</font></th>  
	</tr>
	'  
  
SELECT 
	@TableHTML = @TableHTML + '<tr><td><font face="Verdana" size="1">' + 
				ISNULL(CONVERT(VARCHAR(100), A.name), '') +'</font></td>' +    
	CASE enabled  
		WHEN 0 THEN '<td bgcolor="#FFCC99"><b><font face="Verdana" size="1">False</font></b></td>'  
		WHEN 1 THEN '<td><font face="Verdana" size="1">True</font></td>'  
	ELSE '<td><font face="Verdana" size="1">Unknown</font></td>'  
	END  +   
	CASE last_run_outcome     
		WHEN 0 THEN '<td bgColor="#ff0000"><b><blink><font face="Verdana" size="2">
		<a href="mailto:support@pioneersolutionsglobal.com?subject=Job failure - ' + @Oriserver +  CONVERT(VARCHAR(15), GETDATE(), 101) +'?@body = SD please log this call to DB support,' + '%0A %0A' + '<<' + ISNULL(CONVERT(VARCHAR(100), name),'''') + '>> Job Failed on ' + @OriServer +  '.' +'%0A%0A Regards,'+'">Failed</a></font></blink></b></td>'
		WHEN 1 THEN '<td><font face="Verdana" size="1">Success</font></td>'  
		WHEN 3 THEN '<td><font face="Verdana" size="1">Cancelled</font></td>'  
		WHEN 5 THEN '<td><font face="Verdana" size="1">Unknown</font></td>'  
	ELSE '<td><font face="Verdana" size="1">Other</font></td>'  
	END  +   
	'<td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(100), A.category),'') + '</font></td>' +   
	'<td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(50), A.last_run_date),'') + '</font></td>' +
	'<td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(50), X.execution_time_minutes),'') +'</font></td> </tr>'   
FROM 
	#jobs_status A
	inner join (
				select 
					A.job_id,
					datediff(mi, A.last_executed_step_date, A.stop_execution_date) execution_time_minutes 
				from 
					msdb..sysjobactivity A
	inner join (
				select 
					max(session_id) sessionid,
					job_id 
				from 
					msdb..sysjobactivity 
				group by 
					job_id
				) B on a.job_id = B.job_id and a.session_id = b.sessionid
	inner join (
				select 
					distinct name, 
					job_id 
				from 
					msdb..sysjobs
				) C on A.job_id = c.job_id
				) X on A.job_id = X.job_id
ORDER BY 
	last_run_date DESC  

SELECT 
	@TableHTML =  @TableHTML + 
	'</table> <font face="Verdana" size="4">Databases</font> <table id="AutoNumber1" style="BORDER-COLLAPSE: collapse" borderColor="#111111" height="40" cellSpacing="0" cellPadding="0" width="933" border="1">
	  
	  <tr>
		<td width="35%" bgColor="#A9A9A9" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">Name</font></b></td>
		<td width="23%" bgColor="#A9A9A9" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">CreatedDate</font></b></td>
		<td width="23%" bgColor="#A9A9A9" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">DB Size(GB)</font></b></td>
		<td width="30%" bgColor="#A9A9A9" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">State</font></b></td>
		<td width="50%" bgColor="#A9A9A9" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">RecoveryModel</font></b></td>
	  </tr>
	<p style="margin-top: 1; margin-bottom: 0">&nbsp;</p>
	'

select 
@TableHTML =  @TableHTML +   
	'<tr><td><font face="Verdana" size="1">' + ISNULL(name, '') +'</font></td>' +    
	'<td><font face="Verdana" size="1">' + CONVERT(VARCHAR(2), DATEPART(dd, create_date)) + '-' + CONVERT(VARCHAR(3),DATENAME(mm,create_date)) + '-' + CONVERT(VARCHAR(4),DATEPART(yy,create_date)) +'</font></td>' +    
	'<td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(10), AA.[Total Size GB]), '') +'</font></td>' +    
	'<td><font face="Verdana" size="1">' + ISNULL(state_desc, '') +'</font></td>' +    
	'<td><font face="Verdana" size="1">' + ISNULL(recovery_model_desc, '') +'</font></td></tr>'
from 
	sys.databases MST
	inner join (select b.name [LOG_DBNAME], 
				CONVERT(VARCHAR(10),SUM(CONVERT(VARCHAR(10),(a.size * 8)) /1024)/1024) [Total Size GB]
				from sys.sysaltfiles A
				inner join sys.databases B on A.dbid = B.database_id
				group by b.name)AA on AA.[LOG_DBNAME] = MST.name
order by 
	MST.name

-- code for CPU status 
SELECT 
	@TableHTML =  @TableHTML + 
	'</table> <p><font face="Verdana" size="4">CPU STATUS (Threshold value = 30000 ticks)</font></p><table id="AutoNumber1" style="BORDER-COLLAPSE: collapse" borderColor="#111111" height="40" cellSpacing="0" cellPadding="0" width="40%" border="1">
	  <tr>
		<td width="35%" bgColor="#A9A9A9" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">CPU USAGE</font></b></td>
		<td width="70%" bgColor="#A9A9A9" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">STATUS</font></b></td>
	  </tr>
	<p style="margin-top: 1; margin-bottom: 0">&nbsp;</p>
	'

EXEC spa_print	@cpu
EXEC spa_print @cpu_stat
SELECT 
	@TableHTML =  @TableHTML +   
	'<tr><td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(100),@cpu ),'') +'</font></td>' +    
	'<td><font face="Verdana" size="1">' +   ISNULL(CONVERT(VARCHAR(100),@cpu_stat ),'')   +'</font></td></tr>' 
FROM #cpu

SELECT @TableHTML =  @TableHTML + '</table>'

-- code for Buffer cache hit ratio
SELECT 
	@TableHTML =  @TableHTML + 
	'</table> <p><font face="Verdana" size="4">Buffer Cache Hit Ratio (Threshold value = 90%)</font></p><table id="AutoNumber1" style="BORDER-COLLAPSE: collapse" borderColor="#111111" height="40" cellSpacing="0" cellPadding="0" width="40%" border="1">
	  <tr>
		<td width="35%" bgColor="#A9A9A9" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">HIT RATIO</font></b></td>
		<td width="70%" bgColor="#A9A9A9" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">STATUS</font></b></td>
	  </tr>
	<p style="margin-top: 1; margin-bottom: 0">&nbsp;</p>
	'


SELECT 
	@TableHTML =  @TableHTML +   
	'<tr><td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(100),@hit_ratio ),'') +'</font></td>' +    
	'<td><font face="Verdana" size="1">' +   ISNULL(CONVERT(VARCHAR(100),@hit_status ),'')   +'</font></td></tr>' 
FROM #hitratio

SELECT @TableHTML =  @TableHTML + '</table>'

---- code for Network packet Error
SELECT 
	@TableHTML =  @TableHTML + 
	'</table> <p><font face="Verdana" size="4">NETWORK PACKET STATUS</font></p><table id="AutoNumber1" style="BORDER-COLLAPSE: collapse" borderColor="#111111" height="40" cellSpacing="0" cellPadding="0" width="40%" border="1">
	  <tr>
		<td width="35%" bgColor="#A9A9A9" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">NETWORK PACKET ERROR</font></b></td>
		<td width="70%" bgColor="#A9A9A9" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">STATUS</font></b></td>
	  </tr>
	<p style="margin-top: 1; margin-bottom: 0">&nbsp;</p>
	'


SELECT 
	@TableHTML =  @TableHTML +   
	'<tr><td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(100),@net_err ),'') +'</font></td>' +    
	'<td><font face="Verdana" size="1">' +   ISNULL(CONVERT(VARCHAR(100),@net_status ),'')   +'</font></td></tr>' 
FROM #networkerr

SELECT @TableHTML =  @TableHTML + '</table>'
---- code for No of connections 
SELECT 
	@TableHTML =  @TableHTML + 
	'</table> <p><font face="Verdana" size="4">CONNECTION STATUS</font></p><table id="AutoNumber1" style="BORDER-COLLAPSE: collapse" borderColor="#111111" height="40" cellSpacing="0" cellPadding="0" width="40%" border="1">
	  <tr>
		<td width="35%" bgColor="#A9A9A9" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">No. of Connection</font></b></td>
		<td width="70%" bgColor="#A9A9A9" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">STATUS</font></b></td>
	  </tr>
	<p style="margin-top: 1; margin-bottom: 0">&nbsp;</p>
	'


SELECT 
	@TableHTML =  @TableHTML +   
	'<tr><td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(100),@cntconn ),'') +'</font></td>' +    
	'<td><font face="Verdana" size="1">' +   ISNULL(CONVERT(VARCHAR(100),@conn_status ),'')   +'</font></td></tr>' 
FROM #num_conn

SELECT @TableHTML =  @TableHTML + '</table>'

--- code for error logs 
SELECT 
	@TableHTML =  @TableHTML + 
	'</table> <p><font face="Verdana" size="4">ERROR LOGS</font></p><table id="AutoNumber1" style="BORDER-COLLAPSE: collapse" borderColor="#111111" height="40" cellSpacing="0" cellPadding="0" width="74%" border="1">
	  <tr>
		<td width="25%" bgColor="#A9A9A9" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">LOG DATE</font></b></td>
		<td width="10%" bgColor="#A9A9A9" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">PROCESS INFO</font></b></td>
		<td width="65%" bgColor="#A9A9A9" height="15"><b>
		<font face="Verdana" size="1" color="#FFFFFF">MESSAGE</font></b></td>
	  </tr>
	<p style="margin-top: 1; margin-bottom: 0">&nbsp;</p>
	'

SELECT 
	@TableHTML =  @TableHTML +   
	'<tr><td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(50), logdate),'') +'</font></td>' +    
	'<td><font face="Verdana" size="1">' +   ISNULL(CONVERT(VARCHAR(100),processinfo ),'')   +'</font></td>'  + 
	'<td><font face="Verdana" size="1">' +   ISNULL(CONVERT(VARCHAR(max),msg_text ),'')   +'</font></td></tr>'
FROM #LogLines
where  lower (Msg_Text) like '%error %' or lower (Msg_Text) like '% error%'
AND logdate > = @enddate

SELECT @TableHTML =  @TableHTML + '</table>'


-- Code for SQL Server Database Backup Stats
SELECT 
	@TableHTML = @TableHTML +   
	'</table><p><font face="Verdana" size="4">SQL SERVER Database Backup Stats</font></p><table style="BORDER-COLLAPSE: collapse" borderColor="#111111" cellPadding="0" width="933" bgColor="#ffffff" borderColorLight="#000000" border="1">    
	
	<tr>    
	<th align="left" width="91" bgColor="#A9A9A9">    
	<font face="Verdana" size="1" color="#FFFFFF">Date</font></th>    
	<th align="left" width="105" bgColor="#A9A9A9">    
	<font face="Verdana" size="1" color="#FFFFFF">Database</font></th>    
	<th align="left" width="165" bgColor="#A9A9A9">    
	 <font face="Verdana" size="1" color="#FFFFFF">File Name</font></th>    
	<th align="left" width="75" bgColor="#A9A9A9">    
	 <font face="Verdana" size="1" color="#FFFFFF">Type</font></th>    
	<th align="left" width="165" bgColor="#A9A9A9"> 
	<font face="Verdana" size="1" color="#FFFFFF">Start Time</font></th>    
	<th align="left" width="165" bgColor="#A9A9A9">    
	<font face="Verdana" size="1" color="#FFFFFF">End Time</font></th>    
	<th align="left" width="136" bgColor="#A9A9A9">    
	<font face="Verdana" size="1" color="#FFFFFF">Size(GB)</font></th>    
	</tr> 
<p style="margin-top: 1; margin-bottom: 0">&nbsp;</p>
	'


SELECT 
	@TableHTML =  @TableHTML +     
	'<tr>  
	<td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(2), DATEPART(dd,MST.backup_start_date)) + '-' + CONVERT(VARCHAR(3),DATENAME(mm, MST.backup_start_date)) + '-' + CONVERT(VARCHAR(4), DATEPART(yyyy, MST.backup_start_date)),'') +'</font></td>' +      
	'<td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(100), MST.database_name), '') +'</font></td>' +      
	'<td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(100), MST.name), '') +'</font></td>' +   
	CASE Type 
	WHEN 'D' THEN '<td><font face="Verdana" size="1">' + 'Full' +'</font></td>'    
	WHEN 'I' THEN '<td><font face="Verdana" size="1">' + 'Differential' +'</font></td>'
	WHEN 'L' THEN '<td><font face="Verdana" size="1">' + 'Log' +'</font></td>'
	WHEN 'F' THEN '<td><font face="Verdana" size="1">' + 'File or Filegroup' +'</font></td>'
	WHEN 'G' THEN '<td><font face="Verdana" size="1">' + 'File Differential' +'</font></td>'
	WHEN 'P' THEN '<td><font face="Verdana" size="1">' + 'Partial' +'</font></td>'
	WHEN 'Q' THEN '<td><font face="Verdana" size="1">' + 'Partial Differential' +'</font></td>'
	ELSE '<td><font face="Verdana" size="1">' + 'Unknown' +'</font></td>'
	END + 
	'<td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(50), MST.backup_start_date), '') +'</font></td>' +  
	'<td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(50), MST.backup_finish_date), '') +'</font></td>' +  
	'<td><font face="Verdana" size="1">' + ISNULL(CONVERT(VARCHAR(10), CAST((MST.backup_size/1024)/1024/1024 AS DECIMAL(10,2))), '') +'</font></td>' +  
	 '</tr>'     
FROM 
	backupset MST
WHERE 
	MST.backup_start_date BETWEEN @StartDate AND @EndDate
ORDER BY 
	MST.backup_start_date DESC

SELECT @TableHTML =  @TableHTML + '</table>'

-- Code for physical database backup file present on disk
INSERT #url
SELECT DISTINCT 
	SUBSTRING(BMF.physical_device_name, 1, len(BMF.physical_device_name) - CHARINDEX('\', REVERSE(BMF.physical_device_name), 0))
from 
	backupset MST
	inner join backupmediafamily BMF ON BMF.media_set_id = MST.media_set_id
where 
	MST.backup_start_date BETWEEN @startdate AND @enddate

select @Cnt = COUNT(*) FROM #url

WHILE @Cnt >0
BEGIN

	SELECT @URL = url FROM #url WHERE idd = @Cnt
	--SELECT @Str = 'EXEC master.dbo.xp_cmdshell ''dir "' + @URL +'" /B/O:D'''

	INSERT #dirpaths SELECT 'PATH: ' + @URL
	INSERT #dirpaths
	
	EXEC (@Str)
	
	INSERT #dirpaths values('')

	SET @Cnt = @Cnt - 1
	
end

DELETE FROM #dirpaths WHERE files IS NULL

select 
	@TableHTML = @TableHTML +   
	'<p><font face="Verdana" size="4">Physical Backup Files</font></p><table style="BORDER-COLLAPSE: collapse" borderColor="#111111" cellPadding="0" width="933" bgColor="#ffffff" borderColorLight="#000000" border="1">    
	<tr>    
	<th align="left" width="91" bgColor="#A9A9A9">    
	<font face="Verdana" size="1" color="#FFFFFF">Physical Files</font></th>
	</tr>
<p style="margin-top: 1; margin-bottom: 0">&nbsp;</p>
	'    

SELECT 
	@TableHTML =  @TableHTML + '<tr>'  + 
	CASE SUBSTRING(files, 1, 5) 
		WHEN 'PATH:' THEN '<td bgcolor = "#D7D7D7"><b><font face="Verdana" size="1">' + files  + '</font><b></td>' 
	ELSE 
		'<td><font face="Verdana" size="1">' + files  + '</font></td>' 
	END + 
	'</tr>'  
FROM 
	#dirpaths  
--<p><font face="Verdana" size="2"><b>Server Owner:</b> '+@owner+'</font></p>
SELECT 
	@TableHTML =  @TableHTML + '</table>' +   
	'<p style="margin-top: 0; margin-bottom: 0">&nbsp;</p>
	<hr color="#000000" size="1">
	  
	<p style="margin-top: 0; margin-bottom: 0"><font face="Verdana" size="2">Thanks   
	and Regards,</font></p>  
	<p style="margin-top: 0; margin-bottom: 0"><font face="Verdana" size="2">DB   
	Support Team </font></p>  
	<font face="Verdana" size="2">Pioneer Solutions   </font></p>  
	<p>&nbsp;</p>'  

EXEC msdb.dbo.sp_send_dbmail  
	@profile_name = @MailProfile,    
	@recipients=@Recepients,    
	@subject = @strSubject,    
	@body = @TableHTML,    
	@body_format = 'HTML' ;    

SET NOCOUNT OFF
END
