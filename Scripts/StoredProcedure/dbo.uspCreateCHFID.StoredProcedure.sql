/****** Object:  StoredProcedure [dbo].[uspCreateCHFID]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspCreateCHFID]
(
	@HowMany INT
)
AS
BEGIN
	CREATE TABLE #tbl(Number NVARCHAR(12))

	DECLARE @CHFID VARCHAR(12)
	DECLARE @lower INT = 1
	DECLARE @upper INT = 10000000
	DECLARE @Number DECIMAL(18,0)
	DECLARE @Count INT = 0
	
	IF @HowMany > @upper 
		SET @upper = @HowMany

	WHILE @Count < @HowMany
		BEGIN
		NEXT_NUMBER:
			SET @Number = ROUND((@upper - @lower) * RAND() + @lower,0)
			IF NOT EXISTS(SELECT Number From #tbl WHERE Number = @Number)
				INSERT INTO #tbl values(@Number)
			ELSE
				GOTO NEXT_NUMBER
			SET @Count = @Count + 1
		END

	UPDATE #tbl SET [Number] = RIGHT('000000000' + CAST([Number] AS VARCHAR(8)) + CAST([Number] % 7 AS CHAR(1)),9)

	SELECT DISTINCT * FROM #tbl
	DROP TABLE #tbl
END

GO
