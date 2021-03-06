/****** Object:  StoredProcedure [dbo].[uspSSRSFeedbackPrompt]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspSSRSFeedbackPrompt]
(
	@SMSStatus INT = 0,
	@LocationId INT = 0,
	@WardID INT = 0,
	@VillageID INT = 0,
	@OfficerID INT = 0,
	@RangeFrom DATE = '',
	@RangeTo DATE = ''
)
AS
BEGIN	
	IF @RangeFrom = '' SET @RangeFrom = GETDATE()
	IF @RangeTo = '' SET @RangeTo = GETDATE()


	SELECT D.DistrictName,W.WardName, V.VillageName,ISNULL(NULLIF(O.VEOLastName, ''), O.LastName) + ' ' + ISNULL(NULLIF(O.VEOOtherNames, ''), O.OtherNames) AS Officer, ISNULL(NULLIF(O.VEOPhone, ''), O.Phone)VEOPhone,
	FP.FeedbackPromptDate,FP.ClaimID,C.ClaimCode, HF.HFCode, HF.HFName, I.CHFID, I.OtherNames, I.LastName, ICD.ICDName, C.DateFrom, ISNULL(C.DateTo,C.DateFrom) DateTo,FP.SMSStatus,C.Claimed
	FROM tblFeedbackPrompt FP INNER JOIN tblClaim C ON FP.ClaimID = C.ClaimID
	INNER JOIN tblHF HF ON C.HFID = HF.HfID
	INNER JOIN tblICDCodes ICD ON C.ICDID = ICD.ICDID
	INNER JOIN tblInsuree I ON C.InsureeID = I.InsureeID
	INNER JOIN tblFamilies F ON I.FamilyID = F.FamilyID
	INNER JOIN tblVillages V ON V.VillageID = F.LocationId
	INNER JOIN tblWards W ON W.WardID = V.WardID
	INNER JOIN tblDistricts D ON D.DistrictID = W.DistrictID
	LEFT OUTER JOIN tblPolicy PL ON F.FamilyID = PL.FamilyId
	LEFT OUTER JOIN tblOfficer O ON PL.OfficerID = O.OfficerID
	WHERE FP.ValidityTo IS NULL 
	AND C.ValidityTo IS NULL 
	AND HF.ValidityTo IS NULL 
	AND I.ValidityTo IS NULL 
	AND F.ValidityTo IS NULL 
	AND D.ValidityTo IS NULL 
	AND W.ValidityTo IS NULL 
	AND V.ValidityTo IS NULL 
	AND PL.ValidityTo IS NULL 
	AND O.ValidityTo IS NULL 
	AND ICD.ValidityTo IS NULL
	AND C.FeedbackStatus = 4
	AND (FP.SMSStatus = @SMSStatus OR @SMSStatus = 0)
	AND (D.DistrictID  = @LocationId OR @LocationId = 0)
	AND (W.WardID = @WardID OR @WardID = 0)
	AND (V.VillageID = @VillageID OR @VillageId = 0)
	AND (O.OfficerID = @OfficerID OR @OfficerId = 0)
	AND FP.FeedbackPromptDate BETWEEN @RangeFrom AND @RangeTo
	GROUP BY D.DistrictName,W.WardName, V.VillageName,O.VEOLastName, O.LastName, O.VEOOtherNames, O.OtherNames, O.VEOPhone, O.Phone,
	FP.FeedbackPromptDate,FP.ClaimID,C.ClaimCode, HF.HFCode, HF.HFName, I.CHFID, I.OtherNames, I.LastName, ICD.ICDName, C.DateFrom, C.DateTo,FP.SMSStatus,C.Claimed
END

GO
