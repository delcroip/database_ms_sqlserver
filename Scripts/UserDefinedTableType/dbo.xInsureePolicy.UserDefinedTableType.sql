/****** Object:  UserDefinedTableType [dbo].[xInsureePolicy]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xInsureePolicy] AS TABLE(
	[InsureePolicyId] [int] NULL,
	[InsureeId] [int] NULL,
	[PolicyId] [int] NULL,
	[EnrollmentDate] [date] NULL,
	[StartDate] [date] NULL,
	[EffectiveDate] [date] NULL,
	[ExpiryDate] [date] NULL,
	[ValidityFrom] [datetime] NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyId] [int] NULL,
	[AuditUserId] [int] NULL,
	[isOffline] [bit] NULL
)
GO
