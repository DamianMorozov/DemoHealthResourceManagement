------------------------------------------------------------------------------------------------------------------------
-- DB_KILL_SESSIONS
------------------------------------------------------------------------------------------------------------------------
USE [MASTER];
SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
PRINT N'[ ] SET TRANSACTION ISOLATION LEVEL READ COMMITTED';
DECLARE @DB_NAME_CUR VARCHAR(128) = NULL;
DECLARE @DB_NAME_DEV VARCHAR(128) = 'HRM_DEMO_DEV';
DECLARE @DB_NAME_PROD VARCHAR(128) = 'HRM_DEMO_PROD';
DECLARE @FILE_BACKUP_CUR VARCHAR(256) = NULL;
DECLARE @FILE_BACKUP_DEV VARCHAR(256) = 'HRM_DEMO_DEV.BAK';
DECLARE @FILE_BACKUP_PROD VARCHAR(256) = 'HRM_DEMO_PROD.BAK';
DECLARE @FILE_EXIST INT;
DECLARE @CMD NVARCHAR(MAX);
------------------------------------------------------------------------------------------------------------------------
DECLARE @IS_ACTION_DEV BIT = 1;
DECLARE @IS_ACTION_PROD BIT = 0;
------------------------------------------------------------------------------------------------------------------------
-- DEVELOP
IF (@IS_ACTION_DEV = 1) BEGIN
	IF (DB_ID(@DB_NAME_DEV) IS NOT NULL) BEGIN
		SET @DB_NAME_CUR = @DB_NAME_DEV;
		SET @FILE_BACKUP_CUR = @FILE_BACKUP_DEV;
	END;
END;
------------------------------------------------------------------------------------------------------------------------
-- PRODUCT
IF (@IS_ACTION_PROD = 1) BEGIN
	IF (DB_ID(@DB_NAME_PROD) IS NOT NULL) BEGIN
		SET @DB_NAME_CUR = @DB_NAME_PROD;
		SET @FILE_BACKUP_CUR = @FILE_BACKUP_PROD;
	END;
END;
------------------------------------------------------------------------------------------------------------------------
-- JOB
IF (@DB_NAME_CUR IS NULL) BEGIN
	PRINT N'[x] DB IS NOT SET';
END ELSE BEGIN
	PRINT N'[✓] DB IS SET [' + @DB_NAME_CUR + N']';
	-- KILL SESSIONS
	SET @CMD = '';
	SELECT @CMD = @CMD + 'KILL ' + CONVERT(VARCHAR(5), SPID) + '; '  FROM MASTER..SYSPROCESSES  WHERE DBID = DB_ID(@DB_NAME_CUR);
	PRINT @CMD;
	EXEC(@CMD);
	PRINT N'[✓] SESSIONS KILLED COMPLETE';
	-- MULTI_USER
	SET @CMD = 'ALTER DATABASE [' + @DB_NAME_CUR + '] SET MULTI_USER WITH ROLLBACK IMMEDIATE';
	PRINT @CMD;
	EXEC(@CMD);
	PRINT N'[✓] ALTER DB MULTI_USER COMPLETE';
END;
------------------------------------------------------------------------------------------------------------------------
