/****** Object:  UserDefinedTableType [dbo].[xOfficerVillages]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xOfficerVillages] AS TABLE(
	[OfficerVillageId] [int] NULL,
	[OfficerId] [int] NULL,
	[LocationId] [int] NULL,
	[ValidityFrom] [datetime] NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyId] [int] NULL,
	[AuditUserId] [int] NULL
)
GO
