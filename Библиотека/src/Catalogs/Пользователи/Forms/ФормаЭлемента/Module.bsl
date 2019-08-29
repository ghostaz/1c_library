
////////////////////////////////////////////////////////////////////////////////
// Обработчики событий формы
//

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	//** Установка начальных значений
	//   перед загрузкой данных из настроек на сервере
	//   для случая, когда данные ещё не были записаны и не загружаются
	ПоказатьПодсистемыРолей = Истина;
	Элементы.РолиПоказатьПодсистемыРолей.Пометка = Истина;
	// Для нового элемента показать все роли, иначе только выбранные
	ПоказатьТолькоВыбранныеРоли                      = ЗначениеЗаполнено(Объект.Ссылка);
	Элементы.РолиПоказатьТолькоВыбранныеРоли.Пометка = ЗначениеЗаполнено(Объект.Ссылка);
	//
	ОбновитьДеревоРолей();
	
	//** Заполнение постоянных данных
	АвторизованПолноправныйПользователь = Пользователи.ЭтоПолноправныйПользовательИБ();
	
	// Заполнение списка выбора языка
	Для каждого МетаданныеЯзыка ИЗ Метаданные.Языки Цикл
		Элементы.ПредставлениеЯзыка.СписокВыбора.Добавить(МетаданныеЯзыка.Синоним);
	КонецЦикла;
	
	//** Подготовка к интерактивным действиям с учетом сценариев открытия формы
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если НЕ ЗначениеЗаполнено(Объект.Ссылка) Тогда
		// Создание нового элемента
		//Если Параметры.ГруппаНовогоПользователя <> Справочники.ГруппыПользователей.ВсеПользователи Тогда
		//	ГруппаНовогоПользователя = Параметры.ГруппаНовогоПользователя;
		//КонецЕсли;
		Если ЗначениеЗаполнено(Параметры.ЗначениеКопирования) Тогда
			// Копирование элемента
			Объект.Наименование = "";
			ПрочитатьПользователяИБ(ЗначениеЗаполнено(Параметры.ЗначениеКопирования.ИдентификаторПользователяИБ));
		Иначе
			// Добавление элемента
			Объект.ИдентификаторПользователяИБ = Параметры.ИдентификаторПользователяИБ;
			// Чтение начальных значений свойств пользователя ИБ
			ПрочитатьПользователяИБ();
		КонецЕсли;
	Иначе
		// Открытие существующего элемента
		ПрочитатьПользователяИБ();
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Ложь);
	
	ОпределитьДействияВФорме();
	
	ОпределитьНесоответствияПользователяСПользователемИБ();
	
	//** Установка постоянной доступности свойств
	Элементы.КонтактнаяИнформация.Видимость   = ЗначениеЗаполнено(ДействияВФорме.КонтактнаяИнформация);
	Элементы.СвойстваПользователяИБ.Видимость = ЗначениеЗаполнено(ДействияВФорме.СвойстваПользователяИБ);
	Элементы.ОтображениеРолей.Видимость       = ЗначениеЗаполнено(ДействияВФорме.Роли);
	
	ТолькоПросмотр = ТолькоПросмотр ИЛИ
	                 ДействияВФорме.Роли <> "Редактирование" И
	                 ДействияВФорме.КонтактнаяИнформация <> "Редактирование" И
	                 НЕ ( ДействияВФорме.СвойстваПользователяИБ = "РедактированиеВсех" ИЛИ
	                      ДействияВФорме.СвойстваПользователяИБ = "РедактированиеСвоих"     ) И
	                 ДействияВФорме.СвойстваЭлемента <> "Редактирование";
	
	УстановитьТолькоПросмотрРолей(ДействияВФорме.Роли <> "Редактирование");
	
	//** Обработчик подсистемы "Контактная информация"
	//УправлениеКонтактнойИнформацией.ПриСозданииНаСервере(ЭтаФорма, Объект, "КонтактнаяИнформация");
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	#Если ВебКлиент Тогда
	Элементы.ПользовательИнфБазыПользовательОС.КнопкаВыбора = Ложь;
	#КонецЕсли
	
	УстановитьДоступностьСвойств();
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписью(Отказ)
	
	ОчиститьСообщения();
	
	Если ДействияВФорме.Роли = "Редактирование" И ПользовательИнфБазыРоли.Количество() = 0 Тогда
		
		Если Вопрос(НСтр("ru = 'Пользователю информационной базы не установлено ни одной роли. Продолжить?'"),
						   РежимДиалогаВопрос.ДаНет,
						   ,
						   ,
						   НСтр("ru = 'Запись пользователя информационной базы'")) = КодВозвратаДиалога.Нет Тогда
			Отказ = Истина;
		КонецЕсли;
	КонецЕсли;
	
	// Обработка записи первого администратора
	ТекстВопроса = "";
	Если ТребуетсяСоздатьПервогоАдминистратора(ТекстВопроса) Тогда
		Если Вопрос(ТекстВопроса,
		            РежимДиалогаВопрос.ДаНет,
		            ,
		            ,
		            НСтр("ru = 'Запись пользователя информационной базы'")) = КодВозвратаДиалога.Нет Тогда
			Отказ = Истина;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	Если ТребуетсяСоздатьПервогоАдминистратора() Тогда
		ПараметрыЗаписи.Вставить("ЗаписьПервогоАдминистратора");
	КонецЕсли;
	
	Если ДействияВФорме.СвойстваЭлемента <> "Редактирование" Тогда
		ЗаполнитьЗначенияСвойств(ТекущийОбъект, БСП.ПолучитьЗначенияРеквизитов(ТекущийОбъект.Ссылка, "Наименование, ПометкаУдаления"));
	КонецЕсли;
	
	ТекущийОбъект.ДополнительныеСвойства.Вставить("ГруппаНовогоПользователя", ГруппаНовогоПользователя);
	
	Если ДоступКИнформационнойБазеРазрешен Тогда
		
		Если Элементы.ПолноеИмяПояснениеНесоответствия.Видимость Тогда
			ПользовательИнфБазыПолноеИмя = Объект.Наименование;
		КонецЕсли;
		
		ЗаписатьПользователяИБ(ТекущийОбъект, Отказ);
		Если НЕ Отказ Тогда
			Если ТекущийОбъект.ИдентификаторПользователяИБ <> СтарыйИдентификаторПользователяИБ Тогда
				ПараметрыЗаписи.Вставить("ДобавленПользовательИБ", ТекущийОбъект.ИдентификаторПользователяИБ);
			Иначе
				ПараметрыЗаписи.Вставить("ИзмененПользовательИБ", ТекущийОбъект.ИдентификаторПользователяИБ);
			КонецЕсли
		КонецЕсли;
		
	ИначеЕсли НЕ ЕстьСвязьСНесуществующимПользователемИБ ИЛИ
	          ДействияВФорме.СвойстваПользователяИБ = "РедактированиеВсех" Тогда
		
		ТекущийОбъект.ИдентификаторПользователяИБ = Неопределено;
	КонецЕсли;
	
	//// Обработчик подсистемы "Контактная информация"
	//Если НЕ Отказ И ДействияВФорме.КонтактнаяИнформация = "Редактирование" Тогда
	//	УправлениеКонтактнойИнформацией.ПередЗаписьюНаСервере(ЭтаФорма, ТекущийОбъект, Отказ);
	//КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриЗаписиНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	Если НЕ ДоступКИнформационнойБазеРазрешен И ПользовательИБСуществует Тогда
		УдалитьПользователяИБ(Отказ);
		Если НЕ Отказ Тогда
			ПараметрыЗаписи.Вставить("УдаленПользовательИБ", СтарыйИдентификаторПользователяИБ);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	Если ТекущийОбъект.ДополнительныеСвойства.Свойство("ЕстьОшибки") Тогда
		ПараметрыЗаписи.Вставить("ЕстьОшибки");
	КонецЕсли;
	
	ПрочитатьПользователяИБ();
	
	ОпределитьНесоответствияПользователяСПользователемИБ(ПараметрыЗаписи);
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	
	Если ПараметрыЗаписи.Свойство("ДобавленПользовательИБ") Тогда
		Оповестить("ДобавленПользовательИБ", ПараметрыЗаписи.ДобавленПользовательИБ, ЭтаФорма);
		
	ИначеЕсли ПараметрыЗаписи.Свойство("ИзмененПользовательИБ") Тогда
		Оповестить("ИзмененПользовательИБ", ПараметрыЗаписи.ИзмененПользовательИБ, ЭтаФорма);
		
	ИначеЕсли ПараметрыЗаписи.Свойство("УдаленПользовательИБ") Тогда
		Оповестить("УдаленПользовательИБ", ПараметрыЗаписи.УдаленПользовательИБ, ЭтаФорма);
		
	ИначеЕсли ПараметрыЗаписи.Свойство("ОчищенаСвязьСНесуществущимПользователемИБ") Тогда
		Оповестить("ОчищенаСвязьСНесуществущимПользователемИБ", ПараметрыЗаписи.ОчищенаСвязьСНесуществущимПользователемИБ, ЭтаФорма);
	КонецЕсли;
	
	Если ПараметрыЗаписи.Свойство("ЕстьОшибки") Тогда
		Предупреждение(НСтр("ru = 'При записи возникли ошибки (см. журнал регистрации)'"));
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ГруппаНовогоПользователя) Тогда
		ОповеститьОбИзменении(ГруппаНовогоПользователя);
		Оповестить("ИзмененСоставГруппыПользователей", ГруппаНовогоПользователя, ЭтаФорма);
		ГруппаНовогоПользователя = Неопределено;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ОбработкаПроверкиЗаполненияНаСервере(Отказ, ПроверяемыеРеквизиты)
	
	Если ДоступКИнформационнойБазеРазрешен Тогда
		
		Если НЕ Отказ И ПустаяСтрока(ПользовательИнфБазыИмя) Тогда
			БСП.СообщитьПользователю(
							НСтр("ru = 'Не заполнено имя пользователя информационной базы.'"), ,
							"ПользовательИнфБазыИмя", ,
							Отказ);
		КонецЕсли;
		
		Если  НЕ Отказ И ПользовательИнфБазыПароль <> Неопределено И Пароль <> ПодтверждениеПароля Тогда
			БСП.СообщитьПользователю(
							НСтр("ru = 'Пароль и подтверждение пароля не совпадают.'"), ,
							"Пароль", ,
							Отказ);
			Возврат;
		КонецЕсли;
		
		Если НЕ Отказ И НЕ ПустаяСтрока(ПользовательИнфБазыПользовательОС) Тогда
			УстановитьПривилегированныйРежим(Истина);
			Попытка
				ПользовательИБ = ПользователиИнформационнойБазы.СоздатьПользователя();
				ПользовательИБ.ПользовательОС = ПользовательИнфБазыПользовательОС;
			Исключение
				БСП.СообщитьПользователю(
								НСтр("ru = 'Пользователь ОС должен быть в формате
								           |\\ИмяДомена\ИмяПользователя'"), ,
								"ПользовательИнфБазыПользовательОС", ,
								Отказ);
			КонецПопытки;
			УстановитьПривилегированныйРежим(Ложь);
		КонецЕсли;
	КонецЕсли;
	
	Если Отказ Тогда
		ПроверяемыеРеквизиты.Очистить();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриЗагрузкеДанныхИзНастроекНаСервере(Настройки)
	
	Если Настройки["ПоказатьПодсистемыРолей"] = Ложь Тогда
		ПоказатьПодсистемыРолей = Ложь;
		Элементы.РолиПоказатьПодсистемыРолей.Пометка = Ложь;
	Иначе
		ПоказатьПодсистемыРолей = Истина;
		Элементы.РолиПоказатьПодсистемыРолей.Пометка = Истина;
	КонецЕсли;
	
	ОбновитьДеревоРолей();
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий команд и элементов формы
//

&НаКлиенте
Процедура ПолноеИмяВыполнитьСинхронизацию(Команда)
	
	Объект.Наименование = ПользовательИнфБазыПолноеИмя;
	Элементы.ПолноеИмяОбработкаНесоответствия.Видимость = Ложь;
	
КонецПроцедуры

&НаКлиенте
Процедура НаименованиеПриИзменении(Элемент)
	
	// Если ПолноеИмя определено, то его нужно обновлять.
	// Прим.: неопределенное ПолноеИмя или другое свойство
	//        не учитывается при записи пользователя ИБ
	//        ПолноеИмя определено только для вида
	//        интерактивных действий "БезОграничения"
	Если ПользовательИнфБазыПолноеИмя <> Неопределено Тогда
		ПользовательИнфБазыПолноеИмя = Объект.Наименование;
	КонецЕсли;
	
	Если НЕ ПользовательИБСуществует И ДоступКИнформационнойБазеРазрешен Тогда
		ПользовательИнфБазыИмя = ПолучитьКраткоеИмяПользователяИБ(Объект.Наименование);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ДоступКИнформационнойБазеРазрешенПриИзменении(Элемент)
	
	Если НЕ ПользовательИБСуществует И ДоступКИнформационнойБазеРазрешен Тогда
		ПользовательИнфБазыИмя       = ПолучитьКраткоеИмяПользователяИБ(Объект.Наименование);
		ПользовательИнфБазыПолноеИмя = Объект.Наименование;
	КонецЕсли;
	
	УстановитьДоступностьСвойств();
	
КонецПроцедуры

&НаКлиенте
Процедура ПользовательИнфБазыАутентификацияСтандартнаяПриИзменении(Элемент)
	
	УстановитьДоступностьСвойств();
	
КонецПроцедуры

&НаКлиенте
Процедура ПарольПриИзменении(Элемент)
	
	ПользовательИнфБазыПароль = Пароль;
	
КонецПроцедуры

&НаКлиенте
Процедура ПользовательИнфБазыАутентификацияОСПриИзменении(Элемент)
	
	УстановитьДоступностьСвойств();
	
КонецПроцедуры

&НаКлиенте
Процедура ПользовательИнфБазыПользовательОСНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	#Если НЕ ВебКлиент Тогда
		Результат = ОткрытьФормуМодально("Справочник.Пользователи.Форма.ФормаВыбораПользователяОС");
		
		Если ТипЗнч(Результат) = Тип("Строка") Тогда
			ПользовательИнфБазыПользовательОС = Результат;
		КонецЕсли;
	#КонецЕсли
	
КонецПроцедуры

//** Для работы интерфейса ролей

&НаКлиенте
Процедура ПоказатьТолькоВыбранныеРоли(Команда)
	
	ПоказатьТолькоВыбранныеРоли = НЕ ПоказатьТолькоВыбранныеРоли;
	Элементы.РолиПоказатьТолькоВыбранныеРоли.Пометка = ПоказатьТолькоВыбранныеРоли;
	
	ОбновитьДеревоРолей();
	РазвернутьПодсистемыРолей();
	
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьПодсистемыРолей(Команда)
	
	ПоказатьПодсистемыРолей = НЕ ПоказатьПодсистемыРолей;
	Элементы.РолиПоказатьПодсистемыРолей.Пометка = ПоказатьПодсистемыРолей;
	
	ОбновитьДеревоРолей();
	РазвернутьПодсистемыРолей();
	
КонецПроцедуры

&НаКлиенте
Процедура РолиПометкаПриИзменении(Элемент)
	
	Если Элементы.Роли.ТекущиеДанные <> Неопределено Тогда
		ОбновитьСоставРолей(Элементы.Роли.ТекущаяСтрока, Элементы.Роли.ТекущиеДанные.Пометка);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьФлажки(Команда)
	
	ОбновитьСоставРолей(Неопределено, Истина);
	Если ПоказатьТолькоВыбранныеРоли Тогда
		РазвернутьПодсистемыРолей();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СнятьФлажки(Команда)
	
	ОбновитьСоставРолей(Неопределено, Ложь);
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Вспомогательные процедуры и функции формы
//

&НаСервере
Функция ТребуетсяСоздатьПервогоАдминистратора(ТекстВопроса = Неопределено)
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если ПользователиИнформационнойБазы.ПолучитьПользователей().Количество() = 0 Тогда
		//
		ДеревоРолей = РеквизитФормыВЗначение("Роли");
		Отбор = Новый Структура("Пометка, Имя, ЭтоРоль", Истина, "ПолныеПрава", Истина);
		Если ДеревоРолей.Строки.НайтиСтроки(Отбор).Количество() = 0 Тогда
			// Подготовка текста вопроса при записи первого администратора
			ТекстВопроса = НСтр("ru = 'Первый пользователь информационной базы должен иметь полные права.
			                          |Роль будет добавлена автоматически. Продолжить?'");
			Возврат Истина;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

&НаСервере
Процедура ОпределитьДействияВФорме()
	
	ДействияВФорме = Новый Структура;
	ДействияВФорме.Вставить("Роли",                   ""); // "", "Просмотр",     "Редактирование"
	ДействияВФорме.Вставить("КонтактнаяИнформация",   ""); // "", "Просмотр",     "Редактирование"
	ДействияВФорме.Вставить("СвойстваПользователяИБ", ""); // "", "ПросмотрВсех", "РедактированиеВсех", "РедактированиеСвоих"
	ДействияВФорме.Вставить("СвойстваЭлемента",       ""); // "", "Просмотр",     "Редактирование"
	
	Если Пользователи.ЭтоПолноправныйПользовательИБ() Тогда
		// Администратор
		ДействияВФорме.Роли                   = "Редактирование";
		ДействияВФорме.КонтактнаяИнформация   = "Редактирование";
		ДействияВФорме.СвойстваПользователяИБ = "РедактированиеВсех";
		ДействияВФорме.СвойстваЭлемента       = "Редактирование";
		
	ИначеЕсли РольДоступна("ДобавлениеИзменениеПользователей")
	        И НЕ Пользователи.ЭтоПолноправныйПользовательИБ(Объект.Ссылка) Тогда
		// Ответственный за список пользователей и групп пользователей
		// (Исполнитель распоряжений о приеме на работу и переводу,
		//  переназначению, созданию отделов, подразделений и рабочих групп)
		ДействияВФорме.Роли                   = "";
		ДействияВФорме.КонтактнаяИнформация   = "Редактирование";
		ДействияВФорме.СвойстваПользователяИБ = "РедактированиеВсех";
		ДействияВФорме.СвойстваЭлемента       = "Редактирование";
		
	ИначеЕсли ЗначениеЗаполнено(Пользователи.ТекущийПользователь()) И
	          Объект.Ссылка = Пользователи.ТекущийПользователь() Тогда
		// Свои свойства
		ДействияВФорме.Роли                   = "";
		ДействияВФорме.КонтактнаяИнформация   = "Редактирование";
		ДействияВФорме.СвойстваПользователяИБ = "РедактированиеСвоих";
		ДействияВФорме.СвойстваЭлемента       = "Просмотр";
		
	Иначе
		// Чужие свойства
		ДействияВФорме.Роли                   = "";
		ДействияВФорме.КонтактнаяИнформация   = "Просмотр";
		ДействияВФорме.СвойстваПользователяИБ = "";
		ДействияВФорме.СвойстваЭлемента       = "Просмотр";
	КонецЕсли;
	
	// Проверка имен действий в форме
	Если Найти(", Просмотр, Редактирование,", ", " + ДействияВФорме.Роли + ",") = 0 Тогда
		ДействияВФорме.Роли = "";
	КонецЕсли;
	Если Найти(", Просмотр, Редактирование,", ", " + ДействияВФорме.КонтактнаяИнформация + ",") = 0 Тогда
		ДействияВФорме.КонтактнаяИнформация = "";
	КонецЕсли;
	Если Найти(", ПросмотрВсех, РедактированиеВсех, РедактированиеСвоих,", ", " + ДействияВФорме.СвойстваПользователяИБ + ",") = 0 Тогда
		ДействияВФорме.СвойстваПользователяИБ = "";
	КонецЕсли;
	Если Найти(", Просмотр, Редактирование,", ", " + ДействияВФорме.СвойстваЭлемента + ",") = 0 Тогда
		ДействияВФорме.СвойстваЭлемента = "";
	КонецЕсли;
	
КонецПроцедуры

//** Чтение, запись, удаление, расчет краткого имени пользователя ИБ, проверка несоответствия

&НаСервере
Процедура ПрочитатьПользователяИБ(ПриКопированииЭлемента = Ложь, ТолькоРоли = Ложь)
	
	УстановитьПривилегированныйРежим(Истина);
	
	ПрочитанныеРоли = Неопределено;
	
	Если ТолькоРоли Тогда
		Пользователи.ПрочитатьПользователяИБ(Объект.ИдентификаторПользователяИБ, , ПрочитанныеРоли);
		ЗаполнитьРоли(ПрочитанныеРоли);
		Возврат;
	КонецЕсли;
	
	Пароль              = "";
	ПодтверждениеПароля = "";
	ПрочитанныеСвойства               = Неопределено;
	СтарыйИдентификаторПользователяИБ = Неопределено;
	ПользовательИБСуществует          = Ложь;
	ДоступКИнформационнойБазеРазрешен = Ложь;
	
	// Заполнение начальных значений свойств пользователяИБ у пользователя.
	Пользователи.ПрочитатьПользователяИБ(Неопределено, ПрочитанныеСвойства, ПрочитанныеРоли);
//	ПрочитанныеСвойства.ПользовательИнфБазыПоказыватьВСпискеВыбора = НЕ Константы.ИспользоватьВнешнихПользователей.Получить();
	ЗаполнитьЗначенияСвойств(ЭтаФорма, ПрочитанныеСвойства);
	ПользовательИнфБазыАутентификацияСтандартная = Истина;
	
	Если ПриКопированииЭлемента Тогда
		
		Если Пользователи.ПрочитатьПользователяИБ(Параметры.ЗначениеКопирования.ИдентификаторПользователяИБ, ПрочитанныеСвойства, ПрочитанныеРоли) Тогда
			// Т.к. у скопированного пользователя есть связь с пользователемИБ,
			// то устанавливается будущая связь и у нового пользователя.
			ДоступКИнформационнойБазеРазрешен = Истина;
			// Т.к. пользовательИБ скопированного пользователя прочитан,
			// то копируются свойства и роли пользователяИБ.
			ЗаполнитьЗначенияСвойств(ЭтаФорма,
			                         ПрочитанныеСвойства,
			                         "ПользовательИнфБазыАутентификацияСтандартная,
			                         |ПользовательИнфБазыЗапрещеноИзменятьПароль,
			                         |ПользовательИнфБазыПоказыватьВСпискеВыбора,
			                         |ПользовательИнфБазыАутентификацияОС");
		КонецЕсли;
		Объект.ИдентификаторПользователяИБ = Неопределено;
	Иначе
		Если Пользователи.ПрочитатьПользователяИБ(Объект.ИдентификаторПользователяИБ, ПрочитанныеСвойства, ПрочитанныеРоли) Тогда
		
			ПользовательИБСуществует          = Истина;
			ДоступКИнформационнойБазеРазрешен = Истина;
			СтарыйИдентификаторПользователяИБ = Объект.ИдентификаторПользователяИБ;
			
			ЗаполнитьЗначенияСвойств(ЭтаФорма,
			                         ПрочитанныеСвойства,
			                         "ПользовательИнфБазыИмя,
			                         |ПользовательИнфБазыПолноеИмя,
			                         |ПользовательИнфБазыАутентификацияСтандартная,
			                         |ПользовательИнфБазыПоказыватьВСпискеВыбора,
			                         |ПользовательИнфБазыЗапрещеноИзменятьПароль,
			                         |ПользовательИнфБазыАутентификацияОС,
			                         |ПользовательИнфБазыПользовательОС");
			
			Если ПрочитанныеСвойства.ПользовательИнфБазыПарольУстановлен Тогда
				Пароль              = "**********";
				ПодтверждениеПароля = "**********";
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	ЗаполнитьПредставлениеРежимаЗапуска(ПрочитанныеСвойства.ПользовательИнфБазыРежимЗапуска);
	ЗаполнитьПредставлениеЯзыка(ПрочитанныеСвойства.ПользовательИнфБазыЯзык);
	ЗаполнитьРоли(ПрочитанныеРоли);
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьПользователяИБ(ТекущийОбъект, Отказ)
	
	// Восстановление действий в форме, если они изменены на клиенте
	ОпределитьДействияВФорме();
	
	Если НЕ (ДействияВФорме.СвойстваПользователяИБ = "РедактированиеВсех" ИЛИ
	         ДействияВФорме.СвойстваПользователяИБ = "РедактированиеСвоих"    )Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	НовыеСвойства = Неопределено;
	НовыеРоли     = Неопределено;
	
	// Чтение старых свойств/заполнение начальных свойств пользователяИБ у пользователя.
	Пользователи.ПрочитатьПользователяИБ(ТекущийОбъект.ИдентификаторПользователяИБ, НовыеСвойства);
	
	Если ДействияВФорме.СвойстваПользователяИБ = "РедактированиеВсех" Тогда
		ЗаполнитьЗначенияСвойств(НовыеСвойства, ЭтаФорма);
		НовыеСвойства.ПользовательИнфБазыРежимЗапуска = ПолучитьВыбранныйРежимЗапуска();
	Иначе
		ЗаполнитьЗначенияСвойств(НовыеСвойства,
		                         ЭтаФорма,
		                         "ПользовательИнфБазыИмя,
		                         |ПользовательИнфБазыПароль");
	КонецЕсли;
	НовыеСвойства.ПользовательИнфБазыЯзык = ПолучитьВыбранныйЯзык();
		
	Если ДействияВФорме.Роли = "Редактирование" Тогда
		НовыеРоли = ПользовательИнфБазыРоли.Выгрузить(, "Роль").ВыгрузитьКолонку("Роль");
	КонецЕсли;
	
	// Попытка записи пользователя ИБ
	ОписаниеОшибки = "";
	Если Пользователи.ЗаписатьПользователяИБ(ТекущийОбъект.ИдентификаторПользователяИБ, НовыеСвойства, НовыеРоли, НЕ ПользовательИБСуществует, ОписаниеОшибки) Тогда
		Если НЕ ПользовательИБСуществует Тогда
			ТекущийОбъект.ИдентификаторПользователяИБ = НовыеСвойства.ПользовательИнфБазыУникальныйИдентификатор;
			ПользовательИБСуществует = Истина;
		КонецЕсли;
	Иначе
		Отказ = Истина;
		БСП.СообщитьПользователю(ОписаниеОшибки);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура УдалитьПользователяИБ(Отказ)
	
	УстановитьПривилегированныйРежим(Истина);
	
	ОписаниеОшибки = "";
	Если НЕ Пользователи.УдалитьПользователяИБ(СтарыйИдентификаторПользователяИБ, ОписаниеОшибки) Тогда
		БСП.СообщитьПользователю(ОписаниеОшибки, , , , Отказ);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьКраткоеИмяПользователяИБ(Знач ПолноеИмя)
	
	КраткоеИмя = "";
	ПервыйПроходЦикла = Истина;
	
	Пока Истина Цикл
		Если НЕ ПервыйПроходЦикла Тогда
			КраткоеИмя = КраткоеИмя + ВРег(Лев(ПолноеИмя, 1));
		КонецЕсли;
		ПозицияПробела = Найти(ПолноеИмя, " ");
		Если ПозицияПробела = 0 Тогда
			Если ПервыйПроходЦикла Тогда
				КраткоеИмя = ПолноеИмя;
			КонецЕсли;
			Прервать;
		КонецЕсли;
		
		Если ПервыйПроходЦикла Тогда
			КраткоеИмя = Лев(ПолноеИмя, ПозицияПробела - 1);
		КонецЕсли;
		
		ПолноеИмя = Прав(ПолноеИмя, СтрДлина(ПолноеИмя) - ПозицияПробела);
		
		ПервыйПроходЦикла = Ложь;
	КонецЦикла;
	
	КраткоеИмя = СтрЗаменить(КраткоеИмя, " ", "");
	
	Возврат КраткоеИмя;
	
КонецФункции

&НаСервере
Процедура ОпределитьНесоответствияПользователяСПользователемИБ(ПараметрыЗаписи = Неопределено)
	
	//** Проверка соответствия свойства "ПолноеИмя" пользователяИБ и свойства "Наименование" пользователя
	
	Если НЕ (ДействияВФорме.СвойстваЭлемента       = "Редактирование" И
	         ДействияВФорме.СвойстваПользователяИБ = "РедактированиеВсех") Тогда
		// Прочитанное ПолноеИмя пользователя не может быть изменено, если не совпадает
		ПользовательИнфБазыПолноеИмя = Неопределено;
	КонецЕсли;
	
	Если НЕ ПользовательИБСуществует ИЛИ
	     ПользовательИнфБазыПолноеИмя = Неопределено ИЛИ
	     ПользовательИнфБазыПолноеИмя = Объект.Наименование Тогда
		
		Элементы.ПолноеИмяОбработкаНесоответствия.Видимость = Ложь;
		
	ИначеЕсли ЗначениеЗаполнено(Объект.Ссылка) Тогда
	
		Элементы.ПолноеИмяПояснениеНесоответствия.Заголовок = БСП.ПодставитьПараметрыВСтроку(
				Элементы.ПолноеИмяПояснениеНесоответствия.Заголовок,
				ПользовательИнфБазыПолноеИмя);
	Иначе
		Объект.Наименование = ПользовательИнфБазыПолноеИмя;
		Элементы.ПолноеИмяОбработкаНесоответствия.Видимость = Ложь;
	КонецЕсли;
	
	//** Определение связи с несуществующим пользователем ИБ
	ЕстьНоваяСвязьСНесуществующимПользователемИБ = НЕ ПользовательИБСуществует И ЗначениеЗаполнено(Объект.ИдентификаторПользователяИБ);
	Если ПараметрыЗаписи <> Неопределено
	   И ЕстьСвязьСНесуществующимПользователемИБ
	   И НЕ ЕстьНоваяСвязьСНесуществующимПользователемИБ Тогда
		
		ПараметрыЗаписи.Вставить("ОчищенаСвязьСНесуществущимПользователемИБ", Объект.Ссылка);
	КонецЕсли;
	ЕстьСвязьСНесуществующимПользователемИБ = ЕстьНоваяСвязьСНесуществующимПользователемИБ;
	
	Если ДействияВФорме.СвойстваПользователяИБ <> "РедактированиеВсех" Тогда
		// Связь не может быть изменена
		Элементы.СвязьОбработкаНесоответствия.Видимость = Ложь;
	Иначе
		Элементы.СвязьОбработкаНесоответствия.Видимость = ЕстьСвязьСНесуществующимПользователемИБ;
	КонецЕсли;
	
КонецПроцедуры

//** Начальное заполнение, проверка заполнения, доступность свойств

&НаСервере
Процедура ЗаполнитьПредставлениеРежимаЗапуска(РежимЗапуска)
	
	Если РежимЗапуска = "Авто" Тогда
		ПредставлениеРежимаЗапуска = НСтр("ru = 'Авто'");
		
	ИначеЕсли РежимЗапуска = "ОбычноеПриложение" Тогда
		ПредставлениеРежимаЗапуска = НСтр("ru = 'Обычное приложение'");
		
	ИначеЕсли РежимЗапуска = "УправляемоеПриложение" Тогда
		ПредставлениеРежимаЗапуска = НСтр("ru = 'Управляемое приложение'");
	Иначе
		ПредставлениеРежимаЗапуска = "";
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьВыбранныйРежимЗапуска()
	
	Если ПредставлениеРежимаЗапуска = НСтр("ru = 'Авто'") Тогда
		Возврат "Авто";
		
	ИначеЕсли ПредставлениеРежимаЗапуска = НСтр("ru = 'Обычное приложение'") Тогда
		Возврат "ОбычноеПриложение";
		
	ИначеЕсли ПредставлениеРежимаЗапуска = НСтр("ru = 'Управляемое приложение'") Тогда
		Возврат "УправляемоеПриложение";
		
	КонецЕсли;
	
	Возврат "";
	
КонецФункции

&НаСервере
Процедура ЗаполнитьПредставлениеЯзыка(Язык)
	
	ПредставлениеЯзыка = "";
	
	Для каждого МетаданныеЯзыка ИЗ Метаданные.Языки Цикл
	
		Если МетаданныеЯзыка.Имя = Язык Тогда
			ПредставлениеЯзыка = МетаданныеЯзыка.Синоним;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьВыбранныйЯзык()
	
	Для каждого МетаданныеЯзыка ИЗ Метаданные.Языки Цикл
	
		Если МетаданныеЯзыка.Синоним = ПредставлениеЯзыка Тогда
			Возврат МетаданныеЯзыка.Имя;
		КонецЕсли;
	КонецЦикла;
	
	Возврат "";
	
КонецФункции

&НаСервере
Процедура ЗаполнитьРоли(ПрочитанныеРоли)
	
	ПользовательИнфБазыРоли.Очистить();
	
	Для каждого Роль Из ПрочитанныеРоли Цикл
		ПользовательИнфБазыРоли.Добавить().Роль = Роль;
	КонецЦикла;
	
	ОбновитьДеревоРолей();
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьДоступностьСвойств()
	
	Элементы.Наименование.ТолькоПросмотр                                 = ДействияВФорме.СвойстваЭлемента       <> "Редактирование";
	Элементы.ДоступКИнформационнойБазеРазрешен.ТолькоПросмотр            = ДействияВФорме.СвойстваПользователяИБ <> "РедактированиеВсех";
	Элементы.СвойстваПользователяИБ.ТолькоПросмотр                       = ДействияВФорме.СвойстваПользователяИБ =  "ПросмотрВсех";
	Элементы.ПользовательИнфБазыАутентификацияСтандартная.ТолькоПросмотр = ДействияВФорме.СвойстваПользователяИБ <> "РедактированиеВсех";
	Элементы.Пароль.ТолькоПросмотр                                       = ПользовательИнфБазыЗапрещеноИзменятьПароль И НЕ АвторизованПолноправныйПользователь;
	Элементы.ПодтверждениеПароля.ТолькоПросмотр                          = ПользовательИнфБазыЗапрещеноИзменятьПароль И НЕ АвторизованПолноправныйПользователь;
	Элементы.ПользовательИнфБазыЗапрещеноИзменятьПароль.ТолькоПросмотр   = ДействияВФорме.СвойстваПользователяИБ <> "РедактированиеВсех";
	Элементы.ПользовательИнфБазыПоказыватьВСпискеВыбора.ТолькоПросмотр   = ДействияВФорме.СвойстваПользователяИБ <> "РедактированиеВсех";
	Элементы.ПользовательИнфБазыАутентификацияОС.ТолькоПросмотр          = ДействияВФорме.СвойстваПользователяИБ <> "РедактированиеВсех";
	Элементы.ПользовательИнфБазыПользовательОС.ТолькоПросмотр            = ДействияВФорме.СвойстваПользователяИБ <> "РедактированиеВсех";
	Элементы.ПредставлениеРежимаЗапуска.ТолькоПросмотр                   = ДействияВФорме.СвойстваПользователяИБ <> "РедактированиеВсех";
	
	Элементы.ОсновныеСвойства.Доступность                     = ДоступКИнформационнойБазеРазрешен;
	Элементы.ОтображениеРолей.Доступность                     = ДоступКИнформационнойБазеРазрешен;
	Элементы.ПользовательИнфБазыИмя.АвтоОтметкаНезаполненного = ДоступКИнформационнойБазеРазрешен;
	
	Элементы.Пароль.Доступность                                     = ПользовательИнфБазыАутентификацияСтандартная;
	Элементы.ПодтверждениеПароля.Доступность                        = ПользовательИнфБазыАутентификацияСтандартная;
	Элементы.ПользовательИнфБазыЗапрещеноИзменятьПароль.Доступность = ПользовательИнфБазыАутентификацияСтандартная;
	Элементы.ПользовательИнфБазыПоказыватьВСпискеВыбора.Доступность = ПользовательИнфБазыАутентификацияСтандартная;
	
	Элементы.ПользовательИнфБазыПользовательОС.Доступность = ПользовательИнфБазыАутентификацияОС;
	
КонецПроцедуры

//** Для работы интерфейса ролей

&НаСервере
Функция КоллекцияРолей(ТаблицаЗначенийДляЧтения = Ложь)
	
	Если ТаблицаЗначенийДляЧтения Тогда
		Возврат РеквизитФормыВЗначение("ПользовательИнфБазыРоли");
	КонецЕсли;
	
	Возврат ПользовательИнфБазыРоли;
	
КонецФункции

&НаСервере
Процедура УстановитьТолькоПросмотрРолей(Знач ТолькоПросмотрРолей = Неопределено, Знач РазрешитьПросмотрТолькоВыбранных = Ложь)
	
	Если ТолькоПросмотрРолей <> Неопределено Тогда
		Элементы.Роли.ТолькоПросмотр              =    ТолькоПросмотрРолей;
		Элементы.РолиУстановитьФлажки.Доступность = НЕ ТолькоПросмотрРолей;
		Элементы.РолиСнятьФлажки.Доступность      = НЕ ТолькоПросмотрРолей;
	КонецЕсли;
	
	Если РазрешитьПросмотрТолькоВыбранных Тогда
		Элементы.РолиПоказатьТолькоВыбранныеРоли.Доступность = Ложь;
	КонецЕсли;
	
КонецПроцедуры


&НаКлиенте
Процедура РазвернутьПодсистемыРолей(Коллекция = Неопределено);
	
	Если Коллекция = Неопределено Тогда
		Коллекция = Роли.ПолучитьЭлементы();
	КонецЕсли;
	
	// Развернуть все
	Для каждого Строка ИЗ Коллекция Цикл
		Элементы.Роли.Развернуть(Строка.ПолучитьИдентификатор());
		Если НЕ Строка.ЭтоРоль Тогда
			РазвернутьПодсистемыРолей(Строка.ПолучитьЭлементы());
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьДеревоРолей()
	
	Если НЕ Элементы.РолиПоказатьТолькоВыбранныеРоли.Доступность Тогда
		Элементы.РолиПоказатьТолькоВыбранныеРоли.Пометка = Истина;
		ПоказатьТолькоВыбранныеРоли = Истина;
	КонецЕсли;
	
	// Запоминание текущей строки
	ТекущаяПодсистема = "";
	ТекущаяРоль       = "";
	//
	Если Элементы.Роли.ТекущаяСтрока <> Неопределено Тогда
		ТекущиеДанные = Роли.НайтиПоИдентификатору(Элементы.Роли.ТекущаяСтрока);
		Если ТекущиеДанные.ЭтоРоль Тогда
			ТекущаяПодсистема = ?(ТекущиеДанные.ПолучитьРодителя() = Неопределено, "", ТекущиеДанные.ПолучитьРодителя().Имя);
			ТекущаяРоль       = ТекущиеДанные.Имя;
		Иначе
			ТекущаяПодсистема = ТекущиеДанные.Имя;
			ТекущаяРоль       = "";
		КонецЕсли;
	КонецЕсли;
	
	ДеревоРолей = БСП.ДеревоРолей(ПоказатьПодсистемыРолей).Скопировать();
	ДеревоРолей.Колонки.Добавить("Пометка",       Новый ОписаниеТипов("Булево"));
	ДеревоРолей.Колонки.Добавить("НомерКартинки", Новый ОписаниеТипов("Число"));
	ПодготовитьДеревоРолей(ДеревоРолей.Строки, СкрытьРольПолныеПрава, ПоказатьТолькоВыбранныеРоли);
	
	ЗначениеВРеквизитФормы(ДеревоРолей, "Роли");
	
	Элементы.Роли.Отображение = ?(ДеревоРолей.Строки.Найти(Ложь, "ЭтоРоль") = Неопределено, ОтображениеТаблицы.Список, ОтображениеТаблицы.Дерево);
	
	// Восстановление текущей строки
	НайденныеСтроки = ДеревоРолей.Строки.НайтиСтроки(Новый Структура("ЭтоРоль, Имя", Ложь, ТекущаяПодсистема), Истина);
	Если НайденныеСтроки.Количество() <> 0 Тогда
		ОписаниеПодсистемы = НайденныеСтроки[0];
		ИндексПодсистемы = ?(ОписаниеПодсистемы.Родитель = Неопределено, ДеревоРолей.Строки, ОписаниеПодсистемы.Родитель.Строки).Индекс(ОписаниеПодсистемы);
		СтрокаПодсистемы = ДанныеФормыКоллекцияЭлементовДерева(Роли, ОписаниеПодсистемы).Получить(ИндексПодсистемы);
		Если ЗначениеЗаполнено(ТекущаяРоль) Тогда
			НайденныеСтроки = ОписаниеПодсистемы.Строки.НайтиСтроки(Новый Структура("ЭтоРоль, Имя", Истина, ТекущаяРоль));
			Если НайденныеСтроки.Количество() <> 0 Тогда
				ОписаниеРоли = НайденныеСтроки[0];
				Элементы.Роли.ТекущаяСтрока = СтрокаПодсистемы.ПолучитьЭлементы().Получить(ОписаниеПодсистемы.Строки.Индекс(ОписаниеРоли)).ПолучитьИдентификатор();
			Иначе
				Элементы.Роли.ТекущаяСтрока = СтрокаПодсистемы.ПолучитьИдентификатор();
			КонецЕсли;
		Иначе
			Элементы.Роли.ТекущаяСтрока = СтрокаПодсистемы.ПолучитьИдентификатор();
		КонецЕсли;
	Иначе
		НайденныеСтроки = ДеревоРолей.Строки.НайтиСтроки(Новый Структура("ЭтоРоль, Имя", Истина, ТекущаяРоль), Истина);
		Если НайденныеСтроки.Количество() <> 0 Тогда
			ОписаниеРоли = НайденныеСтроки[0];
			ИндексРоли = ?(ОписаниеРоли.Родитель = Неопределено, ДеревоРолей.Строки, ОписаниеРоли.Родитель.Строки).Индекс(ОписаниеРоли);
			СтрокаРоли = ДанныеФормыКоллекцияЭлементовДерева(Роли, ОписаниеРоли).Получить(ИндексРоли);
			Элементы.Роли.ТекущаяСтрока = СтрокаРоли.ПолучитьИдентификатор();
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПодготовитьДеревоРолей(Знач Коллекция, Знач СкрытьРольПолныеПрава, Знач ПоказатьТолькоВыбранныеРоли)
	
	Индекс = Коллекция.Количество()-1;
	
	Пока Индекс >= 0 Цикл
		Строка = Коллекция[Индекс];
		
		ПодготовитьДеревоРолей(Строка.Строки, СкрытьРольПолныеПрава, ПоказатьТолькоВыбранныеРоли);
		
		Если Строка.ЭтоРоль Тогда
			Если СкрытьРольПолныеПрава И ВРег(Строка.Имя) = ВРег("ПолныеПрава") Тогда
				Коллекция.Удалить(Индекс);
			Иначе
				Строка.НомерКартинки = 6;
				Строка.Пометка = КоллекцияРолей().НайтиСтроки(Новый Структура("Роль", Строка.Имя)).Количество() > 0;
				Если ПоказатьТолькоВыбранныеРоли И НЕ Строка.Пометка Тогда
					Коллекция.Удалить(Индекс);
				КонецЕсли;
			КонецЕсли;
		Иначе
			Если Строка.Строки.Количество() = 0 Тогда
				Коллекция.Удалить(Индекс);
			Иначе
				Строка.НомерКартинки = 5;
				Строка.Пометка = Строка.Строки.НайтиСтроки(Новый Структура("Пометка", Ложь)).Количество() = 0;
			КонецЕсли;
		КонецЕсли;
		
		Индекс = Индекс-1;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция ДанныеФормыКоллекцияЭлементовДерева(Знач ДанныеФормыДерево, Знач СтрокаДереваЗначений)
	
	Если СтрокаДереваЗначений.Родитель = Неопределено Тогда
		ДанныеФормыКоллекцияЭлементовДерева = ДанныеФормыДерево.ПолучитьЭлементы();
	Иначе
		ИндексРодителя = ?(СтрокаДереваЗначений.Родитель.Родитель = Неопределено, СтрокаДереваЗначений.Владелец().Строки, СтрокаДереваЗначений.Родитель.Родитель.Строки).Индекс(СтрокаДереваЗначений.Родитель);
		ДанныеФормыКоллекцияЭлементовДерева = ДанныеФормыКоллекцияЭлементовДерева(ДанныеФормыДерево, СтрокаДереваЗначений.Родитель).Получить(ИндексРодителя).ПолучитьЭлементы();
	КонецЕсли;
	
	Возврат ДанныеФормыКоллекцияЭлементовДерева;
	
КонецФункции


&НаСервере
Процедура ОбновитьСоставРолей(ИндентификаторСтроки, Добавить);
	
	Если ИндентификаторСтроки = Неопределено Тогда
		// Обработка всех
		КоллекцияРолей = КоллекцияРолей();
		КоллекцияРолей.Очистить();
		Если Добавить Тогда
			ВсеРоли = БСП.ВсеРоли();
			Для каждого ОписаниеРоли Из ВсеРоли Цикл
				Если ОписаниеРоли.Имя <> "ПолныеПрава" Тогда
					КоллекцияРолей.Добавить().Роль = ОписаниеРоли.Имя;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		Если ПоказатьТолькоВыбранныеРоли Тогда
			Если КоллекцияРолей.Количество() > 0 Тогда
				ОбновитьДеревоРолей();
			Иначе
				Роли.ПолучитьЭлементы().Очистить();
			КонецЕсли;
			// Возврат
			Возврат;
			// Возврат
		КонецЕсли;
	Иначе
		ТекущиеДанные = Роли.НайтиПоИдентификатору(ИндентификаторСтроки);
		Если ТекущиеДанные.ЭтоРоль Тогда
			ДобавитьУдалитьРоль(ТекущиеДанные.Имя, Добавить);
		Иначе
			ДобавитьУдалитьРолиПодсистемы(ТекущиеДанные.ПолучитьЭлементы(), Добавить);
		КонецЕсли;
	КонецЕсли;
	
	ОбновитьПометкуВыбранныхРолей(Роли.ПолучитьЭлементы());
	
	Модифицированность = Истина;
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьУдалитьРоль(Знач Роль, Знач Добавить)
	
	НайденныеРоли = КоллекцияРолей().НайтиСтроки(Новый Структура("Роль", Роль));
	
	Если Добавить Тогда
		Если НайденныеРоли.Количество() = 0 Тогда
			КоллекцияРолей().Добавить().Роль = Роль;
		КонецЕсли;
	Иначе
		Если НайденныеРоли.Количество() > 0 Тогда
			КоллекцияРолей().Удалить(НайденныеРоли[0]);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьУдалитьРолиПодсистемы(Знач Коллекция, Знач Добавить)
	
	Для каждого Строка Из Коллекция Цикл
		Если Строка.ЭтоРоль Тогда
			ДобавитьУдалитьРоль(Строка.Имя, Добавить);
		Иначе
			ДобавитьУдалитьРолиПодсистемы(Строка.ПолучитьЭлементы(), Добавить);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьПометкуВыбранныхРолей(Знач Коллекция)
	
	Индекс = Коллекция.Количество()-1;
	
	Пока Индекс >= 0 Цикл
		Строка = Коллекция[Индекс];
		
		Если Строка.ЭтоРоль Тогда
			Строка.Пометка = КоллекцияРолей().НайтиСтроки(Новый Структура("Роль", Строка.Имя)).Количество() > 0;
			Если ПоказатьТолькоВыбранныеРоли И НЕ Строка.Пометка Тогда
				Коллекция.Удалить(Индекс);
			КонецЕсли;
		Иначе
			ОбновитьПометкуВыбранныхРолей(Строка.ПолучитьЭлементы());
			Если Строка.ПолучитьЭлементы().Количество() = 0 Тогда
				Коллекция.Удалить(Индекс);
			Иначе
				Строка.Пометка = Истина;
				Для каждого Элемент Из Строка.ПолучитьЭлементы() Цикл
					Если НЕ Элемент.Пометка Тогда
						Строка.Пометка = Ложь;
						Прервать;
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;
		КонецЕсли;
		
		Индекс = Индекс-1;
	КонецЦикла;
	
КонецПроцедуры


////** Для работы подсистемы КонтактнаяИнформация

//&НаКлиенте
//Процедура Подключаемый_КонтактнаяИнформацияПриИзменении(Элемент)
//	
//	УправлениеКонтактнойИнформациейКлиент.ПредставлениеПриИзменении(ЭтаФорма, Элемент);
//	
//КонецПроцедуры

//&НаКлиенте
//Процедура Подключаемый_КонтактнаяИнформацияНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
//	
//	УправлениеКонтактнойИнформациейКлиент.ПредставлениеНачалоВыбора(ЭтаФорма, Элемент, Модифицированность, СтандартнаяОбработка);
//	
//КонецПроцедуры


