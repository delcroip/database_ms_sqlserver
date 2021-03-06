/****** Object:  StoredProcedure [dbo].[uspSSRSCapitationPayment]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspSSRSCapitationPayment]

(
	@RegionId INT = NULL,
	@DistrictId INT = NULL,
	@ProdId INT,
	@Year INT,
	@Month INT,
	@HFLevel xAttributeV READONLY
)
AS
BEGIN
	
	DECLARE @Level1 CHAR(1) = NULL,
			@Sublevel1 CHAR(1) = NULL,
			@Level2 CHAR(1) = NULL,
			@Sublevel2 CHAR(1) = NULL,
			@Level3 CHAR(1) = NULL,
			@Sublevel3 CHAR(1) = NULL,
			@Level4 CHAR(1) = NULL,
			@Sublevel4 CHAR(1) = NULL,
			@ShareContribution DECIMAL(5, 2),
			@WeightPopulation DECIMAL(5, 2),
			@WeightNumberFamilies DECIMAL(5, 2),
			@WeightInsuredPopulation DECIMAL(5, 2),
			@WeightNumberInsuredFamilies DECIMAL(5, 2),
			@WeightNumberVisits DECIMAL(5, 2),
			@WeightAdjustedAmount DECIMAL(5, 2)

	DECLARE @FirstDay DATE = CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-01'; 
	DECLARE @LastDay DATE = EOMONTH(CAST(@Year AS VARCHAR(4)) + '-' + CAST(@Month AS VARCHAR(2)) + '-01', 0)
	DECLARE @DaysInMonth INT = DATEDIFF(DAY,@FirstDay,DATEADD(MONTH,1,@FirstDay));

	SELECT @Level1 = Level1, @Sublevel1 = Sublevel1, @Level2 = Level2, @Sublevel2 = Sublevel2, @Level3 = Level3, @Sublevel3 = Sublevel3, 
	@Level4 = Level4, @Sublevel4 = Sublevel4, @ShareContribution = ISNULL(ShareContribution, 0), @WeightPopulation = ISNULL(WeightPopulation, 0), 
	@WeightNumberFamilies = ISNULL(WeightNumberFamilies, 0), @WeightInsuredPopulation = ISNULL(WeightInsuredPopulation, 0), @WeightNumberInsuredFamilies = ISNULL(WeightNumberInsuredFamilies, 0), 
	@WeightNumberVisits = ISNULL(WeightNumberVisits, 0), @WeightAdjustedAmount = ISNULL(WeightAdjustedAmount, 0)
	FROM tblProduct Prod 
	WHERE ProdId = @ProdId;


	PRINT @ShareContribution
	PRINT @WeightPopulation
	PRINT @WeightNumberFamilies 
	PRINT @WeightInsuredPopulation 
	PRINT @WeightNumberInsuredFamilies 
	PRINT @WeightNumberVisits 
	PRINT @WeightAdjustedAmount


	;WITH TotalPopFam AS
	(
		SELECT C.HFID  ,
		CASE WHEN ISNULL(@DistrictId, @RegionId) IN (R.RegionId, D.DistrictId) THEN 1 ELSE 0 END * SUM((ISNULL(L.MalePopulation, 0) + ISNULL(L.FemalePopulation, 0) + ISNULL(L.OtherPopulation, 0)) *(0.01* Catchment))[Population], 
		CASE WHEN ISNULL(@DistrictId, @RegionId) IN (R.RegionId, D.DistrictId) THEN 1 ELSE 0 END * SUM(ISNULL(((L.Families)*(0.01* Catchment)), 0))TotalFamilies
		FROM tblHFCatchment C
		INNER JOIN tblLocations L ON L.LocationId = C.LocationId
		INNER JOIN tblHF HF ON C.HFID = HF.HfID
		INNER JOIN tblDistricts D ON HF.LocationId = D.DistrictId
		INNER JOIN tblRegions R ON D.Region = R.RegionId
		WHERE C.ValidityTo IS NULL
		AND L.ValidityTo IS NULL
		AND HF.ValidityTo IS NULL
		GROUP BY C.HFID, D.DistrictId, R.RegionId
	), InsuredInsuree AS
	(
		SELECT HC.HFID, @ProdId ProdId, COUNT(DISTINCT IP.InsureeId)*(0.01 * Catchment) TotalInsuredInsuree
		FROM tblInsureePolicy IP
		INNER JOIN tblInsuree I ON I.InsureeId = IP.InsureeId
		INNER JOIN tblFamilies F ON F.FamilyId = I.FamilyId
		INNER JOIN tblHFCatchment HC ON HC.LocationId = F.LocationId
		INNER JOIN uvwLocations L ON L.LocationId = HC.LocationId
		INNER JOIN tblPolicy PL ON PL.PolicyID = IP.PolicyId
		WHERE HC.ValidityTo IS NULL 
		AND I.ValidityTo IS NULL
		AND IP.ValidityTo IS NULL
		AND F.ValidityTo IS NULL
		AND PL.ValidityTo IS NULL
		AND IP.EffectiveDate <= @LastDay 
		AND IP.ExpiryDate > @LastDay
		AND PL.ProdID = @ProdId
		GROUP BY HC.HFID, Catchment--, L.LocationId
	), InsuredFamilies AS
	(
		SELECT HC.HFID, COUNT(DISTINCT F.FamilyID)*(0.01 * Catchment) TotalInsuredFamilies
		FROM tblInsureePolicy IP
		INNER JOIN tblInsuree I ON I.InsureeId = IP.InsureeId
		INNER JOIN tblFamilies F ON F.InsureeID = I.InsureeID
		INNER JOIN tblHFCatchment HC ON HC.LocationId = F.LocationId
		INNER JOIN uvwLocations L ON L.LocationId = HC.LocationId
		INNER JOIN tblPolicy PL ON PL.PolicyID = IP.PolicyId
		WHERE HC.ValidityTo IS NULL 
		AND I.ValidityTo IS NULL
		AND IP.ValidityTo IS NULL
		AND F.ValidityTo IS NULL
		AND PL.ValidityTo IS NULL
		AND IP.EffectiveDate <= @LastDay 
		AND IP.ExpiryDate > @LastDay
		AND PL.ProdID = @ProdId
		GROUP BY HC.HFID, Catchment--, L.LocationId
	), Claims AS
	(
		SELECT C.HFID,  COUNT(C.ClaimId)TotalClaims
		FROM tblClaim C
		INNER JOIN (
			SELECT ClaimId FROM tblClaimItems WHERE ProdId = @ProdId AND ValidityTo IS NULL
			UNION
			SELECT ClaimId FROM tblClaimServices WHERE ProdId = @ProdId AND ValidityTo IS NULL
			) CProd ON CProd.ClaimID = C.ClaimID
		WHERE C.ValidityTo IS NULL
		AND C.ClaimStatus >= 8
		AND YEAR(C.DateProcessed) = @Year
		AND MONTH(C.DateProcessed) = @Month
		GROUP BY C.HFID
	), ClaimValues AS
	(
		SELECT HFID, @ProdId ProdId, SUM(PriceValuated)TotalAdjusted
		FROM(
		SELECT C.HFID, CValue.PriceValuated
		FROM tblClaim C
		INNER JOIN (
			SELECT ClaimId, PriceValuated FROM tblClaimItems WHERE ValidityTo IS NULL AND ProdId = @ProdId
			UNION ALL
			SELECT ClaimId, PriceValuated FROM tblClaimServices WHERE ValidityTo IS NULL AND ProdId = @ProdId
			) CValue ON CValue.ClaimID = C.ClaimID
		WHERE C.ValidityTo IS NULL
		AND C.ClaimStatus >= 8
		AND YEAR(C.DateProcessed) = @Year
		AND MONTH(C.DateProcessed) = @Month
		)CValue
		GROUP BY HFID
	),Locations AS
	(
		SELECT 0 LocationId, N'National' LocationName, NULL ParentLocationId
		UNION
		SELECT LocationId,LocationName, ISNULL(ParentLocationId, 0) FROM tblLocations WHERE ValidityTo IS NULL AND LocationId = ISNULL(@DistrictId, @RegionId)
		UNION ALL
		SELECT L.LocationId, L.LocationName, L.ParentLocationId 
		FROM tblLocations L 
		INNER JOIN Locations ON Locations.LocationId = L.ParentLocationId
		WHERE L.validityTo IS NULL
		AND L.LocationType IN ('R', 'D')
	), Allocation AS
	(
		SELECT ProdId, CAST(SUM(ISNULL(Allocated, 0)) AS DECIMAL(18, 6))Allocated
		FROM
		(SELECT PL.ProdID,
		CASE 
		WHEN MONTH(DATEADD(D,-1,PL.ExpiryDate)) = @Month AND YEAR(DATEADD(D,-1,PL.ExpiryDate)) = @Year AND (DAY(PL.ExpiryDate)) > 1
			THEN CASE WHEN DATEDIFF(D,CASE WHEN PR.PayDate < @FirstDay THEN @FirstDay ELSE PR.PayDate END,PL.ExpiryDate) = 0 THEN 1 ELSE DATEDIFF(D,CASE WHEN PR.PayDate < @FirstDay THEN @FirstDay ELSE PR.PayDate END,PL.ExpiryDate) END  * ((SUM(PR.Amount))/(CASE WHEN (DATEDIFF(DAY,CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END,PL.ExpiryDate)) <= 0 THEN 1 ELSE DATEDIFF(DAY,CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END,PL.ExpiryDate) END))
		WHEN MONTH(CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END) = @Month AND YEAR(CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END) = @Year
			THEN ((@DaysInMonth + 1 - DAY(CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END)) * ((SUM(PR.Amount))/CASE WHEN DATEDIFF(DAY,CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END,PL.ExpiryDate) <= 0 THEN 1 ELSE DATEDIFF(DAY,CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END,PL.ExpiryDate) END)) 
		WHEN PL.EffectiveDate < @FirstDay AND PL.ExpiryDate > @LastDay AND PR.PayDate < @FirstDay
			THEN @DaysInMonth * (SUM(PR.Amount)/CASE WHEN (DATEDIFF(DAY,CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END,DATEADD(D,-1,PL.ExpiryDate))) <= 0 THEN 1 ELSE DATEDIFF(DAY,CASE WHEN PR.PayDate < PL.EffectiveDate THEN PL.EffectiveDate ELSE PR.PayDate END,PL.ExpiryDate) END)
		END Allocated
		FROM tblPremium PR 
		INNER JOIN tblPolicy PL ON PR.PolicyID = PL.PolicyID
		INNER JOIN tblProduct Prod ON Prod.ProdId = PL.ProdID
		INNER JOIN Locations L ON ISNULL(Prod.LocationId, 0) = L.LocationId
		WHERE PR.ValidityTo IS NULL
		AND PL.ValidityTo IS NULL
		AND PL.ProdID = @ProdId
		AND PL.PolicyStatus <> 1
		AND PR.PayDate <= PL.ExpiryDate
		GROUP BY PL.ProdID, PL.ExpiryDate, PR.PayDate,PL.EffectiveDate)Alc
		GROUP BY ProdId
	)



	,ReportData AS
	(
		SELECT L.RegionCode, L.RegionName, L.DistrictCode, L.DistrictName, HF.HFCode, HF.HFName, Hf.AccCode, HL.Name HFLevel, SL.HFSublevelDesc HFSublevel,
		PF.[Population] [Population], PF.TotalFamilies TotalFamilies, II.TotalInsuredInsuree, IFam.TotalInsuredFamilies, C.TotalClaims, CV.TotalAdjusted
		,(
			  ISNULL(ISNULL(PF.[Population], 0) * (Allocation.Allocated * (0.01 * @ShareContribution) * (0.01 * @WeightPopulation)) /  NULLIF(SUM(PF.[Population])OVER(),0),0)  
			+ ISNULL(ISNULL(PF.TotalFamilies, 0) * (Allocation.Allocated * (0.01 * @ShareContribution) * (0.01 * @WeightNumberFamilies)) /NULLIF(SUM(PF.[TotalFamilies])OVER(),0),0) 
			+ ISNULL(ISNULL(II.TotalInsuredInsuree, 0) * (Allocation.Allocated * (0.01 * @ShareContribution) * (0.01 * @WeightInsuredPopulation)) /NULLIF(SUM(II.TotalInsuredInsuree)OVER(),0),0) 
			+ ISNULL(ISNULL(IFam.TotalInsuredFamilies, 0) * (Allocation.Allocated * (0.01 * @ShareContribution) * (0.01 * @WeightNumberInsuredFamilies)) /NULLIF(SUM(IFam.TotalInsuredFamilies)OVER(),0),0) 
			+ ISNULL(ISNULL(C.TotalClaims, 0) * (Allocation.Allocated * (0.01 * @ShareContribution) * (0.01 * @WeightNumberVisits)) /NULLIF(SUM(C.TotalClaims)OVER() ,0),0) 
			+ ISNULL(ISNULL(CV.TotalAdjusted, 0) * (Allocation.Allocated * (0.01 * @ShareContribution) * (0.01 * @WeightAdjustedAmount)) /NULLIF(SUM(CV.TotalAdjusted)OVER(),0),0)

		) PaymentCathment

		, Allocation.Allocated * (0.01 * @WeightPopulation) * (0.01 * @ShareContribution) AlcContriPopulation
		, Allocation.Allocated * (0.01 * @WeightNumberFamilies) * (0.01 * @ShareContribution) AlcContriNumFamilies
		, Allocation.Allocated * (0.01 * @WeightInsuredPopulation) * (0.01 * @ShareContribution) AlcContriInsPopulation
		, Allocation.Allocated * (0.01 * @WeightNumberInsuredFamilies) * (0.01 * @ShareContribution) AlcContriInsFamilies
		, Allocation.Allocated * (0.01 * @WeightNumberVisits) * (0.01 * @ShareContribution) AlcContriVisits
		, Allocation.Allocated * (0.01 * @WeightAdjustedAmount) * (0.01 * @ShareContribution) AlcContriAdjustedAmount

		,  ISNULL((Allocation.Allocated * (0.01 * @WeightPopulation) * (0.01 * @ShareContribution))/ NULLIF(SUM(PF.[Population]) OVER(),0),0) UPPopulation
		,  ISNULL((Allocation.Allocated * (0.01 * @WeightNumberFamilies) * (0.01 * @ShareContribution))/NULLIF(SUM(PF.TotalFamilies) OVER(),0),0) UPNumFamilies
		,  ISNULL((Allocation.Allocated * (0.01 * @WeightInsuredPopulation) * (0.01 * @ShareContribution))/NULLIF(SUM(II.TotalInsuredInsuree) OVER(),0),0) UPInsPopulation
		,  ISNULL((Allocation.Allocated * (0.01 * @WeightNumberInsuredFamilies) * (0.01 * @ShareContribution))/ NULLIF(SUM(IFam.TotalInsuredFamilies) OVER(),0),0) UPInsFamilies
		,  ISNULL((Allocation.Allocated * (0.01 * @WeightNumberVisits) * (0.01 * @ShareContribution)) / NULLIF(SUM(C.TotalClaims) OVER(),0),0) UPVisits
		,  ISNULL((Allocation.Allocated * (0.01 * @WeightAdjustedAmount) * (0.01 * @ShareContribution))/ NULLIF(SUM(CV.TotalAdjusted) OVER(),0),0) UPAdjustedAmount




		FROM tblHF HF
		INNER JOIN @HFLevel HL ON HL.Code = HF.HFLevel
		LEFT OUTER JOIN tblHFSublevel SL ON SL.HFSublevel = HF.HFSublevel
		INNER JOIN uvwLocations L ON L.LocationId = HF.LocationId
		LEFT OUTER JOIN TotalPopFam PF ON PF.HFID = HF.HfID
		LEFT OUTER JOIN InsuredInsuree II ON II.HFID = HF.HfID
		LEFT OUTER JOIN InsuredFamilies IFam ON IFam.HFID = HF.HfID
		LEFT OUTER JOIN Claims C ON C.HFID = HF.HfID
		LEFT OUTER JOIN ClaimValues CV ON CV.HFID = HF.HfID
		LEFT OUTER JOIN Allocation ON Allocation.ProdID = @ProdId

		WHERE HF.ValidityTo IS NULL
		AND (((L.RegionId = @RegionId OR @RegionId IS NULL) AND (L.DistrictId = @DistrictId OR @DistrictId IS NULL)) OR CV.ProdID IS NOT NULL OR II.ProdId IS NOT NULL)
		AND (HF.HFLevel IN (@Level1, @Level2, @Level3, @Level4) OR (@Level1 IS NULL AND @Level2 IS NULL AND @Level3 IS NULL AND @Level4 IS NULL))
		AND(
			((HF.HFLevel = @Level1 OR @Level1 IS NULL) AND (HF.HFSublevel = @Sublevel1 OR @Sublevel1 IS NULL))
			OR ((HF.HFLevel = @Level2 ) AND (HF.HFSublevel = @Sublevel2 OR @Sublevel2 IS NULL))
			OR ((HF.HFLevel = @Level3) AND (HF.HFSublevel = @Sublevel3 OR @Sublevel3 IS NULL))
			OR ((HF.HFLevel = @Level4) AND (HF.HFSublevel = @Sublevel4 OR @Sublevel4 IS NULL))
		  )

	)



	SELECT  MAX (RegionCode)RegionCode, 
			MAX(RegionName)RegionName,
			MAX(DistrictCode)DistrictCode,
			MAX(DistrictName)DistrictName,
			HFCode, 
			MAX(HFName)HFName,
			MAX(AccCode)AccCode, 
			MAX(HFLevel)HFLevel, 
			MAX(HFSublevel)HFSublevel,
			ISNULL(SUM([Population]),0)[Population],
			ISNULL(SUM(TotalFamilies),0)TotalFamilies,
			ISNULL(SUM(TotalInsuredInsuree),0)TotalInsuredInsuree,
			ISNULL(SUM(TotalInsuredFamilies),0)TotalInsuredFamilies,
			ISNULL(MAX(TotalClaims), 0)TotalClaims,
			ISNULL(SUM(AlcContriPopulation),0)AlcContriPopulation,
			ISNULL(SUM(AlcContriNumFamilies),0)AlcContriNumFamilies,
			ISNULL(SUM(AlcContriInsPopulation),0)AlcContriInsPopulation,
			ISNULL(SUM(AlcContriInsFamilies),0)AlcContriInsFamilies,
			ISNULL(SUM(AlcContriVisits),0)AlcContriVisits,
			ISNULL(SUM(AlcContriAdjustedAmount),0)AlcContriAdjustedAmount,
			ISNULL(SUM(UPPopulation),0)UPPopulation,
			ISNULL(SUM(UPNumFamilies),0)UPNumFamilies,
			ISNULL(SUM(UPInsPopulation),0)UPInsPopulation,
			ISNULL(SUM(UPInsFamilies),0)UPInsFamilies,
			ISNULL(SUM(UPVisits),0)UPVisits,
			ISNULL(SUM(UPAdjustedAmount),0)UPAdjustedAmount,
			ISNULL(SUM(PaymentCathment),0)PaymentCathment,
			ISNULL(SUM(TotalAdjusted),0)TotalAdjusted
	
	 FROM ReportData

	 GROUP BY HFCode



END
GO
