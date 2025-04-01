/*
	============================================================================
		File:		04 - JSON strict vs. lax.sql

		Summary:	This script demonstrates the different usage of strict
					definition vs lax definition

					THIS SCRIPT IS PART OF THE TRACK: "Leverage JSON in SQL Server"

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

/*
	It is important to use the names of the property keys as they are defined in the JSON file!
*/
:SETVAR	json_file_name	"D:\OneDrive\Dokumente\GitHub\Leverage JSON in SQL Server\02 - JSON Files\01 - json object.json"

SELECT	JSON_VAlUE(BulkColumn, N'$.c_custkey')		AS	c_custkey,
		JSON_VALUE(BulkColumn, N'$.c_mktsegment')	AS	c_mktsegment,
		JSON_VALUE(BulkColumn, N'$.c_nationkey')	AS	c_nationkey,
		JSON_VALUE(BulkColumn, N'$.c_name')			AS	c_name
FROM	OPENROWSET 
		(
			BULK
			'$(json_file_name)',
			SINGLE_CLOB
		) AS jf;
GO

/*
	It is important to use the names of the keys as they are defined in the JSON file!
	If we don't use the exact property names we get NULL as result!

	UPPER AND LOWER CASE LETTERS ARE ALSO TAKEN INTO ACCOUNT!
*/
:SETVAR	json_file_name	"D:\OneDrive\Dokumente\GitHub\Leverage JSON in SQL Server\02 - JSON Files\01 - json object.json"
SELECT	JSON_VAlUE(BulkColumn, N'$.c_custkey')		AS	c_custkey,
		JSON_VALUE(BulkColumn, N'$.c_Mktsegment')	AS	c_mktsegment,
		JSON_VALUE(BulkColumn, N'$.c_natchokey')	AS	c_nationkey,
		JSON_VALUE(BulkColumn, N'$.c_name')			AS	c_name
FROM	OPENROWSET 
		(
			BULK
			'$(json_file_name)',
			SINGLE_CLOB
		) AS jf;
GO

/*
	The above example is using LAX parsing rules for the JSON object
*/
:SETVAR	json_file_name	"D:\OneDrive\Dokumente\GitHub\Leverage JSON in SQL Server\02 - JSON Files\01 - json object.json"
SELECT	JSON_VAlUE(BulkColumn, N'lax $.c_custkey')		AS	c_custkey,
		JSON_VALUE(BulkColumn, N'lax $.c_Mktsegment')	AS	c_mktsegment,
		JSON_VALUE(BulkColumn, N'lax $.c_natchokey')	AS	c_nationkey,
		JSON_VALUE(BulkColumn, N'lax $.c_name')			AS	c_name
FROM	OPENROWSET 
		(
			BULK
			'$(json_file_name)',
			SINGLE_CLOB
		) AS jf;
GO


/*
	If the query should not be executed when the properties are not correct
	we can use strict mode!	
*/
:SETVAR	json_file_name	"D:\OneDrive\Dokumente\GitHub\Leverage JSON in SQL Server\02 - JSON Files\01 - json object.json"
SELECT	JSON_VAlUE(BulkColumn, N'strict $.c_custkey')		AS	c_custkey,
		JSON_VALUE(BulkColumn, N'strict $.c_Mktsegment')	AS	c_mktsegment,
		JSON_VALUE(BulkColumn, N'strict $.c_natchokey')	AS	c_nationkey,
		JSON_VALUE(BulkColumn, N'strict $.c_name')			AS	c_name
FROM	OPENROWSET 
		(
			BULK
			'$(json_file_name)',
			SINGLE_CLOB
		) AS jf;
GO