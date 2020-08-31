--Author: Tara Nath Subedi
--Purpose: Add identity(1,1) in "rule_id" column of "deal_confirmation_rule" table.
--Issue Against: 2406
--Dated: May 16,2010

IF OBJECT_ID(N'deal_confirmation_rule', N'U') IS NOT NULL
    AND NOT EXISTS ( SELECT 'X'
                     FROM   sys.columns
                     WHERE  object_id = OBJECT_ID(N'deal_confirmation_rule',
                                                  N'U')
                            AND name = 'rule_id'
                            AND is_identity = 1 ) 
    BEGIN
 
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
        ALTER TABLE dbo.deal_confirmation_rule DROP CONSTRAINT FK_deal_confirmation_rule_source_deal_type
        COMMIT

        BEGIN TRANSACTION
        ALTER TABLE dbo.deal_confirmation_rule DROP CONSTRAINT FK_deal_confirmation_rule_contract_group
        COMMIT

        BEGIN TRANSACTION
        ALTER TABLE dbo.deal_confirmation_rule DROP CONSTRAINT FK_deal_confirmation_rule_source_commodity
        COMMIT

        BEGIN TRANSACTION
        ALTER TABLE dbo.deal_confirmation_rule DROP CONSTRAINT FK_deal_confirmation_rule_source_counterparty
        COMMIT

        BEGIN TRANSACTION
        CREATE TABLE dbo.Tmp_deal_confirmation_rule
            (
              rule_id INT NOT NULL
                          IDENTITY(1, 1),
              counterparty_id INT NOT NULL,
              buy_sell_flag CHAR(1) NULL,
              commodity_id INT NULL,
              contract_id INT NULL,
              deal_type_id INT NULL,
              confirm_template_id INT NULL,
              revision_confirm_template_id INT NULL
            )
        ON  [PRIMARY]
 
        SET IDENTITY_INSERT dbo.Tmp_deal_confirmation_rule ON
 
        IF EXISTS ( SELECT  *
                    FROM    dbo.deal_confirmation_rule ) 
            EXEC
                ( 'INSERT INTO dbo.Tmp_deal_confirmation_rule (rule_id, counterparty_id, buy_sell_flag, commodity_id, contract_id, deal_type_id, confirm_template_id, revision_confirm_template_id)
		SELECT rule_id, counterparty_id, buy_sell_flag, commodity_id, contract_id, deal_type_id, confirm_template_id, revision_confirm_template_id FROM dbo.deal_confirmation_rule WITH (HOLDLOCK TABLOCKX)'
                )
 
        SET IDENTITY_INSERT dbo.Tmp_deal_confirmation_rule OFF
 
        DROP TABLE dbo.deal_confirmation_rule
 
        EXECUTE sp_rename N'dbo.Tmp_deal_confirmation_rule',
            N'deal_confirmation_rule', 'OBJECT' 
 
        ALTER TABLE dbo.deal_confirmation_rule
        ADD CONSTRAINT PK_deal_confirmation_rule PRIMARY KEY CLUSTERED ( rule_id )
                WITH ( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF,
                       ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON )
                ON [PRIMARY]

 
        ALTER TABLE dbo.deal_confirmation_rule
                WITH NOCHECK
        ADD CONSTRAINT FK_deal_confirmation_rule_source_counterparty FOREIGN KEY ( counterparty_id ) REFERENCES dbo.source_counterparty ( source_counterparty_id ) ON UPDATE NO ACTION
                ON DELETE NO ACTION 
	
 
        ALTER TABLE dbo.deal_confirmation_rule
                WITH NOCHECK
        ADD CONSTRAINT FK_deal_confirmation_rule_source_commodity FOREIGN KEY ( commodity_id ) REFERENCES dbo.source_commodity ( source_commodity_id ) ON UPDATE NO ACTION
                ON DELETE NO ACTION 
	
 
        ALTER TABLE dbo.deal_confirmation_rule
                WITH NOCHECK
        ADD CONSTRAINT FK_deal_confirmation_rule_contract_group FOREIGN KEY ( contract_id ) REFERENCES dbo.contract_group ( contract_id ) ON UPDATE NO ACTION
                ON DELETE NO ACTION 
	
 
        ALTER TABLE dbo.deal_confirmation_rule
                WITH NOCHECK
        ADD CONSTRAINT FK_deal_confirmation_rule_source_deal_type FOREIGN KEY ( deal_type_id ) REFERENCES dbo.source_deal_type ( source_deal_type_id ) ON UPDATE NO ACTION
                ON DELETE NO ACTION 
	
 
        COMMIT

        PRINT 'Table ''deal_confirmation_rule'' changed to have Identity on ''rule_id'' column. '

    END
