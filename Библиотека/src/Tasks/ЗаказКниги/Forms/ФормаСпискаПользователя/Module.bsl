
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Исполнитель = ПолучитьТекущегоПользователя();
	Список.Параметры.Элементы[0].Значение = Исполнитель;
	Список.Параметры.Элементы[0].Использование = Истина;	
КонецПроцедуры

&НаСервере
Функция ПолучитьТекущегоПользователя()
	Возврат ПараметрыСеанса.ТекущийПользователь;			
КонецФункции