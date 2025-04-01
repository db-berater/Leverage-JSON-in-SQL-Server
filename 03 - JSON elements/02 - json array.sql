/*
	============================================================================
		File:		02 - json array.sql

		Summary:	This script demonstrates the native elements of a JSON array

					THIS SCRIPT IS PART OF THE TRACK: "SQL Server - JSON"
					NOTE:	The script mus run in SQLCMD mode!

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
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

USE ERP_Demo;
GO

:SETVAR	json_file_name	"D:\OneDrive\Dokumente\GitHub\Leverage JSON in SQL Server\02 - JSON Files\02 - json array.json"
DECLARE	@json_file	NVARCHAR(MAX);
SELECT	@json_file = BulkColumn
FROM	OPENROWSET 
		(
			BULK
			'$(json_file_name)',
			SINGLE_CLOB
		) AS jf;

/*
	With JSON_VALUE we cannot access a list of values but only a single value!
*/
SELECT	JSON_VALUE(@json_file, N'$.c_custkey[0]');

/*
	If the JSON file has multiple JSON objects you must use OPENJSON!
*/
SELECT	*
FROM	OPENJSON (@json_file)
WITH
(
	c_custkey		BIGINT,
	c_mktsegment	CHAR(10),
	c_nationkey		INT,
	c_name			VARCHAR(25),
	c_address		VARCHAR(40),
	c_phone			CHAR(15),
	c_acctbal		MONEY,
	c_comment		VARCHAR(118)
);
GO