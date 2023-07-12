------------------------------------------------------------------------------------------------------------------------
-- PATIENTS_SELECT
------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
PRINT N'[ ] SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED';
DECLARE @DB_NAME_CUR VARCHAR(128) = NULL;
DECLARE @DB_NAME_DEV VARCHAR(128) = 'HRM_DEMO_DEV';
DECLARE @DB_NAME_PROD VARCHAR(128) = 'HRM_DEMO_PROD';
DECLARE @SCHEMA_NAME VARCHAR(128) = 'REF';
DECLARE @SCHEMA_ID INT = (SELECT [SCHEMA_ID] FROM [SYS].[SCHEMAS] WHERE [NAME] = @SCHEMA_NAME);
DECLARE @CMD NVARCHAR(MAX);
------------------------------------------------------------------------------------------------------------------------
DECLARE @IS_ACTION BIT = 1;
------------------------------------------------------------------------------------------------------------------------
IF (@IS_ACTION = 0) BEGIN
	PRINT N'[x] ACTION IS DISABLED';
END ELSE BEGIN
	-- CHECK DB
	SET @DB_NAME_CUR = (SELECT DB_NAME());
	IF NOT (@DB_NAME_CUR = @DB_NAME_DEV OR @DB_NAME_CUR = @DB_NAME_PROD) BEGIN
		PRINT N'[x] CURRENT DB [' + @DB_NAME_CUR + '] IS NOT CORRECT';
	END ELSE BEGIN
		PRINT N'[✓] CURRENT DB [' + @DB_NAME_CUR + '] IS CORRECT';
		-- SELECT
		IF EXISTS (SELECT 1 FROM [SYS].[TABLES] WHERE [SCHEMA_ID] = @SCHEMA_ID AND [name] = N'PATIENTS') BEGIN
			SELECT 
				 [C].[ID] [CLIENT_ID]
				,[C].[DT_CREATE] [CLIENT_DT_CREATE]
				,[C].[DT_CHANGE] [CLIENT_DT_CHANGE]
				,[P].[FAMILY]
				,[P].[NAME]
				,[P].[SURNAME]
				,[P].[GENDER]
				,[P].[DT_BIRTH]
				,[P].[CELLPHONE]
				,[P].[EMAIL]
			FROM [REF].[PATIENTS] [C]
			INNER JOIN [REF].[PERSONS] [P] ON [C].[PERSON_ID] = [P].[ID]
			ORDER BY [P].[FAMILY], [P].[NAME], [P].[SURNAME];
		END;
	END;
END;
------------------------------------------------------------------------------------------------------------------------
