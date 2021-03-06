/****** Object:  Table [dbo].[tblPLItems]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPLItems](
	[PLItemID] [int] IDENTITY(1,1) NOT NULL,
	[PLItemName] [nvarchar](100) NOT NULL,
	[DatePL] [date] NOT NULL,
	[LocationId] [int] NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[RowID] [timestamp] NULL,
 CONSTRAINT [PK_tblPLItems] PRIMARY KEY CLUSTERED 
(
	[PLItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblPLItems] ADD  CONSTRAINT [DF_tblPLItems_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblPLItems]  WITH CHECK ADD  CONSTRAINT [FK_tblPLItems_tblLocations] FOREIGN KEY([LocationId])
REFERENCES [dbo].[tblLocations] ([LocationId])
GO
ALTER TABLE [dbo].[tblPLItems] CHECK CONSTRAINT [FK_tblPLItems_tblLocations]
GO
