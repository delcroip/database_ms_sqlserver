/****** Object:  UserDefinedFunction [dbo].[udfPolicyRenewal2]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[udfPolicyRenewal2]
(
	@ProdID INT = 0,
	@DistrictID INT = 0,
	@Month INT,
	@Year INT
)
RETURNS TABLE
AS
RETURN
	SELECT RenewPolicy.ProdID, COUNT(RenewPolicy.PolicyID)Renewals FROM 
	(SELECT PL.ProdID,PL.PolicyID
	FROM tblPolicy PL  INNER JOIN TblProduct PR ON PL.ProdID = PR.ProdID
	WHERE PL.ValidityTo IS NULL AND PR.ValidityTo IS NULL
	AND (PL.ProdID = @ProdID OR @ProdID = 0)
	AND (PR.DistrictID = @DistrictID OR @DistrictID = 0)
	AND MONTH(PL.EnrollDate) = @Month AND YEAR(PL.EnrollDate) = @Year) RenewPolicy LEFT OUTER JOIN 
	(SELECT PL.ProdID
	FROM tblPolicy PL INNER JOIN tblProduct PR ON PL.ProdID = PR.ProdID
	INNER JOIN tblFamilies F ON PL.FamilyID = F.FamilyID
	WHERE PL.ValidityTo IS NULL  AND PR.ValidityTo IS NULL AND F.ValidityTo IS NULL
	AND (PL.ProdID = @ProdID OR @ProdID = 0)
	AND (PR.DistrictID = @DistrictID OR @DistrictID = 0)
	AND MONTH(PL.EnrollDate) < @Month AND YEAR(PL.EnrollDate) < @Year)RenewPolicy1 ON RenewPolicy.ProdID = RenewPolicy1.ProdID
	LEFT OUTER JOIN 
	(SELECT PL.ProdID
	FROM tblPolicy PL INNER JOIN tblProduct PR ON PL.ProdID = PR.ConversionProdID
	INNER JOIN tblFamilies F ON PL.FamilyID = F.FamilyID
	WHERE PL.ValidityTo IS NULL AND PR.ValidityTo IS NULL AND F.FamilyID IS NULL
	AND (PL.ProdID = @ProdID OR @ProdID = 0)
	AND (PR.DistrictID = @DistrictID OR @DistrictID = 0)
	AND MONTH(PL.EnrollDate) < @Month AND YEAR(PL.EnrollDate) < @Year
	)RenewPolicy2 ON RenewPolicy.ProdID = RenewPolicy2.ProdID
	WHERE RenewPolicy1.ProdID IS NOT NULL OR RenewPolicy2.ProdID IS NOT NULL
	GROUP BY RenewPolicy.ProdID


GO
