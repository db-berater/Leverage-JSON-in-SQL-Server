/*
	============================================================================
		File:		01 - restore demo database.sql

		Summary:	Restores the demo database ERP_Demo from a local storage.

					THIS SCRIPT IS PART OF THE TRACK: "SQL Server - JSON"

		Date:		February 2025

		SQL Server Version: 2016 / 2017 / 2019 / 2022
	------------------------------------------------------------------------------
		Written by Uwe Ricken, db Berater GmbH

		This script is intended only as a supplement to demos and lectures
		given by Uwe Ricken.  
  
		THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
		ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
		TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
		PARTICULAR PURPOSE.
	============================================================================
*/
USE master;
GO

EXEC dbo.sp_restore_ERP_demo @query_store = 1;
GO

ALTER DATABASE ERP_Demo
SET COMPATIBILITY_LEVEL = 150;
GO