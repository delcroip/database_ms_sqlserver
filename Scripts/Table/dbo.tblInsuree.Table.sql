/****** Object:  Table [dbo].[tblInsuree]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblInsuree](
	[InsureeID] [int] IDENTITY(1,1) NOT NULL,
	[FamilyID] [int] NOT NULL,
	[CHFID] [nvarchar](12) NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[OtherNames] [nvarchar](100) NOT NULL,
	[DOB] [date] NOT NULL,
	[Gender] [char](1) NULL,
	[Marital] [char](1) NULL,
	[IsHead] [bit] NOT NULL,
	[passport] [nvarchar](25) NULL,
	[Phone] [nvarchar](50) NULL,
	[PhotoID] [int] NULL,
	[PhotoDate] [date] NULL,
	[CardIssued] [bit] NOT NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[RowID] [timestamp] NULL,
	[Relationship] [smallint] NULL,
	[Profession] [smallint] NULL,
	[Education] [smallint] NULL,
	[Email] [nvarchar](100) NULL,
	[isOffline] [bit] NULL,
	[TypeOfId] [nvarchar](1) NULL,
	[HFID] [int] NULL,
	[CurrentAddress] [nvarchar](200) NULL,
	[GeoLocation] [nvarchar](250) NULL,
	[CurrentVillage] [int] NULL,
 CONSTRAINT [PK_tblInsuree] PRIMARY KEY CLUSTERED 
(
	[InsureeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblInsuree] ADD  CONSTRAINT [DF_tblInsuree_IsHead]  DEFAULT ((0)) FOR [IsHead]
GO
ALTER TABLE [dbo].[tblInsuree] ADD  CONSTRAINT [DF_tblInsuree_CardIssued]  DEFAULT ((0)) FOR [CardIssued]
GO
ALTER TABLE [dbo].[tblInsuree] ADD  CONSTRAINT [DF_tblInsuree_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblInsuree] ADD  CONSTRAINT [DF__tblInsure__isOff__0E64051E]  DEFAULT ((0)) FOR [isOffline]
GO
ALTER TABLE [dbo].[tblInsuree]  WITH CHECK ADD  CONSTRAINT [FK_tblEducations_tblInsuree] FOREIGN KEY([Education])
REFERENCES [dbo].[tblEducations] ([EducationId])
GO
ALTER TABLE [dbo].[tblInsuree] CHECK CONSTRAINT [FK_tblEducations_tblInsuree]
GO
ALTER TABLE [dbo].[tblInsuree]  WITH CHECK ADD  CONSTRAINT [FK_tblIdentificationTypes_tblInsuree] FOREIGN KEY([TypeOfId])
REFERENCES [dbo].[tblIdentificationTypes] ([IdentificationCode])
GO
ALTER TABLE [dbo].[tblInsuree] CHECK CONSTRAINT [FK_tblIdentificationTypes_tblInsuree]
GO
ALTER TABLE [dbo].[tblInsuree]  WITH CHECK ADD  CONSTRAINT [FK_tblInsuree_tblFamilies1-FamilyID] FOREIGN KEY([FamilyID])
REFERENCES [dbo].[tblFamilies] ([FamilyID])
GO
ALTER TABLE [dbo].[tblInsuree] CHECK CONSTRAINT [FK_tblInsuree_tblFamilies1-FamilyID]
GO
ALTER TABLE [dbo].[tblInsuree]  WITH CHECK ADD  CONSTRAINT [FK_tblInsuree_tblGender] FOREIGN KEY([Gender])
REFERENCES [dbo].[tblGender] ([Code])
GO
ALTER TABLE [dbo].[tblInsuree] CHECK CONSTRAINT [FK_tblInsuree_tblGender]
GO
ALTER TABLE [dbo].[tblInsuree]  WITH CHECK ADD  CONSTRAINT [FK_tblInsuree_tblHF] FOREIGN KEY([HFID])
REFERENCES [dbo].[tblHF] ([HfID])
GO
ALTER TABLE [dbo].[tblInsuree] CHECK CONSTRAINT [FK_tblInsuree_tblHF]
GO
ALTER TABLE [dbo].[tblInsuree]  WITH CHECK ADD  CONSTRAINT [FK_tblInsuree_tblPhotos] FOREIGN KEY([PhotoID])
REFERENCES [dbo].[tblPhotos] ([PhotoID])
GO
ALTER TABLE [dbo].[tblInsuree] CHECK CONSTRAINT [FK_tblInsuree_tblPhotos]
GO
ALTER TABLE [dbo].[tblInsuree]  WITH CHECK ADD  CONSTRAINT [FK_tblProfessions_tblInsuree] FOREIGN KEY([Profession])
REFERENCES [dbo].[tblProfessions] ([ProfessionId])
GO
ALTER TABLE [dbo].[tblInsuree] CHECK CONSTRAINT [FK_tblProfessions_tblInsuree]
GO
ALTER TABLE [dbo].[tblInsuree]  WITH CHECK ADD  CONSTRAINT [FK_tblRelations_tblInsuree] FOREIGN KEY([Relationship])
REFERENCES [dbo].[tblRelations] ([RelationId])
GO
ALTER TABLE [dbo].[tblInsuree] CHECK CONSTRAINT [FK_tblRelations_tblInsuree]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1: Spouse of the member
2: Daughter/Son
3: Father/Mother/Father-in-law/Mother-in-law
4: Grand Father/Grand Mother
5: Brother/Sister
6: Lives in the same dwelling
7: Others' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblInsuree', @level2type=N'COLUMN',@level2name=N'Relationship'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1: Self Employed in Agriculture
2: Selft Employed in Business/Trade
3: Regular Salaried Employee
4: Casual wage Laborer
5: Does not work right now but seeking or ready to be employed
6: Not able to work due to disability/Old Age
7: Attends educational institutions
8: Pre-school child
9: Attends domestic duties for household
10: Retired, pensioner, remittance recipient, etc.
11: Housewife
12: Others' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblInsuree', @level2type=N'COLUMN',@level2name=N'Profession'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1: Nursery
2: Primary School
3: First School Certificate
4: Secondary School
5: Ordinary level certificate
6: High school
7: Advanced level certificate
8: Diploma
9: Graduate
10: Postgraduate
11: Above postgraduate
12: Never been to school and Illiterate
13: Never been to school but literate
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblInsuree', @level2type=N'COLUMN',@level2name=N'Education'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'C: Citizenship
D: Driver''s license
B: Birth Certificate
V: VDC Recommendation' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblInsuree', @level2type=N'COLUMN',@level2name=N'TypeOfId'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Health facility Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblInsuree', @level2type=N'COLUMN',@level2name=N'HFID'
GO
