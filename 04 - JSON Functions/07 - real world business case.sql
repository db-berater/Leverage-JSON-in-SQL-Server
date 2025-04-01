/*
	============================================================================
		File:		07 - real world scenario.sql

		Summary:	This script recieves fro the website openweathermap.org
					weather data by a get-request.
					The output is a JSON format!

					THIS SCRIPT IS PART OF THE TRACK: "SQL Server - JSON"

		Date:		February 2025

		SQL Server Version: 2016 / 2017 / 2019 / 2022
	============================================================================
*/

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
EXEC sp_configure 'Ole Automation Procedures', 1;
RECONFIGURE;
GO

DECLARE	@WinHttpObject		AS INT;
DECLARE	@ResponseJsonText	AS VARCHAR(8000);

EXEC	sp_OACreate 'WinHttp.WinHttpRequest.5.1', @WinHttpObject OUT;
EXEC	sp_OAMethod
			@WinHttpObject,
			'open',
			NULL,
			'get',
			'https://samples.openweathermap.org/data/2.5/weather?q=London,uk&appid=439d4b804bc8187953eb36d2a8c26a02',
			'false';
EXEC	sp_OAMethod @WinHttpObject, 'send';
EXEC	sp_OAMethod @WinHttpObject, 'responseText', @ResponseJsonText OUTPUT;
EXEC	sp_OADestroy @WinHttpObject;

SELECT	@ResponseJsonText;

IF ISJSON(@ResponseJsonText) = 1
BEGIN
	SELECT	City,
			temperature,
			pressure,
			humidity,
			temp_min,
			temp_max
	FROM	OPENJSON(@ResponseJsonText) 
	WITH	(City VARCHAR(100) '$.name')
			CROSS APPLY OPENJSON(@ResponseJsonText, '$.main')
			WITH
			(
				temperature	NUMERIC(10, 2)	'$.temp',
				pressure	INT				'$.pressure',
				humidity	INT				'$.humidity',
				temp_min	NUMERIC(10, 2)	'$.temp_min',
				temp_max	NUMERIC(10, 2)	'$.temp_max'
			);
END
GO

EXEC sp_configure 'Ole Automation Procedures', 0;
EXEC sp_configure 'show advanced options', 0;
RECONFIGURE;
GO
