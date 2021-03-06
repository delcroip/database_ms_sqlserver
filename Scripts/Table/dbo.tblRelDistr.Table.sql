/****** Object:  Table [dbo].[tblRelDistr]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRelDistr](
	[DistrID] [int] IDENTITY(1,1) NOT NULL,
	[DistrType] [tinyint] NOT NULL,
	[DistrCareType] [char](1) NOT NULL,
	[ProdID] [int] NOT NULL,
	[Period] [tinyint] NOT NULL,
	[DistrPerc] [decimal](18, 2) NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[RowID] [timestamp] NULL,
 CONSTRAINT [PK_tblRelDistr] PRIMARY KEY CLUSTERED 
(
	[DistrID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblRelDistr] ADD  CONSTRAINT [DF_tblRelDistr_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblRelDistr]  WITH CHECK ADD  CONSTRAINT [FK_tblRelDistr_tblProduct] FOREIGN KEY([ProdID])
REFERENCES [dbo].[tblProduct] ([ProdID])
GO
ALTER TABLE [dbo].[tblRelDistr] CHECK CONSTRAINT [FK_tblRelDistr_tblProduct]
GO
