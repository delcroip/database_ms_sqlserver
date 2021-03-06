/****** Object:  Table [dbo].[tblFamilies]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFamilies](
	[FamilyID] [int] IDENTITY(1,1) NOT NULL,
	[InsureeID] [int] NOT NULL,
	[LocationId] [int] NULL,
	[Poverty] [bit] NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[RowID] [timestamp] NULL,
	[FamilyType] [nvarchar](2) NULL,
	[FamilyAddress] [nvarchar](200) NULL,
	[isOffline] [bit] NULL,
	[Ethnicity] [nvarchar](1) NULL,
	[ConfirmationNo] [nvarchar](12) NULL,
	[ConfirmationType] [nvarchar](3) NULL,
 CONSTRAINT [PK_tblFamilies] PRIMARY KEY CLUSTERED 
(
	[FamilyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblFamilies] ADD  CONSTRAINT [DF_tblFamilies_InsureeID]  DEFAULT ((0)) FOR [InsureeID]
GO
ALTER TABLE [dbo].[tblFamilies] ADD  CONSTRAINT [DF_tblFamilies_Poverty]  DEFAULT ((0)) FOR [Poverty]
GO
ALTER TABLE [dbo].[tblFamilies] ADD  CONSTRAINT [DF_tblFamilies_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblFamilies] ADD  CONSTRAINT [DF__tblFamili__isOff__0D6FE0E5]  DEFAULT ((0)) FOR [isOffline]
GO
ALTER TABLE [dbo].[tblFamilies]  WITH CHECK ADD  CONSTRAINT [FK_tblConfirmationType_tblFamilies] FOREIGN KEY([ConfirmationType])
REFERENCES [dbo].[tblConfirmationTypes] ([ConfirmationTypeCode])
GO
ALTER TABLE [dbo].[tblFamilies] CHECK CONSTRAINT [FK_tblConfirmationType_tblFamilies]
GO
ALTER TABLE [dbo].[tblFamilies]  WITH NOCHECK ADD  CONSTRAINT [FK_tblFamilies_tblInsuree] FOREIGN KEY([InsureeID])
REFERENCES [dbo].[tblInsuree] ([InsureeID])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[tblFamilies] NOCHECK CONSTRAINT [FK_tblFamilies_tblInsuree]
GO
ALTER TABLE [dbo].[tblFamilies]  WITH CHECK ADD  CONSTRAINT [FK_tblFamilies_tblLocations] FOREIGN KEY([LocationId])
REFERENCES [dbo].[tblLocations] ([LocationId])
GO
ALTER TABLE [dbo].[tblFamilies] CHECK CONSTRAINT [FK_tblFamilies_tblLocations]
GO
ALTER TABLE [dbo].[tblFamilies]  WITH CHECK ADD  CONSTRAINT [FK_tblFamilyTypes_tblFamilies] FOREIGN KEY([FamilyType])
REFERENCES [dbo].[tblFamilyTypes] ([FamilyTypeCode])
GO
ALTER TABLE [dbo].[tblFamilies] CHECK CONSTRAINT [FK_tblFamilyTypes_tblFamilies]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'H: Household
S: Students (School)
SU: Students (University)
P: Priests
T: Teachers
OP: Orphanages
C: Council
D: Data Electronics' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblFamilies', @level2type=N'COLUMN',@level2name=N'FamilyType'
GO
