#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда // Для работы толстого клиента https://its.1c.ru/db/v8std#content:680:hdoc

Процедура ПередЗаписью(Отказ)
	
	Фамилия = СокрЛП(Фамилия);
	Имя = СокрЛП(Имя);
	Отчество = СокрЛП(Отчество);
	
	Наименование = СокрЛП(Фамилия + " " + Имя + " " + Отчество);
	
	Если ПустаяСтрока(Наименование) Тогда
		СообщениеПользователю = Новый СообщениеПользователю();
		СообщениеПользователю.Текст = НСтр("ru = 'Не заполнены ФИО абонента'");
		СообщениеПользователю.Поле = "Фамилия";
		СообщениеПользователю.УстановитьДанные(ЭтотОбъект);
		СообщениеПользователю.Сообщить();
		Отказ = Истина;
	КонецЕсли;
	
КонецПроцедуры

#Иначе
	ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли