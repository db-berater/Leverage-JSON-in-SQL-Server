/*
	============================================================================
		File:		02 - JSON_VALUE function.sql

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
	JSON_VALUE:	JSON_VALUE is a function in T-SQL (Transact-SQL) that is used to extract a
				scalar value from a JSON string stored in a SQL Server database.
				It takes two parameters:
						the first parameter is the JSON expression 
						the second parameter is a JSON path that specifies the
						location of the value within the JSON data.
	***************************************************************************
*/
:SETVAR	json_file_name	"D:\OneDrive\Dokumente\GitHub\Leverage JSON in SQL Server\02 - JSON Files\07 - JSON_VALUE.json"
SELECT	ISJSON(BulkColumn)
FROM	OPENROWSET 
		(
			BULK
			'$(json_file_name)',
			SINGLE_CLOB
		) AS jf;

/*
	Let's check the structure of the JSON file first
*/
:SETVAR	json_file_name	"D:\OneDrive\Dokumente\GitHub\Leverage JSON in SQL Server\02 - JSON Files\07 - JSON_VALUE.json"
WITH ors
AS
(
	SELECT	BulkColumn
	FROM	OPENROWSET 
			(
				BULK
				'$(json_file_name)',
				SINGLE_CLOB
			) AS o
)
SELECT	x.*
FROM	ors
		CROSS APPLY
		(
			SELECT	*
			FROM	OPENJSON (ors.BulkColumn)
		) AS x;
GO

SELECT	JSON_VALUE(BulkColumn, N'$.customer[0].first_name'),
		JSON_VALUE(BulkColumn, N'$.customer[0].last_name'),
		JSON_VALUE(BulkColumn, N'$.customer[0].address[0].street'),
		JSON_VALUE(BulkColumn, N'$.customer[0].address[0].street_no')
FROM	OPENROWSET 
		(
			BULK
			'$(json_file_name)',
			SINGLE_CLOB
		) AS jf;
GO