------------------------------------------------------------------------------------------------------------------------
-- DB_TABLES_SIZES
------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
PRINT N'[ ] SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED';
DECLARE @DB_NAME_CUR VARCHAR(128) = NULL;
DECLARE @DB_NAME_DEV VARCHAR(128) = 'HRM_DEMO_DEV';
DECLARE @DB_NAME_PROD VARCHAR(128) = 'HRM_DEMO_PROD';
DECLARE @SCHEMA_ID INT = 0;
DECLARE @CMD NVARCHAR(MAX);
------------------------------------------------------------------------------------------------------------------------
-- CHECK DB
SET @DB_NAME_CUR = (SELECT DB_NAME());
IF NOT (@DB_NAME_CUR = @DB_NAME_DEV OR @DB_NAME_CUR = @DB_NAME_PROD) BEGIN
	PRINT N'[x] CURRENT DB [' + @DB_NAME_CUR + '] IS NOT CORRECT';
END ELSE BEGIN
	PRINT N'[✓] CURRENT DB [' + @DB_NAME_CUR + '] IS CORRECT';
	SELECT
		 ('[' + [S].[NAME] + '].[' + [T].[NAME] + ']') [SCHEMA_TABLE]
		,[S].[NAME] [SCHEMA]
		,[T].[NAME] [TABLE]
		,[P].[ROWS] [ROWS_COUNT]
		,(CASE WHEN SUM([A].[USED_PAGES]) * 8 > 0 
			THEN SUM([A].[USED_PAGES]) * 8 / 1024 ELSE 0 END) [USED_SPACE_MB]
		,(CASE WHEN (SUM([A].[TOTAL_PAGES]) - SUM([A].[USED_PAGES])) * 8 > 0
			THEN (SUM([A].[TOTAL_PAGES]) - SUM([A].[USED_PAGES])) * 8 / 1024 ELSE 0 END) [UNUSED_SPACE_MB]
		,(CASE WHEN SUM([A].[TOTAL_PAGES]) * 8 > 0
			THEN SUM([A].[TOTAL_PAGES]) * 8 / 1024 ELSE 0 END) [TOTAL_SPACE_MB]
		,[F].[NAME] AS [FILENAME]
	FROM [SYS].[TABLES] [T]
	INNER JOIN [SYS].[INDEXES] [I] ON [T].[OBJECT_ID] = [I].[OBJECT_ID]
	INNER JOIN [SYS].[PARTITIONS] [P] ON [I].[OBJECT_ID] = [P].[OBJECT_ID] AND [I].[INDEX_ID] = [P].[INDEX_ID]
	INNER JOIN [SYS].[ALLOCATION_UNITS] [A] ON [P].[PARTITION_ID] = [A].[CONTAINER_ID]
	LEFT OUTER JOIN [SYS].[SCHEMAS] [S] ON [T].[SCHEMA_ID] = [S].[SCHEMA_ID]
	INNER JOIN [SYS].[DATABASE_FILES] [F] ON [A].[DATA_SPACE_ID] = [F].[DATA_SPACE_ID]
	WHERE [T].[IS_MS_SHIPPED] = 0 AND [I].[OBJECT_ID] > 255
	GROUP BY [T].[NAME], [S].[NAME], [P].[ROWS], [F].[NAME]
	ORDER BY [S].[NAME], [T].[NAME];
END;
------------------------------------------------------------------------------------------------------------------------
