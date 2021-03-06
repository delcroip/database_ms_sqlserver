/****** Object:  StoredProcedure [dbo].[uspFeedbackPromptSMS]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspFeedbackPromptSMS]
(
	@RangeFrom DATE = '',
	@RangeTo DATE = ''
)
AS
BEGIN
	DECLARE @LinkBreak NVARCHAR(10) = CHAR(10)

	IF @RangeFrom = '' SET @RangeFrom = GETDATE()
	IF @RangeTo = '' SET @RangeTo = GETDATE()

	DECLARE @SMSQueue TABLE (SMSID int IDENTITY(1,1), PhoneNumber nvarchar(50) , SMSMessage nvarchar(4000) , SMSLength AS LEN(SMSMessage) )

	INSERT INTO @SMSQueue(PhoneNumber,SMSMessage)
	SELECT FP.PhoneNumber,'--Feedback--' + @LinkBreak +
	CAST(C.ClaimID AS VARCHAR(15)) + @LinkBreak +  I.LastName + ' ' + I.OtherNames + @LinkBreak + V.VillageName + @LinkBreak + W.WardName + @LinkBreak + HF.HFName + @LinkBreak + 
	CAST(C.DateFrom AS VARCHAR(10)) + @LinkBreak + I.CHFID + @LinkBreak AS SMS
	FROM tblFeedbackPrompt FP INNER JOIN tblClaim C ON FP.ClaimID = C.ClaimID 
	INNER JOIN tblInsuree I ON C.InsureeID = I.InsureeID
	INNER JOIN tblFamilies F ON I.FamilyID =F.FamilyID
	INNER JOIN tblVillages V ON F.VillageID = V.VillageID
	INNER JOIN tblWards W ON F.WardID = W.WardID
	INNER JOIN tblHF HF ON C.HFID =HF.HfID
	WHERE C.ValidityTo IS NULL AND I.ValidityTo IS NULL AND F.ValidityTo IS NULL AND V.ValidityTo IS NULL AND W.ValidityTo IS NULL AND HF.ValidityTo IS NULL
	AND FP.FeedbackPromptDate BETWEEN @RangeFrom AND @RangeTo
	
	SELECT 'IMIS-FEEDBACK' seder,
	(
	SELECT REPLACE(PhoneNumber,' ','')[to]
	FROM @SMSQueue PNo
	WHERE PNo.SMSID = SMS.SMSID
	FOR XML PATH('recipients'), TYPE
	)PhoneNumber,
	SMS.SMSMessage [text]
	FROM @SMSQueue SMS
	WHERE LEN(SMS.PhoneNumber) > 0
	AND LEN(ISNULL(SMS.SMSMessage,'')) > 0
	FOR XML PATH('message'), ROOT('request'), TYPE;

END
GO
