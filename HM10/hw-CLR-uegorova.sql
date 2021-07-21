
--подключение и использование функции нахождения следующего простого числа
--с условиями:
--если введенное число простое - оно и является результатом
--Если введено null, то отображается 0
--для отрицательных значений, 0 и 1 будет выводиться 2

DROP FUNCTION IF EXISTS fn_ReturnNextPrimary
DROP ASSEMBLY IF EXISTS AssemblyCLR

CREATE ASSEMBLY AssemblyCLR
FROM 'C:\Users\uegorova.ICS\source\repos\CLR_2021\CLR_2021\bin\Debug\CLR_2021.dll'
WITH PERMISSION_SET = SAFE;  

CREATE FUNCTION dbo.fn_ReturnNextPrimary(@Name int)  
RETURNS int
AS EXTERNAL NAME AssemblyCLR.[CLR_2021.CLR_1].NextPrimeNumber;
GO 

create table #Numbers 
(
	num int null,
)

insert into #Numbers
values(null), (1), (200), (100000), (851), (-200), (3)

SELECT num
	,dbo.fn_ReturnNextPrimary(num)
from #Numbers