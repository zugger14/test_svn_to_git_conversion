IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__matching___audit__38862065]') AND type = 'D')
BEGIN
	ALTER TABLE matching_header_audit DROP CONSTRAINT DF__matching___audit__38862065
END
GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__matching___creat__397A449E]') AND type = 'D')
BEGIN
	ALTER TABLE matching_header_audit DROP CONSTRAINT DF__matching___creat__397A449E
END
