/****** Object:  UserDefinedTableType [dbo].[xFamilies]    Script Date: 19.09.2018 15:16:40 ******/
CREATE TYPE [dbo].[xFamilies] AS TABLE(
	[FamilyID] [int] NULL,
	[InsureeID] [int] NULL,
	[LocationID] [int] NULL,
	[Poverty] [bit] NULL,
	[ValidityFrom] [datetime] NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NULL,
	[FamilyType] [nvarchar](2) NULL,
	[FamilyAddress] [nvarchar](200) NULL,
	[Ethnicity] [nvarchar](1) NULL,
	[isOffline] [bit] NULL,
	[ConfirmationNo] [nvarchar](12) NULL,
	[ConfirmationType] [nvarchar](3) NULL
)
GO
