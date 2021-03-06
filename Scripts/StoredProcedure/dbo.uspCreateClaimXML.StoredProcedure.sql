/****** Object:  StoredProcedure [dbo].[uspCreateClaimXML]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspCreateClaimXML]
(
	@ClaimID INT
)
AS
BEGIN
	SELECT
	(SELECT CONVERT(VARCHAR(10),C.DateClaimed,103) ClaimDate, HF.HFCode HFCode,C.ClaimCode, I.CHFID, 
	CONVERT(VARCHAR(10),C.DateFrom,103) StartDate, CONVERT(VARCHAR(10),ISNULL(C.DateTo,C.DateFrom),103) EndDate,ICD.ICDCode, 
	C.Explanation Comment, ISNULL(C.Claimed,0) Total,CA.ClaimAdminCode ClaimAdmin,
	ICD1.ICDCode ICDCode1,ICD2.ICDCode ICDCode2,ICD3.ICDCode ICDCode3 ,ICD4.ICDCode ICDCode4 ,C.VisitType
	from tblClaim C INNER JOIN tblHF HF ON C.HFID = HF.HfID
	INNER JOIN tblInsuree I ON C.InsureeID = I.InsureeID
	INNER JOIN tblICDCodes ICD ON C.ICDID = ICD.ICDID
	LEFT OUTER JOIN tblIcdCodes ICD1 ON C.ICDID1 = ICD1.ICDID
	LEFT OUTER JOIN tblIcdCodes ICD2 ON C.ICDID2 = ICD2.ICDID
	LEFT OUTER JOIN tblIcdCodes ICD3 ON C.ICDID3 = ICD3.ICDID
	LEFT OUTER JOIN tblIcdCodes ICD4 ON C.ICDID4 = ICD4.ICDID
	LEFT OUTER JOIN tblClaimAdmin CA ON CA.ClaimAdminId = C.ClaimAdminId
	WHERE C.ClaimID = @ClaimID
	FOR XML PATH('Details'),TYPE),
	(SELECT I.ItemCode,CI.PriceAsked ItemPrice, CI.QtyProvided ItemQuantity
	FROM tblClaim C INNER JOIN tblClaimItems CI ON C.ClaimID = CI.ClaimID
	INNER JOIN tblItems I ON CI.ItemID = I.ItemID
	WHERE C.ClaimID = @ClaimID
	FOR XML PATH('Item'),ROOT ('Items'), TYPE),
	(SELECT S.ServCode ServiceCode,CS.PriceAsked ServicePrice, CS.QtyProvided ServiceQuantity
	FROM tblClaim C INNER JOIN tblClaimServices CS ON C.ClaimID = CS.ClaimID
	INNER JOIN tblServices S ON CS.ServiceID = S.ServiceID
	WHERE C.ClaimID = @ClaimID
	FOR XML PATH('Service'),ROOT ('Services'), TYPE)
	FOR XML PATH(''), ROOT('Claim')
END

GO
