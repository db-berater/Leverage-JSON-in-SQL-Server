/*
	============================================================================
		File:		03 - json values.sql

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

:SETVAR	json_file_name	"D:\OneDrive\Dokumente\GitHub\Leverage JSON in SQL Server\02 - JSON Files\04 - json values.json"
DECLARE	@json_file	NVARCHAR(MAX);
SELECT	@json_file = BulkColumn
FROM	OPENROWSET 
		(
			BULK
			'$(json_file_name)',
			SINGLE_CLOB
		) AS jf;

;WITH type_list
AS
(
	SELECT	o.type_column_value,
            o.json_data_type
	FROM	(
				VALUES
					(0, 'null'),
					(1, 'string'),
					(2, 'number'),
					(3, 'true/false'),
					(4, 'array'),
					(5, 'object')
			) AS o (type_column_value, json_data_type)
)
SELECT	oj.[Key],
        oj.Value,
        oj.Type,
		tl.json_data_type
FROM	OPENJSON(@json_file) AS oj
		INNER JOIN type_list AS tl
		ON (oj.Type = tl.type_column_value);
GO