------------------------------------------------------------------------------------------------------------------------
-- DB_KILL_SESSIONS
------------------------------------------------------------------------------------------------------------------------
USE [MASTER];
SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
PRINT N'[ ] SET TRANSACTION ISOLATION LEVEL READ COMMITTED';
DECLARE @DB_NAME_DEV VARCHAR(128) = 'HRM_DEMO_DEV';
DECLARE @DB_NAME_PROD VARCHAR(128) = 'HRM_DEMO_PROD';
DECLARE @CMD NVARCHAR(MAX);
------------------------------------------------------------------------------------------------------------------------
DECLARE @IS_ACTION_DEV BIT = 1;
DECLARE @IS_ACTION_PROD BIT = 0;
------------------------------------------------------------------------------------------------------------------------
-- JOB
IF (@IS_ACTION_DEV = 1 OR @IS_ACTION_PROD = 1) BEGIN
	-- KILL SESSIONS
	SET @CMD = '';
	IF (@IS_ACTION_DEV = 1)
		SELECT @CMD = @CMD + 'KILL ' + CONVERT(VARCHAR(5), SPID) + '; '  FROM MASTER..SYSPROCESSES  WHERE DBID = DB_ID(@DB_NAME_DEV);
	ELSE IF (@IS_ACTION_PROD = 1)
		SELECT @CMD = @CMD + 'KILL ' + CONVERT(VARCHAR(5), SPID) + '; '  FROM MASTER..SYSPROCESSES  WHERE DBID = DB_ID(@DB_NAME_PROD);
	PRINT @CMD;
	EXEC(@CMD);
	PRINT N'[✓] SESSIONS KILLED COMPLETE';
	-- MULTI_USER
	IF (@IS_ACTION_DEV = 1)
		SET @CMD = 'ALTER DATABASE [' + @DB_NAME_DEV + '] SET MULTI_USER WITH ROLLBACK IMMEDIATE';
	ELSE IF (@IS_ACTION_PROD = 1)
		SET @CMD = 'ALTER DATABASE [' + @DB_NAME_PROD + '] SET MULTI_USER WITH ROLLBACK IMMEDIATE';
	PRINT @CMD;
	EXEC(@CMD);
	PRINT N'[✓] ALTER DB MULTI_USER COMPLETE';
END;
------------------------------------------------------------------------------------------------------------------------
