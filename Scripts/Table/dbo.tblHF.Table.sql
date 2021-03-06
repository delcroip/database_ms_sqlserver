/****** Object:  Table [dbo].[tblHF]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblHF](
	[HfID] [int] IDENTITY(1,1) NOT NULL,
	[HFCode] [nvarchar](8) NOT NULL,
	[HFName] [nvarchar](100) NOT NULL,
	[LegalForm] [char](1) NOT NULL,
	[HFLevel] [char](1) NOT NULL,
	[HFSublevel] [char](1) NULL,
	[HFAddress] [nvarchar](100) NULL,
	[LocationId] [int] NOT NULL,
	[Phone] [nvarchar](50) NULL,
	[Fax] [nvarchar](50) NULL,
	[eMail] [nvarchar](50) NULL,
	[HFCareType] [char](1) NOT NULL,
	[PLServiceID] [int] NULL,
	[PLItemID] [int] NULL,
	[AccCode] [nvarchar](25) NULL,
	[OffLine] [bit] NOT NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[RowID] [timestamp] NULL,
 CONSTRAINT [PK_tblHF] PRIMARY KEY CLUSTERED 
(
	[HfID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblHF] ADD  CONSTRAINT [DF_tblHF_OffLine]  DEFAULT ((0)) FOR [OffLine]
GO
ALTER TABLE [dbo].[tblHF] ADD  CONSTRAINT [DF_tblHF_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblHF]  WITH CHECK ADD  CONSTRAINT [FK_tblHF_tblLocations] FOREIGN KEY([LocationId])
REFERENCES [dbo].[tblLocations] ([LocationId])
GO
ALTER TABLE [dbo].[tblHF] CHECK CONSTRAINT [FK_tblHF_tblLocations]
GO
ALTER TABLE [dbo].[tblHF]  WITH CHECK ADD  CONSTRAINT [FK_tblHF_tblPLItems-PLItemID] FOREIGN KEY([PLItemID])
REFERENCES [dbo].[tblPLItems] ([PLItemID])
GO
ALTER TABLE [dbo].[tblHF] CHECK CONSTRAINT [FK_tblHF_tblPLItems-PLItemID]
GO
ALTER TABLE [dbo].[tblHF]  WITH CHECK ADD  CONSTRAINT [FK_tblHF_tblPLServices-PLService-ID] FOREIGN KEY([PLServiceID])
REFERENCES [dbo].[tblPLServices] ([PLServiceID])
GO
ALTER TABLE [dbo].[tblHF] CHECK CONSTRAINT [FK_tblHF_tblPLServices-PLService-ID]
GO
ALTER TABLE [dbo].[tblHF]  WITH CHECK ADD  CONSTRAINT [FK_tblHFSublevel_tblHF] FOREIGN KEY([HFSublevel])
REFERENCES [dbo].[tblHFSublevel] ([HFSublevel])
GO
ALTER TABLE [dbo].[tblHF] CHECK CONSTRAINT [FK_tblHFSublevel_tblHF]
GO
ALTER TABLE [dbo].[tblHF]  WITH CHECK ADD  CONSTRAINT [FK_tblLegalForms_tblHF] FOREIGN KEY([LegalForm])
REFERENCES [dbo].[tblLegalForms] ([LegalFormCode])
GO
ALTER TABLE [dbo].[tblHF] CHECK CONSTRAINT [FK_tblLegalForms_tblHF]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'G: Government
C: Catholic
P: Protestant
R: Private' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblHF', @level2type=N'COLUMN',@level2name=N'LegalForm'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'I: Integrated
R: Reference
N: No Sublevel' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblHF', @level2type=N'COLUMN',@level2name=N'HFAddress'
GO
