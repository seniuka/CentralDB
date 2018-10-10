CREATE TABLE [Inst].[InsTriggers] (
    [ServerName]   NVARCHAR (128) NULL,
    [InstanceName] NVARCHAR (128) NULL,
    [TriggerName]  NVARCHAR (128) NULL,
    [CreateDate]   NVARCHAR (30)  NULL,
    [LastModified] NVARCHAR (30)  NULL,
    [IsEnabled]    BIT            NULL,
    [DateAdded]    SMALLDATETIME  NULL,
    [InsTrgID]     INT            IDENTITY (1, 1) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CI_InstTriggers]
    ON [Inst].[InsTriggers]([ServerName] ASC, [InstanceName] ASC, [DateAdded] ASC, [InsTrgID] ASC) WITH (FILLFACTOR = 85);

