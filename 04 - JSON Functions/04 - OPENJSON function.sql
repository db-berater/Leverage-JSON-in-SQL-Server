/*
	============================================================================
		File:		0040 - OPENJSON - parse JSON.sql

		Summary:	This script demonstrates the different JSON formats
					which can be used by Microsoft SQL Server

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

/* Different data types */
DECLARE @json NVARCHAR(MAX) = N'{
   "String_value": "John",
   "DoublePrecisionFloatingPoint_value": 45,
   "DoublePrecisionFloatingPoint_value": 2.3456,
   "BooleanTrue_value": true,
   "BooleanFalse_value": false,
   "Null_value": null,
   "Array_value": ["a","r","r","a","y"],
   "Object_value": {"obj":"ect"}
}';

SELECT * FROM OpenJson(@json);
GO

/* To access a nested object you must specify the path! */
DECLARE @json NVARCHAR(4000) = N'{  
"path":	{  
			"to":	{
						"sub-object":["en-GB", "en-UK","de-AT","es-AR","sr-Cyrl"]  
					}  
        }  
 }';

SELECT [key], value
FROM OPENJSON(@json,'$.path.to."sub-object"')
GO

/* Pratical use of OPENJSON */
DECLARE	@json	NVARCHAR(MAX);

SELECT	@json = BulkColumn
FROM	OPENROWSET 
		(
			BULK
			'S:\JSON\Johnny and Jane.json',
			SINGLE_CLOB
		) AS jf;

-- Parse the JSON using OPENJSON
SELECT	[Key],
        Value,
        Type
FROM OPENJSON(@json);

-- Extract specific values from the JSON
SELECT
    JSON_VALUE(@json, '$.person.name') AS 'Name',
    JSON_VALUE(@json, '$.person.age') AS 'Age',
    JSON_VALUE(@json, '$.person.address.street') AS 'Street',
    JSON_VALUE(@json, '$.person.address.city') AS 'City',
    JSON_QUERY(@json, '$.languages') AS 'Languages';


SELECT	BulkColumn
FROM	OPENROWSET 
		(
			BULK
			'S:\JSON\Record 01 - Uwe Ricken - MultipleAddresses.json',
			SINGLE_CLOB
		) AS jf;
GO


/* Basics of JSON objects - output of all information including the addresss array! */
SELECT	oj.*
FROM	OPENROWSET 
		(
			BULK
			'S:\JSON\Record 01 - Uwe Ricken - MultipleAddresses.json',
			SINGLE_CLOB
		) AS JF
		CROSS APPLY OPENJSON(BulkColumn) AS oj;
GO

/* but if we want to get the data from the array we must name the arry! */
SELECT	oj.*
FROM	OPENROWSET 
		(
			BULK
			'S:\JSON\Record 01 - Uwe Ricken - MultipleAddresses.json',
			SINGLE_CLOB
		) AS JF
		CROSS APPLY OPENJSON(jf.BulkColumn, N'$.address') AS oj;
GO

/*
	To get the information from one object inside the array
	you must address it by its position in the array!
*/
SELECT	oj.*
FROM	OPENROWSET 
		(
			BULK
			'S:\JSON\Record 01 - Uwe Ricken - MultipleAddresses.json',
			SINGLE_CLOB
		) AS JF
		CROSS APPLY OPENJSON(jf.BulkColumn, N'$.address[0]') AS oj
GO

/*
	To get the information as a table you can name the attributes!
*/
SELECT	oj.*
FROM	OPENROWSET 
		(
			BULK
			'S:\JSON\Record 01 - Uwe Ricken - MultipleAddresses.json',
			SINGLE_CLOB
		) AS jf
		CROSS APPLY OPENJSON(jf.BulkColumn, N'$.address[0]')
		WITH	(
					street		NVARCHAR(64),
					street_no	INT,
					zip_code	NVARCHAR(10),
					city		NVARCHAR(128),
					state		NVARCHAR(128),
					country		NVARCHAR(128)
				) AS oj
GO

/*
	Now we can put all together in one SELECT statement
*/
SELECT	first_name,
        last_name,
        street,
        street_no,
        zip_code,
        city,
        state,
        country
FROM	OPENROWSET 
		(
			BULK
			'S:\JSON\Record 01 - Uwe Ricken - MultipleAddresses.json',
			SINGLE_CLOB
		) AS jf
		CROSS APPLY OPENJSON(jf.BulkColumn)
		WITH	(
					first_name		NVARCHAR(128)	N'$.first_name',
					last_name		NVARCHAR(128)	N'$.last_name',
					address_info	NVARCHAR(MAX)	N'$.address' AS JSON
				)
		CROSS APPLY OPENJSON(address_info)
		WITH	(
					street		NVARCHAR(64),
					street_no	INT,
					zip_code	NVARCHAR(10),
					city		NVARCHAR(128),
					state		NVARCHAR(128),
					country		NVARCHAR(128)
				);
GO