ALTER TABLE BetLinks ADD ClientId int NULL
go
UPDATE Countries set CurrencyTypeId = 4 where id = 5
go
INSERT INTO ApplicationSources(ID, Name)
VALUES(90,'Uni-com Az')
GO
INSERT INTO ApplicationSources(ID, Name)
VALUES(100,'Uni-com Uz')
GO
INSERT INTO AccountType(ID, Name) values (3, 'UNI-com Азербайджан')
GO

CREATE TABLE dbo.ClientTranslations (
  TranslationId INT IDENTITY
 ,TypeId INT NOT NULL
 ,ObjectId INT NOT NULL
 ,LanguageId INT NOT NULL
 ,[Text] NVARCHAR(1000)
 ,CONSTRAINT PK_ClientTranslations_ID PRIMARY KEY (TranslationId)
)
GO

CREATE UNIQUE INDEX IDX_ClientTranslations
ON dbo.ClientTranslations (TypeId, ObjectId, LanguageId)
GO

INSERT INTO ClientTranslations (TypeId, ObjectId, LanguageId, Text)
  SELECT 1, ctt.CoefTypeId, ctt.LanguageId, ctt.CoefTypeName FROM CoefTypeTranslations ctt
GO

INSERT INTO ClientTranslations (TypeId, ObjectId, LanguageId, Text)
  SELECT 3, lmt.MemberId, lmt.LanguageId, lmt.LineMemberText FROM LineMemberTranslations lmt
  INNER JOIN (SELECT lmt.LineMemberTranslationId      
  ,RowNum = ROW_NUMBER() OVER (PARTITION BY lmt.MemberId, lmt.LanguageId ORDER BY lmt.LineMemberTranslationId)
  FROM LineMemberTranslations lmt) rows ON rows.LineMemberTranslationId = lmt.LineMemberTranslationId
  WHERE rows.RowNum = 1
GO

INSERT INTO ClientTranslations (TypeId, ObjectId, LanguageId, Text)
  SELECT 4, tpt.TextPositionId, tpt.LanguageId, tpt.Text FROM TextPositionTranslations tpt
GO

INSERT INTO ClientTranslations (TypeId, ObjectId, LanguageId, Text)
  SELECT 5, t.StringId,t.LanguageId, t.Text  FROM Translations t
GO

INSERT INTO ClientTranslations (TypeId, ObjectId, LanguageId, Text)
  VALUES (5, 40232, 1, N'По техническим причинам совершить ставку невозможно, обратитесь на Горячую линию'),
(5, 40233, 1, N'Исчерпан максимальный лимит ставок на ветку событий ''{0}'' для игрока'),
(5, 40234, 1, N'Исчерпан максимальный лимит ставок на ветку событий ''{0}'' для игрока.{1}Удалите событие {2}-''{3}'' из билета'),
(5, 40235, 1, N'Исчерпан лимит ставок на ''{0}'' до {1}'),
(5, 40236, 1, N'Запрещен прием ставок по банковской карте'),
(5, 40237, 1, N'По техническим причинам совершить ставку на данном ППС невозможно, обратитесь на Горячую линию'),
(5, 40238, 1, N'Запрет участия в бонусной программе'),
(5, 40239, 1, N'Недостаточно баллов для совершения ставки.'),
(5, 40240, 1, N'Недостаточно баллов для совершения ставки. На счету {0} {1}.'),
(5, 40242, 1, N'Недостаточно средств для совершения ставки'),
(5, 40243, 1, N'Этот клиент не сможет сделать повторную ставку на такой же или похожий набор исходов ещё некоторое время'),
(5, 40244, 1, N'Вы не сможете сделать повторную ставку на такой же или похожий набор исходов'),
(5, 40245, 1, N'Данный тип ставки невозможен'),
(5, 40246, 2, N'Coef not valid'),
(5, 40246, 1, N'Коэффициент не действителен'),
(5, 40247, 1, N'Live-ставку нельзя оплатить по безнал. расчету'),
(5, 40248, 1, N'Ставку, требующую подтверждения, нельзя оплатить по безнал. расчету'),
(5, 40249, 1, N'Произошла ошибка'),
(5, 40250, 1, N'Выбрана оплата купоном, однако идентификатор купона отсутствует'),
(5, 40251, 1, N'Непредвиденная ошибка'),
(5, 40251, 2, N'Unexpected error'),
(5, 40252, 1, N'балл'),
(5, 40252, 2, N'point'),
(5, 40253, 1, N'балла'),
(5, 40253, 2, N'points'),
(5, 40254, 1, N'баллов'),
(5, 40254, 2, N'points'),
(5, 40255, 1, N'Купон с Id = {0} отсутствует в базе'),
(5, 40256, 1, N'Минимальная сумма ставки на событие {0} - {1}'),
(5, 40257, 1, N'Невозможно оплатить по безнал. расчету'),
(5, 40258, 1, N'Невозможно принять ставку на закрытом ППС'),
(5, 40259, 1, N'Невозможно принять ставку.'),
(5, 40260, 1, N'Нельзя сделать ставку в счет выплаты, если выигрыш превышает 400000 руб.'),
(5, 40261, 1, N'Ошибка создания ставки в счет выплаты.'),
(5, 40262, 1, N'Не поддерживается. Обратитесь к разработчику ПО.'),
(5, 40263, 1, N'По Вашему аккаунту проводится проверка. На время проверки возможность совершать ставки и финансовые операции со счётом будут недоступны. Позвоните, пожалуйста, по телефону горячей линии <a href=''tel:+78007002990''>8-800-700-29-90.</a>'),
(5, 40264, 1, N'Выплата заблокирована до принятия решения по выплате НДФЛ'),
(5, 40265, 1, N'Нельзя выдать сумму, большую суммы выигрыша.'),
(5, 40267, 1, N'Запрещено'),
(5, 40268, 1, N'Не существует аккаунта с указанным ID'),
(5, 40269, 1, N'Не правильно указан номер мобильного телефона.'),
(5, 40270, 1, N'Не корректно указана сумма выигрыша'),
(5, 40271, 1, N'Не верно указан код выигрыша'),
(5, 40272, 1, N'По билету ранее была проведена выплата.'),
(5, 40273, 1, N'Запрошенная сумма выигрыша не соответствует сумме в заявке.\nОбратитесь в службу поддержки.\nЗаявка {0}.'),
(5, 40274, 1, N'Существующая заявка на выплату выигрыша не совпадает с текущим запросом.\nОбратитесь в службу поддержки.'),
(5, 40275, 1, N'Исчерпан лимит ставок на {0} до {1}'),
(5, 40276, 1, N'Некорректные исходы в корзине');
GO
CREATE TABLE dbo.LineMemberNameMapping (
  Id INT IDENTITY
 ,LineMemberId INT NOT NULL
 ,Name NVARCHAR(200) NOT NULL
 ,CONSTRAINT PK_LineMemberNameMapping_Id PRIMARY KEY (Id)
)
GO
CREATE UNIQUE NONCLUSTERED INDEX IDX_LineMemberMapping
ON dbo.LineMemberNameMapping (
	LineMemberId, Name ASC
)
GO

INSERT INTO LineMemberNameMapping (LineMemberId, Name)
  SELECT DISTINCT
    lmt.MemberId
   ,lmt.LineMemberText
  FROM LineMemberTranslations lmt
GO
INSERT [dbo].[Clients] ([ClientId], [ClientTypeId], [ClientName], [ClientAddress], [ClientBalanceValue], [ClientComment], [ClientTimeShift], [ClientRegionId], [AcceptGoods], [ClientTV], [ClientNew],
[ClientMetro], [ClientMapFile], [ClientSiteVisible], [LanguageId], [OrgId], [ClientSeccode], [Status], [BankId], [Lunch], [OpenDate], [CloseDate], [TestsCount], [LastTestDate], [ZipCode],
[BaseClientId], [ClientWhere], [DeviceBalanceValue], [KladrID], [DebitMode], [OfficeID], [CityID], [KKMNumber], [EKLZNumber], [IsNew], [TrialPeriod])
VALUES (7774, 2, N'Uni-Com Азербайджан', N'Uni-Com Азербайджан', 0, N'Интернет', 1, 12, 0, 0, 0,
N'', N'', 0, 6, 1, N'', 0, NULL, NULL, CAST(N'2021-03-01 00:00:00.000' AS DateTime), NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL,
NULL, NULL, NULL, 0, NULL)
GO
---Maybe yes, maybe not
CREATE VIEW [dbo].[CoefEventResultView]
AS
SELECT 
Coefs.CoefID,
Events.EventName,
Events.LineID as EventId,
Events.EventCreationTime,
Events.EventStartTime,
Events.Live,
Events.EventTypeGroupID,
Coefs.CoefWon,
Coefs.CoefValue,
Coefs.Comment as MoneyBackComment,
CAST(CASE Events.ResultComment WHEN 'отмена' THEN 1 ELSE 0 END as bit) AS IsCanceled,
CAST(CASE WHEN Events.EventStartTime < GETDATE() THEN 1 ELSE 0 END as bit) AS IsOver,
EventComments.CommentEng as Comment,
EventComments.InfoEng as Info,
ST.SportTypeID,
Events.EventScore,
Events.EventResultText as EventResult,
GlobalTranslate.Eng as LeagueTitle
FROM Coefs (nolock)
INNER JOIN Events (nolock) ON Events.LineID = Coefs.LineID
INNER JOIN LineMembers ST (nolock) ON Events.EventTypeGroupID = ST.LineMemberId
INNER JOIN LineMembers (nolock) ON Events.LineMemberId = LineMembers.LineMemberId
INNER JOIN GlobalTranslate (nolock) ON LineMembers.TranslateId = GlobalTranslate.Id
INNER JOIN CoefTypes (nolock) ON Coefs.CoefTypeID = CoefTypes.CoefTypeID
LEFT OUTER JOIN EventComments (nolock) ON EventComments.EventId = Events.LineID
GO





--Удалить после успешного релиза
--DROP TABLE EventPositionTranslations, TextPositionTranslations, CoefTypeTranslations, Translations, LineMemberTranslations
--GO