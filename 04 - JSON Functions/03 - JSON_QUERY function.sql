/*
	============================================================================
		File:		03 - JSON_QUERY function.sql

		Summary:	This script demonstrates the variety of JSON functions
					included in Microsoft SQL Server since 2016

					THIS SCRIPT IS PART OF THE TRACK: "SQL Server - JSON"

		Date:		September 2023

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

:SETVAR	json_file_name	"D:\OneDrive\Dokumente\GitHub\Leverage JSON in SQL Server\02 - JSON Files\03 - json array.json"
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
:SETVAR	json_file_name	"D:\OneDrive\Dokumente\GitHub\Leverage JSON in SQL Server\02 - JSON Files\03 - json array.json"
SELECT	JSON_VALUE(jf.BulkColumn, N'$.Student.first_name')	AS	first_name,
		JSON_VALUE(jf.BulkColumn, N'$.Student.languages'),
		JSON_QUERY(jf.BulkColumn, N'$.Student.languages')	AS	js_query
FROM	OPENROWSET 
		(
			BULK
			'$(json_file_name)',
			SINGLE_CLOB
		) AS jf;
GO

:SETVAR	json_file_name	"D:\OneDrive\Dokumente\GitHub\Leverage JSON in SQL Server\02 - JSON Files\03 - json array.json"
SELECT	JSON_VALUE(jf.BulkColumn, N'$.Student.first_name')	AS	first_name,
		JSON_VALUE(jf.BulkColumn, N'$.Student.last_name')	AS	last_name,
		l.*
FROM	OPENROWSET 
		(
			BULK
			'$(json_file_name)',
			SINGLE_CLOB
		) AS jf
		CROSS APPLY
		(
			SELECT	JSON_QUERY(jf.BulkColumn, N'$.Student.languages') AS languages
		) AS l
GO

:SETVAR	json_file_name	"D:\OneDrive\Dokumente\GitHub\Leverage JSON in SQL Server\02 - JSON Files\03 - json array.json"
SELECT	JSON_VALUE(jf.BulkColumn, N'$.Student.first_name')	AS	first_name,
		JSON_VALUE(jf.BulkColumn, N'$.Student.last_name')	AS	last_name,
		l.*
FROM	OPENROWSET 
		(
			BULK
			'$(json_file_name)',
			SINGLE_CLOB
		) AS jf
		CROSS APPLY
		(
			SELECT	[value]	AS	dev_language
			FROM	OPENJSON
					(
						JSON_QUERY(jf.BulkColumn, N'$.Student.languages')
					)
		) AS l;
GO


/*
	We create a product description table which holds detailed information about
	the products (for comparision)
*/
DROP TABLE IF EXISTS dbo.parts_description;
GO

CREATE TABLE dbo.parts_description
(
	pd_partkey		BIGINT			NOT NULL,
	pd_description	NVARCHAR(MAX)	NOT NULL,

	CONSTRAINT pk_parts_description PRIMARY KEY CLUSTERED (pd_partkey)
	WITH (DATA_COMPRESSION = PAGE)
);
GO

/*
	Note:	When you work with BLOB data it is best practice to store them
			outside of the row when the majority of your data is larger than 8 Kbytes!
*/
EXEC sp_tableoption
	@TableNamePattern = N'dbo.parts_description',
	@OptionName = 'LARGE VALUE TYPES OUT OF ROW',
	@OptionValue = 'true';
GO

INSERT INTO dbo.parts_description WITH (TABLOCK)
(pd_partkey, pd_description)
SELECT	TOP (1000)
		p_partkey,
		jso.pd_description
FROM	dbo.parts AS p
		CROSS APPLY
		(
			SELECT	p_type,
					p_size,
					p_brand,
					p_name,
					p_retailprice
			FROM	(
						VALUES
						(
							[p_type],
							[p_size],
							[p_brand],
							[p_name],
							[p_retailprice]
						)
					) AS x (p_type, p_size, p_brand, p_name, p_retailprice)
			FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER 
		) AS jso (pd_description)
GO

/*
	The first query will generate a list of all information stored in
	the attribute [ProductInfo]
*/
SELECT	JSON_QUERY(pd_description)	AS product_description
FROM	dbo.parts_description
GO

/*
	Compare two articles and show the differences
*/
SELECT	part_01.[key],
		part_01.[value]	AS	[250505],
		part_02.[value]	AS	[250506]
FROM	OPENJSON
		(
			(
				SELECT	pd_description
				FROM	dbo.parts_description
				WHERE	pd_partkey = 250505
			)
		) AS part_01
		INNER JOIN
		(
			SELECT	[key], [value]
			FROM	OPENJSON
					(
						(
							SELECT	pd_description
							FROM	dbo.parts_description
							WHERE	pd_partkey = 250506
						)
					)
		) AS part_02
		ON (part_02.[key] = part_01.[key])
GO
