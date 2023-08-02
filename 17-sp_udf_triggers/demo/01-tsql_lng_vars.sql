
-- Переменные
DECLARE @a INT
SET @a=10
SELECT @a

-- группа инстркций BEGIN END
begin
	print '1';
	begin
		begin
			return -- выход из всех блоков
			print'2';
		end
	print'3';
	end
end

-- try catch
BEGIN TRY
	select 1/0;
END TRY
BEGIN CATCH
  SELECT error_message(),error_line() --смотри меня в retult
  RAISERROR('смотри меня в message ',16,1)
END CATCH

-- @@ERROR
select 1/0;
if(@@ERROR<>0)
begin
	SELECT error_message(),error_line() -- не работают
end


-- if else
DECLARE @a INT
SET @a=10
if(@a>0)
	SELECT @a
else
	SELECT N'отрицатеьное'

--  case when
DECLARE @a INT
SET @a=10
Select	case when @a>0 then N'положительное'
		else
		N'отрицатеьное'
		end	

-- цикл break continue
--какие вообще есть значения в таблице
Use WideWorldImporters
select * from [Warehouse].[StockItemHoldings]
where QuantityOnHand <100 
order by QuantityOnHand

WHILE ( SELECT avg(QuantityOnHand) FROM [Warehouse].[StockItemHoldings])>0 -- бесконечный цикл, можно только логические условия ставить
BEGIN    
   IF ( SELECT count(*) FROM [Warehouse].[StockItemHoldings] 
		where QuantityOnHand<100 ) = 9 
			print N'Найдено';
			BREAK;  
END


while (1=1)
begin
	begin
		print '1';
		break;-- тоже глобальный выход
		print '2';
	end
	print '3';
end

