/****** Object:  StoredProcedure [dbo].[uspClaimSelection]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspClaimSelection]
(
	@ReviewType TINYINT,	--1: Review 2:Feedback
	@Claims dbo.xClaimSelection READONLY,
	@SelectionType TINYINT,		--0: All 1: Random 2: Variance
	@SelectionValue DECIMAL(18,2),
	@Value DECIMAL(18,2) = 0,
	@Submitted INT = 0 OUTPUT,
	@Selected INT = 0 OUTPUT,
	@NotSelected INT = 0 OUTPUT
)
AS
BEGIN
	DECLARE @tbl TABLE(ClaimID INT)
	
	IF @ReviewType = 1
	BEGIN
		INSERT INTO @tbl(ClaimID)
		SELECT udtClaims.ClaimID 
		FROM @Claims as udtClaims INNER JOIN tblClaim ON tblClaim.ClaimID = udtClaims.ClaimID
		AND tblClaim.ReviewStatus = 1
		
		UPDATE tblClaim SET ReviewStatus = 2
		FROM tblClaim INNER JOIN @tbl tbl ON tblClaim.ClaimID = tbl.ClaimID
		
	END
	ELSE
	BEGIn
		INSERT INTO @tbl(ClaimID)
		SELECT udtClaims.ClaimID 
		FROM @Claims as udtClaims INNER JOIN tblClaim ON tblClaim.ClaimID = udtClaims.ClaimID
		AND tblClaim.FeedbackStatus = 1
		
		UPDATE tblClaim SET FeedbackStatus = 2
		FROM tblClaim INNER JOIN @tbl tbl ON tblClaim.ClaimID = tbl.ClaimID
		
	END
	
	IF @SelectionType = 0
		BEGIN
			IF @ReviewType = 1
			BEGIN
				UPDATE tblClaim SET ReviewStatus = 4
				FROM tblClaim INNER JOIN @tbl t ON tblClaim.ClaimID = t.ClaimID
				WHERE tblClaim.ValidityTo IS NULL AND ISNULL(tblClaim.Claimed,0) >= @Value
				
				SELECT @Selected = @@ROWCOUNT
			END
			ELSE
			BEGIN
				UPDATE tblClaim SET FeedbackStatus = 4
				FROM tblClaim INNER JOIN @tbl t ON tblClaim.ClaimID = t.ClaimID
				WHERE tblClaim.ValidityTo IS NULL AND ISNULL(tblClaim.Claimed,0) >= @Value
				
				SELECT @Selected = @@ROWCOUNT
			END	
		END
		
	IF @SelectionType = 1
		BEGIN
			IF @ReviewType = 1
			BEGIN
				UPDATE tblClaim SET ReviewStatus = 4
				WHERE ClaimID IN 
				(SELECT TOP (@SelectionValue) PERCENT tblClaim.ClaimID 
					FROM tblClaim INNER JOIN @Claims udtClaims ON tblClaim.ClaimID = udtClaims.ClaimID
					WHERE tblClaim.ValidityTo IS NULL
					ORDER BY NEWID())
					
				SELECT @Selected = @@ROWCOUNT
			END
			ELSE
			BEGIN
				UPDATE tblClaim SET FeedbackStatus = 4
				WHERE ClaimID IN 
				(SELECT TOP (@SelectionValue) PERCENT tblClaim.ClaimID 
					FROM tblClaim INNER JOIN @Claims udtClaims ON tblClaim.ClaimID = udtClaims.ClaimID
					WHERE tblClaim.ValidityTo IS NULL
					ORDER BY NEWID())
					
				SELECT @Selected = @@ROWCOUNT
			END
		END
	IF @SelectionType = 2
		BEGIN
			
			DECLARE @tmp TABLE(ClaimID INT, ICDID INT,Claimed DECIMAL(18,2), Average DECIMAL(18,2),	Variance DECIMAL(18,2),isExceeds AS CASE WHEN Claimed >= Variance THEN 1 ELSE 0 END)

			INSERT INTO @tmp(ClaimID,ICDID,Claimed)
			SELECT t.ClaimID,C.ICDID,C.Claimed
			FROM @tbl t INNER JOIN tblClaim C ON t.ClaimID = C.ClaimID
			WHERE C.ValidityTo IS NULL 
			AND ISNULL(C.Claimed,0) >= @Value 
		
			UPDATE @tmp SET Average = a.Average, Variance= a.Average + (a.Average * (0.01 * 
			@SelectionValue))
			FROM @tmp t INNER JOIN 
			(SELECT tmp.ICDID,AVG(tblClaim.Claimed) Average
			from tblClaim INNER JOIN @tmp tmp ON tblClaim.ICDID = tmp.ICDID
			WHERE tblClaim.ValidityTo IS NULL AND tblClaim.ClaimStatus IN (8,16)
			AND DateClaimed between DATEADD(Year,-1,GetDATE()-1) AND GETDATE() - 1
			GROUP BY tmp.ICDID)a ON t.ICDID = a.ICDID
		
			IF @ReviewType = 1
			BEGIN
				UPDATE tblClaim SET ReviewStatus = 4
				WHERE ClaimID IN 
				(SELECT ClaimID FROM @tmp WHERE isExceeds = 1)
				
				SELECT @Selected = @@ROWCOUNT
			END
			ELSE
			BEGIN
				UPDATE tblClaim SET FeedbackStatus = 4
				WHERE ClaimID IN 
				(SELECT ClaimID FROM @tmp WHERE isExceeds = 1)
				
				SELECT @Selected = @@ROWCOUNT
			END
		END
	
	
	SELECT @Submitted = COUNT(*) FROM @tbl
	SET @NotSelected = @Submitted - @Selected 
	
	
END



GO
