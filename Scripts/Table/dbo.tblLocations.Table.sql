/****** Object:  Table [dbo].[tblLocations]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblLocations](
	[LocationId] [int] IDENTITY(1,1) NOT NULL,
	[LocationCode] [nvarchar](8) NULL,
	[LocationName] [nvarchar](50) NULL,
	[ParentLocationId] [int] NULL,
	[LocationType] [nchar](1) NOT NULL,
	[ValidityFrom] [datetime] NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyId] [int] NULL,
	[AuditUserId] [int] NULL,
	[RowId] [timestamp] NOT NULL,
	[MalePopulation] [int] NULL,
	[FemalePopulation] [int] NULL,
	[OtherPopulation] [int] NULL,
	[Families] [int] NULL,
 CONSTRAINT [PK_tblLocations] PRIMARY KEY CLUSTERED 
(
	[LocationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblLocations] ADD  CONSTRAINT [DF_tblLocations_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
