/*************************************************/
/* AUTHOR      : VISHWAS KHANAL					 */ 
/* DATED       : 15.JAN.2008					 */
/* PROJECT     : TRMTracker						 */
/* DESCRIPTION : CHANGE REQUEST AS ON 14 JAN 2004*/
/*************************************************/

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'counterparty_credit_info' AND COLUMN_NAME = 'Debt_Rating2')
BEGIN
	ALTER TABLE counterparty_credit_info ADD  Debt_Rating2 INT
END

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'counterparty_credit_info' AND COLUMN_NAME = 'Debt_Rating3')
BEGIN
	ALTER TABLE counterparty_credit_info ADD  Debt_Rating3 INT
END

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'counterparty_credit_info' AND COLUMN_NAME = 'Debt_Rating4')
BEGIN
	ALTER TABLE counterparty_credit_info ADD  Debt_Rating4 INT
END

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'counterparty_credit_info' AND COLUMN_NAME = 'Debt_Rating5')
BEGIN
	ALTER TABLE counterparty_credit_info ADD  Debt_Rating5 INT
END
