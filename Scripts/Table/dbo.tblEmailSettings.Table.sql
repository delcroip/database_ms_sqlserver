/****** Object:  Table [dbo].[tblEmailSettings]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblEmailSettings](
	[EmailId] [nvarchar](200) NOT NULL,
	[EmailPassword] [nvarchar](200) NOT NULL,
	[SMTPHost] [nvarchar](200) NOT NULL,
	[Port] [int] NOT NULL,
	[EnableSSL] [bit] NOT NULL
) ON [PRIMARY]
GO
