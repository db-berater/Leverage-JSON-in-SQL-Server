/*
	============================================================================
		File:		0050 - JSON_MODIFY.sql

		Summary:	This script demonstrates the usage of JSON_MODIFY in T-SQL

		***************************************************************************
		JSON_MODIFY:	is a function in T-SQL (Transact-SQL) that allows you to modify
						or update values within a JSON string or column.
						It enables you to change specific properties or elements within
						a JSON document by specifying a JSON path and a new value to
						replace the existing one.
		***************************************************************************

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
/*
	To make a string variable a JSON object just use JSON_OBJECT
*/
DECLARE	@output_variable	NVARCHAR(MAX);
SET		@output_variable = JSON_OBJECT();
PRINT	@output_variable;
GO

/*
	To make a string variable a JSON object with a new JSON object
	you must add the new object name as first parameter!
*/
DECLARE	@output_variable	NVARCHAR(MAX);
SET		@output_variable = JSON_OBJECT('status':JSON_OBJECT());
PRINT	@output_variable;
GO

/*
	To make a string variable a valid JSON object with values
	just add the structure to the JSON_OBJECT function
*/
DECLARE	@output_variable	NVARCHAR(MAX);
SET		@output_variable = JSON_OBJECT
(
	'first_name':'Uwe',
	'last_name':'Ricken',
	'birthday': '1964-02-18'
);
PRINT	@output_variable;
GO

/* special handling is required for NULL values */
DECLARE	@output_variable	NVARCHAR(MAX);
SET		@output_variable = JSON_OBJECT
(
	'first_name':'Uwe',
	'last_name':'Ricken',
	'birthday': NULL
);
PRINT	@output_variable;
GO

DECLARE	@output_variable	NVARCHAR(MAX);
SET		@output_variable = JSON_OBJECT
(
	'first_name':'Uwe',
	'last_name':'Ricken',
	'birthday': NULL	ABSENT ON NULL
);
PRINT	@output_variable;
GO

DECLARE	@output_variable	NVARCHAR(MAX);
SET		@output_variable = JSON_OBJECT
(
	'first_name':'Uwe',
	'last_name':'Ricken',
	'birthday': NULL	NULL ON NULL	/* default behavior*/
);
PRINT	@output_variable;
GO

/*
	Final construct for a new JSON object "employee"
*/
DECLARE	@output_variable NVARCHAR(MAX);
SET		@output_variable = JSON_OBJECT
							(
								'employee':JSON_OBJECT
								(
									'first_name':'Uwe',
									'last_name':'Ricken',
									'birthday': NULL	NULL ON NULL	/* default behavior*/
								)
							);
PRINT	@output_variable;
GO

/*
	To add multiple objects (e.g. from a query) to an existing JSON object
	we can transfer the result into an existing JSON structure
*/
SELECT	c_custkey		AS	c_custkey,
		JSON_OBJECT
		(
			'name':	c.c_name,
			'mktsegment': c.c_mktsegment,
			'timestamp': FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm', N'en-us')
		)
FROM	dbo.customers AS c
WHERE	c.c_custkey <= 3;
GO

/*
	To add multiple objects (e.g. from a query) to an existing JSON object
	we can transfer the result into an existing JSON structure
*/
SELECT	c.c_custkey		AS	c_custkey,
		JSON_OBJECT
		(
			'name':	c.c_name,
			'mktsegment': c.c_mktsegment,
			'timestamp': FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm', N'en-us'),
			'orders': COUNT_BIG(o.o_orderkey)
		)
FROM	dbo.customers AS c
		INNER JOIN dbo.orders AS o
		ON (c.c_custkey = o.o_custkey)
WHERE	c.c_custkey <= 5
GROUP BY
		c.c_custkey,
		c.c_name,
		c.c_mktsegment;
GO

/*
	To modify an empty JSON variable we must define
	whether it will be an objet or an array!	
*/
DECLARE	@output_variable NVARCHAR(MAX);
SELECT	@output_variable = BulkColumn
FROM	OPENROWSET 
		(
			BULK
			'S:\JSON\Record 01 - Multiple Records.json',
			SINGLE_CLOB
		) AS jf;

SELECT	*
FROM	OPENJSON (@output_variable)
WITH	(
			first_name		NVARCHAR(128),
			last_name		NVARCHAR(128)
		);
GO

/* Let's add Gladstone Gander to the list of employees */
DECLARE	@output_variable	NVARCHAR(MAX);
SELECT	@output_variable = BulkColumn
FROM	OPENROWSET 
		(
			BULK
			'S:\JSON\Record 01 - Multiple Records.json',
			SINGLE_CLOB
		) AS jf;

SET	@output_variable = JSON_MODIFY
						(
							@output_variable,
							N'append $',
							JSON_QUERY(N'{"first_name": "Gladstone", "last_name":"Gander"}')
						);

SELECT	*
FROM	OPENJSON (@output_variable)
WITH	(
			first_name		NVARCHAR(128),
			last_name		NVARCHAR(128)
		);

/* Now we add an address for Gladstone Gander */
SET	@output_variable = JSON_MODIFY
						(
							@output_variable,
							N'append $[2].addresses',
							JSON_QUERY
							(
								N'
								{
									"street":	"Gänsemarkt",
									"street_no":	4,
									"zip_code":	"20111",
									"city":		"Hamburg",
									"state":	"Hamburg",
									"country":	"Germany"
								}'
							)
						);

PRINT @output_variable;
GO

