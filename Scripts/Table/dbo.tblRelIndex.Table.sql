/****** Object:  Table [dbo].[tblRelIndex]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRelIndex](
	[RelIndexID] [int] IDENTITY(1,1) NOT NULL,
	[ProdID] [int] NOT NULL,
	[RelType] [tinyint] NOT NULL,
	[RelCareType] [char](1) NOT NULL,
	[RelYear] [int] NOT NULL,
	[RelPeriod] [tinyint] NOT NULL,
	[CalcDate] [datetime] NOT NULL,
	[RelIndex] [decimal](18, 4) NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[LocationId] [int] NULL,
 CONSTRAINT [PK_tblRelIndex] PRIMARY KEY CLUSTERED 
(
	[RelIndexID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblRelIndex] ADD  CONSTRAINT [DF_tblRelIndex_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblRelIndex]  WITH CHECK ADD  CONSTRAINT [FK_tblRelIndex_tblProduct] FOREIGN KEY([ProdID])
REFERENCES [dbo].[tblProduct] ([ProdID])
GO
ALTER TABLE [dbo].[tblRelIndex] CHECK CONSTRAINT [FK_tblRelIndex_tblProduct]
GO
