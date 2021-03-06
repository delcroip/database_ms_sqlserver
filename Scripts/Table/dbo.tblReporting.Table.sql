/****** Object:  Table [dbo].[tblReporting]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblReporting](
	[ReportingId] [int] IDENTITY(1,1) NOT NULL,
	[ReportingDate] [datetime] NOT NULL,
	[LocationId] [int] NOT NULL,
	[ProdId] [int] NOT NULL,
	[PayerId] [int] NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NOT NULL,
	[RecordFound] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ReportingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
