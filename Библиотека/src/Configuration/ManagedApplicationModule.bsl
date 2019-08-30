Процедура ПередНачаломРаботыСистемы(Отказ)

	// Если версии разные, то будет попытка обновления и надо об этом оповестить
	Если ОбновлениеКонфигурацииСервер.ПолучитьВерсиюКонфигурации() <> ОбновлениеКонфигурацииСервер.ПолучитьЗарегистрированнуюВерсиюКонфигурации() Тогда
		ОбновлениеКонфигурацииКлиент.ПоказатьОповещениеОбОбновлении();
	КонецЕсли;

	// Запуск процедур обновления конфигурации
	РезультатПроверкиОбновления = ОбновлениеКонфигурацииСервер.ПроверитьОбновления();
	Если РезультатПроверкиОбновления = "ОбновлениеПроизведено" Тогда
		ОбновлениеКонфигурацииКлиент.ОтобразитьИзмененияВВерсии();
	ИначеЕсли РезультатПроверкиОбновления = "НедостаточноПрав" Тогда
		Предупреждение(НСтр("ru = 'Обнаружено обновление конфигурации. Пожалуйста, запустите конфигурацию под полными правами.'"));
		ЗавершитьРаботуСистемы();
	КонецЕсли;

КонецПроцедуры