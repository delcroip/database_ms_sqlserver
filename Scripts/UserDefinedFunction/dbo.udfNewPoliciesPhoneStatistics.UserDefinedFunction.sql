/****** Object:  UserDefinedFunction [dbo].[udfNewPoliciesPhoneStatistics]    Script Date: 19.09.2018 15:16:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udfNewPoliciesPhoneStatistics](
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
	  SELECT COUNT(1)  
	  FROM 
	  tblPolicy PL
	  INNER JOIN @tblOfficerSub O ON O.NewOfficer = PL.OfficerID
	  WHERE PL.ValidityTo IS NULL  AND PolicyStage ='N' AND EnrollDate >= @DateFrom AND EnrollDate <=@DateTo
	  )
END



GO
