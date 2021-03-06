/****** Object:  Table [dbo].[tblItems]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblItems](
	[ItemID] [int] IDENTITY(1,1) NOT NULL,
	[ItemCode] [nvarchar](6) NOT NULL,
	[ItemName] [nvarchar](100) NOT NULL,
	[ItemType] [char](1) NOT NULL,
	[ItemPackage] [nvarchar](255) NULL,
	[ItemPrice] [decimal](18, 2) NOT NULL,
	[ItemCareType] [char](1) NOT NULL,
	[ItemFrequency] [smallint] NULL,
	[ItemPatCat] [tinyint] NOT NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[RowID] [timestamp] NULL,
 CONSTRAINT [PK_tblItems] PRIMARY KEY CLUSTERED 
(
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblItems] ADD  CONSTRAINT [DF_tblItems_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
