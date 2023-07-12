------------------------------------------------------------------------------------------------------------------------
-- DB_SECURITY_PROD
------------------------------------------------------------------------------------------------------------------------
SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
PRINT N'[ ] SET TRANSACTION ISOLATION LEVEL READ COMMITTED';
------------------------------------------------------------------------------------------------------------------------
DECLARE @IS_ACTION BIT = 1;
------------------------------------------------------------------------------------------------------------------------
-- JOB
IF (DB_ID('HRM_DEMO_PROD') IS NULL) BEGIN
	PRINT N'[x] DB IS NOT EXISTS';
END ELSE IF (@IS_ACTION = 1) BEGIN
	-- DROP LOGINS
	USE [MASTER];
	IF EXISTS(SELECT 1 FROM [SYS].[SERVER_PRINCIPALS] WHERE [NAME] = 'HM_USER') BEGIN
		DROP LOGIN [HM_USER];
		PRINT N'[✓] DROP LOGIN [HM_USER] IS DONE';
	END;
	IF EXISTS(SELECT * FROM [SYS].[SERVER_PRINCIPALS] WHERE [NAME] = 'HM_ADMIN') BEGIN
		DROP LOGIN [HM_ADMIN];
		PRINT N'[✓] DROP LOGIN [HM_ADMIN] IS DONE';
	END;
	-- DROP SQL_USER
	USE [HRM_DEMO_PROD];
	IF EXISTS (SELECT [NAME] FROM [SYS].[DATABASE_PRINCIPALS] WHERE [TYPE] = N'S' AND [name] = N'HM_USER') BEGIN
		DROP USER [HM_USER];
		PRINT N'[✓] DROP USER [HM_USER] IS DONE';
	END;
	IF EXISTS (SELECT [NAME] FROM [SYS].[DATABASE_PRINCIPALS] WHERE [TYPE] = N'S' AND [name] = N'HM_ADMIN') BEGIN
		DROP USER [HM_ADMIN];
		PRINT N'[✓] DROP USER [HM_USER] IS DONE';
	END;
	-- CREATE LOGINS
	USE [master];
	CREATE LOGIN [HM_USER] WITH PASSWORD = N'HM_USER', DEFAULT_DATABASE = [master], DEFAULT_LANGUAGE = [us_english], 
		CHECK_EXPIRATION = OFF, CHECK_POLICY = OFF;
	PRINT N'[✓] CREATE LOGIN [HM_USER] IS DONE';
	CREATE LOGIN [HM_ADMIN] WITH PASSWORD = N'HM_ADMIN', DEFAULT_DATABASE = [master], DEFAULT_LANGUAGE = [us_english], 
		CHECK_EXPIRATION = OFF, CHECK_POLICY = OFF;
	PRINT N'[✓] CREATE LOGIN [HM_ADMIN] IS DONE';
	-- CREATE USER [HM_USER]
	USE [HRM_DEMO_PROD];
	CREATE USER [HM_USER] FOR LOGIN [HM_USER];
	PRINT N'[✓] CREATE USER [HM_USER] FOR LOGIN [HM_USER] IS DONE';
	ALTER USER [HM_USER] WITH DEFAULT_SCHEMA = [dbo];
	ALTER ROLE [db_datareader] ADD MEMBER [HM_USER];
	PRINT N'[✓] ALTER ROLE [db_datareader] ADD MEMBER [HM_USER] IS DONE';
	ALTER ROLE [db_datawriter] ADD MEMBER [HM_USER];
	PRINT N'[✓] ALTER ROLE [db_datawriter] ADD MEMBER [HM_USER] IS DONE';
	-- CREATE USER [HM_ADMIN]
	USE [HRM_DEMO_PROD];
	CREATE USER [HM_ADMIN] FOR LOGIN [HM_ADMIN];
	PRINT N'[✓] CREATE USER [HM_ADMIN] FOR LOGIN [HM_ADMIN] IS DONE';
	ALTER USER [HM_ADMIN] WITH DEFAULT_SCHEMA = [dbo];
	ALTER ROLE [db_datareader] ADD MEMBER [HM_ADMIN];
	PRINT N'[✓] ALTER ROLE [db_datareader] ADD MEMBER [HM_ADMIN] IS DONE';
	ALTER ROLE [db_datawriter] ADD MEMBER [HM_ADMIN];
	PRINT N'[✓] ALTER ROLE [db_datawriter] ADD MEMBER [HM_ADMIN] IS DONE';
	ALTER ROLE [db_owner] ADD MEMBER [HM_ADMIN];
	PRINT N'[✓] ALTER ROLE [db_owner] ADD MEMBER [HM_ADMIN] IS DONE';
	ALTER ROLE [db_securityadmin] ADD MEMBER [HM_ADMIN];
	PRINT N'[✓] ALTER ROLE [db_securityadmin] ADD MEMBER [HM_ADMIN] IS DONE';
END;
------------------------------------------------------------------------------------------------------------------------
