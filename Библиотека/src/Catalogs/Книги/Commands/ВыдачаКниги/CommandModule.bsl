
&НаКлиенте
Процедура ОбработкаКоманды(ПараметрКоманды, ПараметрыВыполненияКоманды)
	
	// Открываем форму с заполненными значениями заполнения. Туда мы запихнем ссылки на книги, которые надо выдать
	ПараметрыФормы = Новый Структура("МассивКниг", ПараметрКоманды);
	ОткрытьФорму("Документ.ВыдачаКниг.ФормаОбъекта", ПараметрыФормы, ПараметрыВыполненияКоманды.Источник, ПараметрыВыполненияКоманды.Уникальность, ПараметрыВыполненияКоманды.Окно);
	
КонецПроцедуры
