/****** Object:  StoredProcedure [dw].[uspPremumAllocated]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dw].[uspPremumAllocated]
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @Counter INT = 1,
			@Year INT,
			@Date DATE,
			@EndDate DATE,
			@DaysInMonth INT,
			@MaxYear INT


	DECLARE @tblResult TABLE(
							Allocated DECIMAL(18,6),
							Region NVARCHAR(50), 
							DistrictName NVARCHAR(50), 
							ProductCode NVARCHAR(8), 
							ProductName NVARCHAR(100),
							MonthTime INT, 
							QuarterTime INT, 
							YearTime INT
							);

	SELECT @Year = YEAR(MIN(PayDate)) FROM tblPremium WHERE ValidityTo IS NULL;
	SELECT @MaxYear = YEAR(MAX(ExpiryDate)) FROM tblPolicy WHERE ValidityTo IS NULL;	



	WHILE @Year <= @MaxYear
	BEGIN	
		WHILE @Counter <= 12
		BEGIN

			SELECT @Date = CAST(CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Counter AS VARCHAR(2)) + '-' + '01' AS DATE)
			SELECT @DaysInMonth = DAY(EOMONTH(@Date)) --DATEDIFF(DAY,@Date,DATEADD(MONTH,1,@Date))
			SELECT @EndDate = EOMONTH(@Date)--CAST(CONVERT(VARCHAR(4),@Year) + '-' + CONVERT(VARCHAR(2),@Counter) + '-' + CONVERT(VARCHAR(2),@DaysInMonth) AS DATE)
	


			;WITH Allocation AS
			(
				SELECT R.RegionName Region, D.DistrictName,Prod.ProductCode, Prod.ProductName,
				@Counter MonthTime,DATEPART(QUARTER,@Date)QuarterTime,@Year YearTime
				,CASE 
				WHEN MONTH(DATEADD(D,-1,PL.ExpiryDate)) = @Counter AND YEAR(DATEADD(D,-1,PL.ExpiryDate)) = @Year AND (DAY(PL.ExpiryDate)) > 1
					THEN CASE WHEN DATEDIFF(D,CASE WHEN PR.PayDate < @Date THEN @Date ELSE PR.PayDate END,PL.ExpiryDate) = 0 THEN 1 ELSE DATEDIFF(D,CASE WHEN PR.PayDate < @Date THEN @Date ELSE PR.PayDate END,PL.ExpiryDate) END  * ((SUM(PR.Amount))/(CASE WHEN (DATEDIFF(DAY,CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END,PL.ExpiryDate)) <= 0 THEN 1 ELSE DATEDIFF(DAY,CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END,PL.ExpiryDate) END))
				WHEN MONTH(CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END) = @Counter AND YEAR(CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END) = @Year
					THEN ((@DaysInMonth + 1 - DAY(CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END)) * ((SUM(PR.Amount))/CASE WHEN DATEDIFF(DAY,CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END,PL.ExpiryDate) <= 0 THEN 1 ELSE DATEDIFF(DAY,CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END,PL.ExpiryDate) END)) 
				WHEN PL.EffectiveDate < @Date AND PL.ExpiryDate > @EndDate AND PR.PayDate < @Date
					THEN @DaysInMonth * (SUM(PR.Amount)/CASE WHEN (DATEDIFF(DAY,CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END,DATEADD(D,-1,PL.ExpiryDate))) <= 0 THEN 1 ELSE DATEDIFF(DAY,CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END,PL.ExpiryDate) END)
				END Allocated
				FROM tblPremium PR INNER JOIN tblPolicy PL ON PR.PolicyID = PL.PolicyID
				INNER JOIN tblProduct Prod ON PL.ProdID = Prod.ProdID 
				INNER JOIN tblFamilies F ON PL.FamilyID = F.FamilyID
				INNER JOIN tblVillages V ON V.VillageId = F.LocationId
				INNER JOIN tblWards W ON W.WardId = V.WardId
				INNER JOIN tblDistricts D ON D.DistrictID = W.DistrictID
				INNER JOIN tblRegions R ON D.Region = R.RegionID
				--LEFT OUTER JOIN tblDistricts D ON Prod.DistrictID = D.DistrictID
				--LEFT OUTER JOIN tblRegions R ON R.RegionId = D.Region
				WHERE PR.ValidityTo IS NULL
				AND PL.ValidityTo IS NULL
				AND Prod.ValidityTo IS  NULL
				AND F.ValidityTo IS NULL
				AND D.ValidityTo IS NULL
				AND PL.PolicyStatus <> 1
				AND PR.PayDate <= PL.ExpiryDate
	
				GROUP BY PL.ExpiryDate, PR.PayDate, PL.EffectiveDate,R.RegionName, D.DistrictName,Prod.ProductCode, Prod.ProductName
			)
			INSERT INTO @tblResult(Allocated ,Region, DistrictName, ProductCode, ProductName, MonthTime, QuarterTime, YearTime)
			SELECT SUM(Allocated)Allocated, Region,DistrictName,ProductCode, ProductName,MonthTime,QuarterTime,YearTime
			FROM Allocation
			GROUP BY Region, DistrictName, ProductCode, ProductName,MonthTime,QuarterTime,YearTime;


			SET @Counter += 1;
		END	
		SET @Counter = 1;
		SET @Year += 1;
	END
	SELECT * FROM @tblResult;
END
GO
