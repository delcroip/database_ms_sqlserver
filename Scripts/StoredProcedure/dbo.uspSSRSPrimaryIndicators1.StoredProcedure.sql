/****** Object:  StoredProcedure [dbo].[uspSSRSPrimaryIndicators1]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspSSRSPrimaryIndicators1] 
(
	@LocationId INT = 0,
	@ProductID INT = 0,
	@MonthFrom INT,
	@MonthTo INT = 0,
	@Year INT,
	@Mode INT = 1
)
AS
BEGIN
	DECLARE @LastDay DATE
	
	IF @LocationId=-1
	SET @LocationId=NULL
	IF NOT OBJECT_ID('tempdb..#tmpResult') IS NULL DROP TABLE #tmpResult
	
	CREATE TABLE #tmpResult(
		[Quarter] INT,
		NameOfTheMonth VARCHAR(15),
		OfficerCode VARCHAR(8),
		LastName NVARCHAR(50),
		OtherNames NVARCHAR(50),
		ProductCode NVARCHAR(8),
		ProductName NVARCHAR(100),
		NoOfPolicyMale INT,
		NoOfPolicyFemale INT,
		NoOfPolicyOther INT, -- bY Ruzo
		NoOfNewPolicyMale INT,
		NoOfNewPolicyFemale INT,
		NoOfNewPolicyOther INT, -- bY Ruzo
		NoOfSuspendedPolicy INT,
		NoOfExpiredPolicy INT,
		NoOfRenewPolicy INT,
		NoOfInsureeMale INT,
		NoOfInsureeFemale INT,
		NoOfInsureeOther INT, -- bY Ruzo
		NoOfNewInsureeMale INT,
		NoOfNewInsureeFemale INT,
		NoOfNewInsureeOther INT, -- bY Ruzo
		PremiumCollected DECIMAL(18,2),
		PremiumAvailable DECIMAL(18,2),
		MonthId INT,
		OfficerStatus CHAR(1)
	)	
	
	
DECLARE @Counter INT = 1
DECLARE @MaxCount INT = 12

IF @MonthFrom > 0
	BEGIN
		SET @Counter = @MonthFrom
		SET @MaxCount = @MonthTo
	END
	
WHILE @Counter <> @MaxCount + 1
BEGIN
	
	SET @LastDay = DATEADD(DAY,-1,DATEADD(MONTH,1,CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Counter AS VARCHAR(2)) + '-01'))
	IF @Mode = 1
		INSERT INTO #tmpResult
		SELECT DATEPART(QQ,@LastDay) [Quarter],
		CAST(YEAR(@LastDay) AS VARCHAR(4)) + ' ' + DATENAME(MONTH,@LastDay)NameOfTheMonth,NULL,NULL,NULL,MainInfo.ProductCode,MainInfo.ProductName,
		TP.Male AS NoOfPolicyMale,
		TP.Female AS NoOfPolicyFemale,
		TP.Other AS NoOfPolicyOther,
		NP.Male AS NoOfNewPolicyMale,
		NP.Female AS NoOfNewPolicyFemale,
		NP.Other AS NoOfNewPolicyOther,
		SP.SuspendedPolicies NoOfSuspendedPolicy,
		EP.ExpiredPolicies NoOfExpiredPolicy,
		PR.Renewals NoOfRenewPolicy,
		PIn.Male NoOfInsureeMale,Pin.Female NoOfInsureeFemale, PIn.Other NoOfInsureeOther,
		NPI.Male NoOfNewInsureeMale, NPI.Female NoOfNewInsureeFemale, NPI.Other NoOfNewInsureeOther,
		NPC.PremiumCollection PremiumCollected,
		AP.Allocated PremiumAvailable,
		@Counter MonthId,
		NULL OfficerStatus

		FROM 
		(SELECT PR.ProdID,PR.ProductCode,PR.ProductName
		FROM tblProduct PR 
		--INNER JOIN uvwLocations L ON L.LocationId = ISNULL(PR.LocationId, 0) OR L.RegionId = PR.LocationId OR L.DistrictId= PR.LocationId
		WHERE PR.ValidityTo IS NULL
		--AND (PR.LocationId = @LocationId OR @LocationId = 0 OR PR.LocationId IS NULL)
		AND (PR.ProdID = @ProductID OR @ProductID = 0)
		--AND (L.LocationId = ISNULL(@LocationId, 0) OR ISNULL(@LocationId, 0) = 0)
		)MainInfo LEFT OUTER JOIN
		dbo.udfTotalPolicies(@ProductID,@LocationId,@LastDay,@Mode) TP ON MainInfo.ProdID = TP.ProdID LEFT OUTER JOIN
		dbo.udfNewPolicies(@ProductID,@LocationId,@Counter,@Year,@Mode) NP ON MainInfo.ProdID = NP.ProdID LEFT OUTER JOIN
		dbo.udfSuspendedPolicies(@ProductID,@LocationId,@Counter,@Year,@Mode)SP ON MainInfo.ProdID = SP.ProdID LEFT OUTER JOIN
		dbo.udfExpiredPolicies(@ProductID,@LocationId,@Counter,@Year,@Mode)EP ON MainInfo.ProdID = EP.ProdID LEFT OUTER JOIN
		dbo.udfPolicyRenewal(@ProductID,@LocationId,@Counter,@Year,@Mode) PR ON MainInfo.ProdID = PR.ProdID LEFT OUTER JOIN
		dbo.udfPolicyInsuree(@ProductID,@LocationId,@lastDay,@Mode)PIn ON MainInfo.ProdID = PIn.ProdID LEFT OUTER JOIN
		dbo.udfNewPolicyInsuree(@ProductID,@LocationId,@Counter,@Year,@Mode)NPI ON MainInfo.ProdID = NPI.ProdID LEFT OUTER JOIN
		dbo.udfNewlyPremiumCollected(@ProductID,@LocationId,@Counter,@Year,@Mode)NPC ON MainInfo.ProdID = NPC.ProdID  LEFT OUTER JOIN
		dbo.udfAvailablePremium(@ProductID,@LocationId,@Counter,@Year,@Mode)AP ON MainInfo.ProdID = AP.ProdID 
	ELSE
		INSERT INTO #tmpResult
	
		SELECT DATEPART(QQ,@LastDay) [Quarter],
		CAST(YEAR(@LastDay) AS VARCHAR(4)) + ' ' + DATENAME(MONTH,@LastDay)NameOfTheMonth,MainInfo.Code,MainInfo.LastName,MainInfo.OtherNames,MainInfo.ProductCode,MainInfo.ProductName,
		TP.Male AS NoOfPolicyMale,
		TP.Female AS NoOfPolicyFemale,
		TP.Other AS NoOfPolicyOther,
		NP.Male AS NoOfNewPolicyMale,
		NP.Female AS NoOfNewPolicyFemale,
		NP.Other AS NoOfNewPolicyOther,
		SP.SuspendedPolicies NoOfSuspendedPolicy,
		EP.ExpiredPolicies NoOfExpiredPolicy,
		PR.Renewals NoOfRenewPolicy,
		PIn.Male NoOfInsureeMale,Pin.Female NoOfInsureeFemale, PIn.Other NoOfInsureeOther,
		NPI.Male NoOfNewInsureeMale, NPI.Female NoOfNewInsureeFemale, NPI.Other NoOfNewInsureeOther,
		NPC.PremiumCollection PremiumCollected,
		AP.Allocated PremiumAvailable,
		@Counter MonthId,
		IIF(ISNULL(CAST(WorksTo AS DATE) , DATEADD(DAY, 1, GETDATE())) <= CAST(GETDATE() AS DATE), 'N', 'A')OfficerStatus

		FROM 
		(SELECT PR.ProdID,PR.ProductCode,PR.ProductName, o.code,O.LastName,O.OtherNames, O.WorksTo
		FROM tblProduct PR 
		INNER JOIN tblPolicy PL ON PR.ProdID = PL.ProdID
		INNER JOIN tblFamilies F ON PL.FamilyID = F.FamilyID
		INNER JOIN tblVillages V ON V.VillageId = F.LocationId
		INNER JOIN tblWards W ON W.WardId = V.WardId
		INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
		INNER JOIN (select OfficerID,code,LastName,OtherNames,LocationId,ValidityTo, WorksTo from tblOfficer) O on PL.OfficerID = O.OfficerID
		WHERE pr.ValidityTo is null and o.ValidityTo is null
		--AND (PR.LocationId = @LocationId OR @LocationId = 0 OR PR.LocationId IS NULL)
		--AND (D.DistrictID = @LocationId OR @LocationId IS NULL)
		AND (PR.ProdID = @ProductID OR @ProductID = 0)
		AND PL.ValidityTo IS NULL --AND F.ValidityTo IS NULL
		AND V.ValidityTO IS NULL
		AND W.ValidityTo IS NULL
		AND D.ValidityTo IS NULL
		AND (D.Region = @LocationId OR D.DistrictId = @LocationId OR @LocationId = 0)
		)MainInfo LEFT OUTER JOIN
		dbo.udfTotalPolicies(@ProductID,@LocationId,@LastDay,@Mode) TP ON MainInfo.ProdID = TP.ProdID and (maininfo.Code = tp.Officer OR maininfo.Code = ISNULL(TP.Officer,0))  LEFT OUTER JOIN
		dbo.udfNewPolicies(@ProductID,@LocationId,@Counter,@Year,@Mode) NP ON MainInfo.ProdID = NP.ProdID  and (maininfo.Code = np.Officer OR maininfo.Code = ISNULL(NP.Officer,0)) LEFT OUTER JOIN
		dbo.udfSuspendedPolicies(@ProductID,@LocationId,@Counter,@Year,@Mode)SP ON MainInfo.ProdID = SP.ProdID  and (maininfo.Code = sp.Officer OR maininfo.Code = ISNULL(SP.Officer,0))LEFT OUTER JOIN
		dbo.udfExpiredPolicies(@ProductID,@LocationId,@Counter,@Year,@Mode)EP ON MainInfo.ProdID = EP.ProdID and (maininfo.Code = ep.Officer OR maininfo.Code = ISNULL(EP.Officer,0)) LEFT OUTER JOIN
		dbo.udfPolicyRenewal(@ProductID,@LocationId,@Counter,@Year,@Mode) PR ON MainInfo.ProdID = PR.ProdID and (maininfo.Code = pr.Officer OR maininfo.Code = ISNULL(PR.Officer,0)) LEFT OUTER JOIN
		dbo.udfPolicyInsuree(@ProductID,@LocationId,@lastDay,@Mode)PIn ON MainInfo.ProdID = PIn.ProdID and (maininfo.Code = pin.Officer OR maininfo.Code = ISNULL(PIn.Officer,0)) LEFT OUTER JOIN
		dbo.udfNewPolicyInsuree(@ProductID,@LocationId,@Counter,@Year,@Mode)NPI ON MainInfo.ProdID = NPI.ProdID and (maininfo.Code = npi.Officer OR maininfo.Code = ISNULL(NPI.Officer,0))LEFT OUTER JOIN
		dbo.udfNewlyPremiumCollected(@ProductID,@LocationId,@Counter,@Year,@Mode)NPC ON MainInfo.ProdID = NPC.ProdID and (maininfo.Code = npc.Officer OR maininfo.Code = ISNULL(NPC.Officer,0)) LEFT OUTER JOIN
		dbo.udfAvailablePremium(@ProductID,@LocationId,@Counter,@Year,@Mode)AP ON MainInfo.ProdID = AP.ProdID and (maininfo.Code = ap.Officer OR maininfo.Code = ISNULL(AP.Officer,0))

	SET @Counter = @Counter + 1

END

	SELECT * FROM #tmpResult
	GROUP BY [Quarter], NameOfTheMonth, OfficerCode, LastName, OtherNames,ProductCode, ProductName, NoOfPolicyMale, NoOfPolicyFemale,NoOfPolicyOther, NoOfNewPolicyMale,
	NoOfNewPolicyFemale,NoOfNewPolicyOther, NoOfSuspendedPolicy, NoOfExpiredPolicy, NoOfRenewPolicy, NoOfInsureeMale, NoOfInsureeFemale,NoOfInsureeOther, NoOfNewInsureeMale,
	NoOfNewInsureeFemale,NoOfNewInsureeOther, PremiumCollected, PremiumAvailable, MonthId, OfficerStatus
  ORDER BY MonthId

END
GO
