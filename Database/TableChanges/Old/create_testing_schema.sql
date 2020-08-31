--this scripts create testing schema for regression testing related objects also manages permission such that tables can 
--be created in this schema by every FARRMS user

IF SCHEMA_ID( N'testing') IS NULL
BEGIN
	--Since CREATE SCHEMA stmt needs its own batch, embed it under EXEC block.
	--Reason for creating a new role or using db_farrms for schema owner instead of using dbo user is because using same owner can let the user access other schema objects
	--even when denied explicitly as described under MS KB article 914847. Though this is not a problem for us as the only other schema is dbo and acess to 
	--its objects is generally required.
	EXEC('CREATE SCHEMA [testing] AUTHORIZATION [db_farrms]');
END
ELSE
BEGIN
	ALTER AUTHORIZATION ON SCHEMA::[testing] TO db_farrms
END
GO

--Following two permissions are required to create a table in a schema
GRANT CREATE TABLE TO [db_farrms]
--GRANT ALTER ON SCHEMA::testing TO [db_farrms]
--This is already granted as db_farrms role owns schema testing


