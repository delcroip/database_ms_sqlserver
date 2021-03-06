/****** Object:  UserDefinedFunction [dbo].[udfPremiumComposition]    Script Date: 19.09.2018 15:16:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[udfPremiumComposition]
(	
	
)


RETURNS @Resul TABLE(PolicyId INT, AssFee DECIMAL(18,2),RegFee DECIMAL(18,2),PremFee DECIMAL(18,2) )
AS
BEGIN

	INSERT INTO @Resul(PolicyId,AssFee,RegFee,PremFee)
	SELECT tblPolicy.PolicyID, CASE WHEN ISNULL(tblProduct.GeneralAssemblyLumpSum,0) = 0 THEN  (COUNT(tblInsureePolicy.InsureeId) * ISNULL(tblProduct.GeneralAssemblyFee,0)) ELSE tblProduct.GeneralAssemblyLumpSum  END  as AssFee, CASE WHEN tblPolicy.PolicyStage = 'N' THEN (CASE WHEN ISNULL(tblProduct.RegistrationLumpSum ,0) = 0 THEN COUNT(tblInsureePolicy.InsureeId) * isnull(tblProduct.RegistrationFee,0) ELSE tblProduct.RegistrationLumpSum END) ELSE 0 END as RegFee, CASE WHEN ISNULL(tblProduct.LumpSum,0) = 0 THEN ( SUM (CASE WHEN (DATEDIFF(YY  ,tblInsuree.DOB,tblInsureePolicy.EffectiveDate) >= 18) THEN 1 ELSE 0 END) * tblProduct.PremiumAdult)  + ( SUM (CASE WHEN (DATEDIFF(YY  ,tblInsuree.DOB,tblInsureePolicy.EffectiveDate) < 18) THEN 1 ELSE 0 END) * tblProduct.PremiumChild ) ELSE tblproduct.LumpSum  END as PremFee
	
	FROM         tblPolicy INNER JOIN
						  tblInsureePolicy ON tblPolicy.PolicyID = tblInsureePolicy.PolicyId INNER JOIN
						  tblInsuree ON tblInsureePolicy.InsureeId = tblInsuree.InsureeID INNER JOIN tblProduct ON tblProduct.ProdID = tblPolicy.ProdID 
	WHERE     (tblInsureePolicy.ValidityTo IS NULL) AND (tblPolicy.ValidityTo IS NULL) AND (tblInsuree.ValidityTo IS NULL) AND tblInsureePolicy.EffectiveDate IS NOT NULL and tblProduct.ValidityTo is null
	GROUP BY tblPolicy.PolicyID, tblProduct.GeneralAssemblyFee , tblProduct.GeneralAssemblyLumpSum , tblProduct .RegistrationFee, tblProduct .RegistrationLumpSum   ,tblProduct .LumpSum , tblProduct .PremiumAdult ,tblProduct .PremiumChild ,tblPolicy.PolicyStage

	

RETURN
END
GO
