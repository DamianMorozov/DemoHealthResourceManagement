------------------------------------------------------------------------------------------------------------------------
-- INDEXES_SELECT
------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
PRINT N'[ ] SET TRANSACTION ISOLATION LEVEL READ COMMITTED';
DECLARE @DB_NAME_CUR VARCHAR(128) = NULL;
DECLARE @DB_NAME_DEV VARCHAR(128) = 'HRM_DEMO_DEV';
DECLARE @DB_NAME_PROD VARCHAR(128) = 'HRM_DEMO_PROD';
DECLARE @SCHEMA_REF_NAME VARCHAR(128) = 'REF';
DECLARE @SCHEMA_DIM_NAME VARCHAR(128) = 'DIM';
DECLARE @SCHEMA_REF_ID INT = (SELECT [SCHEMA_ID] FROM [SYS].[SCHEMAS] WHERE [NAME] = @SCHEMA_REF_NAME);
DECLARE @SCHEMA_DIM_ID INT = (SELECT [SCHEMA_ID] FROM [SYS].[SCHEMAS] WHERE [NAME] = @SCHEMA_DIM_NAME);
DECLARE @CMD NVARCHAR(MAX);
DECLARE @INDEX SYSNAME;
DECLARE @INDEXES TABLE([SCHEMA] SYSNAME NULL, [TABLE] SYSNAME NOT NULL, [COLUMN] SYSNAME NOT NULL, 
	[INDEX_ID] INT NOT NULL, [INDEX] SYSNAME NULL, [TYPE_DESC] NVARCHAR(256) NULL);
------------------------------------------------------------------------------------------------------------------------
-- CHECK DB
SET @DB_NAME_CUR = (SELECT DB_NAME());
IF NOT (@DB_NAME_CUR = @DB_NAME_DEV OR @DB_NAME_CUR = @DB_NAME_PROD) BEGIN
	PRINT N'[x] CURRENT DB [' + @DB_NAME_CUR + '] IS NOT CORRECT';
END ELSE BEGIN
	PRINT N'[✓] CURRENT DB [' + @DB_NAME_CUR + '] IS CORRECT';
	SELECT (CASE 
		WHEN [T].[schema_id] = @SCHEMA_REF_ID THEN @SCHEMA_REF_NAME
		WHEN [T].[schema_id] = @SCHEMA_DIM_ID THEN @SCHEMA_DIM_NAME
		ELSE NULL END) [SCHEMA]
		,[T].[name] [TABLE]
		,[IND].[index_id] [INDEX_ID]
		,[COL].[name] [COLUMN]
		,[IND].[name] [INDEX]
		,[IND].[type_desc] [TYPE_DESC]
	FROM [sys].[indexes] [IND]
	INNER JOIN [sys].[index_columns] [IC] ON [IND].[object_id] = [IC].[object_id] AND [IND].[index_id] = [IC].[index_id]
	INNER JOIN [sys].[columns] [COL] ON [IC].[object_id] = [COL].[object_id] AND [IC].[column_id] = [COL].[column_id]
	INNER JOIN [sys].[tables] [T] ON [IND].[object_id] = [T].[object_id]
	ORDER BY [SCHEMA], [TABLE], [INDEX_ID];
END;
------------------------------------------------------------------------------------------------------------------------
