-- https://github.com/olahallengren/sql-server-maintenance-solution/blob/master/IndexOptimize.sql

use WideWorldImporters; 

--настройка индексов
exec master.dbo.IndexOptimize
	@Databases = N'WideWorldImporters',
	--действия при фрагментации
	@FragmentationLow = NULL, --ничего 
	@FragmentationMedium = 'INDEX_REORGANIZE',
	@FragmentationHigh = 'INDEX_REBUILD_ONLINE, INDEX_REORGANIZE', --попробовать провести перестроение индекса онлайн, если не получится - перефрагментацию (возможные значения можно посмотреть в тексте хп)

	--менее агрессивная перестройка индекса
	@FragmentationLevel1 = 30,  --5, рекомендации MS
	@FragmentationLevel2 = 70, --30, рекомендации MS
	@SortInTempdb = 'N', --'Y' - если tempdb на быстром диске
	@MaxDOP = 2, --NULL,
	@Resumable = 'Y', 
	--@FillFactor = NULL,
	--@PadIndex = NULL,
	--@UpdateStatistics = 'ALL',  --null обновление статистики

	@PartitionLevel = 'Y',
	@TimeLimit = NULL, --, ограничение по времени (сек)
	@Delay = 10, --NULL, задержка между индексами
	@LogToTable = 'Y', --логирование в таблицу CommandLog
	@Execute = 'Y' -- 'N' - тест 'Y' - запуск

go
select * from master.dbo.CommandLog order by StartTime desc

