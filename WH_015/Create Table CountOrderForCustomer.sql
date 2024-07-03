




CREATE TABLE [Report].[CountOrderForCustomer](
	[id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[CountOrder] [int] NULL,
	[CustomerName] [nvarchar](200) NULL,
	[DateTimeStamp] [datetime] NULL
) ON [USERDATA]



