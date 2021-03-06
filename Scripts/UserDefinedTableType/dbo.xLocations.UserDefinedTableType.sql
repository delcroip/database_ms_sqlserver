/****** Object:  UserDefinedTableType [dbo].[xLocations]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xLocations] AS TABLE(
	[LocationId] [int] NOT NULL,
	[LocationCode] [nvarchar](8) NULL,
	[LocationName] [nvarchar](50) NULL,
	[ParentLocationId] [int] NULL,
	[LocationType] [nchar](1) NOT NULL,
	[ValidityFrom] [datetime] NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyId] [int] NULL,
	[AuditUserId] [int] NULL
)
GO
