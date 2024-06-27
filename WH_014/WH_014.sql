
-- Включаем среду CLR
exec sp_configure 'show advanced options', 1;
exec sp_configure 'clr enabled', 1;
Exec sp_configure 'CLR strict security' ,0
RECONFIGURE;
-- включение доверия внешним программам
 alter database ProjectShop set TRUSTWORTHY on
 -- подключаем Dll
 Create assembly CLR_SumStr from N'E:\Otus\Reposetory\OtusLearning\WH_014\CLR_SumStr.dll'


 -- Создаем функцию 
CREATE AGGREGATE [dbo].[CLR_SumStr]
(@Value [nvarchar](max))
RETURNS[nvarchar](max)
EXTERNAL NAME [CLR_SumStr].[CLR_SumStr]

-- Проверяем работу
Select [dbo].[CLR_SumStr](username +' /')
From Application.UserProfile