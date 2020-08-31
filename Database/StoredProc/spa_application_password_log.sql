IF OBJECT_ID(N'spa_application_password_log', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_application_password_log]
 GO 
/* Modification History
-------------------------
Modified by : Vishwas Khanal
Dated  : 08.June.2009
Desc   : Used the PHP Encryption for password saving
Search Key : PHPEnc
*/


CREATE PROCEDURE [dbo].[spa_application_password_log]
@flag char(1),
@user_login_id varchar(50),
@as_of_date varchar(20)=NULL,
@user_pwd varchar(50)
 AS
if @flag='i'
begin
	declare @now datetime
	set @now=getdate()

	insert application_users_password_log(
		user_login_id,
		as_of_date,
		user_pwd)
	values(
		@user_login_id,
		@now,		
		@user_pwd) --PHPEnc
		--dbo.FNAEncrypt(@user_pwd))
end




