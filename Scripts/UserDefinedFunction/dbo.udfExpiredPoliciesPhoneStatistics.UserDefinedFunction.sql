/****** Object:  UserDefinedFunction [dbo].[udfExpiredPoliciesPhoneStatistics]    Script Date: 19.09.2018 15:16:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[udfExpiredPoliciesPhoneStatistics](
	@DateFrom DATE, 
	@DateTo DATE, 
	@OfficerId INT
)

RETURNS INT
AS
BEGIN
		DECLARE @LegacyOfficer INT
		DECLARE @tblOfficerSub TABLE(OldOfficer INT, NewOfficer INT)

		INSERT INTO @tblOfficerSub(OldOfficer, NewOfficer) 
		SELECT DISTINCT @OfficerID, @OfficerID 

		SET @LegacyOfficer = (SELECT OfficerID FROM tblOfficer WHERE ValidityTo IS NULL AND OfficerIDSubst = @OfficerID)
		WHILE @LegacyOfficer IS NOT NULL
			BEGIN
				INSERT INTO @tblOfficerSub(OldOfficer, NewOfficer) 
				SELECT DISTINCT @OfficerID, @LegacyOfficer 
				IF EXISTS(SELECT 1 FROM @tblOfficerSub  GROUP BY NewOfficer HAVING COUNT(1) > 1)
					BREAK;
				SET @LegacyOfficer = (SELECT OfficerID FROM tblOfficer WHERE ValidityTo IS NULL AND OfficerIDSubst = @LegacyOfficer)
			END;

      RETURN(
			SELECT COUNT(1) ExpiredPolicies
			FROM tblPolicy PL
			LEFT OUTER JOIN (SELECT PL.PolicyID, F.FamilyID, PR.ProdID
			FROM tblPolicy PL 
			INNER JOIN tblFamilies F ON F.FamilyId = PL.FamilyId
			INNER JOIN tblProduct PR ON PR.ProdID= PL.ProdID OR(PL.ProdID = PR.ConversionProdID )
			WHERE 
			PL.ValidityTo IS NULL 
			AND F.ValidityTo IS NULL
			AND PR.ValidityTo IS NULL
			AND PL.PolicyStage='R'
			) R ON PL.ProdID=R.ProdID AND PL.FamilyID=R.FamilyID
			INNER JOIN @tblOfficerSub O ON O.NewOfficer = PL.OfficerID
			WHERE
			PL.ValidityTo IS NULL
			AND PL.PolicyStatus = 8
			AND R.PolicyID IS NULL
			AND (PL.ExpiryDate >= @DateFrom AND PL.ExpiryDate < = @DateTo)
			
	  )
END



GO
