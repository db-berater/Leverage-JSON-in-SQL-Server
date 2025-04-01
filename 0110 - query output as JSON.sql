/*
	============================================================================
		File:		0100 - query output as JSON.sql

		Summary:	This script demonstrates the possibilities to generate
					an output of a query in a JSON format

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
USE demo_db;
GO

DROP TABLE IF EXISTS dbo.customer_properties;
DROP TABLE IF EXISTS dbo.properties;
DROP TABLE IF EXISTS dbo.customers;
GO

SELECT * INTO dbo.customers FROM CustomerOrders.dbo.Customers;
SELECT * INTO dbo.customer_properties FROM CustomerOrders.dbo.CustomerProperties;
SELECT * INTO dbo.properties FROM CustomerOrders.dbo.Properties;
GO

/*
	Cleaning up
*/
WITH data
AS
(
	SELECT	ROW_NUMBER() OVER (PARTITION BY Customer_Id, Property_Id ORDER BY (SELECT NULL)) AS row_num,
			*
	FROM	customer_properties
)
DELETE	[data]
WHERE	data.row_num > 1;
GO

CREATE UNIQUE CLUSTERED INDEX cuix_customers_id ON dbo.customers(id);
CREATE UNIQUE CLUSTERED INDEX cuix_properties_id ON dbo.properties(id);
CREATE UNIQUE CLUSTERED INDEX cuix_customer_properties_customer_id_property_id
ON dbo.customer_properties(Customer_Id, Property_Id);
GO

ALTER TABLE dbo.customer_properties
ADD CONSTRAINT fk_customers FOREIGN KEY (Customer_Id)
REFERENCES dbo.customers (id);
GO

ALTER TABLE dbo.customer_properties
ADD CONSTRAINT fk_properties FOREIGN KEY (Property_Id)
REFERENCES dbo.properties(id);
GO

CREATE OR ALTER VIEW dbo.customer_phone_number
AS
	SELECT	c.Id					AS	customer_id,
            c.Name					AS	customer_name,
			cp_01.Property_Value	AS	phone_number,
			cp_02.Property_Value	AS	fax_number
	FROM	dbo.customers AS c
			LEFT JOIN dbo.customer_properties AS cp_01
			ON
			(
				c.Id = cp_01.Customer_Id
				AND cp_01.Property_Id = 1
			)
			LEFT JOIN dbo.properties AS p_01
			ON (cp_01.Property_Id = p_01.Id)
			LEFT JOIN dbo.customer_properties AS cp_02
			ON
			(
				c.Id = cp_02.Customer_Id
				AND cp_02.Property_Id = 2
			)
			LEFT JOIN dbo.properties AS p_02
			ON (cp_02.Property_Id = p_02.Id);
GO

/************************* preparation phase done *******************************/
SELECT	customer_id,
        customer_name,
        phone_number,
		fax_number
FROM	dbo.customer_phone_number
WHERE	customer_id <= 10;
GO

/* output as JSON - different solutions */
SELECT	customer_id,
        customer_name,
        phone_number,
		fax_number
FROM	dbo.customer_phone_number
WHERE	customer_id <= 10
FOR JSON AUTO;
GO

/* output as JSON - NULL values will NOT be shown */
SELECT	customer_id,
        customer_name,
        phone_number,
		fax_number
FROM	dbo.customer_phone_number
WHERE	customer_id <= 15
FOR JSON AUTO, INCLUDE_NULL_VALUES;
GO

/* we can exclude arrays if we want to have the result in different objects! */
SELECT	customer_id,
        customer_name,
        phone_number,
		fax_number
FROM	dbo.customer_phone_number
WHERE	customer_id <= 15
FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
GO

/* If we want an array for the data we can use ROOT as option! */
SELECT	customer_id,
        customer_name,
        phone_number,
		fax_number
FROM	dbo.customer_phone_number
WHERE	customer_id <= 5
FOR JSON AUTO, ROOT('customers');
GO

/*
	If we want an array for all details we can add them by addressing them
	inside the query

	Result should be
	[
		customers:
		[
			{
				"id":10,
				"name": "Trubanova..."
				"contact":
				[
					{
						"property_name":"Phone",
						"property_value":"0124"
					},
					{
						"property_name":"Fax",
						"property_value": "23423"
					}
				]
			}
		]
	]
*/

SELECT	c.Id,
        c.Name,
        c.InsertUser,
        c.InsertDate,
		p.Property,
		cp.Property_Value
FROM	dbo.customers AS c
		INNER JOIN
		(
			dbo.customer_properties AS cp
			INNER JOIN dbo.properties AS p
			ON (cp.Property_Id = p.Id)
		)
		ON (c.id = cp.Customer_Id)
WHERE	c.id <= 2
FOR JSON AUTO;
GO

SELECT	c.Id,
        c.Name,
        c.InsertUser,
        c.InsertDate,
		contact.contact_info
FROM	dbo.customers AS c
		CROSS APPLY 
		(
			SELECT JSON_QUERY
			(
				(
					SELECT	p.Property,
							cp.Property_value
					FROM	dbo.customer_properties AS cp
							INNER JOIN dbo.properties AS p
							ON (cp.Property_Id = p.Id)
					WHERE	cp.Customer_Id = c.Id
					FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
				)
			)
		) AS contact (contact_info)
WHERE	c.id <= 2
FOR JSON AUTO, ROOT ('customer');
GO

/*
	Let's put all contact information into a JSON field!
*/
DROP TABLE IF EXISTS dbo.customer_contacts;
GO

SELECT	c.Id,
        c.Name,
        c.InsertUser,
        c.InsertDate,
        ct.contact_details
INTO	dbo.customer_contacts
FROM	dbo.customers AS c
		CROSS APPLY
		(
			SELECT	JSON_QUERY
			(
				(
					SELECT	property_name,
							property_value
					FROM	(
								SELECT	Property			AS	property_name,
										property_value		AS	property_value
								FROM	dbo.properties AS p
										LEFT JOIN dbo.customer_properties AS cp
										ON
										(
											p.id = cp.Property_Id
											AND cp.customer_id = c.Id
										)
							) AS x
					FOR JSON AUTO, INCLUDE_NULL_VALUES --, WITHOUT_ARRAY_WRAPPER
				)
			)
		) AS ct (contact_details);
GO

CREATE UNIQUE CLUSTERED INDEX ciux_customer_contacts_id
ON dbo.customer_contacts (id);
GO

/* The result is a JSON array with all contact */
SELECT	cc.Id,
        cc.Name,
        cc.InsertUser,
        cc.InsertDate,
		cc.contact_details,
		x.contact_art,
		x.contact_value
FROM	dbo.customer_contacts cc
		CROSS APPLY
		(
			SELECT	contact_art,
                    contact_value
			FROM	OPENJSON(contact_details, '$')
			WITH	(
						contact_art		NVARCHAR(64)	'$.property_name',
						contact_value	NVARCHAR(64)	'$.property_value'
					)
		) AS x (contact_art, contact_value)
WHERE	id = 1;
GO

/* Update phone-number from customer 1 */
UPDATE	dbo.customer_contacts
SET		contact_details = JSON_MODIFY(contact_details, '$[2].property_value', 'uwe.ricken@db-berater.de')
WHERE	id = 1;
GO

SELECT	cc.Id,
        cc.Name,
        cc.InsertUser,
        cc.InsertDate,
		x.contact_art,
		x.contact_value
FROM	dbo.customer_contacts cc
		CROSS APPLY
		(
			SELECT	contact_art,
                    contact_value
			FROM	OPENJSON(contact_details, '$')
			WITH	(
						contact_art		NVARCHAR(64)	'$.property_name',
						contact_value	NVARCHAR(64)	'$.property_value'
					)
		) AS x (contact_art, contact_value)
WHERE	id = 1;
GO

SELECT	c.Id,
		c.Name,
		c.InsertUser,
		c.InsertDate,
		(
			SELECT	JSON_QUERY
			(
				(
					SELECT	property_name,
							property_value
					FROM	(
								SELECT	Property			AS	property_name,
										property_value		AS	property_value
								FROM	dbo.properties AS p
										LEFT JOIN dbo.customer_properties AS cp
										ON
										(
											p.id = cp.Property_Id
											AND cp.customer_id = c.Id
										)
							) AS x
					FOR JSON AUTO, INCLUDE_NULL_VALUES
				)
			)
		)	AS	contact_details
FROM dbo.customers AS c
---WHERE c.Id <= 1
FOR JSON AUTO;
