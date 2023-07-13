------------------------------------------------------------------------------------------------------------------------
-- TASK_2_RECEPTIONS_2015 | Сколько приёмов всех пациентов было в каждую дату 2015 года
------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
PRINT N'[ ] SET TRANSACTION ISOLATION LEVEL READ COMMITTED';
DECLARE @DB_NAME_CUR VARCHAR(128) = NULL;
DECLARE @DB_NAME_DEV VARCHAR(128) = 'HRM_DEMO_DEV';
DECLARE @DB_NAME_PROD VARCHAR(128) = 'HRM_DEMO_PROD';
DECLARE @SCHEMA_NAME VARCHAR(128) = 'DIM';
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
		IF EXISTS (SELECT 1 FROM [SYS].[TABLES] WHERE [SCHEMA_ID] = @SCHEMA_ID AND [name] = N'RECEPTIONS') BEGIN
			-- Статистика приёмов по дням за 2015 год
			SELECT 
				 CAST([R].[DT_CREATE] AS DATE) [Дата]
				,COUNT(1) [Приёмы]
			FROM (
				SELECT *
				FROM [DIM].[RECEPTIONS] [R]
				WHERE YEAR([DT_CREATE]) = 2015) [R]
			GROUP BY CAST([R].[DT_CREATE] AS DATE)
			ORDER BY [Дата];
			-- Статистика приёмов по дням за 2015 год
			SELECT 
				 CAST([R].[DT_CREATE] AS DATE) [Дата]
				,COUNT(1) [Приёмы]
			FROM [DIM].[RECEPTIONS] [R]
			WHERE YEAR([DT_CREATE]) = 2015
			GROUP BY CAST([R].[DT_CREATE] AS DATE)
			ORDER BY [Дата];
			-- Статистика приёмов по дням за 2015 год
			DECLARE @TABLE TABLE ([DT] DATE, [COUNT] SMALLINT);
			DECLARE @DT DATE;
			DECLARE CUR_RECEPTIONS CURSOR FOR SELECT CAST([DT_CREATE] AS DATE) FROM [DIM].[RECEPTIONS] WHERE YEAR([DT_CREATE]) = 2015;
			OPEN CUR_RECEPTIONS;
				FETCH NEXT FROM CUR_RECEPTIONS INTO @DT;
				WHILE (@@FETCH_STATUS = 0) BEGIN
					IF NOT EXISTS(SELECT 1 FROM @TABLE WHERE [DT] = @DT)
						INSERT INTO @TABLE([DT], [COUNT]) VALUES(@DT, 1);
					ELSE
						UPDATE @TABLE SET [COUNT] = [COUNT] + 1 WHERE [DT] = @DT;
					FETCH NEXT FROM CUR_RECEPTIONS INTO @DT;
				END;
			CLOSE CUR_RECEPTIONS;
			DEALLOCATE CUR_RECEPTIONS;
			SELECT
				[DT] [Дата], [COUNT] [Приёмы]
			FROM @TABLE
			ORDER BY [Дата];
------------------------------------------------------------------------------------------------------------------------
-- К задаче не относится, но пусть будет здесь
------------------------------------------------------------------------------------------------------------------------
			-- Статистика приёмов по месяцам за 2015 год
			SELECT
				 2015 [Год]
				,MONTH(CAST([R].[DT_CREATE] AS DATE)) [Месяц]
				,COUNT(1) [Приёмы]
			FROM [DIM].[RECEPTIONS] [R]
			WHERE YEAR([DT_CREATE]) = 2015
			GROUP BY MONTH(CAST([R].[DT_CREATE] AS DATE))
			ORDER BY [Год], [Месяц];
			-- Статистика приёмов по годам
			SELECT
				 YEAR(CAST([R].[DT_CREATE] AS DATE)) [Год]
				,COUNT(1) [Приёмы]
			FROM [DIM].[RECEPTIONS] [R]
			GROUP BY YEAR(CAST([R].[DT_CREATE] AS DATE))
			ORDER BY [Год];
			-- Статистика приёмов по годам
			SELECT
				 YEAR(CAST([R].[DT_CREATE] AS DATE)) [Год]
				,MONTH(CAST([R].[DT_CREATE] AS DATE)) [Месяц]
				,COUNT(1) [Приёмы]
			FROM [DIM].[RECEPTIONS] [R]
			GROUP BY YEAR(CAST([R].[DT_CREATE] AS DATE)), MONTH(CAST([R].[DT_CREATE] AS DATE))
			ORDER BY [Год], [Месяц];
		END;
	END;
END;
------------------------------------------------------------------------------------------------------------------------
