////////////////////////////////////////////////////////////////////////////////
// Процедуры и функции программного интерфейса


// Получает значение параметра сеанса "Текущий пользователь"
//
// Возвращаемое значение:
//  СправочникСсылка.Пользователи
//
Функция ТекущийПользователь() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Возврат ПараметрыСеанса.ТекущийПользователь;
	
КонецФункции

// Функция ЭтоПолноправныйПользовательИБ проверяет,
// является ли полноправным текущий пользователь ИБ или
// пользователь ИБ заданного пользователя (обычного или внешнего).
//
//  Полноправными считается:
// а) пользователь ИБ при пустом списке пользователей ИБ,
//    если основная роль не задана или ПолныеПрава,
// б) пользователь ИБ с ролью ПолныеПрава.
//
//
// Параметры:
//  Пользователь - Неопределено (проверяется текущий пользователь ИБ),
//                 Справочник.Пользователи(осуществляется поиск пользователя ИБ по уникальному
//                  идентификатору, заданному в реквизите ИдентификаторПользователяИБ,
//                  если пользователь ИБ не найден, возвращается Ложь).
//
// Возвращаемое значение:
//  Булево.
//
Функция ЭтоПолноправныйПользовательИБ(Пользователь = Неопределено) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если ЗначениеЗаполнено(Пользователь) И Пользователь <> ПараметрыСеанса.ТекущийПользователь Тогда
		ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(БСП.ПолучитьЗначенияРеквизитов(Пользователь, "ИдентификаторПользователяИБ"));
		Если ПользовательИБ = Неопределено Тогда
			Возврат Ложь;
		КонецЕсли;
	Иначе
		ПользовательИБ = ПользователиИнформационнойБазы.ТекущийПользователь();
	КонецЕсли;
	
	Если ПользовательИБ.УникальныйИдентификатор = ПользователиИнформационнойБазы.ТекущийПользователь().УникальныйИдентификатор Тогда
		
		Если ЗначениеЗаполнено(ПользовательИБ.Имя) Тогда
			
			Возврат РольДоступна("ПолныеПрава") ИЛИ ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(ПользователиИнформационнойБазы.ТекущийПользователь().УникальныйИдентификатор).Роли.Содержит(Метаданные.Роли.ПолныеПрава);
		Иначе
			// Авторизован пустой пользователь - список пользователей пуст,
			// если основная роль пустая - все права разрешены.
			// С версии 8.3 ОсновнуюРоль переименовали в ОсновныеРоли
			Если Метаданные.ОсновныеРоли.Количество() = 0 ИЛИ
				 Метаданные.ОсновныеРоли.Содержит(Метаданные.Роли.ПолныеПрава) Тогда				
				Возврат Истина;
			Иначе
				Возврат Ложь;
			КонецЕсли;
		КонецЕсли;
	Иначе
		Возврат ПользовательИБ.Роли.Содержит(Метаданные.Роли.ПолныеПрава);
	КонецЕсли;
	
КонецФункции

// Функция ПолноеИмяНеУказанногоПользователя возвращает
// представление не указанного пользователя, т.е. когда
// список пользователей пуст.
// 
// Возвращаемое значение:
//  Строка.
//
Функция ПолноеИмяНеУказанногоПользователя() Экспорт
	
	Возврат НСтр("ru = '<Не указан>'");
	
КонецФункции

// Функция СоздатьПервогоАдминистратора используется
// при обновлении и начальном заполнении информационной базы
//  При использовании подсистемы УправлениеДоступом
// первый администратор будет автоматически включен
// в группу доступа Администраторы (если действие встроено)
//
// Параметры:
//  УчетнаяЗапись - ПользовательИнформационнойБазы - используется
//                  когда нужно создать первого администратора из уже имеющегося
//                  пользователя ИБ (см. функцию Пользователи.ОшибкаАвторизации())
//
// Возвращаемое значение:
//  Неопределено - пользователь связанный с пользователем ИБ с административными правами уже существует,
//  СправочникСсылка.Пользователи - пользователь с которым связан администратор
//
Функция СоздатьПервогоАдминистратора(УчетнаяЗапись = Неопределено) Экспорт
	
	// Добавление администратора (администратор системы - полные права).
	
	Если УчетнаяЗапись = Неопределено Тогда
		// Если существует пользователь с правом администрирование,
		// тогда первый администратор уже создан и его не требуется создавать.
		УчетнаяЗапись = Неопределено;
		Для каждого ПользовательИБ Из ПользователиИнформационнойБазы.ПолучитьПользователей() Цикл
			Если ПользовательИБ.Роли.Содержит(Метаданные.Роли.ПолныеПрава) Тогда
				Возврат Неопределено;
			КонецЕсли;
		КонецЦикла;
		Если УчетнаяЗапись = Неопределено Тогда
			УчетнаяЗапись = ПользователиИнформационнойБазы.СоздатьПользователя();
			УчетнаяЗапись.Имя       = "Администратор";
			УчетнаяЗапись.ПолноеИмя = УчетнаяЗапись.Имя;
			УчетнаяЗапись.Роли.Очистить();
			УчетнаяЗапись.Роли.Добавить(Метаданные.Роли.ПолныеПрава);
			УчетнаяЗапись.Записать();
		КонецЕсли;
	КонецЕсли;
	
	Если ПользовательПоИдентификаторуСуществует(УчетнаяЗапись.УникальныйИдентификатор) Тогда
		Пользователь = Справочники.Пользователи.НайтиПоРеквизиту("ИдентификаторПользователяИБ", УчетнаяЗапись.УникальныйИдентификатор);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Пользователь) Тогда
		Пользователь = Справочники.Пользователи.НайтиПоНаименованию(УчетнаяЗапись.ПолноеИмя);
		Если ЗначениеЗаполнено(Пользователь)
		   И ЗначениеЗаполнено(Пользователь.ИдентификаторПользователяИБ)
		   И Пользователь.ИдентификаторПользователяИБ <> УчетнаяЗапись.УникальныйИдентификатор
		   И ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(Пользователь.ИдентификаторПользователяИБ) <> Неопределено Тогда
			Пользователь = Неопределено;
		КонецЕсли;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Пользователь) Тогда
		Пользователь = Справочники.Пользователи.СоздатьЭлемент();
		ПользовательСоздан = Истина;
	Иначе
		Пользователь = Пользователь.ПолучитьОбъект();
		ПользовательСоздан = Ложь;
	КонецЕсли;
	Пользователь.ИдентификаторПользователяИБ = УчетнаяЗапись.УникальныйИдентификатор;
	Пользователь.Наименование = УчетнаяЗапись.ПолноеИмя;
	Пользователь.ОбменДанными.Загрузка = Истина;
	Пользователь.Записать();
	Если ПользовательСоздан Тогда
		ОбновитьСоставГруппПользователей(Справочники.ГруппыПользователей.ВсеПользователи);
	КонецЕсли;
	
	Возврат Пользователь.Ссылка;
	
КонецФункции

// Функция выполняет поиск элемента справочника Пользователи
// по имени пользователя информационной базы
// Параметры
//  ИмяПользователя - строка - имя пользователя информационной базы
// Возвращаемое значение
//  ссылка на пользователя типа СправочникСсылка.Пользователи,
//  если элемент справочника не найден, возвращается пустая ссылка,
//  если пользователь ИБ не найден, возвращается Неопределено.
//
// Примечание: В случае, если пользователь имеет административные права,
//	то допускается поиск любого пользователя. Если пользователь не имеет
//	административных прав, то допускается поиск только того пользователя,
//	под которым данный пользователь авторизовался.
//
Функция НайтиПоИмени(знач ИмяПользователяИБ) Экспорт
	
	ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоИмени(ИмяПользователяИБ);
	
	Если ПользовательИБ = Неопределено Тогда
		Возврат Неопределено;
	Иначе
		Возврат Справочники.Пользователи.НайтиПоРеквизиту("ИдентификаторПользователяИБ", ПользовательИБ.УникальныйИдентификатор);
	КонецЕсли;
	
КонецФункции


////////////////////////////////////////////////////////////////////////////////
// Процедуры и функции подсистемы для внутренних нужд

// Функция ПрочитатьПользователяИБ считывает свойства пользователя
// информационной базы по строковому или уникальному идентификатору.
//
// Параметры:
//  Идентификатор - Неопределено, Строка, УникальныйИдентификатор (идентификатор пользователя).
//  Свойства     - Структура:
//                 ПользовательИнфБазыУникальныйИдентификатор   - УникальныйИдентификатор
//                 ПользовательИнфБазыИмя                       - Строка
//                 ПользовательИнфБазыПолноеИмя                 - Строка
//
//                 ПользовательИнфБазыАутентификацияСтандартная - Булево
//                 ПользовательИнфБазыПоказыватьВСпискеВыбора   - Булево
//                 ПользовательИнфБазыПароль                    - Неопределено
//                 ПользовательИнфБазыСохраняемоеЗначениеПароля - Строка
//                 ПользовательИнфБазыПарольУстановлен          - Булево
//                 ПользовательИнфБазыЗапрещеноИзменятьПароль   - Булево
//
//                 ПользовательИнфБазыАутентификацияОС          - Булево
//                 ПользовательИнфБазыПользовательОС            - Строка
//
//                 ПользовательИнфБазыОсновнойИнтерфейс         - Строка (имя интерфейса из коллекции Метаданные.Интерфейсы)
//                 ПользовательИнфБазыРежимЗапуска              - Строка (значения: "Авто", "ОбычноеПриложение", "УправляемоеПриложение")
//                 ПользовательИнфБазыЯзык                      - Строка (имя языка из коллекции Метаданные.Языки)
//
//  Роли           - Массив значений типа Строка (имена ролей из коллекции Метаданные.Роли)
//  
//  ОписаниеОшибки - Строка, содержит описание ошибки, если чтение не удалось.
//
// Возвращаемое значение:
//  Булево,
//  если Истина - успех, иначе отказ, см. ОписаниеОшибки.
//
Функция ПрочитатьПользователяИБ(Знач Идентификатор, Свойства = Неопределено, Роли = Неопределено, ОписаниеОшибки = "", ПользовательИБ = Неопределено) Экспорт
	
	// Подготовка структур возвращаемых данных
	Свойства = Новый Структура;
	Свойства.Вставить("ПользовательИнфБазыУникальныйИдентификатор",   Новый УникальныйИдентификатор);
	Свойства.Вставить("ПользовательИнфБазыИмя",                       "");
	Свойства.Вставить("ПользовательИнфБазыПолноеИмя",                 "");
	Свойства.Вставить("ПользовательИнфБазыАутентификацияСтандартная", Ложь);
	Свойства.Вставить("ПользовательИнфБазыПоказыватьВСпискеВыбора",   Ложь);
	Свойства.Вставить("ПользовательИнфБазыПароль",                    Неопределено);
	Свойства.Вставить("ПользовательИнфБазыСохраняемоеЗначениеПароля", "");
	Свойства.Вставить("ПользовательИнфБазыПарольУстановлен",          Ложь);
	Свойства.Вставить("ПользовательИнфБазыЗапрещеноИзменятьПароль",   Ложь);
	Свойства.Вставить("ПользовательИнфБазыАутентификацияОС",          Ложь);
	Свойства.Вставить("ПользовательИнфБазыПользовательОС",            "");
	Свойства.Вставить("ПользовательИнфБазыОсновнойИнтерфейс",         ?(Метаданные.ОсновнойИнтерфейс = Неопределено, "", Метаданные.ОсновнойИнтерфейс.Имя));
	Свойства.Вставить("ПользовательИнфБазыРежимЗапуска",              "Авто");
	Свойства.Вставить("ПользовательИнфБазыЯзык",                      ?(Метаданные.ОсновнойЯзык = Неопределено, "", Метаданные.ОсновнойЯзык.Имя));
	
	Роли = Новый Массив;
	
	Если ТипЗнч(Идентификатор) = Тип("УникальныйИдентификатор") Тогда
		ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(Идентификатор);
	ИначеЕсли ТипЗнч(Идентификатор) = Тип("Строка") Тогда
		ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоИмени(Идентификатор);
	Иначе
		ПользовательИБ = Неопределено;
	КонецЕсли;
	
	Если ПользовательИБ = Неопределено Тогда
		ОписаниеОшибки = БСП.ПодставитьПараметрыВСтроку(НСтр("ru = 'Пользователь информационной базы ""%1""' не найден!"), Идентификатор);
		Возврат Ложь;
	КонецЕсли;
	
	Свойства.ПользовательИнфБазыУникальныйИдентификатор     = ПользовательИБ.УникальныйИдентификатор;
	Свойства.ПользовательИнфБазыИмя                         = ПользовательИБ.Имя;
	Свойства.ПользовательИнфБазыПолноеИмя                   = ПользовательИБ.ПолноеИмя;
	Свойства.ПользовательИнфБазыАутентификацияСтандартная   = ПользовательИБ.АутентификацияСтандартная;
	Свойства.ПользовательИнфБазыПоказыватьВСпискеВыбора     = ПользовательИБ.ПоказыватьВСпискеВыбора;
	Свойства.ПользовательИнфБазыСохраняемоеЗначениеПароля   = ПользовательИБ.СохраняемоеЗначениеПароля;
	Свойства.ПользовательИнфБазыПарольУстановлен            = ПользовательИБ.ПарольУстановлен;
	Свойства.ПользовательИнфБазыЗапрещеноИзменятьПароль     = ПользовательИБ.ЗапрещеноИзменятьПароль;
	Свойства.ПользовательИнфБазыАутентификацияОС            = ПользовательИБ.АутентификацияОС;
	Свойства.ПользовательИнфБазыПользовательОС              = ПользовательИБ.ПользовательОС;
	Свойства.ПользовательИнфБазыОсновнойИнтерфейс           = ?(ПользовательИБ.ОсновнойИнтерфейс = Неопределено, "", ПользовательИБ.ОсновнойИнтерфейс.Имя);
	Свойства.ПользовательИнфБазыРежимЗапуска                = ?(ПользовательИБ.РежимЗапуска = РежимЗапускаКлиентскогоПриложения.ОбычноеПриложение,
	                                                            "ОбычноеПриложение",
	                                                            ?(ПользовательИБ.РежимЗапуска = РежимЗапускаКлиентскогоПриложения.УправляемоеПриложение,
	                                                              "УправляемоеПриложение",
	                                                              "Авто"));
	Свойства.ПользовательИнфБазыЯзык                        = ?(ПользовательИБ.Язык = Неопределено, "", ПользовательИБ.Язык.Имя);
	
	Для каждого Роль Из ПользовательИБ.Роли Цикл
		Роли.Добавить(Роль.Имя);
	КонецЦикла;
	
	Возврат Истина;
	
КонецФункции

// Функция ЗаписатьПользователяИБ
// либо перезаписывает свойства пользователяИБ,
//      найденного по строковому или уникальному идентификатору,
// либо создает нового пользователяИБ, когда задано создать,
//      при этом, если пользовательИБ найден будет ошибка
//
// Параметры:
//  Идентификатор - Строка, УникальныйИдентификатор (идентификатор пользователя).
//  НовыеСвойства - Структура (свойство может быть не задано,
//                            тогда используется прочитанное или начальное значение)
//                 ПользовательИнфБазыУникальныйИдентификатор   - Неопределено (задается после записи пользователя ИБ)
//                 ПользовательИнфБазыИмя                       - Неопределено, Строка
//                 ПользовательИнфБазыПолноеИмя                 - Неопределено, Строка
//
//                 ПользовательИнфБазыАутентификацияСтандартная - Неопределено, Булево
//                 ПользовательИнфБазыПоказыватьВСпискеВыбора   - Неопределено, Булево
//                 ПользовательИнфБазыПароль                    - Неопределено, Строка
//                 ПользовательИнфБазыСохраняемоеЗначениеПароля - Неопределено, Строка
//                 ПользовательИнфБазыПарольУстановлен          - Неопределено, Булево
//                 ПользовательИнфБазыЗапрещеноИзменятьПароль   - Неопределено, Булево
//
//                 ПользовательИнфБазыАутентификацияОС          - Неопределено, Булево
//                 ПользовательИнфБазыПользовательОС            - Неопределено, Строка
//
//                 ПользовательИнфБазыОсновнойИнтерфейс         - Неопределено, Строка (имя интерфейса из коллекции Метаданные.Интерфейсы)
//                 ПользовательИнфБазыРежимЗапуска              - Неопределено, Строка (значения: "Авто", "ОбычноеПриложение", "УправляемоеПриложение")
//                 ПользовательИнфБазыЯзык                      - Неопределено, Строка (имя языка из коллекции Метаданные.Языки)
//
//  НовыеРоли      - Неопределено, Массив значений типа Строка (имена ролей из коллекции Метаданные.Роли)
//
//  ОписаниеОшибки - Строка, содержит описание ошибки, если чтение не удалось.
//
// Возвращаемое значение:
//  Булево,
//  если Истина - успех, иначе отказ, см. ОписаниеОшибки.
//
Функция ЗаписатьПользователяИБ(Знач Идентификатор, Знач НовыеСвойства, Знач НовыеРоли, Знач СоздатьНового = Ложь, ОписаниеОшибки = "") Экспорт
	
	ПользовательИБ = Неопределено;
	СтарыеСвойства = Неопределено;
	СтарыеРоли     = Неопределено;
	Свойства       = Неопределено;
	Роли           = Неопределено;
	
	ПредварительноеЧтение = ПрочитатьПользователяИБ(Идентификатор, СтарыеСвойства, СтарыеРоли, ОписаниеОшибки);
	
	Если НЕ ПрочитатьПользователяИБ(Идентификатор, Свойства, Роли, ОписаниеОшибки, ПользовательИБ) ИЛИ НЕ ПредварительноеЧтение Тогда
		
		Если СоздатьНового Тогда
			ПользовательИБ = ПользователиИнформационнойБазы.СоздатьПользователя();
		Иначе
			Возврат Ложь;
		КонецЕсли;
	ИначеЕсли СоздатьНового Тогда
		ОписаниеОшибки = БСП.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Невозможно создать пользователя информационной базы ""%1""
		                                        |так как он уже существует!'"),
				Идентификатор);
		Возврат Ложь;
	КонецЕсли;
	
	// Подготовка новых значений свойств
	Для каждого КлючИЗначение Из Свойства Цикл
		Если НовыеСвойства.Свойство(КлючИЗначение.Ключ) И НовыеСвойства[КлючИЗначение.Ключ] <> Неопределено Тогда
			Свойства[КлючИЗначение.Ключ] = НовыеСвойства[КлючИЗначение.Ключ];
		КонецЕсли;
	КонецЦикла;
	
	Если НовыеРоли <> Неопределено Тогда
		Роли = НовыеРоли;
	КонецЕсли;
	
	// Установка новых значений свойств
	
	ПользовательИБ.Имя                         = Свойства.ПользовательИнфБазыИмя;
	ПользовательИБ.ПолноеИмя                   = Свойства.ПользовательИнфБазыПолноеИмя;
	ПользовательИБ.АутентификацияСтандартная   = Свойства.ПользовательИнфБазыАутентификацияСтандартная;
	ПользовательИБ.ПоказыватьВСпискеВыбора     = Свойства.ПользовательИнфБазыПоказыватьВСпискеВыбора;
	Если Свойства.ПользовательИнфБазыПароль <> Неопределено Тогда
		ПользовательИБ.Пароль                  = Свойства.ПользовательИнфБазыПароль;
	КонецЕсли;
	ПользовательИБ.ЗапрещеноИзменятьПароль     = Свойства.ПользовательИнфБазыЗапрещеноИзменятьПароль;
	ПользовательИБ.АутентификацияОС            = Свойства.ПользовательИнфБазыАутентификацияОС;
	ПользовательИБ.ПользовательОС              = Свойства.ПользовательИнфБазыПользовательОС;
	Если ЗначениеЗаполнено(Свойства.ПользовательИнфБазыОсновнойИнтерфейс) Тогда
	    ПользовательИБ.ОсновнойИнтерфейс       = Метаданные.Интерфейсы[Свойства.ПользовательИнфБазыОсновнойИнтерфейс];
	Иначе
	    ПользовательИБ.ОсновнойИнтерфейс       = Неопределено;
	КонецЕсли;
	Если ЗначениеЗаполнено(Свойства.ПользовательИнфБазыРежимЗапуска) Тогда
	    ПользовательИБ.РежимЗапуска            = РежимЗапускаКлиентскогоПриложения[Свойства.ПользовательИнфБазыРежимЗапуска];
	КонецЕсли;
	Если ЗначениеЗаполнено(Свойства.ПользовательИнфБазыЯзык) Тогда
	    ПользовательИБ.Язык                    = Метаданные.Языки[Свойства.ПользовательИнфБазыЯзык];
	Иначе
	    ПользовательИБ.Язык                    = Неопределено;
	КонецЕсли;
	
	ПользовательИБ.Роли.Очистить();
	Для каждого Роль Из Роли Цикл
		ПользовательИБ.Роли.Добавить(Метаданные.Роли[Роль]);
	КонецЦикла;
	
	// Добавление роли ПолныеПрава, при попытке создать первого пользователя с пустым списком ролей
	Если ПользователиИнформационнойБазы.ПолучитьПользователей().Количество() = 0 И
	     НЕ ПользовательИБ.Роли.Содержит(Метаданные.Роли.ПолныеПрава) Тогда
		
		ПользовательИБ.Роли.Добавить(Метаданные.Роли.ПолныеПрава);
	КонецЕсли;
	
	// Попытка записи нового или измененного пользователяИБ
	Попытка
		ПользовательИБ.Записать();
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		Если ИнформацияОбОшибке.Причина = Неопределено Тогда
			ОписаниеОшибки = ИнформацияОбОшибке.Описание;
		Иначе
			ОписаниеОшибки = ИнформацияОбОшибке.Причина.Описание;
		КонецЕсли;
		ОписаниеОшибки = НСтр("ru = 'Ошибка при записи пользователя информационной базы:'") + Символы.ПС + ОписаниеОшибки;
		Возврат Ложь;
	КонецПопытки;
	
	НовыеСвойства.ПользовательИнфБазыУникальныйИдентификатор = ПользовательИБ.УникальныйИдентификатор;
	
	Возврат Истина;
	
КонецФункции

// Функция удаляет пользователя информационной базы
// по строковому или уникальному идентификатору.
//
// Параметры:
//  ОписаниеОшибки - Строка, содержит описание ошибки, если чтение не удалось.
//
// Возвращаемое значение:
//  Булево,
//  если Истина - успех, иначе отказ, см. ОписаниеОшибки.
//
Функция УдалитьПользователяИБ(Знач Идентификатор, ОписаниеОшибки = "") Экспорт
	
	ПользовательИБ = Неопределено;
	Свойства       = Неопределено;
	Роли           = Неопределено;
	
	Если НЕ ПрочитатьПользователяИБ(Идентификатор, Свойства, Роли, ОписаниеОшибки, ПользовательИБ) Тогда
		Возврат Ложь;
	Иначе
		Попытка
			ПользовательИБ.Удалить();
		Исключение
			ОписаниеОшибки = НСтр("ru = 'Ошибка при удалении пользователя информационной базы:'") + Символы.ПС + ИнформацияОбОшибке().Причина.Описание;
			Возврат Ложь;
		КонецПопытки;
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

// Функция проверяет существования пользователя информационной базы
// Параметры
// Идентификатор - УникальныйИдентификатор, Строка
//                 УИД пользователяИБ или Имя пользователяИБ
//
// Возвращаемое значение:
//  Булево
//
Функция ПользовательИБСуществует(Знач Идентификатор) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если ТипЗнч(Идентификатор) = Тип("УникальныйИдентификатор") Тогда
		ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(Идентификатор);
	Иначе
		ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоИмени(Идентификатор);
	КонецЕсли;
	
	Если ПользовательИБ = Неопределено Тогда
		Возврат Ложь;
	Иначе
		Возврат Истина;
	КонецЕсли;
	
КонецФункции

// Процедура, определяет пользователя, под которым запущен сеанс и пытается
// найти соответсвие ему в справочнике Пользователи. Если соответствие
// не найдено - создается новый элемент. Параметр сеанса ТекущийПользователь
// устанавливается как ссылка на найденный (созданный) элемент справочника.
//
Процедура ОпределитьТекущегоПользователя() Экспорт

		// Если пользовательесть попытаемся найти его в справочнике	
	ИдентификаторПользователяИБ = ПользователиИнформационнойБазы.ТекущийПользователь().УникальныйИдентификатор;
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
		|	Пользователи.Ссылка
		|ИЗ
		|	Справочник.Пользователи КАК Пользователи
		|ГДЕ
		|	Пользователи.ИдентификаторПользователяИБ = &ИдентификаторПользователяИБ";

	Запрос.УстановитьПараметр("ИдентификаторПользователяИБ", ИдентификаторПользователяИБ);

	Результат = Запрос.Выполнить().Выгрузить();

	Если Результат.Количество() = 1 Тогда
	// Пользователь найден, получим его ссылку
		ПараметрыСеанса.ТекущийПользователь = Результат[0].Ссылка;
	ИначеЕсли Результат.Количество() > 1 Тогда
	// Несколько одинаковых пользователей
		Сообщить("В справочнике пользователей имеется два одинаковых пользователя");
	Иначе
	// Пользователь не найден - создадим		
		Пользователь = Справочники.Пользователи.СоздатьЭлемент();
		Пользователь.Наименование = ПользователиИнформационнойБазы.ТекущийПользователь().Имя;
		Пользователь.ПолноеНаименование = ПользователиИнформационнойБазы.ТекущийПользователь().ПолноеИмя;
		Пользователь.ИдентификаторПользователяИБ = ИдентификаторПользователяИБ;
		Пользователь.Записать();
	КонецЕсли;

КонецПроцедуры

// Функция определяет наличие элемента в справочнике Пользователи
// по уникальному идентификатору пользователя информационной.
//  Функция используется для проверки связи пользователяИБ только
// с одним элементом справочников Пользователи.
//
// Параметры:
//  УникальныйИдентификатор - УникальныйИдентификатор пользователя ИБ
//  СсылкаНаТекущего - СправочникСсылка.Пользователи
//                     Неопределено, - когда параметр задан
//                     указанная ссылка исключается из поиска,
//                     т.е. может быть найден только другой элемент.
//
// Возвращаемое значение:
//  Булево.
//
Функция ПользовательПоИдентификаторуСуществует(УникальныйИдентификатор, СсылкаНаТекущего = Неопределено) Экспорт

	УстановитьПривилегированныйРежим(Истина);

	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
		|	ИСТИНА КАК ЗначениеИстина
		|ИЗ
		|	Справочник.Пользователи КАК Пользователи
		|ГДЕ
		|	Пользователи.ИдентификаторПользователяИБ = &УникальныйИдентификатор
		|	И Пользователи.Ссылка <> &СсылкаНаТекущего";
	Запрос.УстановитьПараметр("СсылкаНаТекущего", СсылкаНаТекущего);
	Запрос.УстановитьПараметр("УникальныйИдентификатор", УникальныйИдентификатор);

	Возврат НЕ Запрос.Выполнить().Пустой();

КонецФункции

// Функция проверяет связан ли пользовательИБ с указанным
// именем с элементом справочника Пользователи
// Если пользователь не найден, значит тоже не связан
// 
// Параметры:
//  ИмяПользователя - Строка
//
// Возвращаемое значение:
//  Булево.
//
Функция ПользовательИБНеЗанят(знач ИмяПользователя) Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоИмени(ИмяПользователя);
	
	Если ПользовательИБ = Неопределено Тогда
		Возврат Истина;
	КонецЕсли;
	
	Если ПользовательПоИдентификаторуСуществует(ПользовательИБ.УникальныйИдентификатор) Тогда
		Возврат Ложь;
	Иначе
		Возврат Истина;
	КонецЕсли
	
КонецФункции

// Процедура ОбновитьСоставГруппПользователей обновляет в регистре сведений
// "Состав групп пользователей" соответствие групп пользователей и пользователей
// с учетом иерархии групп пользователей (родитель включает пользователей порожденных групп).
//  Эти данные требуются для формы списка и формы выбора пользователей.
//  Данные регистра могут быть применены в других целях для повышения производительности,
// т.к. не требуется работать с иерархией на языке запросов.
//
// Параметры:
//  ГруппаПользователей - СправочникСсылка.ГруппыПользователей
//
Процедура ОбновитьСоставГруппПользователей(Знач ГруппаПользователей) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ГруппаПользователей) Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	// Подготовка групп родителей.
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	ТаблицаГруппРодителей.Родитель,
	|	ТаблицаГруппРодителей.Ссылка
	|ПОМЕСТИТЬ ТаблицаГруппРодителей
	|ИЗ
	|	&ТаблицаГруппРодителей КАК ТаблицаГруппРодителей");
	Запрос.УстановитьПараметр("ТаблицаГруппРодителей", ТаблицаГруппРодителей("Справочник.ГруппыПользователей"));
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	Запрос.Выполнить();
	
	// Выполнение для текущий группы и каждой группы-родителя.
	Пока НЕ ГруппаПользователей.Пустая() Цикл
		
		Запрос.УстановитьПараметр("ГруппаПользователей", ГруппаПользователей);
		
		Если ГруппаПользователей <> Справочники.ГруппыПользователей.ВсеПользователи Тогда
			// Удаление связей для удаленных пользователей.
			Запрос.Текст =
			"ВЫБРАТЬ РАЗЛИЧНЫЕ
			|	СоставГруппПользователей.Пользователь
			|ИЗ
			|	РегистрСведений.СоставГруппПользователей КАК СоставГруппПользователей
			|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ГруппыПользователей.Состав КАК ГруппыПользователейСостав
			|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ ТаблицаГруппРодителей КАК ТаблицаГруппРодителей
			|			ПО (ТаблицаГруппРодителей.Ссылка = ГруппыПользователейСостав.Ссылка)
			|				И (ТаблицаГруппРодителей.Родитель = &ГруппаПользователей)
			|		ПО (СоставГруппПользователей.ГруппаПользователей = &ГруппаПользователей)
			|			И СоставГруппПользователей.Пользователь = ГруппыПользователейСостав.Пользователь
			|ГДЕ
			|	СоставГруппПользователей.ГруппаПользователей = &ГруппаПользователей
			|	И ГруппыПользователейСостав.Ссылка ЕСТЬ NULL ";
			ПользователиУдаленныеИзГруппы = Запрос.Выполнить().Выбрать();
			МенеджерЗаписи = РегистрыСведений.СоставГруппПользователей.СоздатьМенеджерЗаписи();
			Пока ПользователиУдаленныеИзГруппы.Следующий() Цикл
				МенеджерЗаписи.ГруппаПользователей = ГруппаПользователей;
				МенеджерЗаписи.Пользователь        = ПользователиУдаленныеИзГруппы.Пользователь;
				МенеджерЗаписи.Удалить();
			КонецЦикла;
		КонецЕсли;
		
		// Добавление связей для добавленных пользователей.
		Если ГруппаПользователей = Справочники.ГруппыПользователей.ВсеПользователи Тогда
			Запрос.Текст =
			"ВЫБРАТЬ
			|	ЗНАЧЕНИЕ(Справочник.ГруппыПользователей.ВсеПользователи) КАК ГруппаПользователей,
			|	Пользователи.Ссылка КАК Пользователь
			|ИЗ
			|	Справочник.Пользователи КАК Пользователи
			|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СоставГруппПользователей КАК СоставГруппПользователей
			|		ПО (СоставГруппПользователей.ГруппаПользователей = ЗНАЧЕНИЕ(Справочник.ГруппыПользователей.ВсеПользователи))
			|			И (СоставГруппПользователей.Пользователь = Пользователи.Ссылка)
			|ГДЕ
			|	СоставГруппПользователей.Пользователь ЕСТЬ NULL 
			|
			|ОБЪЕДИНИТЬ
			|
			|ВЫБРАТЬ
			|	Пользователи.Ссылка,
			|	Пользователи.Ссылка
			|ИЗ
			|	Справочник.Пользователи КАК Пользователи
			|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СоставГруппПользователей КАК СоставГруппПользователей
			|		ПО (СоставГруппПользователей.ГруппаПользователей = Пользователи.Ссылка)
			|			И (СоставГруппПользователей.Пользователь = Пользователи.Ссылка)
			|ГДЕ
			|	СоставГруппПользователей.Пользователь ЕСТЬ NULL ";
		Иначе
			Запрос.Текст =
			"ВЫБРАТЬ РАЗЛИЧНЫЕ
			|	&ГруппаПользователей КАК ГруппаПользователей,
			|	ГруппыПользователейСостав.Пользователь
			|ИЗ
			|	Справочник.ГруппыПользователей.Состав КАК ГруппыПользователейСостав
			|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ТаблицаГруппРодителей КАК ТаблицаГруппРодителей
			|		ПО (ТаблицаГруппРодителей.Ссылка = ГруппыПользователейСостав.Ссылка)
			|			И (ТаблицаГруппРодителей.Родитель = &ГруппаПользователей)
			|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СоставГруппПользователей КАК СоставГруппПользователей
			|		ПО (СоставГруппПользователей.ГруппаПользователей = &ГруппаПользователей)
			|			И (СоставГруппПользователей.Пользователь = ГруппыПользователейСостав.Пользователь)
			|ГДЕ
			|	СоставГруппПользователей.Пользователь ЕСТЬ NULL ";
		КонецЕсли;
		ПользователиДобавленныеВГруппу = Запрос.Выполнить().Выгрузить();
		Если ПользователиДобавленныеВГруппу.Количество() > 0 Тогда
			НаборЗаписей = РегистрыСведений.СоставГруппПользователей.СоздатьНаборЗаписей();
			НаборЗаписей.Загрузить(ПользователиДобавленныеВГруппу);
			НаборЗаписей.Записать(Ложь); // Добавление недостающих записей связей.
		КонецЕсли;
		
		ГруппаПользователей = БСП.ПолучитьЗначениеРеквизита(ГруппаПользователей, "Родитель");
	КонецЦикла;
	
КонецПроцедуры

// Функция ТаблицаГруппРодителей используется в процедурах ОбновитьСоставГруппПользователей,
// ОбновитьСоставГруппВнешнихПользователей.
//
Функция ТаблицаГруппРодителей(Таблица) Экспорт
	
	// Подготовка состава групп родителей.
	Запрос = Новый Запрос(
	"ВЫБРАТЬ
	|	ГруппыТаблицы.Ссылка,
	|	ГруппыТаблицы.Родитель
	|ИЗ
	|	" + Таблица + " КАК ГруппыТаблицы");
	ТаблицаЭлементов = Запрос.Выполнить().Выгрузить();
	ТаблицаЭлементов.Индексы.Добавить("Родитель");
	ТаблицаГруппРодителей = ТаблицаЭлементов.Скопировать(Новый Массив);
	
	Для каждого ОписаниеЭлемента Из ТаблицаЭлементов Цикл
		ОписаниеГруппыРодителя = ТаблицаГруппРодителей.Добавить();
		ОписаниеГруппыРодителя.Родитель = ОписаниеЭлемента.Ссылка;
		ОписаниеГруппыРодителя.Ссылка   = ОписаниеЭлемента.Ссылка;
		ЗаполнитьГруппыРодителя(ОписаниеЭлемента.Ссылка, ОписаниеЭлемента.Ссылка, ТаблицаЭлементов, ТаблицаГруппРодителей);
	КонецЦикла;
	
	Возврат ТаблицаГруппРодителей;
	
КонецФункции

Процедура ЗаполнитьГруппыРодителя(Знач Родитель, Знач ТекущийРодитель, Знач ТаблицаЭлементов, Знач ТаблицаРодителей)
	
	ОписанияГруппРодителя = ТаблицаЭлементов.НайтиСтроки(Новый Структура("Родитель", ТекущийРодитель));
	Для каждого ОписаниеГруппы Из ОписанияГруппРодителя Цикл
		ОписаниеГруппыРодителя = ТаблицаРодителей.Добавить();
		ОписаниеГруппыРодителя.Родитель = Родитель;
		ОписаниеГруппыРодителя.Ссылка   = ОписаниеГруппы.Ссылка;
		ЗаполнитьГруппыРодителя(Родитель, ОписаниеГруппы.Ссылка, ТаблицаЭлементов, ТаблицаРодителей);
	КонецЦикла;
	
КонецПроцедуры

// Процедура вызывается при начале работы системы
// чтобы проверить возможность выполнения авторизации
// и вызвать заполнение значений параметров сеанса
// ТекущийПользователь и ВнешнийПользователь
//
// Возвращаемое значение:
//  Строка - если не пустая строка, значит ошибка авторизации, следует завершить работу 1С:Предприятия
//
Функция ОшибкаАвторизации() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если ПустаяСтрока(ПользователиИнформационнойБазы.ТекущийПользователь().Имя)
	 ИЛИ ПользовательПоИдентификаторуСуществует(ПользователиИнформационнойБазы.ТекущийПользователь().УникальныйИдентификатор) Тогда
		// Авторизуется пользователь по умолчанию
		// или пользовательИБ найден в справочнике
		Возврат "";
	КонецЕсли;
	
	// Требуется, либо создать администратора, либо сообщить об отказе авторизации
	
	ТекстСообщенияОбОшибке = "";
	ТребуетсяСоздатьАдминистратора = Ложь;
	
	ПользователиИБ = ПользователиИнформационнойБазы.ПолучитьПользователей();
	
	Если ПользователиИБ.Количество() = 1
	 ИЛИ ПравоДоступа("Администрирование", Метаданные, ПользователиИнформационнойБазы.ТекущийПользователь()) Тогда
		// Авторизуется администратор, созданный в конфигураторе
		ТребуетсяСоздатьАдминистратора = Истина;
	Иначе
		// Авторизуется обычный пользователь, созданный в конфигураторе
		ТекстСообщенияОбОшибке = ТекстСообщенияПользовательНеНайденВСправочнике(ПользователиИнформационнойБазы.ТекущийПользователь().Имя);
	КонецЕсли;
	
	Если ТребуетсяСоздатьАдминистратора Тогда
		//
		Если РольДоступна("ПолныеПрава") Тогда
			//
			Пользователь = СоздатьПервогоАдминистратора(ПользователиИнформационнойБазы.ТекущийПользователь());
			//
			Комментарий = НСтр("ru = 'Обнаружено, что пользователь информационной базы
			                         |с ролью ""Полные права"" был создан в Конфигураторе:
			                         |
			                         |- пользователь не найден в справочнике Пользователи,
			                         |- пользователь зарегистрирован в справочнике Пользователи.
			                         |
			                         |Пользователей информационной базы следует создавать в режиме 1С:Предприятия.'");
			ЗаписьЖурналаРегистрации(
					"Пользователи.Администратор зарегистрирован в справочнике Пользователи",
					УровеньЖурналаРегистрации.Предупреждение,
					Метаданные.Справочники.Пользователи,
					Пользователь,
					Комментарий);
		Иначе
			ТекстСообщенияОбОшибке = НСтр("ru = 'Обнаружено, что пользователь информационной базы
			                                    |с правом Администрирование был создан в Конфигураторе.
			                                    |
			                                    |Для входа администратору требуется роль ""Полные права"".
			                                    |
			                                    |Пользователей информационной базы следует создавать в режиме 1С:Предприятия.
			                                    |
			                                    |Работа системы будет завершена.'");
		КонецЕсли;
	КонецЕсли;
	
	Возврат ТекстСообщенияОбОшибке;
	
КонецФункции

Функция ТекстСообщенияПользовательНеНайденВСправочнике(ИмяПользователя)

	ТекстСообщенияОбОшибке = НСтр("ru = 'Авторизация не выполнена. Работа системы будет завершена.
		|
		|Пользователь ""%1"" не найден в справочнике ""Пользователи"".
		|
		|Обратитесь к администратору.'");

	ТекстСообщенияОбОшибке = БСП.ПодставитьПараметрыВСтроку(ТекстСообщенияОбОшибке, ИмяПользователя);

	Возврат ТекстСообщенияОбОшибке;

КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Процедуры-обработчики обновления данных подсистемы


// Процедура вызывается при обновлении конфигурации на версию 1.0.5.15
// Выполняется перезапись всех пользователей.
// Возможен вызов с любой версии начиная с 1.0.5.15.
//
Процедура ЗаполнениеРегистраСоставГруппПользователей() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	Выборка = Справочники.Пользователи.Выбрать();
	Пока Выборка.Следующий() Цикл
		
		Объект = Выборка.ПолучитьОбъект();
		Объект.Записать();
		
	КонецЦикла;
	
КонецПроцедуры
