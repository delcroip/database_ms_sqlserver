/****** Object:  Table [dbo].[tblSubmittedPhotos]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSubmittedPhotos](
	[PhotoId] [int] IDENTITY(1,1) NOT NULL,
	[ImageName] [nvarchar](50) NULL,
	[CHFID] [nvarchar](12) NULL,
	[OfficerCode] [nvarchar](8) NULL,
	[PhotoDate] [date] NULL,
	[RegisterDate] [datetime] NULL,
 CONSTRAINT [PK_tblSubmittedPhotos] PRIMARY KEY CLUSTERED 
(
	[PhotoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSubmittedPhotos] ADD  DEFAULT (getdate()) FOR [RegisterDate]
GO
