/****** Object:  Table [dbo].[tblServices]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblServices](
	[ServiceID] [int] IDENTITY(1,1) NOT NULL,
	[ServCode] [nvarchar](6) NOT NULL,
	[ServName] [nvarchar](100) NOT NULL,
	[ServType] [char](1) NOT NULL,
	[ServLevel] [char](1) NOT NULL,
	[ServPrice] [decimal](18, 2) NOT NULL,
	[ServCareType] [char](1) NOT NULL,
	[ServFrequency] [smallint] NULL,
	[ServPatCat] [tinyint] NOT NULL,
	[ValidityFrom] [datetime] NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NULL,
	[RowID] [timestamp] NULL,
	[ServCategory] [char](1) NULL,
 CONSTRAINT [PK_tblServices] PRIMARY KEY CLUSTERED 
(
	[ServiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblServices] ADD  CONSTRAINT [DF_tblServices_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'S: Surgery
C: Consultation
D: Delivery
O: Other' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblServices', @level2type=N'COLUMN',@level2name=N'ServCategory'
GO
