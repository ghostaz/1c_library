
&НаКлиенте
Процедура ПутьКФайлуНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ДиалогОткрытияФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогОткрытияФайла.ПолноеИмяФайла = "";
	Фильтр = "Таблица Excel(*.xls)|*.xls|Таблица Excel 2007(*.xlsx)|*.xlsx|CSV файл(*.csv)|*.csv|Все файлы(*.*)|*.*";
	ДиалогОткрытияФайла.Фильтр = Фильтр;
	ДиалогОткрытияФайла.МножественныйВыбор = Ложь;
	ДиалогОткрытияФайла.Заголовок = НСтр("ru = 'Выберите файл'");
	
	Если ДиалогОткрытияФайла.Выбрать() Тогда
		ПутьКФайлу = ДиалогОткрытияФайла.ПолноеИмяФайла;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ИмпортСправочникаКниг(Команда)
	НачальнаяСтрока = 2;
	xlLastCell = 11;
	НомерЛистаExcel=1;
	ВыбФайл = Новый Файл(ПутьКФайлу);
	Если НЕ ВыбФайл.Существует() Тогда
		Сообщить(НСтр("ru = 'Файл не существует.'"));
		Возврат;
	КонецЕсли;
	
	Попытка
		Excel = Новый COMОбъект("Excel.Application");
		Excel.WorkBooks.Open(ПутьКФайлу);
		Сообщить(НСтр("ru = 'Обработка файла Microsoft Excel...'"));
		ExcelЛист = Excel.Sheets(НомерЛистаExcel);
	Исключение
		Сообщить(НСтр("ru = 'Ошибка. Возможно неверно указан номер листа книги Excel.'"));
		Возврат;
	КонецПопытки;
	ActiveCell = Excel.ActiveCell.SpecialCells(xlLastCell);
	RowCount = ActiveCell.Row;
	// Сформируем массив книг что бы передать на обработку в сервер один раз
	МассивКниг = Новый Массив;
	Для Row = НачальнаяСтрока По RowCount Цикл
		Column = 2; //Инвентарный номер
		ИнвентарныйНомер = СокрЛП(ExcelЛист.Cells(Row,Column).Value);
		Column = 3; //Наименование
		Наименование = СокрЛП(ExcelЛист.Cells(Row,Column).Value);
		Column = 4; //Страниц
		Страниц = СокрЛП(ExcelЛист.Cells(Row,Column).Value);
		Column = 5; //Издательство
		Издательство = СокрЛП(ExcelЛист.Cells(Row,Column).Value);
		Column = 6; //Авторы
		Авторы = СокрЛП(ExcelЛист.Cells(Row,Column).Value);
		Column = 7; //Описание
		Описание = СокрЛП(ExcelЛист.Cells(Row,Column).Value);
		Column = 8; //ISBN
		ISBN = СокрЛП(ExcelЛист.Cells(Row,Column).Value);
		Column = 9; //ББК
		ББК = СокрЛП(ExcelЛист.Cells(Row,Column).Value);
		Попытка
			Страниц = Число(Страниц);
		Исключение
		КонецПопытки;
		СтруктураДанных = Новый Структура;
		СтруктураДанных.Вставить("ИнвентарныйНомер",ИнвентарныйНомер);
		СтруктураДанных.Вставить("Наименование",Наименование);
		СтруктураДанных.Вставить("Страниц",Страниц);
		СтруктураДанных.Вставить("Издательство",Издательство);
		СтруктураДанных.Вставить("Описание",Описание);
		СтруктураДанных.Вставить("ISBN",ISBN);
		СтруктураДанных.Вставить("ББК",ББК);
		МассивКниг.Добавить(СтруктураДанных);
	КонецЦикла;
	// Закрываем Excel что бы не висел процесс и не блокировал файл
	Excel.Quit();
	Excel = Неопределено;	
	ExcelЛист = Неопределено;
	Сообщить(НСтр("ru = 'Завершение чтения. Закрытие Excel.'"));
	// Создадим элементы на сервере
	СоздатьСправочникКниги(МассивКниг);
КонецПроцедуры

&НаСервере
Процедура СоздатьСправочникКниги(МассивКниг)
	
	Для Каждого СтруктураДанных Из МассивКниг Цикл
		
		Издательство = Неопределено;
		Если ЗначениеЗаполнено(СтруктураДанных.Издательство) Тогда
			Издательство = Справочники.Издательства.НайтиПоНаименованию(СтруктураДанных.Издательство, Истина);
			Если Издательство = Справочники.Издательства.ПустаяСсылка() Тогда
				Издательство = Справочники.Издательства.СоздатьИздательство(СтруктураДанных.Издательство);
			КонецЕсли;
		КонецЕсли;
		
		Справочники.Книги.СоздатьКнигу(
			СтруктураДанных.Наименование,
			СтруктураДанных.Наименование,
			СтруктураДанных.Описание,
			Новый Массив(),
			Издательство,
			СтруктураДанных.Страниц,
			0,
			СтруктураДанных.ИнвентарныйНомер,
			СтруктураДанных.ISBN,
			СтруктураДанных.ББК,
			"",
			Неопределено);
			
		КонецЦикла;
		
	Сообщить(НСтр("ru = 'Импорт справочников завершен.'"));
	
КонецПроцедуры;
