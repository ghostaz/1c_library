
&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	ИмяВременногоФайла = ОбщегоНазначенияСервер.ЗагрузитьФайлПоСсылке(Запись.СсылкаНаКартинку);
	
	ФайлНаДиске = Новый Файл(ИмяВременногоФайла);
	Если ФайлНаДиске.Существует() Тогда
		ДвоичныеДанные = Новый ДвоичныеДанные(ИмяВременногоФайла);
		Картинка = ПоместитьВоВременноеХранилище(ДвоичныеДанные, УникальныйИдентификатор);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СсылкаНаСайтНажатие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	ПерейтиПоНавигационнойСсылке(Запись.СсылкаНаСайт);
	
КонецПроцедуры

&НаКлиенте
Процедура Импортировать(Команда)
	
	ПараметрыФормы = Новый Структура("ИдентификаторКниги", Запись.ИдентификаторКниги);
	
	ОткрытьФорму("РегистрСведений.КаталогКниг.Форма.ИмпортКниги", ПараметрыФормы, ЭтотОбъект);
	
КонецПроцедуры
