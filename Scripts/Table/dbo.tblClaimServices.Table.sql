/****** Object:  Table [dbo].[tblClaimServices]    Script Date: 19.09.2018 15:16:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblClaimServices](
	[ClaimServiceID] [int] IDENTITY(1,1) NOT NULL,
	[ClaimID] [int] NOT NULL,
	[ServiceID] [int] NOT NULL,
	[ProdID] [int] NULL,
	[ClaimServiceStatus] [tinyint] NOT NULL,
	[QtyProvided] [decimal](18, 2) NOT NULL,
	[QtyApproved] [decimal](18, 2) NULL,
	[PriceAsked] [decimal](18, 2) NOT NULL,
	[PriceAdjusted] [decimal](18, 2) NULL,
	[PriceApproved] [decimal](18, 2) NULL,
	[PriceValuated] [decimal](18, 2) NULL,
	[Explanation] [ntext] NULL,
	[Justification] [ntext] NULL,
	[RejectionReason] [smallint] NULL,
	[ValidityFrom] [datetime] NOT NULL,
	[ValidityTo] [datetime] NULL,
	[LegacyID] [int] NULL,
	[AuditUserID] [int] NOT NULL,
	[ValidityFromReview] [datetime] NULL,
	[ValidityToReview] [datetime] NULL,
	[AuditUserIDReview] [int] NULL,
	[LimitationValue] [decimal](18, 2) NULL,
	[Limitation] [char](1) NULL,
	[PolicyID] [int] NULL,
	[RemuneratedAmount] [decimal](18, 2) NULL,
	[DeductableAmount] [decimal](18, 2) NULL,
	[ExceedCeilingAmount] [decimal](18, 2) NULL,
	[PriceOrigin] [char](1) NULL,
	[ExceedCeilingAmountCategory] [decimal](18, 2) NULL,
 CONSTRAINT [PK_tblClaimServices] PRIMARY KEY CLUSTERED 
(
	[ClaimServiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblClaimServices] ADD  CONSTRAINT [DF_tblClaimServices_ClaimServiceStatus]  DEFAULT ((1)) FOR [ClaimServiceStatus]
GO
ALTER TABLE [dbo].[tblClaimServices] ADD  CONSTRAINT [DF_tblClaimServices_RejectionReason]  DEFAULT ((0)) FOR [RejectionReason]
GO
ALTER TABLE [dbo].[tblClaimServices] ADD  CONSTRAINT [DF_tblClaimServices_ValidityFrom]  DEFAULT (getdate()) FOR [ValidityFrom]
GO
ALTER TABLE [dbo].[tblClaimServices]  WITH CHECK ADD  CONSTRAINT [FK_tblClaimServices_tblClaim-ClaimID] FOREIGN KEY([ClaimID])
REFERENCES [dbo].[tblClaim] ([ClaimID])
GO
ALTER TABLE [dbo].[tblClaimServices] CHECK CONSTRAINT [FK_tblClaimServices_tblClaim-ClaimID]
GO
ALTER TABLE [dbo].[tblClaimServices]  WITH CHECK ADD  CONSTRAINT [FK_tblClaimServices_tblProduct-ProdID] FOREIGN KEY([ProdID])
REFERENCES [dbo].[tblProduct] ([ProdID])
GO
ALTER TABLE [dbo].[tblClaimServices] CHECK CONSTRAINT [FK_tblClaimServices_tblProduct-ProdID]
GO
ALTER TABLE [dbo].[tblClaimServices]  WITH CHECK ADD  CONSTRAINT [FK_tblClaimServices_tblServices-ServiceID] FOREIGN KEY([ServiceID])
REFERENCES [dbo].[tblServices] ([ServiceID])
GO
ALTER TABLE [dbo].[tblClaimServices] CHECK CONSTRAINT [FK_tblClaimServices_tblServices-ServiceID]
GO
