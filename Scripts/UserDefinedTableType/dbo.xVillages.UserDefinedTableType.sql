/****** Object:  UserDefinedTableType [dbo].[xVillages]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xVillages] AS TABLE(
	[VillageID] [int] NOT NULL,
	[WardID] [int] NOT NULL,
	[VillageName] [nvarchar](50) NOT NULL,
	[VillageCode] [nvarchar](8) NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	PRIMARY KEY CLUSTERED 
(
	[VillageID] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO
