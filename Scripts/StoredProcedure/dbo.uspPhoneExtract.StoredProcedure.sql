/****** Object:  StoredProcedure [dbo].[uspPhoneExtract]    Script Date: 19.09.2018 15:16:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspPhoneExtract]
(
	
	@LocationId int =  0
)
AS
BEGIN
	DECLARE @NotSet as INT = -1

	IF NOT OBJECT_ID('tempdb..#tempBase') IS NULL DROP TABLE #tempBase

		SELECT PR.ProdID,PL.PolicyID,I.CHFID,P.PhotoFolder + case when RIGHT(P.PhotoFolder,1) = '\' then '' else '\' end + P.PhotoFileName PhotoPath,I.LastName + ' ' + I.OtherNames InsureeName,
		CONVERT(VARCHAR,DOB,103) DOB, CASE WHEN I.Gender = 'M' THEN 'Male' ELSE 'Female' END Gender,PR.ProductCode,PR.ProductName,
		CONVERT(VARCHAR(12),IP.ExpiryDate,103) ExpiryDate, 
		CASE WHEN IP.EffectiveDate IS NULL THEN 'I' WHEN CAST(GETDATE() AS DATE) NOT BETWEEN IP.EffectiveDate AND IP.ExpiryDate THEN 'E' ELSE 
		CASE PL.PolicyStatus WHEN 1 THEN 'I' WHEN 2 THEN 'A' WHEN 4 THEN 'S' ELSE 'E' END
		END  AS [Status], ISNULL(MemCount.Members ,0) as FamCount
		INTO #tempBase
		FROM tblInsuree I LEFT OUTER JOIN tblPhotos P ON I.PhotoID = P.PhotoID
		INNER JOIN tblFamilies F ON I.FamilyId = F.FamilyId 
		INNER JOIN tblVillages V ON V.VillageId = F.LocationId
		INNER JOIN tblWards W ON W.WardId = V.WardId
		INNER JOIN tblDistricts D ON D.DistrictId = W.DistrictId
		LEFT OUTER JOIN tblPolicy PL ON I.FamilyID = PL.FamilyID
		LEFT OUTER JOIN tblProduct PR ON PL.ProdID = PR.ProdID
		LEFT OUTER JOIN tblInsureePolicy IP ON IP.InsureeId = I.InsureeId AND IP.PolicyId = PL.PolicyID
		LEFT OUTER JOIN
		(SELECT FamilyID, COUNT(InsureeID) Members FROM tblInsuree WHERE tblInsuree.ValidityTo IS NULL GROUP BY FamilyID) MemCount ON MemCount.FamilyID = F.FamilyID 
 		WHERE I.ValidityTo IS NULL AND PL.ValidityTo IS NULL AND P.ValidityTo IS NULL AND PR.ValidityTo IS NULL AND IP.ValidityTo IS NULL AND F.ValidityTo IS NULL
		AND (D.DistrictID = @LocationId or @LocationId= 0)


		
	IF NOT OBJECT_ID('tempdb..#tempDedRem')IS NULL DROP TABLE #tempDedRem
	CREATE TABLE #tempDedRem (PolicyId INT, ProdID INT,DedInsuree DECIMAL(18,2),DedOPInsuree DECIMAL(18,2),DedIPInsuree DECIMAL(18,2),MaxInsuree DECIMAL(18,2),MaxOPInsuree DECIMAL(18,2),MaxIPInsuree DECIMAL(18,2),DedTreatment DECIMAL(18,2),DedOPTreatment DECIMAL(18,2),DedIPTreatment DECIMAL(18,2),MaxTreatment DECIMAL(18,2),MaxOPTreatment DECIMAL(18,2),MaxIPTreatment DECIMAL(18,2),DedPolicy DECIMAL(18,2),DedOPPolicy DECIMAL(18,2),DedIPPolicy DECIMAL(18,2),MaxPolicy DECIMAL(18,2),MaxOPPolicy DECIMAL(18,2),MaxIPPolicy DECIMAL(18,2))

	INSERT INTO #tempDedRem(PolicyId, ProdID ,DedInsuree ,DedOPInsuree ,DedIPInsuree ,MaxInsuree ,MaxOPInsuree ,MaxIPInsuree ,DedTreatment ,DedOPTreatment ,DedIPTreatment ,MaxTreatment ,MaxOPTreatment ,MaxIPTreatment ,DedPolicy ,DedOPPolicy ,DedIPPolicy ,MaxPolicy ,MaxOPPolicy ,MaxIPPolicy)

					SELECT #tempBase.PolicyId, #tempBase.ProdID,
					DedInsuree ,DedOPInsuree ,DedIPInsuree ,
					MaxInsuree,MaxOPInsuree,MaxIPInsuree ,
					DedTreatment ,DedOPTreatment ,DedIPTreatment,
					MaxTreatment ,MaxOPTreatment ,MaxIPTreatment,
					DedPolicy ,DedOPPolicy ,DedIPPolicy , 
					CASE WHEN ISNULL(NULLIF(SIGN(((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMember, 0))),-1),0) * ((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMember, 0)) + MaxPolicy > MaxCeilingPolicy THEN MaxCeilingPolicy ELSE ISNULL(NULLIF(SIGN(((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMember, 0))),-1),0) * ((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMember, 0)) + MaxPolicy END MaxPolicy ,
					CASE WHEN ISNULL(NULLIF(SIGN(((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMemberOP, 0))),-1),0) * ((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMemberOP, 0)) + MaxOPPolicy > MaxCeilingPolicyOP THEN MaxCeilingPolicyOP ELSE ISNULL(NULLIF(SIGN(((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMemberOP, 0))),-1),0) * ((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMemberOP, 0)) + MaxOPPolicy END MaxOPPolicy ,
					CASE WHEN ISNULL(NULLIF(SIGN(((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMemberIP, 0))),-1),0) * ((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMemberIP, 0)) + MaxIPPolicy > MaxCeilingPolicyIP THEN MaxCeilingPolicyIP ELSE ISNULL(NULLIF(SIGN(((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMemberIP, 0))),-1),0) * ((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMemberIP, 0)) + MaxIPPolicy END MaxIPPolicy
					
		

					FROM tblProduct INNER JOIN #tempBase ON tblProduct.ProdID = #tempBase.ProdID 
					WHERE ValidityTo IS NULL
					GROUP BY 
					#tempBase.PolicyId, #tempBase.ProdID,
					DedInsuree ,DedOPInsuree ,DedIPInsuree ,
					MaxInsuree,MaxOPInsuree,MaxIPInsuree ,
					DedTreatment ,DedOPTreatment ,DedIPTreatment,
					MaxTreatment ,MaxOPTreatment ,MaxIPTreatment,
					DedPolicy ,DedOPPolicy ,DedIPPolicy , 
					CASE WHEN ISNULL(NULLIF(SIGN(((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMember, 0))),-1),0) * ((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMember, 0)) + MaxPolicy > MaxCeilingPolicy THEN MaxCeilingPolicy ELSE ISNULL(NULLIF(SIGN(((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMember, 0))),-1),0) * ((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMember, 0)) + MaxPolicy END  ,
					CASE WHEN ISNULL(NULLIF(SIGN(((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMemberOP, 0))),-1),0) * ((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMemberOP, 0)) + MaxOPPolicy > MaxCeilingPolicyOP THEN MaxCeilingPolicyOP ELSE ISNULL(NULLIF(SIGN(((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMemberOP, 0))),-1),0) * ((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMemberOP, 0)) + MaxOPPolicy END  ,
					CASE WHEN ISNULL(NULLIF(SIGN(((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMemberIP, 0))),-1),0) * ((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMemberIP, 0)) + MaxIPPolicy > MaxCeilingPolicyIP THEN MaxCeilingPolicyIP ELSE ISNULL(NULLIF(SIGN(((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMemberIP, 0))),-1),0) * ((CASE WHEN MemberCount - FamCount < 0 THEN MemberCount ELSE FamCount END - Threshold) * ISNULL(MaxPolicyExtraMemberIP, 0)) + MaxIPPolicy END 


IF (SELECT COUNT(*) FROM #tempBase WHERE [Status] = 'A') > 0
		SELECT CHFID, PhotoPath, InsureeName, DOB,Gender,ProductCode,ProductName,ExpiryDate,[Status],
		CAST(
		CASE WHEN (COALESCE(MaxInsuree,MaxTreatment,ISNULL(MaxPolicy,@NotSet)) <> @NotSet) THEN 1 ELSE 
		(CASE WHEN 
		(COALESCE(MaxIPInsuree,MaxIPTreatment,MaxIPPolicy,MaxOPInsuree,MaxOPTreatment,ISNULL(MaxOPPolicy,@NotSet)) <> @NotSet) THEN 1.1 ELSE
		(CASE WHEN (COALESCE(DedInsuree,DedTreatment,ISNULL(DedPolicy,@NotSet)) <> @NotSet) THEN 1 ELSE 
		(CASE WHEN (COALESCE(DedIPInsuree,DedIPTreatment,DedIPPolicy,DedOPInsuree,DedOPTreatment,ISNULL(DedOPPolicy,@NotSet)) <> @NotSet) THEN 1.1 ELSE 1 END)END)END) END 
		 AS INT) as DedType
		,
		CASE WHEN (COALESCE(DedInsuree,DedTreatment,DedPolicy,DedIPInsuree,DedIPTreatment,ISNULL(DedIPPolicy,@NotSet)) = @NotSet) THEN NULL ELSE COALESCE			(DedInsuree,DedTreatment,DedPolicy,DedIPInsuree,DedIPTreatment,ISNULL(DedIPPolicy,0))  END
		as Ded1
		,
		--ded2

		CASE WHEN 
		(
		CAST(
		CASE WHEN (COALESCE(MaxInsuree,MaxTreatment,ISNULL(MaxPolicy,@NotSet)) <> @NotSet) THEN 1 ELSE 
		(CASE WHEN 
		(COALESCE(MaxIPInsuree,MaxIPTreatment,MaxIPPolicy,MaxOPInsuree,MaxOPTreatment,ISNULL(MaxOPPolicy,@NotSet)) <> @NotSet) THEN 1.1 ELSE
		(CASE WHEN (COALESCE(DedInsuree,DedTreatment,ISNULL(DedPolicy,@NotSet)) <> @NotSet) THEN 1 ELSE 
		(CASE WHEN (COALESCE(DedIPInsuree,DedIPTreatment,DedIPPolicy,DedOPInsuree,DedOPTreatment,ISNULL(DedOPPolicy,@NotSet)) <> @NotSet) THEN 1.1 ELSE 1 END)END)END) END 
		 AS INT) = 1 
		
		) THEN 
		CASE WHEN (COALESCE(DedInsuree,DedTreatment,DedPolicy,DedIPInsuree,DedIPTreatment,ISNULL(DedIPPolicy,@NotSet)) = @NotSet) THEN NULL ELSE COALESCE			(DedInsuree,DedTreatment,DedPolicy,DedIPInsuree,DedIPTreatment,ISNULL(DedIPPolicy,0))  END
		ELSE CASE WHEN COALESCE(DedInsuree,DedTreatment,ISNULL(DedPolicy,@NotSet)) = @NotSet THEN 
		(CASE WHEN COALESCE(DedOPInsuree,DedOPTreatment,ISNULL(DedOPPolicy,@NotSet)) = @NotSet THEN NULL ELSE COALESCE(DedOPInsuree,DedOPTreatment,ISNULL(DedOPPolicy,0))  END) 
		ELSE NULL END END
		  as Ded2
		,
		--ceiling 1
		CASE WHEN COALESCE(MaxInsuree,MaxTreatment,MaxPolicy,MaxIPInsuree,MaxIPTreatment,ISNULL(MaxIPPolicy,@NotSet)) = @NotSet THEN NULL ELSE (CASE WHEN COALESCE(MaxInsuree,MaxTreatment,MaxPolicy,MaxIPInsuree,MaxIPTreatment,ISNULL(MaxIPPolicy,0)) < 0 THEN 0 ELSE COALESCE(MaxInsuree,MaxTreatment,MaxPolicy,MaxIPInsuree,MaxIPTreatment,ISNULL(MaxIPPolicy,0)) END)END 
		 as Ceiling1 ,
		
		--ceiling 2
		CASE WHEN 
		(
		CAST(
		CASE WHEN (COALESCE(MaxInsuree,MaxTreatment,ISNULL(MaxPolicy,@NotSet)) <> @NotSet) THEN 1 ELSE 
		(CASE WHEN 
		(COALESCE(MaxIPInsuree,MaxIPTreatment,MaxIPPolicy,MaxOPInsuree,MaxOPTreatment,ISNULL(MaxOPPolicy,@NotSet)) <> @NotSet) THEN 1.1 ELSE
		(CASE WHEN (COALESCE(DedInsuree,DedTreatment,ISNULL(DedPolicy,@NotSet)) <> @NotSet) THEN 1 ELSE 
		(CASE WHEN (COALESCE(DedIPInsuree,DedIPTreatment,DedIPPolicy,DedOPInsuree,DedOPTreatment,ISNULL(DedOPPolicy,@NotSet)) <> @NotSet) THEN 1.1 ELSE 1 END)END)END) END 
		 AS INT) = 1 
		
		) THEN 
		CASE WHEN COALESCE(MaxInsuree,MaxTreatment,MaxPolicy,MaxIPInsuree,MaxIPTreatment,ISNULL(MaxIPPolicy,@NotSet)) = @NotSet THEN NULL ELSE (CASE WHEN COALESCE(MaxInsuree,MaxTreatment,MaxPolicy,MaxIPInsuree,MaxIPTreatment,ISNULL(MaxIPPolicy,0)) < 0 THEN 0 ELSE COALESCE(MaxInsuree,MaxTreatment,MaxPolicy,MaxIPInsuree,MaxIPTreatment,ISNULL(MaxIPPolicy,0)) END)END 
		ELSE CASE WHEN COALESCE(MaxInsuree,MaxTreatment,ISNULL(MaxPolicy,@NotSet)) = @NotSet THEN 
		(CASE WHEN COALESCE(MaxOPInsuree,MaxOPTreatment,ISNULL(MaxOPPolicy,@NotSet)) = @NotSet THEN NULL ELSE COALESCE(MaxOPInsuree,MaxOPTreatment,ISNULL(MaxOPPolicy,0))  END) 
		ELSE NULL END  END 

		
		  as Ceiling2
		
		
		  from #tempBase Base LEFT OUTER JOIN #tempDedRem DedRem ON Base.PolicyID = DedRem.PolicyId AND Base.ProdID = DedRem.ProdID WHERE [Status] = 'A';
		
	ELSE 
		
		IF (SELECT COUNT(1) FROM #tempBase WHERE (YEAR(GETDATE()) - YEAR(CONVERT(DATETIME,ExpiryDate,103))) <= 2) > 1
			SELECT CHFID, PhotoPath, InsureeName, DOB,Gender,ProductCode,ProductName,ExpiryDate,[Status],
			CAST( CASE WHEN COALESCE(MaxInsuree,MaxTreatment,ISNULL(MaxPolicy,@NotSet)) <> @NotSet THEN 1 ELSE 
		(CASE WHEN 
		COALESCE(MaxIPInsuree,MaxIPTreatment,MaxIPPolicy,MaxOPInsuree,MaxOPTreatment,ISNULL(MaxOPPolicy,@NotSet)) <> @NotSet THEN 1.1 ELSE
		(CASE WHEN COALESCE(DedInsuree,DedTreatment,ISNULL(DedPolicy,@NotSet)) <> @NotSet THEN 1 ELSE 
		(CASE WHEN COALESCE(DedIPInsuree,DedIPTreatment,DedIPPolicy,DedOPInsuree,DedOPTreatment,ISNULL(DedOPPolicy,@NotSet)) <> @NotSet THEN 1.1 ELSE 1 END)END)END) END 
		as INT) as DedType
			
		,
		CASE WHEN COALESCE(DedInsuree,DedTreatment,DedPolicy,DedIPInsuree,DedIPTreatment,ISNULL(DedIPPolicy,0)) = 0 THEN NULL ELSE COALESCE			(DedInsuree,DedTreatment,DedPolicy,DedIPInsuree,DedIPTreatment,ISNULL(DedIPPolicy,0))  END
		as Ded1
		,
		--Deduct2 
		CASE WHEN 
		(
		CAST(
		CASE WHEN (COALESCE(MaxInsuree,MaxTreatment,ISNULL(MaxPolicy,@NotSet)) <> @NotSet) THEN 1 ELSE 
		(CASE WHEN 
		(COALESCE(MaxIPInsuree,MaxIPTreatment,MaxIPPolicy,MaxOPInsuree,MaxOPTreatment,ISNULL(MaxOPPolicy,@NotSet)) <> @NotSet) THEN 1.1 ELSE
		(CASE WHEN (COALESCE(DedInsuree,DedTreatment,ISNULL(DedPolicy,@NotSet)) <> @NotSet) THEN 1 ELSE 
		(CASE WHEN (COALESCE(DedIPInsuree,DedIPTreatment,DedIPPolicy,DedOPInsuree,DedOPTreatment,ISNULL(DedOPPolicy,@NotSet)) <> @NotSet) THEN 1.1 ELSE 1 END)END)END) END 
		 AS INT) = 1 
		
		) THEN 
		CASE WHEN (COALESCE(DedInsuree,DedTreatment,DedPolicy,DedIPInsuree,DedIPTreatment,ISNULL(DedIPPolicy,@NotSet)) = @NotSet) THEN NULL ELSE COALESCE			(DedInsuree,DedTreatment,DedPolicy,DedIPInsuree,DedIPTreatment,ISNULL(DedIPPolicy,0))  END
		ELSE CASE WHEN COALESCE(DedInsuree,DedTreatment,ISNULL(DedPolicy,@NotSet)) = @NotSet THEN 
		(CASE WHEN COALESCE(DedOPInsuree,DedOPTreatment,ISNULL(DedOPPolicy,@NotSet)) = @NotSet THEN NULL ELSE COALESCE(DedOPInsuree,DedOPTreatment,ISNULL(DedOPPolicy,0))  END) 
		ELSE NULL END END
		  as Ded2 ,
		--ceiling 1
		CASE WHEN COALESCE(MaxInsuree,MaxTreatment,MaxPolicy,MaxIPInsuree,MaxIPTreatment,ISNULL(MaxIPPolicy,@NotSet)) = @NotSet THEN NULL ELSE (CASE WHEN COALESCE(MaxInsuree,MaxTreatment,MaxPolicy,MaxIPInsuree,MaxIPTreatment,ISNULL(MaxIPPolicy,0)) < 0 THEN 0 ELSE COALESCE(MaxInsuree,MaxTreatment,MaxPolicy,MaxIPInsuree,MaxIPTreatment,ISNULL(MaxIPPolicy,0)) END)END 
		 as Ceiling1,
		 --ceiling 2
		 CASE WHEN 
		(
		CAST(
		CASE WHEN (COALESCE(MaxInsuree,MaxTreatment,ISNULL(MaxPolicy,@NotSet)) <> @NotSet) THEN 1 ELSE 
		(CASE WHEN 
		(COALESCE(MaxIPInsuree,MaxIPTreatment,MaxIPPolicy,MaxOPInsuree,MaxOPTreatment,ISNULL(MaxOPPolicy,@NotSet)) <> @NotSet) THEN 1.1 ELSE
		(CASE WHEN (COALESCE(DedInsuree,DedTreatment,ISNULL(DedPolicy,@NotSet)) <> @NotSet) THEN 1 ELSE 
		(CASE WHEN (COALESCE(DedIPInsuree,DedIPTreatment,DedIPPolicy,DedOPInsuree,DedOPTreatment,ISNULL(DedOPPolicy,@NotSet)) <> @NotSet) THEN 1.1 ELSE 1 END)END)END) END 
		 AS INT) = 1 
		
		) THEN 
		CASE WHEN COALESCE(MaxInsuree,MaxTreatment,MaxPolicy,MaxIPInsuree,MaxIPTreatment,ISNULL(MaxIPPolicy,@NotSet)) = @NotSet THEN NULL ELSE (CASE WHEN COALESCE(MaxInsuree,MaxTreatment,MaxPolicy,MaxIPInsuree,MaxIPTreatment,ISNULL(MaxIPPolicy,0)) < 0 THEN 0 ELSE COALESCE(MaxInsuree,MaxTreatment,MaxPolicy,MaxIPInsuree,MaxIPTreatment,ISNULL(MaxIPPolicy,0)) END)END 
		ELSE CASE WHEN COALESCE(MaxInsuree,MaxTreatment,ISNULL(MaxPolicy,@NotSet)) = @NotSet THEN 
		(CASE WHEN COALESCE(MaxOPInsuree,MaxOPTreatment,ISNULL(MaxOPPolicy,@NotSet)) = @NotSet THEN NULL ELSE COALESCE(MaxOPInsuree,MaxOPTreatment,ISNULL(MaxOPPolicy,0))  END) 
		ELSE NULL END  END 

		
		  as Ceiling2

	 from #tempBase Base LEFT OUTER JOIN #tempDedRem DedRem ON Base.PolicyID = DedRem.PolicyId AND Base.ProdID = DedRem.ProdID WHERE (YEAR(GETDATE()) - YEAR(CONVERT(DATETIME,ExpiryDate,103))) <= 2 
		ELSE
			SELECT CHFID, PhotoPath, InsureeName, DOB,Gender,ProductCode,ProductName,ExpiryDate,[Status],
			CAST( CASE WHEN COALESCE(MaxInsuree,MaxTreatment,ISNULL(MaxPolicy,@NotSet)) <> @NotSet THEN 1 ELSE 
		(CASE WHEN 
		COALESCE(MaxIPInsuree,MaxIPTreatment,MaxIPPolicy,MaxOPInsuree,MaxOPTreatment,ISNULL(MaxOPPolicy,@NotSet)) <> @NotSet THEN 1.1 ELSE
		(CASE WHEN COALESCE(DedInsuree,DedTreatment,ISNULL(DedPolicy,@NotSet)) <> @NotSet THEN 1 ELSE 
		(CASE WHEN COALESCE(DedIPInsuree,DedIPTreatment,DedIPPolicy,DedOPInsuree,DedOPTreatment,ISNULL(DedOPPolicy,@NotSet)) <> @NotSet THEN 1.1 ELSE 1 END)END)END) END 
		as INT) as DedType
		,
		CASE WHEN COALESCE(DedInsuree,DedTreatment,DedPolicy,DedIPInsuree,DedIPTreatment,ISNULL(DedIPPolicy,0)) = 0 THEN NULL ELSE COALESCE			(DedInsuree,DedTreatment,DedPolicy,DedIPInsuree,DedIPTreatment,ISNULL(DedIPPolicy,0))  END
		as Ded1
		,
		--ded2

		CASE WHEN 
		(
		CAST(
		CASE WHEN (COALESCE(MaxInsuree,MaxTreatment,ISNULL(MaxPolicy,@NotSet)) <> @NotSet) THEN 1 ELSE 
		(CASE WHEN 
		(COALESCE(MaxIPInsuree,MaxIPTreatment,MaxIPPolicy,MaxOPInsuree,MaxOPTreatment,ISNULL(MaxOPPolicy,@NotSet)) <> @NotSet) THEN 1.1 ELSE
		(CASE WHEN (COALESCE(DedInsuree,DedTreatment,ISNULL(DedPolicy,@NotSet)) <> @NotSet) THEN 1 ELSE 
		(CASE WHEN (COALESCE(DedIPInsuree,DedIPTreatment,DedIPPolicy,DedOPInsuree,DedOPTreatment,ISNULL(DedOPPolicy,@NotSet)) <> @NotSet) THEN 1.1 ELSE 1 END)END)END) END 
		 AS INT) = 1 
		
		) THEN 
		CASE WHEN (COALESCE(DedInsuree,DedTreatment,DedPolicy,DedIPInsuree,DedIPTreatment,ISNULL(DedIPPolicy,@NotSet)) = @NotSet) THEN NULL ELSE COALESCE			(DedInsuree,DedTreatment,DedPolicy,DedIPInsuree,DedIPTreatment,ISNULL(DedIPPolicy,0))  END
		ELSE CASE WHEN COALESCE(DedInsuree,DedTreatment,ISNULL(DedPolicy,@NotSet)) = @NotSet THEN 
		(CASE WHEN COALESCE(DedOPInsuree,DedOPTreatment,ISNULL(DedOPPolicy,@NotSet)) = @NotSet THEN NULL ELSE COALESCE(DedOPInsuree,DedOPTreatment,ISNULL(DedOPPolicy,0))  END) 
		ELSE NULL END END
		  as Ded2
		  ,
		--ceiling 1
		CASE WHEN COALESCE(MaxInsuree,MaxTreatment,MaxPolicy,MaxIPInsuree,MaxIPTreatment,ISNULL(MaxIPPolicy,@NotSet)) = @NotSet THEN NULL ELSE (CASE WHEN COALESCE(MaxInsuree,MaxTreatment,MaxPolicy,MaxIPInsuree,MaxIPTreatment,ISNULL(MaxIPPolicy,0)) < 0 THEN 0 ELSE COALESCE(MaxInsuree,MaxTreatment,MaxPolicy,MaxIPInsuree,MaxIPTreatment,ISNULL(MaxIPPolicy,0)) END)END 
		 as Ceiling1
		,
		--ceiling 2

		CASE WHEN 
		(
		CAST(
		CASE WHEN (COALESCE(MaxInsuree,MaxTreatment,ISNULL(MaxPolicy,@NotSet)) <> @NotSet) THEN 1 ELSE 
		(CASE WHEN 
		(COALESCE(MaxIPInsuree,MaxIPTreatment,MaxIPPolicy,MaxOPInsuree,MaxOPTreatment,ISNULL(MaxOPPolicy,@NotSet)) <> @NotSet) THEN 1.1 ELSE
		(CASE WHEN (COALESCE(DedInsuree,DedTreatment,ISNULL(DedPolicy,@NotSet)) <> @NotSet) THEN 1 ELSE 
		(CASE WHEN (COALESCE(DedIPInsuree,DedIPTreatment,DedIPPolicy,DedOPInsuree,DedOPTreatment,ISNULL(DedOPPolicy,@NotSet)) <> @NotSet) THEN 1.1 ELSE 1 END)END)END) END 
		 AS INT) = 1 
		
		) THEN 
		CASE WHEN COALESCE(MaxInsuree,MaxTreatment,MaxPolicy,MaxIPInsuree,MaxIPTreatment,ISNULL(MaxIPPolicy,@NotSet)) = @NotSet THEN NULL ELSE (CASE WHEN COALESCE(MaxInsuree,MaxTreatment,MaxPolicy,MaxIPInsuree,MaxIPTreatment,ISNULL(MaxIPPolicy,0)) < 0 THEN 0 ELSE COALESCE(MaxInsuree,MaxTreatment,MaxPolicy,MaxIPInsuree,MaxIPTreatment,ISNULL(MaxIPPolicy,0)) END)END 
		ELSE CASE WHEN COALESCE(MaxInsuree,MaxTreatment,ISNULL(MaxPolicy,@NotSet)) = @NotSet THEN 
		(CASE WHEN COALESCE(MaxOPInsuree,MaxOPTreatment,ISNULL(MaxOPPolicy,@NotSet)) = @NotSet THEN NULL ELSE COALESCE(MaxOPInsuree,MaxOPTreatment,ISNULL(MaxOPPolicy,0))  END) 
		ELSE NULL END  END 
		  as Ceiling2
 from #tempBase Base LEFT OUTER JOIN #tempDedRem DedRem ON Base.PolicyID = DedRem.PolicyId AND Base.ProdID = DedRem.ProdID 
END


GO
