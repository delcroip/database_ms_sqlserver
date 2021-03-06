/****** Object:  Table [dbo].[tblFeedbackPrompt]    Script Date: 19.09.2018 15:16:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFeedbackPrompt](
	[FeedbackPromptID] [int] IDENTITY(1,1) NOT NULL,
	[FeedbackPromptDate] [date] NOT NULL,
	[ClaimID] [int] NULL,
	[OfficerID] [int] NULL,
	[PhoneNumber] [nvarchar](25) NULL,
	[SMSStatus] [tinyint] NULL,
	[ValidityFrom] [datetime] NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NULL,
 CONSTRAINT [PK_tblFeedbackPrompt] PRIMARY KEY CLUSTERED 
(
	[FeedbackPromptID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblFeedbackPrompt] ADD  CONSTRAINT [DF_tblFeedbackPrompt_SMSStatus]  DEFAULT ((0)) FOR [SMSStatus]
GO
