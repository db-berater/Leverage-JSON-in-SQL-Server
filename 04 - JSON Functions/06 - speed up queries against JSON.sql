/*
	============================================================================
		File:		06 - speed up queries against JSON.sql

		Summary:	This script demonstrates to make queries against JSON objects
					faster.

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
USE ERP_Demo;
GO

/*
	Now we create a demo table with 100.000 customers.
	For all customers we store the total amount of orders in a JSON format
	in a dedicated column
*/
IF SCHEMA_ID(N'demo') IS NULL
	EXEC sp_executesql N'CREATE SCHEMA demo AUTHORIZATION dbo;';
GO

DROP TABLE IF EXISTS demo.customers;
GO

SELECT	c.c_custkey,
        c.c_mktsegment,
        c.c_nationkey,
        c.c_name,
        c.c_address,
        c.c_phone,
        c.c_acctbal,
        c.c_comment,	
		x.[total_amount]
INTO	demo.customers
FROM	ERP_demo.dbo.customers AS c
		CROSS APPLY
		(
			SELECT	SUM(co.o_totalprice)	AS	total_amount
			FROM	ERP_demo.dbo.orders AS co
			WHERE	co.o_custkey = c.c_custkey
			FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER,INCLUDE_NULL_VALUES
		) x (total_amount)
WHERE	c.c_custkey <= 100000;
GO

SELECT	c_custkey,
        c_mktsegment,
        c_nationkey,
        c_name,
        c_address,
        c_phone,
        c_acctbal,
        c_comment,
        total_amount
FROM	demo.customers;
GO

/*
	We want to have all customers with a higher order sum
	than the average order sum for all customers!
*/
SELECT	c.c_custkey,
        c.c_mktsegment,
        c.c_name,
		x.total_amount_money
FROM	dbo.customers AS c
		CROSS APPLY
		(
			SELECT	*
			FROM	OPENJSON(c.total_amount)
			WITH	(total_amount MONEY)
		) AS x(total_amount_money);

/* Let's find all customers with higher or equal amount than average */
SET STATISTICS IO, TIME ON;
GO

SELECT	c.c_custkey,
        c.c_mktsegment,
        c.c_name,
        CAST(JSON_VALUE(c.total_amount, '$.total_amount') AS NUMERIC(10, 2))	AS	total_amount
FROM	dbo.customers AS c
WHERE	CAST(JSON_VALUE(c.total_amount, '$.total_amount') AS NUMERIC(10, 2)) >=
		(
			SELECT	AVG(CAST(JSON_VALUE(total_amount, '$.total_amount') AS NUMERIC(10, 2)))
			FROM	dbo.customers
		);
GO

ALTER TABLE dbo.customers
ADD calc_total_amount AS CAST(JSON_VALUE(total_amount, '$.total_amount') AS NUMERIC(10, 2));
GO

SELECT	c.c_custkey,
        c.c_mktsegment,
        c.c_name,
        c.calc_total_amount
FROM	dbo.customers AS c
WHERE	c.calc_total_amount >=
		(
			SELECT	AVG(calc_total_amount)
			FROM	dbo.customers
		);
GO

CREATE NONCLUSTERED INDEX nix_customers_calc_total_amount
ON dbo.customers (calc_total_amount)
INCLUDE
(
	c_custkey,
	c_mktsegment,
	c_name
)
WITH (DATA_COMPRESSION = PAGE);
GO

SELECT	c_custkey,
        c_mktsegment,
        c_name,
        calc_total_amount
FROM	dbo.customers
WHERE	calc_total_amount >=
	(
		SELECT	AVG(calc_total_amount)
		FROM	dbo.customers
	);
GO
