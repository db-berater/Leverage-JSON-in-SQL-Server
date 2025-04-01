/*
	============================================================================
		File:		01 - json object.sql

		Summary:	This script demonstrates the native elements of a JSON object

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

:SETVAR	json_file_name	"D:\OneDrive\Dokumente\GitHub\Leverage JSON in SQL Server\02 - JSON Files\01 - json object.json"
DECLARE	@json_file	NVARCHAR(MAX);
SELECT	@json_file = BulkColumn
FROM	OPENROWSET 
		(
			BULK
			'$(json_file_name)',
			SINGLE_CLOB
		) AS jf;

SELECT	JSON_VAlUE(@json_file, N'$.c_custkey')		AS	c_custkey,
		JSON_VALUE(@json_file, N'$.c_mktsegment')	AS	c_mktsegment,
		JSON_VALUE(@json_file, N'$.c_nationkey')	AS	c_nationkey,
		JSON_VALUE(@json_file, N'$.c_name')			AS	c_name,
		JSON_VALUE(@json_file, N'$.c_address')		AS	c_address,
		JSON_VALUE(@json_file, N'$.c_phone')		AS	c_phone,
		JSON_VALUE(@json_file, N'$.c_acctbal')		AS	c_acctbal,
		JSON_VALUE(@json_file, N'$.c_comment')		AS	c_comment;
GO