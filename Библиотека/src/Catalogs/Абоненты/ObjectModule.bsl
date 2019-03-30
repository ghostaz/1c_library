
Процедура ПередЗаписью(Отказ)
	
	Фамилия = СокрЛП(Фамилия);
	Имя = СокрЛП(Имя);
	Отчество = СокрЛП(Отчество);
	
	Наименование = СокрЛП(Фамилия + " " + Имя + " " + Отчество);
	
	Если ПустаяСтрока(Наименование) Тогда
		СообщениеПользователю = Новый СообщениеПользователю();
		СообщениеПользователю.Текст = "Не заполнены ФИО абонента";
		СообщениеПользователю.Поле = "Фамилия";
		СообщениеПользователю.УстановитьДанные(ЭтотОбъект);
		СообщениеПользователю.Сообщить();
		Отказ = Истина;
	КонецЕсли;
	
КонецПроцедуры