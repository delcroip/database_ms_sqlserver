/****** Object:  UserDefinedTableType [dbo].[xPolicy]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xPolicy] AS TABLE(
	[PolicyID] [int] NULL,
	[FamilyID] [int] NULL,
	[EnrollDate] [date] NULL,
	[StartDate] [date] NULL,
	[EffectiveDate] [date] NULL,
	[ExpiryDate] [date] NULL,
	[PolicyStatus] [tinyint] NULL,
	[PolicyValue] [decimal](18, 2) NULL,
	[ProdID] [int] NULL,
	[OfficerID] [int] NULL,
	[PolicyStage] [char](1) NULL,
	[ValidityFrom] [datetime] NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NULL,
	[isOffline] [bit] NULL
)
GO
