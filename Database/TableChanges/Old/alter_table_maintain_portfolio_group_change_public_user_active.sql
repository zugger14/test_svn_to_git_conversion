IF EXISTS(SELECT * FROM sys.columns WHERE [name] = N'public' AND OBJECT_ID = OBJECT_ID(N'maintain_portfolio_group'))
BEGIN
    ALTER TABLE maintain_portfolio_group DROP COLUMN [public]
END

IF EXISTS(SELECT * FROM sys.columns WHERE [name] = N'user' AND OBJECT_ID = OBJECT_ID(N'maintain_portfolio_group'))
BEGIN
    ALTER TABLE maintain_portfolio_group DROP COLUMN [user]
END

IF EXISTS(SELECT * FROM sys.columns WHERE [name] = N'active' AND OBJECT_ID = OBJECT_ID(N'maintain_portfolio_group'))
BEGIN
    ALTER TABLE maintain_portfolio_group DROP COLUMN [active]
END

IF NOT EXISTS(SELECT * FROM sys.columns WHERE [name] = N'is_public' AND OBJECT_ID = OBJECT_ID(N'maintain_portfolio_group'))
BEGIN
    ALTER TABLE maintain_portfolio_group ADD [is_public] CHAR(1)
END

IF NOT EXISTS(SELECT * FROM sys.columns WHERE [name] = N'users' AND OBJECT_ID = OBJECT_ID(N'maintain_portfolio_group'))
BEGIN
    ALTER TABLE maintain_portfolio_group ADD [users] VARCHAR(100)
END 


IF NOT EXISTS(SELECT * FROM sys.columns WHERE [name] = N'is_active' AND OBJECT_ID = OBJECT_ID(N'maintain_portfolio_group'))
BEGIN
    ALTER TABLE maintain_portfolio_group ADD [is_active] CHAR(1) 
END 

 


 