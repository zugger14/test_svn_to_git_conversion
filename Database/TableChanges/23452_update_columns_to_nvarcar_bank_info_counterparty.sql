--select * from counterparty_bank_info

IF COL_LENGTH('counterparty_contacts', 'comment') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_contacts ALTER COLUMN comment nvarchar(4000)
END
GO

EXEC sp_fulltext_column      
@tabname =  'counterparty_bank_info' , 
@colname =  'bank_name' , 
@action =  'drop' 
GO

IF COL_LENGTH('counterparty_bank_info', 'bank_name') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_bank_info ALTER COLUMN bank_name nvarchar(4000)
END
GO

EXEC sp_fulltext_column      
@tabname =  'counterparty_bank_info' , 
@colname =  'bank_name' , 
@action =  'add' 
GO

EXEC sp_fulltext_column      
@tabname =  'counterparty_bank_info' , 
@colname =  'wire_ABA' , 
@action =  'drop' 
GO

IF COL_LENGTH('counterparty_bank_info', 'wire_ABA') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_bank_info ALTER COLUMN wire_ABA nvarchar(50)
END
GO

EXEC sp_fulltext_column      
@tabname =  'counterparty_bank_info' , 
@colname =  'wire_ABA' , 
@action =  'add' 
GO

EXEC sp_fulltext_column      
@tabname =  'counterparty_bank_info' , 
@colname =  'ACH_ABA' , 
@action =  'drop' 
GO

IF COL_LENGTH('counterparty_bank_info', 'ACH_ABA') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_bank_info ALTER COLUMN ACH_ABA nvarchar(50)
END
GO

EXEC sp_fulltext_column      
@tabname =  'counterparty_bank_info' , 
@colname =  'ACH_ABA' , 
@action =  'add' 
GO

EXEC sp_fulltext_column      
@tabname =  'counterparty_bank_info' , 
@colname =  'Address1' , 
@action =  'drop' 
Go

IF COL_LENGTH('counterparty_bank_info', 'Address1') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_bank_info ALTER COLUMN Address1 nvarchar(MAX)
END
GO

EXEC sp_fulltext_column      
@tabname =  'counterparty_bank_info' , 
@colname =  'Address1' , 
@action =  'add' 
Go

EXEC sp_fulltext_column      
@tabname =  'counterparty_bank_info' , 
@colname =  'Address2' , 
@action =  'drop' 
Go

IF COL_LENGTH('counterparty_bank_info', 'Address2') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_bank_info ALTER COLUMN Address2 nvarchar(MAX)
END
GO
EXEC sp_fulltext_column      
@tabname =  'counterparty_bank_info' , 
@colname =  'Address2' , 
@action =  'add' 
Go

EXEC sp_fulltext_column      
@tabname =  'counterparty_bank_info' , 
@colname =  'reference' , 
@action =  'drop' 
GO

IF COL_LENGTH('counterparty_bank_info', 'reference') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_bank_info ALTER COLUMN reference nvarchar(50)
END
GO

EXEC sp_fulltext_column      
@tabname =  'counterparty_bank_info' , 
@colname =  'reference' , 
@action =  'add' 
GO

EXEC sp_fulltext_column      
@tabname =  'counterparty_bank_info' , 
@colname =  'accountname' , 
@action =  'drop' 
GO

IF COL_LENGTH('counterparty_bank_info', 'accountname') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_bank_info ALTER COLUMN accountname nvarchar(50)
END
GO
EXEC sp_fulltext_column      
@tabname =  'counterparty_bank_info' , 
@colname =  'accountname' , 
@action =  'add' 
GO

IF COL_LENGTH('counterparty_contract_type', 'description') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_contract_type ALTER COLUMN description nvarchar(max)
END
GO

IF COL_LENGTH('counterparty_contract_address', 'comments') IS NOT NULL
BEGIN
    ALTER TABLE counterparty_contract_address ALTER COLUMN comments NVARCHAR(200)
END
GO

