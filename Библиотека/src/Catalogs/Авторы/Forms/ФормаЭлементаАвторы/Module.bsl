
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Отбор=КнигиАвтора.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	Отбор.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Автор");
	Отбор.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
	Отбор.ПравоеЗначение = Объект.Ссылка;
	Отбор.Использование = Истина;

КонецПроцедуры
