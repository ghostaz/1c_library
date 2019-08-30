
// Проверим не повторяются ли книги в ТЧ
Функция ПроверитьНаОдинаковыеПозиции(ТабЧасть, Отказ) Экспорт
	
	СтрокаНомер = 0;
	Для Каждого Строка Из ТабЧасть Цикл
		СтрокаНомер = СтрокаНомер + 1;
		ПараметрыОтбора = Новый Структура;
		ПараметрыОтбора.Вставить("Книга", Строка.Книга);
		Если ТабЧасть.НайтиСтроки(ПараметрыОтбора).Количество() > 1 Тогда
			Сообщить(НСтр("ru = 'Имеются одинаковые позиции книг. Строка: '") + СтрокаНомер +НСтр("ru = '. Проведение отменено.'"), СтатусСообщения.Важное);
			Отказ = Истина;
			Возврат Ложь;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Истина;
	
КонецФункции

// Проверим остатки книг перед вводом остатков, выведет ошибку если такая книга уже есть
Функция ПроверитьОстаткиНаОтсутствие(ЭтотОбъект, Отказ) Экспорт
	
	Запрос = новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ЕСТЬNULL(КнигиВБиблиотекеОстатки.КоличествоОстаток, 0) КАК КоличествоРегистр,
	               |	ВложенныйЗапрос.Количество КАК КоличествоДокумент,
	               |	ВложенныйЗапрос.Книга,
	               |	ВложенныйЗапрос.НомерСтроки
	               |ИЗ
	               |	(ВЫБРАТЬ
	               |		1 КАК Количество,
	               |		ВводОстатковКнигКниги.Книга КАК Книга,
	               |		ВводОстатковКнигКниги.НомерСтроки КАК НомерСтроки
	               |	ИЗ
	               |		Документ.ВводОстатковКниг.Книги КАК ВводОстатковКнигКниги
	               |	ГДЕ
	               |		ВводОстатковКнигКниги.Ссылка = &Ссылка) КАК ВложенныйЗапрос
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.КнигиВБиблиотеке.Остатки(
	               |				&ДатаКон,
	               |				Книга В
	               |					(ВЫБРАТЬ
	               |						ВыдачаКнигКниги.Книга КАК Книга
	               |					ИЗ
	               |						Документ.ВводОстатковКниг.Книги КАК ВыдачаКнигКниги
	               |					ГДЕ
	               |						ВыдачаКнигКниги.Ссылка = &Ссылка)) КАК КнигиВБиблиотекеОстатки
	               |		ПО ВложенныйЗапрос.Книга = КнигиВБиблиотекеОстатки.Книга";
	Запрос.УстановитьПараметр("Ссылка", ЭтотОбъект.Ссылка);
	Запрос.УстановитьПараметр("ДатаКон", ЭтотОбъект.Дата);
	РезультатЗапроса = Запрос.Выполнить().Выгрузить();
	Для Каждого Строка Из РезультатЗапроса Цикл
		Если Строка.КоличествоРегистр >= Строка.КоличествоДокумент Тогда
			Сообщить(НСтр("ru = 'Уже введены остатки по позиции: '")+ Строка.Книга+ НСтр("ru = ' в строке: '") + Строка.НомерСтроки + НСтр("ru = ' Проведение отменено.'"), СтатусСообщения.Важное);
			Отказ = Истина;
			Возврат Ложь;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Истина;
	
КонецФункции

// Проверить установлена ли дата выдачи если расположение у абонента. Нужна для документа ввода остатков
Функция ПроверитьДатуВыдачи(ЭтотОбъект, Отказ) Экспорт
	
	Для Каждого Строка Из ЭтотОбъект.Книги Цикл
		Если Строка.МестоРазмещения <> Справочники.МестаРазмещения.Библиотека Тогда
			Если НЕ ЗначениеЗаполнено(Строка.ДатаВыдачи) Тогда
				Сообщить(НСтр("ru = 'В строке: '") + Строка.НомерСтроки + НСтр("ru = ' не указана дата выдачи'"));
				Отказ = Истина;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Отказ;
	
КонецФункции

// В строку записываем авторов книги и передаем как результат
Функция ПолучитьСтрокуАвторов(СсылкаНаКнигу) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	КнигиАвторы.Автор
	|ИЗ
	|	Справочник.Книги.Авторы КАК КнигиАвторы
	|ГДЕ
	|	КнигиАвторы.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", СсылкаНаКнигу);
	
	Результат = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = Результат.Выбрать();
	
	СтрокаАвторов = "";
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Если ЗначениеЗаполнено(СтрокаАвторов) Тогда
			СтрокаАвторов = СтрокаАвторов + ", ";
		КонецЕсли;
		СтрокаАвторов = СтрокаАвторов + ВыборкаДетальныеЗаписи.Автор;
	КонецЦикла;
	
	Возврат СтрокаАвторов;
	
КонецФункции

// Функция формирует получает максимальный инвентарный номер
Функция ПолучитьМаксимальныйИнвентарныйНомерКниги(КнигиСсылка) Экспорт
	
	ИнвентарныйНомер = "";
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	Книги.ИнвентарныйНомер КАК ИнвентарныйНомер
	|ИЗ
	|	Справочник.Книги КАК Книги
	|ГДЕ
	|	Книги.Ссылка <> &Ссылка
	|
	|УПОРЯДОЧИТЬ ПО
	|	ИнвентарныйНомер УБЫВ";
	
	Запрос.УстановитьПараметр("Ссылка", КнигиСсылка);
	Результат = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = Результат.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		ИнвентарныйНомер = ВыборкаДетальныеЗаписи.ИнвентарныйНомер;
	КонецЦикла;
	
	Возврат ИнвентарныйНомер;
	
КонецФункции

// Проверим остатки книг перед списанием
// НаДату - дата на которую нужно знать остатки
// МассивСсылокКниг - массив типа СправочникСсылка.Книги содержит книги которые надо узнать имеются ли в библиотеке
Функция ПроверитьОстаткиВБиблиотеке(Отказ, НаДату, МассивСсылокКниг)	Экспорт 
	
	Запрос = новый запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	КнигиВБиблиотекеОстатки.КоличествоОстаток,
	               |	КнигиВБиблиотекеОстатки.Книга,
	               |	КнигиВБиблиотекеОстатки.МестоРазмещения
	               |ИЗ
	               |	РегистрНакопления.КнигиВБиблиотеке.Остатки(
	               |			&ДатаКон,
	               |			Книга В (&МассивКниг)
	               |				И МестоРазмещения <> ЗНАЧЕНИЕ(Справочник.МестаРазмещения.Библиотека)) КАК КнигиВБиблиотекеОстатки";
	Запрос.УстановитьПараметр("МассивКниг", МассивСсылокКниг);
	Запрос.УстановитьПараметр("ДатаКон", НаДату);
	РезультатЗапроса = Запрос.Выполнить().Выбрать();
	МассивРезультата = Новый Массив; // Содержит массив книг которых нет в библиотеке
	Если РезультатЗапроса.Количество() > 0 Тогда
		Отказ = Истина;
		Пока РезультатЗапроса.Следующий() Цикл
			МассивРезультата.Добавить(РезультатЗапроса.Книга);
		КонецЦикла;
	КонецЕсли;
	
	Возврат МассивРезультата;
	
КонецФункции

// Делает запись об ошибке в журнал регистрации
//
// Параметры:
//  КраткоеОписаниеОшибки 	- Строка - Короткое описание ошибки
//  ОбъектМетаданных 		- Метаданные - Метаданные в которых произошла ошибка
//  Данные 					- Ссылочные типы - Ссылка на объект. связанный с ошибкой
//  ОписаниеОшибки 			- Строка - Описание ошибки
//
Процедура ЗафиксироватьОшибку(КраткоеОписаниеОшибки, ОписаниеОшибки, ОбъектМетаданных = Неопределено, Данные = Неопределено) Экспорт

	ЗаписьЖурналаРегистрации(КраткоеОписаниеОшибки, УровеньЖурналаРегистрации.Ошибка, ОбъектМетаданных, Данные, ОписаниеОшибки)

КонецПроцедуры // ЗафиксироватьОшибку()

// Функция - Загрузить файл по ссылке
//
// Параметры:
//  СсылкаНаФайл - Строка - Ссылка на файл в сети интернет
// 
// Возвращаемое значение:
//  Строка - Имя временного файла, который был скачан
//
Функция ЗагрузитьФайлПоСсылке(СсылкаНаФайл, РасширениеФайла = Неопределено) Экспорт
	
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла(РасширениеФайла);
	Попытка
		КопироватьФайл(СсылкаНаФайл, ИмяВременногоФайла);
	Исключение
		СообщениеПользователю = Новый СообщениеПользователю;
		СообщениеПользователю.Текст = НСтр("ru = 'Не удалось загрузить файл по ссылке'");
		СообщениеПользователю.Сообщить();
		ОписаниеОшибки = ОписаниеОшибки();
		ОбщегоНазначенияСервер.ЗафиксироватьОшибку(СообщениеПользователю.Текст, ОписаниеОшибки + Символы.ПС + НСтр("ru = 'Ссылка: '") + СсылкаНаФайл, Метаданные.РегистрыСведений.КаталогКниг, Неопределено);
		Возврат Неопределено;
	КонецПопытки;
	
	Файл = Новый Файл(ИмяВременногоФайла);
	
	Если Не Файл.Существует() Тогда
		СообщениеПользователю = Новый СообщениеПользователю;
		СообщениеПользователю.Текст = НСтр("ru = 'Не удалось загрузить файл по ссылке'");
		СообщениеПользователю.Сообщить();
		ОбщегоНазначенияСервер.ЗафиксироватьОшибку(СообщениеПользователю.Текст, НСтр("ru = 'Ссылка: '") + СсылкаНаФайл, Метаданные.РегистрыСведений.КаталогКниг, Неопределено);
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат ИмяВременногоФайла
	
КонецФункции

// Принимает список книг или групп книг и выдает список книг, в который входят переданные книги плюс книги указанных групп
// 
// Параметры:
// 	СписокКнигСГруппами - Массив(СправочникСсылка.Книги) - Список книг и/или групп книг
// Возвращаемое значение:
// 	Массив - Список книг
//
Функция РазложитьГруппыКниг(СписокКнигСГруппами) Экспорт
	
	ВыбранныеКниги = Новый Массив();
	ВыбранныеГруппыКниг = Новый Массив();
	
	// Среди выделенных разделяем книги и группы
	Для Каждого Элемент Из СписокКнигСГруппами Цикл
		// Если есть неопределено, то это корень - надо добавить все
		Если Не ЗначениеЗаполнено(Элемент) Тогда
			ВыбранныеГруппыКниг.Добавить(ПредопределенноеЗначение("Справочник.Книги.ПустаяСсылка"));
			Продолжить;
		КонецЕсли;		
		Если Элемент.ЭтоГруппа Тогда
			ВыбранныеГруппыКниг.Добавить(Элемент);
		Иначе
			ВыбранныеКниги.Добавить(Элемент);
		КонецЕсли;
	КонецЦикла;
	
	// Группы раскрываем и добавляем книги входящие в группу
	ВыбранныеКнигиИзГрупп = Новый Массив();
	
	Для Каждого ГруппаКниг Из ВыбранныеГруппыКниг Цикл
		КнигиВГруппе = Справочники.Книги.КнигиВГруппе(ГруппаКниг);
		Для Каждого Книга Из КнигиВГруппе Цикл
			ВыбранныеКнигиИзГрупп.Добавить(Книга);
		КонецЦикла;
	КонецЦикла;
	
	Для Каждого Книга Из ВыбранныеКнигиИзГрупп Цикл
		ВыбранныеКниги.Добавить(Книга);
	КонецЦикла;
	
	Возврат ВыбранныеКниги;
	
КонецФункции
