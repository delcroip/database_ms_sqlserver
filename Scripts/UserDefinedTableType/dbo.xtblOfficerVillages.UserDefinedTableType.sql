/****** Object:  UserDefinedTableType [dbo].[xtblOfficerVillages]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xtblOfficerVillages] AS TABLE(
	[OfficerId] [int] NULL,
	[VillageId] [int] NULL,
	[AuditUserId] [int] NULL,
	[Action] [char](1) NULL
)
GO
