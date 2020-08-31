 /*********************************************************/
/* Modified By :Mukesh Singh
   Modified Date : 29-Dec-2008
   Purpose:	Altered the Column Tenot_limt with Tenor_Limit
**********************************************************/

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
EXECUTE sp_rename N'dbo.counterparty_credit_info.Tenor_limt', N'Tmp_tenor_limit', 'COLUMN' 
GO
EXECUTE sp_rename N'dbo.counterparty_credit_info.Tmp_tenor_limit', N'tenor_limit', 'COLUMN' 
GO
COMMIT
