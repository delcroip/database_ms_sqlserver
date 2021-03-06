/****** Object:  Table [dbo].[tblPLItemsDetail]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPLItemsDetail](
	[PLItemDetailID] [int] IDENTITY(1,1) NOT NULL,
	[PLItemID] [int] NOT NULL,
	[ItemID] [int] NOT NULL,
	[PriceOverule] [decimal](18, 2) NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[RowID] [timestamp] NULL,
 CONSTRAINT [PK_tblPLItemsDetail] PRIMARY KEY CLUSTERED 
(
	[PLItemDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblPLItemsDetail] ADD  CONSTRAINT [DF_tblPLItemsDetail_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblPLItemsDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblPLItemsDetail_tblItems-ItemID] FOREIGN KEY([ItemID])
REFERENCES [dbo].[tblItems] ([ItemID])
GO
ALTER TABLE [dbo].[tblPLItemsDetail] CHECK CONSTRAINT [FK_tblPLItemsDetail_tblItems-ItemID]
GO
ALTER TABLE [dbo].[tblPLItemsDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblPLItemsDetail_tblPLItems-PLItemID] FOREIGN KEY([PLItemID])
REFERENCES [dbo].[tblPLItems] ([PLItemID])
GO
ALTER TABLE [dbo].[tblPLItemsDetail] CHECK CONSTRAINT [FK_tblPLItemsDetail_tblPLItems-PLItemID]
GO
