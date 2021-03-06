/****** Object:  StoredProcedure [dbo].[uspSSRSDerivedIndicators1]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspSSRSDerivedIndicators1]
(
	@ProductID INT = 0,
	@LocationId INT = 0,
	@Month INT,
	@Year INT
)
AS
BEGIN		

	IF NOT OBJECT_ID('tempdb..#tmpResult') IS NULL DROP TABLE #tmpResult
	
	CREATE TABLE #tmpResult(
			NameOfTheMonth VARCHAR(15),
			DistrictName NVARCHAR(50),
			ProductCode NVARCHAR(8),
			ProductName NVARCHAR(100),
			IncurredClaimRatio DECIMAL(18,2),
			RenewalRatio DECIMAL(18,2),
			GrowthRatio DECIMAL(18,2),
			Promptness DECIMAL(18,2),
			InsureePerClaim DECIMAL(18,2)
		)

	DECLARE @LastDay DATE
	DECLARE @PreMonth INT
	DECLARE @PreYear INT 
	
	DECLARE @Counter INT = 1
	DECLARE @MaxCount INT = 12

IF @Month > 0
	BEGIN
		SET @Counter = @Month
		SET @MaxCount = @Month
	END
	
WHILE @Counter <> @MaxCount + 1
BEGIN
	SET @LastDay = DATEADD(DAY,-1,DATEADD(MONTH,1,CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Counter AS VARCHAR(2)) + '-01'))
	SET @PreMonth = MONTH(DATEADD(MONTH,-1,@LastDay))
	SET @PreYear = YEAR(DATEADD(MONTH,-1,@LastDay))

INSERT INTO #tmpResult
	SELECT CAST(YEAR(@LastDay) AS VARCHAR(4)) + ' ' + DATENAME(MONTH,@LastDay)NameOfTheMonth,Promptness.DistrictName,MainInfo.ProductCode,MainInfo.ProductName
	,CAST(SUM(ISNULL(R.Remunerated,0))AS FLOAT)/ISNULL(AP.Allocated,1) IncurredClaimRatio
	,CAST(ISNULL(PR.Renewals,0) AS FLOAT)/ISNULL(EP.ExpiredPolicies,1)RenewalRatio
	,CAST((ISNULL(NP.Male,0) + ISNULL(NP.Female,0)) AS FLOAT)/ISNULL(TP.Male + TP.Female,1)GrowthRatio
	,Promptness.AverageDays AS Promptness --Still to come
	,TC.TotalClaims/ISNULL(PIn.Male + PIn.Female,1)InsureePerClaim
	FROM
	(SELECT PR.ProdID,PR.ProductCode,PR.ProductName
	FROM tblProduct PR --LEFT OUTER JOIN tblDistricts D ON PR.DistrictID = D.DistrictID
	WHERE PR.ValidityTo IS NULL --AND D.ValidityTo IS NULL
	--AND (PR.DistrictID = @LocationId OR @DistrictID = 0 OR PR.DistrictID IS NULL)
	AND (PR.ProdID = @ProductID OR @ProductID = 0)
	)MainInfo INNER JOIN
	dbo.udfRemunerated(0,@ProductID,@LocationId,@Counter,@Year) R ON MainInfo.ProdID = R.ProdID LEFT OUTER JOIN
	dbo.udfAvailablePremium(@ProductID,@LocationId,@Counter,@Year,1)AP ON MainInfo.ProdID = AP.ProdID LEFT OUTER JOIN
	dbo.udfPolicyRenewal(@ProductID,@LocationId,@Counter,@Year,1) PR ON MainInfo.ProdID = PR.ProdID LEFT OUTER JOIN
	dbo.udfExpiredPolicies(@ProductID,@LocationId,@Counter,@Year,1)EP ON MainInfo.ProdID = EP.ProdID LEFT OUTER JOIN
	dbo.udfNewPolicies(@ProductID,@LocationId,@PreMonth,@PreYear,1)NP ON MainInfo.ProdID = NP.ProdID LEFT OUTER JOIN
	dbo.udfTotalPolicies(@ProductID,@LocationId,DATEADD(MONTH,-1,@LastDay),1)TP ON MainInfo.ProdID = TP.ProdID LEFT OUTER JOIN
	--dbo.udfRejectedClaims(@ProductID,@LocationId,0,@Counter,@Year)RC ON MainInfo.ProdID = RC.ProdID LEFT OUTER JOIN
	dbo.udfTotalClaims(@ProductId,0,@LocationId,@Counter,@Year) TC ON MainInfo.ProdID = TC.ProdID LEFT OUTER JOIN
	dbo.udfPolicyInsuree(@ProductID,@LocationId,@LastDay,1) PIn ON MainInfo.ProdID = PIn.ProdID LEFT OUTER JOIN
	(SELECT Base.ProdID,AVG(DATEDIFF(dd,Base.DateClaimed,Base.RunDate))AverageDays,Base.DistrictName
		FROM
		(SELECT C.ClaimID,C.DateClaimed,CI.ProdID,B.RunDate,D.DistrictName
		FROM tblClaim C INNER JOIN tblClaimItems CI ON C.ClaimID = CI.ClaimID
		INNER JOIN tblInsuree I ON C.InsureeId = I.InsureeId 
		INNER JOIN tblFamilies F ON I.familyId = F.FamilyId
		INNER JOIN tblVillages V ON V.VillageId = F.LocationId
		INNER JOIN tblWards W ON W.WardId = V.WardId
		INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
		INNER JOIN tblBatchRun B ON C.RunID = B.RunID
		WHERE C.ValidityTo IS NULL AND CI.ValidityTo IS NULL AND I.ValidityTo IS NULL AND F.ValidityTo IS NULL
		AND (CI.ProdID = @ProductID OR @ProductID = 0)
		AND C.RunID IN (SELECT  RunID FROM tblBatchRun WHERE ValidityTo IS NULL AND MONTH(RunDate) =@Counter AND YEAR(RunDate) = @Year)
		GROUP BY C.ClaimID,C.DateClaimed,CI.ProdID,B.RunDate,D.DistrictName
		UNION 
		SELECT C.ClaimID,C.DateClaimed,CS.ProdID,B.RunDate, D.DistrictName
		FROM tblClaim C INNER JOIN tblClaimItems CS ON C.ClaimID = CS.ClaimID
		INNER JOIN tblInsuree I ON C.InsureeId = I.InsureeId 
		INNER JOIN tblFamilies F ON I.familyId = F.FamilyId
		INNER JOIN tblVillages V ON V.VillageId = F.LocationId
		INNER JOIN tblWards W ON W.WardId = V.WardId
		INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
		INNER JOIN tblBatchRun B ON C.RunID = B.RunID
		WHERE C.ValidityTo IS NULL AND CS.ValidityTo IS NULL AND I.ValidityTo IS NULL AND F.ValidityTo IS NULL
		AND (CS.ProdID = @ProductID OR @ProductID = 0)
		AND C.RunID IN (SELECT  RunDate FROM tblBatchRun WHERE ValidityTo IS NULL AND MONTH(RunDate) =@Counter AND YEAR(RunDate) = @Year)
		GROUP BY C.ClaimID,C.DateClaimed,CS.ProdID,B.RunDate, D.DistrictName)Base
		GROUP BY Base.ProdID,Base.DistrictName)Promptness ON MainInfo.ProdID = Promptness.ProdID
	
	GROUP BY Promptness.DistrictName,MainInfo.ProductCode,MainInfo.ProductName,AP.Allocated,PR.Renewals,EP.ExpiredPolicies,NP.Male,NP.Female,TP.Male,TP.Female,Promptness.AverageDays,PIn.Male,Pin.Female, TC.TotalClaims
	
	SET @Counter = @Counter + 1
		
END
	SELECT * FROM #tmpResult
END
GO
