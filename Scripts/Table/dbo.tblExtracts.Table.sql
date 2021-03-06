/****** Object:  Table [dbo].[tblExtracts]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblExtracts](
	[ExtractID] [int] IDENTITY(1,1) NOT NULL,
	[ExtractDirection] [tinyint] NOT NULL,
	[ExtractType] [tinyint] NOT NULL,
	[ExtractSequence] [int] NOT NULL,
	[ExtractDate] [datetime] NOT NULL,
	[ExtractFileName] [nvarchar](255) NULL,
	[ExtractFolder] [nvarchar](255) NULL,
	[LocationId] [int] NOT NULL,
	[HFID] [int] NULL,
	[AppVersionBackend] [decimal](3, 1) NOT NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[RowID] [bigint] NULL,
 CONSTRAINT [PK_tblExtracts] PRIMARY KEY CLUSTERED 
(
	[ExtractID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblExtracts] ADD  CONSTRAINT [DF_tblExtracts_ExtractDirection]  DEFAULT ((0)) FOR [ExtractDirection]
GO
ALTER TABLE [dbo].[tblExtracts] ADD  CONSTRAINT [DF_tblExtracts_ExtractType]  DEFAULT ((0)) FOR [ExtractType]
GO
ALTER TABLE [dbo].[tblExtracts] ADD  CONSTRAINT [DF_tblExtracts_ExtractDate]  DEFAULT (getdate()) FOR [ExtractDate]
GO
ALTER TABLE [dbo].[tblExtracts] ADD  CONSTRAINT [DF_tblExtracts_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0=Export record  1= Import record ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblExtracts', @level2type=N'COLUMN',@level2name=N'ExtractDirection'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1=Phone extract    2= Off line client FULL  4 = Offline client differential' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblExtracts', @level2type=N'COLUMN',@level2name=N'ExtractType'
GO
