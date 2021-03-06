/****** Object:  StoredProcedure [dbo].[uspSSRSUserLogReport]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspSSRSUserLogReport]
(
	@UserId INT = NULL,
	@FromDate DATETIME,
	@ToDate DATETIME,
	@EntityId NVARCHAR(5) = N'',
	@Action NVARCHAR(20) = N''
)
AS
BEGIN

	SET @UserId = NULLIF(@UserId, 0);

	SET @ToDate = DATEADD(SECOND,-1,DATEADD(DAY,1,@ToDate))

	DECLARE @tblLogs TABLE(UserId INT,UserName NVARCHAR(20),EntityId NVARCHAR(5),RecordType NVARCHAR(50),ActionType NVARCHAR(50),RecordIdentity NVARCHAR(500),ValidityFrom DATETIME,ValidityTo DATETIME, LegacyId INT, VF DATETIME,HistoryLegacyId INT)
	--DECLARE @UserId INT = 149
	
	--Line below is commented because UserId is made optional now
	DECLARE @UserName NVARCHAR(50) --= (SELECT LoginName FROM tblUsers WHERE (UserID = @UserId OR @Userid IS NULL))
	
	--DECLARE @FromDate DATETIME = '2013-04-29'
	--DECLARE @ToDate DATETIME = '2013-10-29'

	SET @ToDate = DATEADD(S,-1,DATEADD(D,1,@ToDate))

	INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
	--LOGIN INFORMATION
	SELECT L.UserId UserId,NULL UserName,CASE LogAction WHEN 1 THEN N'LI' ELSE N'LO' END,'Login' RecordType ,CASE LogAction WHEN 1 THEN N'Logged In' ELSE N'Logged Out' END ActionType,CAST(LogAction as NVARCHAR(10)) RecordIdentity,LogTime,NULL,NULL,NULL VF,NULL HistoryLegacyId
	FROM tblLogins L
	WHERE (L.UserId = @UserId OR @UserId IS NULL)
	AND LogTime BETWEEN @FromDate AND @ToDate

	--BATCH RUN INFORMATION
	--UNION ALL
	IF @EntityId = N'BR' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT B.AuditUserID UserId, NULL UserName, N'BR' EntityId,'Batch Run' RecordType,'Executed Batch' ActionType,
		'Batch Run For the District:' + D.DistrictName + ' For the month of ' + DATENAME(MONTH,'2000-' + CAST(B.RunMonth AS NVARCHAR(2)) + '-01') RecordIdentity,B.ValidityFrom,B.ValidityTo,B.LegacyID, NULL VF,NULL HistoryLegacyId
		FROM tblBatchRun B INNER JOIN tblDistricts D ON B.LocationId = D.DistrictID
		WHERE (B.AuditUserID = @UserId OR @UserId IS NULL)
		AND B.ValidityFrom BETWEEN @FromDate AND @ToDate

	--CLAIM INFORMATION
	--UNION ALL

	IF @EntityId = N'C' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT C.AuditUserID UserId, NULL UserName,N'C' EntityId, 'Claim' RecordType,
		NULL,'Claim Code: '+ ClaimCode + ' For Health Facility:' + HF.HFCode RecordIdentity,
		C.ValidityFrom,C.ValidityTo,C.LegacyID,VF,Hist.LegacyID
		FROM tblClaim C INNER JOIN tblHF HF ON C.HFID = HF.HfID
		LEFT OUTER JOIN
		(SELECT MIN(ValidityFrom) VF FROM tblClaim WHERE LegacyID IS NOT NULL GROUP BY LegacyID) Ins ON Ins.VF = C.ValidityFrom
		LEFT OUTER JOIN
		(SELECT LegacyId FROM tblClaim WHERE LegacyID IS NOT NULL GROUP BY LegacyID)Hist ON C.ClaimID = Hist.LegacyID
		WHERE (C.AuditUserID = @UserId OR @UserId IS NULL)
		AND C.ValidityFrom BETWEEN @FromDate AND @ToDate

	--CLAIM ADMINISTRATOR INFORMATION
	--UNION ALL
	IF @EntityId = N'CA' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT A.AuditUserID UserId, NULL UserName, N'CA' EntityId,'Claim Administrator' RecordType,NULL ActionType,
		'Name:' + A.OtherNames + ' ' + A.LastName + ' in the Health Facility:' + HF.HFName RecordIdentity, 
		A.ValidityFrom, A.ValidityTo,A.LegacyID,VF,Hist.LegacyId
		FROM tblClaimAdmin A INNER JOIN tblHF HF ON A.HFID = HF.HFID
		LEFT OUTER JOIN
		(SELECT MIN(ValidityFrom) VF FROM tblClaimAdmin WHERE LegacyId IS NOT NULL GROUP BY LegacyId) Ins ON Ins.VF = A.ValidityFrom
		LEFT OUTER JOIN
		(SELECT LegacyId FROM tblClaimAdmin WHERE LegacyId IS NOT NULL GROUP BY LegacyId) Hist ON A.ClaimAdminId = Hist.LegacyId
		WHERE (A.AuditUserID = @UserId AND @UserId IS NULL)
		AND A.ValidityFrom BETWEEN @FromDate AND @ToDate

	--DISTRICT INFORMATION
	--UNION ALL
	IF @EntityId = N'D' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT D.AuditUserID UserId, NULL UserName, N'D' EntityId,'District' RecordType,NULL ActionType,
		DistrictName RecordIdentity, D.ValidityFrom, D.ValidityTo,D.LegacyID, VF,Hist.LegacyID
		FROM tblDistricts D 
		LEFT OUTER JOIN
		(SELECT MIN(ValidityFrom) VF FROM tblDistricts WHERE LegacyID IS NOT NULL GROUP BY LegacyID) Ins ON D.ValidityFrom = Ins.VF
		LEFT OUTER JOIN
		(SELECT LegacyID FROM tblDistricts WHERE LegacyID IS NOT NULL GROUP BY LegacyID) Hist ON D.DistrictID = Hist.LegacyID
		WHERE (D.AuditUserID = @UserId OR @UserId IS  NULL)
		AND D.ValidityFrom BETWEEN @FromDate AND @ToDate

	--EXTRACT INFORMATION
	--UNION ALL
	IF @EntityId  = N'E' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT E.AuditUserID UserId, NULL UserName, N'E' EntityId,'Extracts' RecordType,NULL ActionType,
		'For the District:' + D.DistrictName + ' File:' + E.ExtractFileName RecordIdentity, E.ValidityFrom, E.ValidityTo,E.LegacyID,VF,Hist.LegacyID
		FROM tblExtracts E INNER JOIN tblDistricts D ON E.LocationId = D.DistrictID
		LEFT OUTER JOIN
		(SELECT MIN(ValidityFrom) VF FROM tblExtracts WHERE LegacyID IS NOT NULL GROUP BY LegacyID) Ins ON E.ValidityFrom = Ins.VF
		LEFT OUTER JOIN
		(SELECT LegacyId FROM tblExtracts WHERE LegacyID IS NOT NULL GROUP BY LegacyID)Hist ON E.ExtractID = Hist.LegacyID
		WHERE (E.AuditUserID = @UserId OR @UserId IS NULL)
		AND E.ValidityFrom BETWEEN @FromDate AND @ToDate

	--FAMILY INFORMATION
	--UNION ALL
	IF @EntityId = N'F' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT F.AuditUserID UserId, NULL UserName, N'F' EntityId,'Family/Group' RecordType,NULL ActionType,
		'Insurance No.:' + I.CHFID + ' In District:' + D.DistrictName  RecordIdentity, 
		F.ValidityFrom, F.ValidityTo,F.LegacyID,VF,Hist.LegacyID
		FROM tblFamilies F INNER JOIN tblDistricts D ON F.LocationId = D.DistrictID
		INNER JOIN tblInsuree I ON F.InsureeID = I.InsureeID
		LEFT OUTER JOIN(
		SELECT MIN(ValidityFrom) VF from tblFamilies WHERE LegacyID is not null group by LegacyID) Ins ON F.ValidityFrom = Ins.VF
		LEFT OUTER JOIN
		(SELECT LegacyId FROM tblFamilies WHERE LegacyID IS NOT NULL GROUP BY LegacyID)Hist ON F.FamilyID = Hist.LegacyID
		WHERE (F.AuditUserID = @UserId OR @UserId IS NULL)
		AND f.ValidityFrom BETWEEN @FromDate AND @ToDate

	--FEEDBACK INFORMATION
	--UNION ALL
	IF @EntityId = N'FB' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT F.AuditUserID UserId, NULL UserName, N'FB' EntityId,'Feedback' RecordType,NULL ActionType,
		'Feedback For the claim:' + C.ClaimCode  RecordIdentity, 
		F.ValidityFrom, F.ValidityTo,F.LegacyID,VF,Hist.LegacyID
		FROM tblFeedback F INNER JOIN tblClaim C ON F.ClaimID = C.ClaimID
		LEFT OUTER JOIN(
		  SELECT MIN(ValidityFrom) VF FROM tblFeedback WHERE LegacyID is not null group by LegacyID) Ins On F.ValidityFrom = Ins.VF
		LEFT OUTER JOIN
		(SELECT LegacyId FROM tblFeedback WHERE LegacyID IS NOT NULL GROUP BY LegacyID) Hist ON F.FeedbackID = Hist.LegacyID
		WHERE (F.AuditUserID = @UserId OR @UserId IS NULL)
		AND F.ValidityFrom BETWEEN @FromDate AND @ToDate

	--HEALTH FACILITY INFORMATION
	--UNION ALL
	IF @EntityId = N'HF' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT HF.AuditUserID UserId, NULL UserName, N'HF' EntityId,'Health Facility' RecordType,NULL ActionType,
		'Code:' + HF.HFCode + ' Name:' + HF.HFName RecordIdentity, 
		HF.ValidityFrom, HF.ValidityTo,HF.LegacyID,VF,Hist.LegacyId
		FROM tblHF HF 
		LEFT OUTER JOIN(
		SELECT MIN(ValidityFrom) VF FROM tblHF WHERE LegacyID is not null group by LegacyID) Ins ON HF.ValidityFrom = Ins.VF
		LEFT OUTER JOIN
		(SELECT LegacyId FROM tblHF WHERE LegacyID IS NOT NULL GROUP BY LegacyID) Hist ON HF.HfID = Hist.LegacyID
		WHERE (HF.AuditUserID = @UserId OR @UserId IS NULL)
		AND HF.ValidityFrom BETWEEN @FromDate AND @ToDate

	--ICD CODE INFORMATION
	--UNION ALL
	IF @EntityId = N'ICD' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT ICD.AuditUserID UserId, NULL UserName, N'ICD' EntityId,'Main Dg.' RecordType,NULL ActionType,
		'Code:' + ICD.ICDCode + ' Name:' + ICD.ICDName RecordIdentity,
		ICD.ValidityFrom, ICD.ValidityTo,ICD.LegacyID,VF, Hist.LegacyId
		FROM tblICDCodes ICD 
		LEFT OUTER JOIN(
		SELECT MIN(ValidityFrom) VF FROM tblICDCodes WHERE LegacyID IS NOT NULL GROUP BY LegacyID) Ins ON ICD.ValidityFrom = Ins.VF
		LEFT OUTER JOIN
		(SELECT LegacyId FROM tblICDCodes WHERE LegacyID IS NOT NULL GROUP BY LegacyId)Hist ON ICD.ICDID = Hist.LegacyId
		WHERE (ICD.AuditUserID = @UserId OR @UserId IS NULL)
		AND ICD.ValidityFrom BETWEEN @FromDate AND @ToDate

	--INSUREE INFORMATION
	--UNION ALL
	IF @EntityId = N'Ins' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT I.AuditUserID UserId, @UserName UserName, N'Ins' EntityId,'Insuree' RecordType,NULL ActionType,
		'Insurance No.:' + I.CHFID RecordIdentity, 
		I.ValidityFrom, I.ValidityTo,I.LegacyID,vf,Hist.LegacyID
		FROM tblInsuree I
		LEFT OUTER JOIN(
		SELECT MIN(validityfrom) vf from tblInsuree where LegacyID is not null group by LegacyID) Ins ON I.ValidityFrom = Ins.vf
		LEFT OUTER JOIN
		(SELECT LegacyId FROM tblInsuree WHERE LegacyID IS NOT NULL GROUP BY LegacyID)Hist ON I.InsureeID = Hist.LegacyID
		WHERE (I.AuditUserID = @UserId OR @UserId IS NULL)
		AND I.ValidityFrom BETWEEN @FromDate AND @ToDate

	--MEDICAL ITEM INFORMATION
	--UNION ALL
	IF @EntityId = N'I' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT I.AuditUserID UserId, @UserName UserName, N'I' EntityId,'Medical Items' RecordType,NULL ActionType,
		'Code:' + I.ItemCode + ' Name:' + I.ItemName RecordIdentity, 
		I.ValidityFrom, I.ValidityTo,I.LegacyID,vf,Hist.LegacyID
		FROM tblItems I
		LEFT OUTER JOIN(
		SELECT MIN(ValidityFrom) vf from tblItems WHERE LegacyID IS NOT NULL GROUP BY LegacyID) Ins on I.ValidityFrom = Ins.vf
		LEFT OUTER JOIN
		(SELECT LegacyId FROM tblItems WHERE LegacyID IS NOT NULL GROUP BY LegacyID)Hist ON I.ItemID = Hist.LegacyID
		WHERE (I.AuditUserID = @UserId OR @UserId IS NULL)
		AND I.ValidityFrom BETWEEN @FromDate AND @ToDate

	--OFFICER INFORMATION
	--UNION ALL
	IF @EntityId = N'O' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT O.AuditUserID UserId, @UserName UserName, N'O' EntityId,'Enrolment Officer' RecordType,NULL ActionType,
		'Code:' + O.Code + ' Name:' + O.OtherNames RecordIdentity, 
		O.ValidityFrom, O.ValidityTo,O.LegacyID,vf,Hist.LegacyID
		FROM tblOfficer O
		left outer join(
		select MIN(ValidityFrom) vf from tblOfficer where LegacyID is not null group by LegacyID) Ins ON O.ValidityFrom = Ins.vf
		LEFT OUTER JOIN
		(SELECT LegacyId FROM tblOfficer WHERE LegacyID IS NOT NULL GROUP BY LegacyID)Hist ON O.OfficerID = Hist.LegacyID
		WHERE (O.AuditUserID = @UserId OR @UserId IS NULL)
		AND O.ValidityFrom BETWEEN @FromDate AND @ToDate

	--PAYER INFORMATION
	--UNION ALL
	IF @EntityId = N'P' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT P.AuditUserID UserId, @UserName UserName, N'P' EntityId,'Payer' RecordType,NULL ActionType,
		'Name:' + P.PayerName RecordIdentity, 
		P.ValidityFrom, P.ValidityTo,P.LegacyID,VF,Hist.LegacyID
		FROM tblPayer P
		left outer join(
		select MIN(ValidityFrom) VF from tblPayer where LegacyID is not null group by LegacyID) Ins ON P.ValidityFrom = Ins.VF
		LEFT OUTER JOIN
		(SELECT LegacyId FROM tblPayer WHERE LegacyID IS NOT NULL GROUP BY LegacyID)Hist ON P.PayerID = Hist.LegacyID
		WHERE (P.AuditUserID = @UserId OR @UserId IS NULL)
		AND P.ValidityFrom BETWEEN @FromDate AND @ToDate

	--PHOTO INFORMATION
	--UNION ALL
	IF @EntityId = N'Ph' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT P.AuditUserID UserId, @UserName UserName, N'Ph' EntityId,'Photo' RecordType,NULL ActionType,
		'Assign to Insurance No.:' + I.CHFID RecordIdentity, 
		P.ValidityFrom, P.ValidityTo,NULL LegacyID,NULL VF,NULL HistoryLegacyId
		FROM tblPhotos P INNER JOIN tblInsuree I ON P.InsureeID = I.InsureeID
		WHERE (P.AuditUserID = @UserId OR @UserId IS NULL)
		AND ISNULL(P.PhotoFileName,'') <> ''
		AND P.ValidityFrom BETWEEN @FromDate AND @ToDate

	--PRICE LIST ITEM INFORMATION
	--UNION ALL
	IF @EntityId = N'PLI' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT I.AuditUserID UserId, @UserName UserName, N'PLI' EntityId,'Price List Items' RecordType,NULL ActionType,
		'Name:' + I.PLItemName + ' In the District:' + D.DistrictName RecordIdentity, 
		I.ValidityFrom, I.ValidityTo,I.LegacyID,VF,Hist.LegacyID
		FROM tblPLItems I INNER JOIN tblDistricts D ON I.LocationId = D.DistrictID
		left outer join(
		select MIN(validityFrom) VF From tblPLItems where LegacyID is not null group by LegacyID) Ins On I.ValidityFrom = Ins.VF
		LEFT OUTER JOIN
		(SELECT LegacyId FROM tblPLItems WHERE LegacyID IS NOT NULL GROUP BY LegacyID)Hist ON I.PLItemID = Hist.LegacyID
		WHERE (I.AuditUserID = @UserId OR @UserId IS NULL)
		AND I.ValidityFrom BETWEEN @FromDate AND @ToDate

	--PRICE LIST ITEM DETAILS INFORMATION
	--UNION ALL
	IF @EntityId = N'PLID' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT I.AuditUserID UserId, @UserName UserName, N'PLID' EntityId,'Price List Items Details' RecordType,NULL ActionType,
		'Item:' + I.ItemName + ' In the Price List:' + PL.PLItemName RecordIdentity, 
		D.ValidityFrom, D.ValidityTo,D.LegacyID,vf,Hist.LegacyID
		FROM tblPLItemsDetail D INNER JOIN tblPLItems PL ON D.PLItemID = PL.PLItemID
		INNER JOIN tblItems I ON D.ItemID = I.ItemID
		left outer join(
		select MIN(validityfrom) vf from tblPLItemsDetail where LegacyID is not null group by LegacyID) Ins On D.ValidityFrom = Ins.vf
		LEFT OUTER JOIN
		(SELECT LegacyId FROM tblPLItemsDetail WHERE LegacyID IS NOT NULL GROUP BY LegacyID)Hist ON D.PLItemDetailID = Hist.LegacyID
		WHERE (I.AuditUserID = @UserId OR @UserId IS NULL)
		AND D.ValidityFrom BETWEEN @FromDate AND @ToDate

	--PRICE LIST SERVICE INFORMATION
	--UNION ALL
	IF @EntityId = N'PLS' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT S.AuditUserID UserId, @UserName UserName, N'PLS' EntityId,'Price List Service' RecordType,NULL ActionType,
		'Name:' + S.PLServName + ' In the District:' + D.DistrictName RecordIdentity, 
		S.ValidityFrom, S.ValidityTo,S.LegacyID,vf,Hist.LegacyID
		FROM tblPLServices S INNER JOIN tblDistricts D ON S.LocationId = D.DistrictID
		left outer join(
		select MIN(validityfrom) vf from tblPLServices where LegacyID is not null group by LegacyID) Ins On S.ValidityFrom = Ins.vf
		LEFT OUTER JOIN
		(SELECT LegacyId FROM tblPLServices WHERE LegacyID IS NOT NULL GROUP BY LegacyID)Hist ON S.PLServiceID = Hist.LegacyID
		WHERE (S.AuditUserID = @UserId OR @UserId IS NULL)
		AND S.ValidityFrom BETWEEN @FromDate AND @ToDate

	--PRICE LIST SERVICE DETAILS INFORMATION
	--UNION ALL
	IF @EntityId = N'PLSD' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT D.AuditUserID UserId, @UserName UserName, N'PLSD' EntityId,'Price List Service Details' RecordType,NULL ActionType,
		'Service:' + S.ServName + ' In the Price List:' + PL.PLServName RecordIdentity, 
		D.ValidityFrom, D.ValidityTo,D.LegacyID,vf,Hist.LegacyID
		FROM tblPLServicesDetail D INNER JOIN tblPLServices PL ON D.PLServiceID = PL.PLServiceID
		INNER JOIN tblServices S ON D.ServiceID = S.ServiceID
		left outer join(
		select MIN(validityfrom) vf from tblPLServicesDetail where LegacyID is not null group by LegacyID) Ins ON D.ValidityFrom = Ins.vf
		LEFT OUTER JOIN
		(SELECT LegacyId FROM tblPLServicesDetail WHERE LegacyID IS NOT NULL GROUP BY LegacyID)Hist ON D.PLServiceID = Hist.LegacyID
		WHERE (D.AuditUserID = @UserId OR @UserId IS NULL)
		AND D.ValidityFrom BETWEEN @FromDate AND @ToDate

	--POLICY INFORMATION
	--UNION ALL
	IF @EntityId =N'PL' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT P.AuditUserID UserId, @UserName UserName, N'PL' EntityId,'Policy' RecordType,NULL ActionType,
		'To the Family/Group Head:' + I.CHFID RecordIdentity, 
		P.ValidityFrom, P.ValidityTo,P.LegacyID,vf,Hist.LegacyID
		FROM tblPolicy P INNER JOIN tblFamilies F ON P.FamilyID = F.FamilyID
		INNER JOIN tblInsuree I ON F.InsureeID = I.InsureeID
		left outer join(
		select MIN(validityfrom) vf from tblPolicy where LegacyID is not null group by LegacyID) Ins on P.ValidityFrom = Ins.vf
		LEFT OUTER JOIN
		(SELECT LegacyId FROM tblPolicy WHERE LegacyID IS NOT NULL GROUP BY LegacyID)Hist ON P.PolicyID = Hist.LegacyID
		WHERE (P.AuditUserID = @UserId OR @UserId IS NULL)
		AND P.ValidityFrom BETWEEN @FromDate AND @ToDate

	--PREMIUM INFORMATION
	--UNION ALL
	IF @EntityId = N'PR' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT PR.AuditUserID UserId, @UserName UserName, N'PR' EntityId,'Contribution' RecordType,NULL ActionType,
		CAST(PR.Amount AS NVARCHAR(20)) + ' Paid for the policy started on ' + CONVERT(NVARCHAR(10),P.StartDate,103) + ' For the Family/Group Head:' + I.CHFID RecordIdentity, 
		PR.ValidityFrom, PR.ValidityTo,PR.LegacyID,vf,Hist.LegacyID
		FROM tblPremium PR INNER JOIN tblPolicy P ON PR.PolicyID = P.PolicyID
		INNER JOIN tblFamilies F ON P.FamilyID = F.FamilyID
		INNER JOIN tblInsuree I ON F.InsureeID = I.InsureeID
		left outer join(
		select MIN(validityfrom) vf from tblPremium where LegacyID is not null group by LegacyID) Ins on PR.ValidityFrom = Ins.vf
		LEFT OUTER JOIN
		(SELECT LegacyID FROM tblPremium WHERE LegacyID IS NOT NULL GROUP BY LegacyID)Hist ON PR.PremiumId = Hist.LegacyID
		WHERE (PR.AuditUserID = @UserId OR @UserId IS NULL)
		AND PR.ValidityFrom BETWEEN @FromDate AND @ToDate

	--PRODUCT INFORMATION
	--UNION ALL
	IF @EntityId = N'PRD' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT PR.AuditUserID UserId, @UserName UserName, N'PRD' EntityId,'Product' RecordType,NULL ActionType,
		'Code:' + PR.ProductCode + ' Name:' + PR.ProductName RecordIdentity, 
		PR.ValidityFrom, PR.ValidityTo,PR.LegacyID,vf,Hist.LegacyID
		FROM tblProduct PR
		left outer join(
		select MIN(validityfrom) vf from tblProduct where LegacyID is not null group by LegacyID) Ins ON PR.ValidityFrom = Ins.vf
		LEFT OUTER JOIN
		(SELECT legacyId FROM tblProduct WHERE LegacyID IS NOT NULL GROUP BY LegacyID)Hist ON PR.ProdId = Hist.LegacyID
		WHERE (PR.AuditUserID = @UserId OR @UserId IS NULL)
		AND PR.ValidityFrom BETWEEN @FromDate AND @ToDate

	--PRODUCT ITEM INFORMATION
	--UNION ALL
	IF @EntityId = N'PRDI' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT ProdI.AuditUserID UserId, @UserName UserName, N'PRDI' EntityId,'Product Item' RecordType,NULL ActionType,
		'Item:' + I.ItemCode + ' in the product: ' + P.ProductCode RecordIdentity, 
		ProdI.ValidityFrom, ProdI.ValidityTo,ProdI.LegacyID,vf,Hist.LegacyID
		FROM tblProductItems ProdI INNER JOIN tblItems I ON ProdI.ItemID = I.ItemID
		INNER JOIN tblProduct P ON ProdI.ProdID = P.ProdID
		left outer join(
		select MIN(validityfrom) vf from tblProductItems where LegacyID is not null group by LegacyID) Ins ON ProdI.ValidityFrom = Ins.vf
		LEFT OUTER JOIN
		(SELECT LegacyId FROM tblProductItems WHERE LegacyID IS NOT NULL GROUP BY LegacyID) Hist ON Prodi.ProdItemID = Hist.LegacyID
		WHERE (ProdI.AuditUserID = @UserId OR @UserId IS NULL)
		AND ProdI.ValidityFrom BETWEEN @FromDate AND @ToDate

	--PRODUCT SERVICE INFORMATION
	--UNION ALL
	IF @EntityId = N'PRDS' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT ProdS.AuditUserID UserId, @UserName UserName, N'PRDS' EntityId,'Product Service' RecordType,NULL ActionType,
		'Service:' + S.ServCode + ' in the product: ' + P.ProductCode RecordIdentity, 
		ProdS.ValidityFrom, ProdS.ValidityTo,ProdS.LegacyID,vf,Hist.LegacyID
		FROM tblProductServices ProdS INNER JOIN tblServices S ON ProdS.ServiceID = S.ServiceID
		INNER JOIN tblProduct P ON ProdS.ProdID = P.ProdID
		left outer join(
		select MIN(validityfrom) vf from tblProductServices where LegacyID is not null group by LegacyID) Ins ON ProdS.ValidityFrom = Ins.vf
		LEFT OUTER JOIN
		(SELECT LegacyId FROM tblProductServices WHERE LegacyID IS NOT NULL GROUP BY LegacyID)Hist ON ProdS.ProdServiceID = Hist.LegacyID
		WHERE (ProdS.AuditUserID = @UserId OR @UserId IS NULL)
		AND ProdS.ValidityFrom BETWEEN @FromDate AND @ToDate

	--RELATIVE DISTRIBUTION INFROMATION
	--UNION ALL
	IF @EntityId = N'RD' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT RD.AuditUserID UserId, @UserName UserName, N'RD' EntityId,'Relative Distribution' RecordType,NULL ActionType,
		'In the Product:' + Prod.ProductCode RecordIdentity, 
		RD.ValidityFrom, RD.ValidityTo,RD.LegacyID,vf,Hist.LegacyID
		FROM tblRelDistr RD INNER JOIN tblProduct Prod ON RD.ProdId = Prod.ProdId
		left outer join(
		select MIN(validityfrom) vf from tblRelDistr where LegacyID is not null group by LegacyID) Ins ON RD.ValidityFrom = Ins.vf
		LEFT OUTER JOIN
		(SELECT LegacyId FROM tblRelDistr WHERE LegacyID IS NOT NULL GROUP BY LegacyID)Hist ON RD.DistrID = Hist.LegacyID
		WHERE (RD.AuditUserID = @UserId OR @UserId IS NULL)
		AND RD.ValidityFrom BETWEEN @FromDate AND @ToDate

	--MEDICAL SERVICE INFORMATION 
	--UNION ALL
	IF @EntityId = N'S' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT S.AuditUserID UserId, @UserName UserName, N'S' EntityId,'Medical Services' RecordType,NULL ActionType,
		'Code:' + S.ServCode + ' Name:' + S.ServName RecordIdentity, 
		S.ValidityFrom, S.ValidityTo,S.LegacyID,vf,Hist.LegacyID
		FROM tblServices S
		left outer join(
		select MIN(validityfrom) vf from tblServices where LegacyID is not null group by LegacyID) Ins ON S.ValidityFrom = Ins.vf
		LEFT OUTER JOIN
		(SELECT LegacyId FROM tblServices WHERE LegacyID IS NOT NULL GROUP BY LegacyID)Hist ON S.ServiceID = Hist.LegacyID
		WHERE (S.AuditUserID = @UserId OR @UserId IS NULL)
		AND S.ValidityFrom BETWEEN @FromDate AND @ToDate

	--USERS INFORMATION
	--UNION ALL
	IF @EntityId = N'U' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT U.AuditUserID UserId, @UserName UserName, N'U' EntityId,'Users' RecordType,NULL ActionType,
		'Login:' + U.LoginName RecordIdentity, 
		U.ValidityFrom, U.ValidityTo,U.LegacyID,vf,Hist.LegacyID
		FROM tblUsers U
		left outer join(
		select MIN(validityfrom) vf from tblUsers where LegacyID is not null group by LegacyID) Ins ON U.ValidityFrom = Ins.vf
		LEFT OUTER JOIN
		(SELECT LegacyId FROM tblUsers WHERE LegacyID IS NOT NULL GROUP BY LegacyID)Hist ON U.UserID = Hist.LegacyID
		WHERE (U.AuditUserID = @UserId OR @UserId IS NULL)
		AND U.ValidityFrom BETWEEN @FromDate AND @ToDate

	--USER DISTRICTS INFORMATION
	--UNION ALL
	IF @EntityId = N'UD' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT UD.AuditUserID UserId, @UserName UserName, N'UD' EntityId,'User Districts' RecordType,NULL ActionType,
		'User:' + U.LoginName + ' Assigned to the District:' + D.DistrictName RecordIdentity, 
		UD.ValidityFrom, UD.ValidityTo,UD.LegacyID,vf,Hist.LegacyID
		FROM tblUsersDistricts UD INNER JOIN tblUsers U ON UD.UserID = U.UserID
		INNER JOIN tblDistricts D ON D.DistrictID = UD.LocationId
		left outer join(
		select MIN(validityfrom) vf from tblUsersDistricts where LegacyID is not null group by LegacyID) Ins ON UD.ValidityFrom = Ins.vf
		LEFT OUTER JOIN
		(SELECT LegacyID FROM tblUsersDistricts WHERE LegacyID IS NOT NULL GROUP BY LegacyID)Hist ON UD.UserDistrictID = Hist.LegacyID
		WHERE (UD.AuditUserID = @UserId OR @UserId IS NULL)
		AND UD.ValidityFrom BETWEEN @FromDate AND @ToDate

	--VILLAGE INFORMATION
	--UNION ALL
	IF @EntityId = N'V' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT V.AuditUserID UserId, @UserName UserName, N'V' EntityId,'Village' RecordType,NULL ActionType,
		'Village:' + V.VillageName + ' in Municipality:' + W.WardName + ' in District:' + D.DistrictName RecordIdentity, 
		V.ValidityFrom, V.ValidityTo,V.LegacyID,vf,Hist.LegacyID
		FROM tblVillages V INNER JOIN tblWards W ON V.WardID = W.WardID
		INNER JOIN tblDistricts D ON W.DistrictID = D.DistrictID
		left outer join(
		select MIN(validityfrom) vf from tblVillages where LegacyID is not null group by LegacyID) Ins ON V.ValidityFrom = Ins.vf
		LEFT OUTER JOIN
		(SELECT LegacyId FROM tblVillages WHERE LegacyID IS NOT NULL GROUP BY LegacyID)Hist ON V.VillageID = Hist.LegacyID
		WHERE (V.AuditUserID = @UserId OR @UserId IS NULL)
		AND V.ValidityFrom BETWEEN @FromDate AND @ToDate

	--WARD INFORMATION
	--UNION ALL
	IF @EntityId = N'W' OR @EntityId = N''
		INSERT INTO @tblLogs(UserId,UserName,EntityId,RecordType,ActionType,RecordIdentity,ValidityFrom,ValidityTo,LegacyId,VF,HistoryLegacyId)
		SELECT W.AuditUserID UserId, @UserName UserName, N'W' EntityId,'Municipality' RecordType,NULL ActionType,
		'Municipality:' + W.WardName + ' in District:' + D.DistrictName RecordIdentity, 
		W.ValidityFrom, W.ValidityTo,W.LegacyID,vf,Hist.LegacyID
		FROM tblWards W INNER JOIN tblDistricts D ON W.DistrictID = D.DistrictID
		left outer join(
		select MIN(validityfrom) vf from tblWards where LegacyID is not null group by LegacyID) Ins ON W.ValidityFrom = Ins.vf
		LEFT OUTER JOIN 
		(SELECT LegacyId FROM tblWards WHERE LegacyID IS NOT NULL GROUP BY LegacyID)Hist ON W.WardID = Hist.LegacyID
		WHERE (W.AuditUserID = @UserId OR @UserId IS NULL)
		AND W.ValidityFrom BETWEEN @FromDate AND @ToDate

	;WITH Result AS
	(
		SELECT UserId,UserName,EntityId,RecordType,
		CASE WHEN ActionType IS NULL AND ( (VF IS NOT NULL OR ((ValidityTo IS  NULL) AND LegacyId IS NULL AND VF IS NULL AND HistoryLegacyId IS NULL))) THEN N'Inserted'      --Inserts (new and updated inserts) 
			 WHEN ((ValidityTo IS NOT NULL) AND LegacyId IS NOT NULL AND VF IS NULL AND HistoryLegacyId IS NULL) THEN N'Modified'
			 WHEN ((ValidityTo IS  NULL) AND LegacyId IS  NULL AND VF IS NULL AND HistoryLegacyId IS NOT NULL) THEN N'Modified'
			 WHEN ((ValidityTo IS NOT NULL) AND LegacyId IS NULL AND VF IS NULL) Then 'Deleted'
			 ELSE ActionType
		END ActionType , RecordIdentity, 
		CASE WHEN ValidityTo IS NOT NULL AND LegacyId IS NULL AND VF IS NULL THEN ValidityTo ELSE ValidityFrom END ActionTime
		FROM @tblLogs
	)SELECT Result.UserId, ISNULL(CASE WHEN Result.UserId <> -1 THEN  U.LoginName ELSE N'Mobile/Offline System' END,N'Unknown') UserName, EntityId, RecordType, ActionType, RecordIdentity, ActionTime 
	FROM Result	LEFT OUTER JOIN tblUsers U ON Result.userId = U.UserID
	WHERE (EntityId = @EntityId OR @EntityId = N'')
	AND (ActionType = @Action OR @Action = N'')
	ORDER BY ActionTime

END


GO
