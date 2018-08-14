
// Функция выводит фрму отбработки обновления, которая отображает изменения в новой версии
// функция должна вызываеться после обновления, т.к. использует номер версии текущей конфигурации
//
// Параметры: нет
//  
Процедура ОтобразитьИзмененияВВерсии() Экспорт
		
	ОткрытьФорму("Обработка.ОбновлениеКонфигурации.Форма.ИзмененияВВерсии");
	
КонецПроцедуры // ОтобразитьИзмененияВВерсии()

Процедура ПоказатьОповещениеОбОбновлении() Экспорт
	
	Состояние("Выполняется обновление конфигурации. Это может занять некоторое время.");
	
КонецПроцедуры // ПоказатьОповещениеОбОбновлении()
