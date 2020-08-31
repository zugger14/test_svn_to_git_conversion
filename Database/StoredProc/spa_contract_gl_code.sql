
/****** Object:  StoredProcedure [dbo].[spa_contract_gl_code]    Script Date: 12/19/2014 21:11:23 ******/
--vsshrestha@pioneersolutionsglobal.com
IF EXISTS (SELECT
    *
  FROM sys.objects
  WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_contract_gl_code]')
  AND TYPE IN (N'P', N'PC'))
  DROP PROCEDURE [dbo].[spa_contract_gl_code]
/****** Object:  StoredProcedure [dbo].[spa_contract_gl_code]    Script Date: 12/19/2014  21:11:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_contract_gl_code] @flag char(1),
@default_gl_id int = NULL,
@default_gl_id_estimates AS int = NULL,
@default_gl_code_cash_applied AS int = NULL,
@manual AS int = NULL
AS
  DECLARE @sql int

  IF @flag = 'g'
  BEGIN
  BEGIN TRY
    UPDATE cgd
    SET cgd.default_gl_id = @default_gl_id,
        cgd.default_gl_id_estimates = @default_gl_id_estimates,
        cgd.default_gl_code_cash_applied = @default_gl_code_cash_applied,
        cgd.manual = @manual
    FROM contract_group_detail cgd
    EXEC spa_ErrorHandler 0,
                          'GL Code Mapping update.',
                          'spa_contract_gl_code',
                          'Success',
                          'GL Code Mapping has been successfully updated.',
                          ''
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0
      ROLLBACK

    EXEC spa_ErrorHandler -1,
                          'GL Code Mapping update.',
                          'spa_contract_gl_code',
                          'DB Error',
                          'Fail to update GL Code Mapping.',
                          ''
  END CATCH
  END