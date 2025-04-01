/*
	============================================================================
		File:		01 - ISJSON.sql

		Summary:	This script demonstrates the variety of JSON functions
					included in Microsoft SQL Server since 2016

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

/*
	***************************************************************************
	ISJSON:	This is the simplest of the functions for JSON support in SQL Server.
			It takes one string argument as the input, validate it and returns ...
			1 if the provided JSON is a valid one
			0 if it doesn’t.
	***************************************************************************
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE ERP_Demo;
GO

:SETVAR	json_file_name	"D:\OneDrive\Dokumente\GitHub\Leverage JSON in SQL Server\02 - JSON Files\05 - ISJSON - valid.json"
SELECT	BulkColumn,
		ISJSON(BulkColumn)	AS	is_json,
		CASE WHEN ISJSON(BulkColumn) = 1
			 THEN 'valid json'
			 ELSE 'non valid json'
		END			AS	is_json_desc
FROM	OPENROWSET 
		(
			BULK
			'$(json_file_name)',
			SINGLE_CLOB
		) AS jf;
GO

:SETVAR	json_file_name	"D:\OneDrive\Dokumente\GitHub\Leverage JSON in SQL Server\02 - JSON Files\06 - ISJSON - invalid.json"
SELECT	Bulkcolumn,
		ISJSON(BulkColumn)	AS	is_json,
		CASE WHEN ISJSON(BulkColumn) = 1
			 THEN 'valid json'
			 ELSE 'non valid json'
		END			AS	is_json_desc
FROM	OPENROWSET 
		(
			BULK
			'$(json_file_name)',
			SINGLE_CLOB
		) AS jf;
GO