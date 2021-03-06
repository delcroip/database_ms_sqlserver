/****** Object:  StoredProcedure [dbo].[uspSSRSPaymentCategoryOverview]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspSSRSPaymentCategoryOverview]
(
	@DateFrom DATE,
	@DateTo DATE,
	@LocationId INT = 0,
	@ProductId INT= 0
)
AS
BEGIN	

	;WITH InsureePolicy AS
	(
		SELECT COUNT(IP.InsureeId) TotalMembers, IP.PolicyId
		FROM tblInsureePolicy IP
		WHERE IP.ValidityTo IS NULL
		GROUP BY IP.PolicyId
	), [Main] AS
	(
		SELECT PL.PolicyId, Prod.ProdID, PL.FamilyId, SUM(CASE WHEN PR.isPhotoFee = 0 THEN PR.Amount ELSE 0 END)TotalPaid,
		SUM(CASE WHEN PR.isPhotoFee = 1 THEN PR.Amount ELSE 0 END)PhotoFee,
		COALESCE(Prod.RegistrationLumpsum, IP.TotalMembers * Prod.RegistrationFee, 0)[Registration],
		COALESCE(Prod.GeneralAssemblyLumpsum, IP.TotalMembers * Prod.GeneralAssemblyFee, 0)[Assembly]

		FROM tblPremium PR
		INNER JOIN tblPolicy PL ON PL.PolicyId = PR.PolicyID
		INNER JOIN InsureePolicy IP ON IP.PolicyId = PL.PolicyID
		INNER JOIN tblProduct Prod ON Prod.ProdId = PL.ProdID
	
		WHERE PR.ValidityTo IS NULL
		AND PL.ValidityTo IS NULL
		AND Prod.ValidityTo IS NULL
		AND PR.PayTYpe <> 'F'
		AND PR.PayDate BETWEEN @DateFrom AND @DateTo
		AND (Prod.ProdID = @ProductId OR @ProductId = 0)
	

		GROUP BY PL.PolicyId, Prod.ProdID, PL.FamilyId, IP.TotalMembers, Prod.GeneralAssemblyLumpsum, Prod.GeneralAssemblyFee, Prod.RegistrationLumpsum, Prod.RegistrationFee
	), RegistrationAndAssembly AS
	(
		SELECT PolicyId, 
		CASE WHEN TotalPaid - Registration >= 0 THEN Registration ELSE TotalPaid END R,
		CASE WHEN TotalPaid - Registration > 0 THEN CASE WHEN TotalPaid - Registration - [Assembly] >= 0 THEN [Assembly] ELSE TotalPaid - Registration END ELSE 0 END A
		FROM [Main]
	), Overview AS
	(
		SELECT Main.ProdId, Main.PolicyId, Main.FamilyId, RA.R, RA.A,
		CASE WHEN TotalPaid - RA.R - Main.[Assembly] >= 0 THEN TotalPaid - RA.R - Main.[Assembly] ELSE Main.TotalPaid - RA.R - RA.A END C,
		Main.PhotoFee
		FROM [Main] 
		INNER JOIN RegistrationAndAssembly RA ON Main.PolicyId = RA.PolicyID
	)

	SELECT Prod.ProdId, Prod.ProductCode, Prod.ProductName, D.DistrictName, SUM(O.R) R, SUM(O.A)A, SUM(O.C)C, SUM(PhotoFee)P
	FROM Overview O
	INNER JOIN tblProduct Prod ON Prod.ProdID = O.ProdId
	INNER JOIN tblFamilies F ON F.FamilyId = O.FamilyID
	INNER JOIN tblVillages V ON V.VillageId = F.LocationId
	INNER JOIN tblWards W ON W.WardId = V.WardId
	INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId

	WHERE Prod.ValidityTo IS NULL
	AND F.ValidityTo IS NULL
	AND (D.Region = @LocationId OR D.DistrictId = @LocationId OR @LocationId = 0)

	GROUP BY Prod.ProdId, Prod.ProductCode, Prod.ProductName, D.DistrictName


END
GO
