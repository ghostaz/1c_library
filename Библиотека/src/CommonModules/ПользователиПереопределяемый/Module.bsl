

// Функция ЗапретРедактированияРолей используется для
// управления поведением подсистем Пользователи,
// когда требуется переключится в режим автоустановки ролей пользователей ИБ,
// например, при встраивании подсистемы УправлениеДоступом.
//
// Возвращаемое значение:
//  Булево.
//
Функция ЗапретРедактированияРолей() Экспорт
	
	Возврат Ложь;
	
КонецФункции

// Процедура ИзменитьДействияВФорме позволяет переопределить
// поведение форм пользователя, внешнего пользователя, группы внешних пользователей
// когда это требуется, например, при встараивании подсистемы "Управление доступом".
//
// Параметры:
//  Ссылка - СправочникСсылка.Пользователи,
//           СправочникСсылка.ГруппыВнешнихПользователей
//           ссылка на пользователя, внешнего пользователя или группу внешних пользователей
//           при создании формы.
//
//  ДействияВФорме - Структура (со свойствами типа Строка):
//           Роли                   = "", "Просмотр",     "Редактирование"
//           КонтактнаяИнформация   = "", "Просмотр",     "Редактирование"
//           СвойстваПользователяИБ = "", "ПросмотрВсех", "РедактированиеВсех", РедактированиеСвоих"
//           СвойстваЭлемента       = "", "Просмотр",     "Редактирование"
//           
//           Для групп внешних пользователей КонтактнаяИнформация и СвойстваПользователяИБ не существуют.
//
Процедура ИзменитьДействияВФорме(Знач Ссылка = Неопределено, Знач ДействияВФорме) Экспорт
	
		
КонецПроцедуры

// Обработчик события ПриЗаписи пользователя информационной базы
// вызывается из процедуры ЗаписатьПользователяИБ(), если пользователь
// был действительно записан.
//
// Параметры:
//  СтарыеСвойства - Структура, см. параметры возвращаемые функцией Пользователи.ПрочитатьПользователяИБ()
//  НовыеСвойства  - Структура, см. параметры возвращаемые функцией Пользователи.ЗаписатьПользователяИБ()
//
Процедура ПриЗаписиПользователяИнформационнойБазы(Знач СтарыеСвойства, Знач НовыеСвойства) Экспорт
	
		
КонецПроцедуры

// Обработчик события ПослеУдаления пользователя информационной базы
// вызывается из процедуры УдалитьПользователяИБ(), если пользователь
// был действительно удален.
//
// Параметры:
//  СтарыеСвойства - Структура, см. параметры возвращаемые функцией Пользователи.ПрочитатьПользователяИБ()
//
Процедура ПослеУдаленияПользователяИнформационнойБазы(Знач СтарыеСвойства) Экспорт
	
	
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики записи первого администратора

// Обработчик события ТекстВопросаПередЗаписьюПервогоАдминистратора вызывается
// из формы пользователя в обработчике перед записью,
// чтобы изменить текст вопроса пользователю,
// например, для подсистемы УправлениеДоступом.
//  Вызов происходит, если установлен ЗапретРедактированияРолей
// и количество пользователей информационной базы равно нулю.
// 
Процедура ТекстВопросаПередЗаписьюПервогоАдминистратора(ТекстВопроса) Экспорт
	
КонецПроцедуры

// Обработчик события ПриЗаписиПервогоАдминистратора вызывается
// из формы пользователя в обработчике ПриЗаписиНаСервере,
// из функции Пользователи.ОшибкаАвторизации() при авторизации администратора,
// когда нет ни одного администратора зарегистрированного в справочнике Пользователи
//  Это нужно, например, для подсистемы УправлениеДоступом,
// чтобы добавить первого администратора в группу доступа Администраторы
// 
// Параметры:
//  Пользователь - СправочникСсылка.Пользователи (изменение объекта запрещено)
//
Процедура ПриЗаписиПервогоАдминистратора(Пользователь) Экспорт
	
	
	
КонецПроцедуры

// Обработчик события ПослеЗаписиАдминистратораПриАвторизации вызывается
// из функции Пользователи.ОшибкаАвторизации() при авторизации администратора,
// когда администратор не зарегистрированн в справочнике Пользователи
//  Обработчик нужен, например, для подсистемы УправлениеДоступом,
// чтобы сообщить, что первый администратор добавлен в группу доступа Администраторы
// 
// Параметры:
//  Комментарий  - Строка - начальное значение задано, можно переустановить,
//                 комментарий записывается в журнал регистрации.
//
Процедура ПослеЗаписиАдминистратораПриАвторизации(Комментарий) Экспорт
	
	
	
КонецПроцедуры

