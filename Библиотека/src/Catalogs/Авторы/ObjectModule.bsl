
Процедура ПередЗаписью(Отказ)
	Если Фамилия<>"" 
		ИЛИ Имя<>""
		ИЛИ Отчество<>"" Тогда		
		ПолноеНаименование 		= СокрП(Фамилия + " " + Имя + " " + Отчество);
	КонецЕсли;
	Если Фамилия<>"" 
		И Имя<>""
		И Отчество<>"" Тогда
		Наименование 	= Фамилия + " " + Сред(Имя,1,1) + ". " + Сред(Отчество,1,1) + ".";		
	ИначеЕсли Фамилия<>"" 
		И Имя<>"" Тогда
		Наименование 	= Фамилия + " " + Сред(Имя,1,1) + ".";
	ИначеЕсли Фамилия<>"" Тогда
		Наименование 	= Фамилия;
	ИначеЕсли Имя<>"" Тогда
		Наименование 	= Имя;
	КонецЕсли;
КонецПроцедуры
