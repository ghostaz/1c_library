
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ОбновитьСтатусРегистрации();
	
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "РегистрацияБазы" Тогда
		 ОбновитьСтатусРегистрации();
	КонецЕсли;
	
КонецПроцедуры

// Обновляет статус регистрации
//
// Параметры
//
&НаКлиенте
Процедура ОбновитьСтатусРегистрации()

	УникальныйИдентификаторБазы = ОбщегоНазначенияВызовСервера.ПолучитьЗначениеКонстанты("УникальныйИдентификаторБазы");
	
	Если ЗначениеЗаполнено(УникальныйИдентификаторБазы) Тогда
		СтатусРегистрации = "Информационная база зарегистрирована";
		ЭтаФорма.Элементы.СтатусРегистрации.ЦветТекста = Новый Цвет(0,150,0);		
	Иначе
		СтатусРегистрации = "Информационная база не зарегистрирована";
		ЭтаФорма.Элементы.СтатусРегистрации.ЦветТекста = Новый Цвет(150,0,0);		
	КонецЕсли;
	
	УникальныйИдентификаторБазыСтрока = УникальныйИдентификаторБазы;

КонецПроцедуры // ОбновитьСтатусРегистрации()


&НаКлиенте
Процедура ЗарегистрироватьБазу(Команда)
	Если ЗарегистрироватьБазуСервер() = 0 Тогда
		СтатусРегистрации = "Произошла ошибка при выполнении операции. Повторите попытку позже.";
		ЭтаФорма.Элементы.СтатусРегистрации.ЦветТекста = Новый Цвет(150,0,0);
	Иначе
		ОбновитьСтатусРегистрации();
	КонецЕсли;		
КонецПроцедуры

&НаСервере
Функция ЗарегистрироватьБазуСервер()
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект", Тип("ОбработкаОбъект.СервисОбслуживания"));
	Результат = ОбработкаОбъект.ЗарегистрироватьБазу();
	
	Возврат Результат;
	
КонецФункции

&НаКлиенте
Процедура ПроверитьОбновление(Команда)
	ПроверитьОбновлениеСервер();	
КонецПроцедуры

&НаСервере
Процедура ПроверитьОбновлениеСервер()
	
		
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект", Тип("ОбработкаОбъект.СервисОбслуживания"));
	РезультатКод = ОбработкаОбъект.ПроверитьОбновление(ВерсияОбновления, ДатаВыпускаОбновления, СсылкаНаОбновление, СсылкаНаОписаниеОбновления, ОписаниеОбновления);
	Если РезультатКод = 0 Тогда
		РезультатПроверкиОбновления 	= "Произошла ошибка при выполнении операции. Повторите попытку позже.";
		ЭтаФорма.Элементы.РезультатПроверкиОбновления.ЦветТекста = Новый Цвет(150,0,0);
	ИначеЕсли РезультатКод = 1 Тогда
		РезультатПроверкиОбновления 	= "Имеется обновление";
		ЭтаФорма.Элементы.РезультатПроверкиОбновления.ЦветТекста = Новый Цвет(0,150,0);
	ИначеЕсли РезультатКод = 2 Тогда
		РезультатПроверкиОбновления 	= "Новых обновлений нет";
		ЭтаФорма.Элементы.РезультатПроверкиОбновления.ЦветТекста = Новый Цвет(150,150,0);
	ИначеЕсли РезультатКод = 3 Тогда
		РезультатПроверкиОбновления 	= "Уникальный идентификатор базы не заполнен. Для пользования сервисом необходима регистрация.";
		ЭтаФорма.Элементы.РезультатПроверкиОбновления.ЦветТекста = Новый Цвет(150,0,0);
	ИначеЕсли РезультатКод = 4 Тогда
		РезультатПроверкиОбновления 	= "База не найдена в списке зарегистрированных";
		ЭтаФорма.Элементы.РезультатПроверкиОбновления.ЦветТекста = Новый Цвет(150,0,0);
	ИначеЕсли РезультатКод = 5 Тогда
		РезультатПроверкиОбновления 	= "Неизвестна версия информационной базы";
		ЭтаФорма.Элементы.РезультатПроверкиОбновления.ЦветТекста = Новый Цвет(150,0,0);
	ИначеЕсли РезультатКод = 6 Тогда
		РезультатПроверкиОбновления 	= "Информационная база незарегистрирована. Для пользования сервисом необходима регистрация.";
		ЭтаФорма.Элементы.РезультатПроверкиОбновления.ЦветТекста = Новый Цвет(150,0,0);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СсылкаНаОбновлениеНажатие(Элемент, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ПерейтиПоНавигационнойСсылке(СсылкаНаОбновление);
КонецПроцедуры

&НаКлиенте
Процедура СсылкаНаОписаниеОбновленияНажатие(Элемент, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	ПерейтиПоНавигационнойСсылке(СсылкаНаОписаниеОбновления);
КонецПроцедуры

&НаКлиенте
Процедура НадписьСсылкаНаСайтНажатие(Элемент)
	ПерейтиПоНавигационнойСсылке("http://codenotes-1c.blogspot.ru/p/blog-page.html");
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ТекущаяВерсия = Метаданные.Версия;
КонецПроцедуры
