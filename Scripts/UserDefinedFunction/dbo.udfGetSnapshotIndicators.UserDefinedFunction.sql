/****** Object:  UserDefinedFunction [dbo].[udfGetSnapshotIndicators]    Script Date: 19.09.2018 15:16:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[udfGetSnapshotIndicators](
	@Date DATE, 
	@OfficerId INT
) RETURNS @tblSnapshotIndicators TABLE(ACtive INT,Expired INT,Idle INT,Suspended INT)
	AS
	BEGIN
		DECLARE @ACtive INT=0
		DECLARE @Expired INT=0
		DECLARE @Idle INT=0
		DECLARE @Suspended INT=0
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


		SET @ACtive = (
						SELECT COUNT(DISTINCT P.FamilyID) ActivePolicies FROM tblPolicy P 
						INNER JOIN @tblOfficerSub O ON P.OfficerID = O.NewOfficer
						WHERE P.ValidityTo IS NULL AND PolicyStatus = 2 
						AND ExpiryDate >=@Date
					  )

		SET @Expired = (SELECT COUNT(1) ExpiredPolicies
			FROM tblPolicy PL
			LEFT OUTER JOIN (SELECT PL.PolicyID, F.FamilyID, PR.ProdID
			FROM tblPolicy PL 
			INNER JOIN tblFamilies F ON F.FamilyId = PL.FamilyId
			INNER JOIN tblProduct PR ON PR.ProdID= PL.ProdID OR (PL.ProdID = PR.ConversionProdID)
			WHERE 
			PL.ValidityTo IS NULL 
			AND F.ValidityTo IS NULL
			AND PR.ValidityTo IS NULL
			AND PL.PolicyStage='R'
			AND  PL.PolicyStatus = 2
			) R ON PL.ProdID=R.ProdID AND PL.FamilyID=R.FamilyID
			INNER JOIN @tblOfficerSub O ON PL.OfficerID = O.NewOfficer
			WHERE
			PL.ValidityTo IS NULL
			AND PL.PolicyStatus = 8
			AND R.PolicyID IS NULL
			AND (PL.ExpiryDate =@Date)
			)
		SET @Idle =		(
						SELECT COUNT(DISTINCT PL.FamilyID) IddlePolicies FROM tblPolicy PL 
						INNER JOIN @tblOfficerSub O ON PL.OfficerID = O.NewOfficer
						INNER JOIN tblProduct PR ON PR.ProdID = PL.ProdID
						LEFT OUTER JOIN (SELECT FamilyID, ProdID FROM tblPolicy WHERE ValidityTo IS NULL AND PolicyStatus =2 AND  ExpiryDate >=@Date) ActivePolicies ON ActivePolicies.FamilyID = PL.FamilyID AND (ActivePolicies.ProdID = PL.ProdID OR ActivePolicies.ProdID = PR.ConversionProdID)
						WHERE PL.ValidityTo IS NULL AND PL.PolicyStatus = 1 
						AND ExpiryDate >=@Date
						AND ActivePolicies.ProdID IS NULL
						)
		SET @Suspended = (
						SELECT COUNT(DISTINCT PL.FamilyID) SuspendedPolicies FROM tblPolicy PL 
						INNER JOIN @tblOfficerSub O ON PL.OfficerID = O.NewOfficer
						INNER JOIN tblProduct PR ON PR.ProdID = PL.ProdID
						LEFT OUTER JOIN (SELECT FamilyID, ProdID FROM tblPolicy WHERE ValidityTo IS NULL AND PolicyStatus =2 AND  ExpiryDate >=@Date) ActivePolicies ON ActivePolicies.FamilyID = PL.FamilyID AND (ActivePolicies.ProdID = PL.ProdID OR ActivePolicies.ProdID = PR.ConversionProdID)
						WHERE PL.ValidityTo IS NULL AND PL.PolicyStatus = 4
						AND ExpiryDate >=@Date
						AND ActivePolicies.ProdID IS NULL
						)
		INSERT INTO @tblSnapshotIndicators(ACtive, Expired, Idle, Suspended) VALUES (@ACtive, @Expired, @Idle, @Suspended)
		  RETURN
	END

GO
