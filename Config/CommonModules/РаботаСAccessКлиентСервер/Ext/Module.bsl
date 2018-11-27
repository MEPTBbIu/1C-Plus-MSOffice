﻿
#Область ПрограммныйИнтерфейс

Функция ДоступенПоставщикJetOLEDB() Экспорт
	
	ЕстьУстановленныйAccess = Ложь;
	
	Попытка
		ИмяФайла = ПолучитьИмяВременногоФайла("accdb");
		АДОХ = Новый COMОбъект("ADOX.Catalog");
		СтрокаПодключения = ПолучитьСтрокуПодключенияJetOLEDB(ИмяФайла);
		АДОХ.Create(СтрокаПодключения);
		РаботаСAccessКлиентСервер.УдалитьФайлЕслиВозможно(ИмяФайла);
		ЕстьУстановленныйAccess = Истина;
	Исключение
		ЕстьУстановленныйAccess = Ложь;	
	КонецПопытки;
	
	Возврат ЕстьУстановленныйAccess;
	
КонецФункции

Процедура СоздатьБазуДанныхAccess(Знач ИмяФайла, Знач ПерезаписыватьФайл = Истина, ИспользоватьКлиенсткоеПриложениеAccess = Неопределено) Экспорт

	Если ПустаяСтрока(ИмяФайла) Тогда 
		ВызватьИсключение "Не задан путь к файлу базы!";
	Иначе
		Если ПерезаписыватьФайл Тогда
			Файл = Новый Файл(ИмяФайла);
			Если Файл.Существует() Тогда
				Файл = Неопределено;
				УдалитьФайлы(ИмяФайла);
			КонецЕсли;
		КонецЕсли;              
	КонецЕсли;	
	
	Если ИспользоватьКлиенсткоеПриложениеAccess = Неопределено Тогда
		ИспользоватьКлиенсткоеПриложениеAccess = ДоступенПоставщикJetOLEDB();
	КонецЕсли;
	
	Если ИспользоватьКлиенсткоеПриложениеAccess = Истина Тогда
		
		Попытка
			АДОХ = Новый COMОбъект("ADOX.Catalog");
		Исключение
			ВызватьИсключение 
				"Не удалось сформировать файл с данными. 
				|При создании объекта ADOX.Catalog произошла ошибка!
				|" + ОписаниеОшибки();
		КонецПопытки;
		
		СтрокаПодключения = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=""" + ИмяФайла + """;Jet OLEDB:Engine Type=5;"; 
		
		Попытка
			АДОХ.Create(СтрокаПодключения);
		Исключение
			ВызватьИсключение 
				"Не удалось сформировать файл с данными. 
				|При создании объекта ADOX.Catalog произошла ошибка!
				|" + ОписаниеОшибки();
		КонецПопытки;
		АДОХ.ActiveConnection.Close();
		АДОХ = Неопределено;
		
	Иначе
		
		Попытка
			ДанныеШаблона = РаботаСAccessВызовСервера.ПолучитьДвоичныеДанныеПустойБазыAccess();			
			ДанныеШаблона.Записать(ИмяФайла);
		Исключение
			ВызватьИсключение
			"Не удалось сформировать файл с данными. 
			|
			|Ошибка: " + ОписаниеОшибки();
		КонецПопытки;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура СоздатьТаблицуБазыДанных(ПутьКБазе, ОписаниеТаблицы, Соединение = Неопределено, ИспользоватьКлиенсткоеПриложениеAccess = Неопределено) Экспорт
	
	Если ИспользоватьКлиенсткоеПриложениеAccess = Неопределено Тогда
		ИспользоватьКлиенсткоеПриложениеAccess = ДоступенПоставщикJetOLEDB();
	КонецЕсли;
	
	Если ИспользоватьКлиенсткоеПриложениеAccess = Истина Тогда
		
		СтрокаПодключения = РаботаСAccessКлиентСервер.ПолучитьСтрокуПодключенияJetOLEDB(ПутьКБазе);
		Catalog = Новый COMОбъект("ADOX.Catalog");
		Catalog.ActiveConnection = СтрокаПодключения;
		
		Table = Новый COMОбъект("ADOX.Table");
		Table.Name = ОписаниеТаблицы.ИмяТаблицы;
		
		Для Каждого ОписаниеПоля Из ОписаниеТаблицы.ОписаниеПолей Цикл
			
			Column = Новый COMОбъект("ADOX.Column");
			Column.Name = ОписаниеПоля.Имя;	
			Column.Type = ОписаниеПоля.Тип;
			
			Если ОписаниеПоля.ТипЗначения = Тип("Число") Тогда
				Если ЗначениеЗаполнено(ОписаниеПоля.Длина) Тогда
					Column.NumericScale = ОписаниеПоля.Длина;
				КонецЕсли;		
				Если ЗначениеЗаполнено(ОписаниеПоля.ДлинаДробнойЧасти) Тогда
					Column.Precision = ОписаниеПоля.ДлинаДробнойЧасти;
				КонецЕсли;
				Column.Attributes = 2; // Доступно значение NULL
			ИначеЕсли ОписаниеПоля.ТипЗначения = Тип("Строка") Тогда
				Если ЗначениеЗаполнено(ОписаниеПоля.Длина) Тогда
					Column.DefinedSize = ОписаниеПоля.Длина;				
				КонецЕсли;			
				Column.Attributes = 2; // Доступно значение NULL
			ИначеЕсли ОписаниеПоля.ТипЗначения = Тип("Дата") Тогда
				Column.Attributes = 2; // Доступно значение NULL
			КонецЕсли;
			
			Table.Columns.Append(Column);
			
		КонецЦикла;
		
		Catalog.Tables.Append(Table);
		
	Иначе
		
		ЗакрытьСоединение = Ложь;
		Если Соединение = Неопределено Тогда
			Соединение = РаботаСAccessКлиентСервер.ПолучитьСоединениеADO(ПутьКБазе);
			ЗакрытьСоединение = Истина;
		КонецЕсли;
			
		Команда = Новый COMОбъект("ADODB.Command");
		Команда.ActiveConnection = Соединение;
		ТекстЗапроса = 
			"CREATE TABLE " + ОписаниеТаблицы.ИмяТаблицы +  "
			|(";	
		НомерПоля = 1;
		ВсегоПолей = ОписаниеТаблицы.ОписаниеПолей.Количество();
		Для Каждого ПолеТаблицы Из ОписаниеТаблицы.ОписаниеПолей Цикл
			
			ЭтоПоследнееПоле = (НомерПоля = ВсегоПолей);
			
			ТекстЗапроса = ТекстЗапроса + "
			|	" + ПолеТаблицы.Имя + " " + ПолеТаблицы.ИмяТипаЗначения + "" + ?(ЭтоПоследнееПоле, "", ",");
			
			НомерПоля = НомерПоля + 1;
			
		КонецЦикла;
				
		ТекстЗапроса = ТекстЗапроса + "
			|)";
		
		Команда.CommandText = ТекстЗапроса;
		
		Попытка
			Команда.Execute();
		Исключение
			ВызватьИсключение
				"Произошла ошибка при создании таблицы.
				|
				|Подробности:
				|" + ОписаниеОшибки();		
		КонецПопытки;

		Если ЗакрытьСоединение Тогда
			РаботаСAccessКлиентСервер.ЗакрытьСоединениеADO(Соединение);
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ДобавитьЗаписьВТаблицу(ОписаниеСтруктурыТаблицы, НаборЗаписейПриемник, ЗаписьИсточник) Экспорт
	
	НаборЗаписейПриемник.AddNew();
	
	Для Каждого ОписаниеПоля Из ОписаниеСтруктурыТаблицы.ОписаниеПолей Цикл
		
		ЗначениеПоля = ЗаписьИсточник[ОписаниеПоля.Имя];
		
		Если ЗначениеЗаполнено(ЗначениеПоля) Тогда
			Если НЕ РаботаСAccessСлужебныйКлиентСервер.ЭтоПримитивныйТип(ТипЗнч(ЗначениеПоля)) Тогда						
				НаборЗаписейПриемник.Fields(ОписаниеПоля.ИндексКолонки).Value = Строка(ЗначениеПоля);
			Иначе						
				Если ОписаниеПоля.ТипЗначения = Тип("Строка") Тогда
					НормализованнаяСтрока = СокрЛП(ЗначениеПоля);
					Если ЗначениеЗаполнено(ОписаниеПоля.Длина) Тогда
						НаборЗаписейПриемник.Fields(ОписаниеПоля.ИндексКолонки).Value = Лев(НормализованнаяСтрока, ОписаниеПоля.Длина)
					Иначе
						НаборЗаписейПриемник.Fields(ОписаниеПоля.ИндексКолонки).Value = НормализованнаяСтрока;
					КонецЕсли;
				ИначеЕсли ОписаниеПоля.ТипЗначения = Тип("Дата") Тогда
					Если РаботаСAccessСлужебныйКлиентСервер.ЭтоКорректнаяДата(ЗначениеПоля) Тогда
						НаборЗаписейПриемник.Fields(ОписаниеПоля.ИндексКолонки).Value = ЗначениеПоля;	
					КонецЕсли;
				Иначе
					НаборЗаписейПриемник.Fields(ОписаниеПоля.ИндексКолонки).Value = ЗначениеПоля;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
	КонецЦикла;
	
	НаборЗаписейПриемник.UpDate();
	
КонецПроцедуры

Функция СоставлениеСтруктурыОписанияПолей(Знач ТаблицаДанных, Знач ИмяТаблицы) Экспорт
	
	СтруктураОписания = Новый Структура("ИмяТаблицы,ОписаниеПолей");
    СтруктураОписания.ИмяТаблицы = ИмяТаблицы;
    СтруктураОписания.ОписаниеПолей = Новый Массив;
    
    ОбщийРазмерЗаписиБайт = 0;
	ИндексКолонки = 0;
    Для Каждого КолонкаТЗ Из ТаблицаДанных.Колонки Цикл
		
		СтруктураСвойстПоля = Новый Структура("Имя,Тип,Длина, ДлинаДробнойЧасти, Синоним, ТипЗначения, ИндексКолонки, ИмяТипаЗначения, ДлинаБайт");
        ТипЗначенияКолонки = КолонкаТЗ.ТипЗначения;		
        ДлинаСтроки = ТипЗначенияКолонки.КвалификаторыСтроки.Длина;
		Разрядность = ТипЗначенияКолонки.КвалификаторыЧисла.Разрядность;
		РазрядностьДробнойЧасти = ТипЗначенияКолонки.КвалификаторыЧисла.РазрядностьДробнойЧасти;
		ДлинаСтроки = КолонкаТЗ.ТипЗначения.КвалификаторыСтроки.Длина;
		СтруктураСвойстПоля.ДлинаБайт = 0;
		
		Если ТипЗначенияКолонки.Типы().Количество() > 2 Тогда
			
			СтруктураСвойстПоля.Имя = КолонкаТЗ.Имя;
            СтруктураСвойстПоля.Тип = "202";//adVarWChar, type 202 [строка в Юникоде длиной в 255 символов (DT_WSTR)] 
            СтруктураСвойстПоля.Длина = 255;
            СтруктураСвойстПоля.Синоним = КолонкаТЗ.Заголовок;
			СтруктураСвойстПоля.ИмяТипаЗначения = "CHAR(" + XMLСтрока(СтруктураСвойстПоля.Длина) + ")";
			СтруктураСвойстПоля.ТипЗначения = Тип("Строка");
			СтруктураСвойстПоля.ДлинаБайт = 255 + 10;
			
		ИначеЕсли ТипЗначенияКолонки.СодержитТип(Тип("Строка")) Тогда
			
			СтруктураСвойстПоля.ТипЗначения = Тип("Строка");
            СтруктураСвойстПоля.Имя = КолонкаТЗ.Имя;
			СтруктураСвойстПоля.Синоним = КолонкаТЗ.Заголовок;			
			
			ДополнительныйТип = Неопределено;
			ТипыПоля = ТипЗначенияКолонки.Типы();
			Если ТипыПоля.Количество() > 1 Тогда
				Для Каждого ТипПоля Из ТипыПоля Цикл
					Если ТипПоля <> Тип("Строка") Тогда
						ДополнительныйТип = ТипПоля;	
					КонецЕсли;
				КонецЦикла;
			КонецЕсли;
			
			Если ДлинаСтроки = 0 И НЕ ДополнительныйТип = Неопределено Тогда
				ДлинаСтроки = РаботаСAccessВызовСервера.ПолучитьДлинуПредставленияСсылочнгоТипа(ДополнительныйТип);
			КонецЕсли;
			
			Если ДлинаСтроки = 0 ИЛИ ДлинаСтроки >= 250 Тогда
				
                СтруктураСвойстПоля.Тип = "202";
				СтруктураСвойстПоля.Длина = 250;				
				СтруктураСвойстПоля.ДлинаБайт = СтруктураСвойстПоля.Длина + 10;
				СтруктураСвойстПоля.ИмяТипаЗначения = "CHAR(" + XMLСтрока(СтруктураСвойстПоля.Длина) + ")";
				
            Иначе
                СтруктураСвойстПоля.Тип = "202";
				СтруктураСвойстПоля.Длина = ДлинаСтроки;
				СтруктураСвойстПоля.ИмяТипаЗначения = "CHAR(" + XMLСтрока(СтруктураСвойстПоля.Длина) + ")";				
				СтруктураСвойстПоля.ДлинаБайт = СтруктураСвойстПоля.Длина + 10;
				
			КонецЕсли;
			
		ИначеЕсли ТипЗначенияКолонки.СодержитТип(Тип("Число")) Тогда
			
			СтруктураСвойстПоля.Имя = КолонкаТЗ.Имя;
            СтруктураСвойстПоля.Синоним = КолонкаТЗ.Заголовок;
			СтруктураСвойстПоля.ТипЗначения = Тип("Число");
			
			Если Разрядность = 0 ИЛИ РазрядностьДробнойЧасти = 0 Тогда
				
				СтруктураСвойстПоля.Тип = "5";					
				СтруктураСвойстПоля.Длина = 15;
				СтруктураСвойстПоля.ДлинаДробнойЧасти = 2;
				СтруктураСвойстПоля.ДлинаБайт = 8;
				СтруктураСвойстПоля.ИмяТипаЗначения = "DOUBLE";
				
			ИначеЕсли Разрядность = 0 И РазрядностьДробнойЧасти > 0 Тогда
				
				СтруктураСвойстПоля.Тип = "5";					
				СтруктураСвойстПоля.Длина = 1;
				СтруктураСвойстПоля.ДлинаДробнойЧасти = РазрядностьДробнойЧасти;
				СтруктураСвойстПоля.ДлинаБайт = 8;
				СтруктураСвойстПоля.ИмяТипаЗначения = "DOUBLE";
				
			ИначеЕсли РазрядностьДробнойЧасти > 0 И Разрядность > 0 Тогда
				
				СтруктураСвойстПоля.Тип = "5";					
				СтруктураСвойстПоля.Длина = Разрядность;
				СтруктураСвойстПоля.ДлинаДробнойЧасти = РазрядностьДробнойЧасти;
				СтруктураСвойстПоля.ДлинаБайт = 8;
				СтруктураСвойстПоля.ИмяТипаЗначения = "DOUBLE";
				
			Иначе
				
				СтруктураСвойстПоля.Тип = "3";				
				СтруктураСвойстПоля.Длина = Разрядность;
				СтруктураСвойстПоля.ДлинаДробнойЧасти = 0;
				СтруктураСвойстПоля.ДлинаБайт = 2;
				СтруктураСвойстПоля.ИмяТипаЗначения = "INTEGER";
				
			КонецЕсли;
						
		ИначеЕсли ТипЗначенияКолонки.СодержитТип(Тип("Булево")) Тогда
			
			СтруктураСвойстПоля.ТипЗначения = Тип("Булево");
            СтруктураСвойстПоля.Имя = КолонкаТЗ.Имя;
            СтруктураСвойстПоля.Тип = "11";
            СтруктураСвойстПоля.Длина = Неопределено;
            СтруктураСвойстПоля.Синоним = КолонкаТЗ.Заголовок;			
			СтруктураСвойстПоля.ДлинаБайт = 2;
			СтруктураСвойстПоля.ИмяТипаЗначения = "BIT";
			
		ИначеЕсли ТипЗначенияКолонки.СодержитТип(Тип("Дата")) Тогда
			
			СтруктураСвойстПоля.ТипЗначения = Тип("Дата");
            СтруктураСвойстПоля.Имя = КолонкаТЗ.Имя;
            СтруктураСвойстПоля.Тип = "7";
            СтруктураСвойстПоля.Длина = Неопределено;
            СтруктураСвойстПоля.Синоним = КолонкаТЗ.Заголовок;			
			СтруктураСвойстПоля.ДлинаБайт = 8;
			СтруктураСвойстПоля.ИмяТипаЗначения = "DATETIME";
			
		Иначе
			
			СтруктураСвойстПоля.ТипЗначения = Тип("Строка");
            СтруктураСвойстПоля.Имя = КолонкаТЗ.Имя;
            СтруктураСвойстПоля.Тип = "202";
            СтруктураСвойстПоля.Длина = 150;
            СтруктураСвойстПоля.Синоним = КолонкаТЗ.Заголовок;			
			СтруктураСвойстПоля.ДлинаБайт = СтруктураСвойстПоля.Длина + 10;
			СтруктураСвойстПоля.ИмяТипаЗначения = "CHAR(" + XMLСтрока(СтруктураСвойстПоля.Длина) + ")";
			
        КонецЕсли;
		
		СтруктураСвойстПоля.ИндексКолонки = ИндексКолонки;		
        СтруктураОписания.ОписаниеПолей.Добавить(СтруктураСвойстПоля);
		ОбщийРазмерЗаписиБайт = ОбщийРазмерЗаписиБайт + СтруктураСвойстПоля.ДлинаБайт;
		ИндексКолонки = ИндексКолонки + 1;
		
    КонецЦикла;
		
    Возврат СтруктураОписания;
КонецФункции

Функция ПолучитьОграниченияВыгрузкиБазы(
		МаксимальныйРазмерМБ = 1536, 
		МаксимальноеКоличествоЗаписей = 5000000,
		ПорцияВыгрузкиДляПроверкиРазмераБазы = 10000) Экспорт
	
	СтруктураОграничений = Новый Структура;
	СтруктураОграничений.Вставить("МаксимальныйРазмерМБ", МаксимальныйРазмерМБ);
	СтруктураОграничений.Вставить("МаксимальноеКоличествоЗаписей", МаксимальноеКоличествоЗаписей);
	СтруктураОграничений.Вставить("ПорцияВыгрузкиДляПроверкиРазмераБазы", ПорцияВыгрузкиДляПроверкиРазмераБазы);
	
	Возврат СтруктураОграничений;
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Функция ПолучитьСоединениеADO(ПутьКБазе) Экспорт
	
	СтрокаПодключения = "Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=" + ПутьКБазе;
	СоединениеКБазе = Новый COMОбъект("ADODB.Connection");	
	
	Попытка 		
		СоединениеКБазе.Open(СтрокаПодключения);		
	Исключение
		СоединениеКБазе = Неопределено;
		ВызватьИсключение
			"Произошла ошибка при установке соединения.
			|
			|Подробности:
			|" + ОписаниеОшибки();		
	КонецПопытки;	
	
	Возврат СоединениеКБазе;
	
КонецФункции

Процедура ЗакрытьСоединениеADO(Соединение) Экспорт
	
	Если Соединение = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Попытка
		Соединение.Close();
	Исключение
		
	КонецПопытки;
	
	Соединение = Неопределено;
	
КонецПроцедуры

Функция ПолучитьНаборЗаписейADO(Соединение, ИмяТаблицы) Экспорт
	
	Запись = Новый COMОбъект("ADODB.RecordSet");	
	ТекстЗапроса = "SELECT * FROM " + ИмяТаблицы;	
	Запись.Open(
		// Текст запроса 
		ТекстЗапроса, 
		// Соединение с базой
		Соединение,
		// Указывает тип курсора, используемого в записей объекта.
		// CursorType (https://docs.microsoft.com/ru-ru/sql/ado/reference/ado-api/cursortypeenum?view=sql-server-2017)
		// 1 = adOpenKeyset. Использует курсор набора ключей. 
		1, 			  
		// Тип блокировки
		// LockTypeEnum (https://docs.microsoft.com/ru-ru/sql/ado/reference/ado-api/open-method-ado-recordset?view=sql-server-2017)
		// 3 = adLockOptimistic (Указывает, оптимистической блокировки, записей.)
		3
	);
	
	Возврат Запись;
	
КонецФункции

Процедура Ожидание(Миллисекунды) Экспорт
	
	ЖдатьДо = ТекущаяУниверсальнаяДатаВМиллисекундах() + (Миллисекунды);
	Пока ЖдатьДо >= ТекущаяУниверсальнаяДатаВМиллисекундах() Цикл
		// Ничего не делаем
	КонецЦикла;
	
КонецПроцедуры

Функция УдалитьФайлЕслиВозможно(ПутьКФайлу) Экспорт
	
	Попытка
		УдалитьФайлы(ПутьКФайлу);
		Возврат Истина;
	Исключение
		Возврат Ложь;
	КонецПопытки;
	
КонецФункции

Функция ПолучитьСтрокуПодключенияJetOLEDB(ИмяФайла) Экспорт
	
	Возврат "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=""" + ИмяФайла + """;Jet OLEDB:Engine Type=5;";
	
КонецФункции

Функция ПолучитьВременныйРабочийКаталог() Экспорт
	
	ПутьКВременномуРабочемуКаталогу = КаталогВременныхФайлов() + "РаботаСAccess\";
	СоздатьКаталог(ПутьКВременномуРабочемуКаталогу);
	
	Возврат ПутьКВременномуРабочемуКаталогу;
	
КонецФункции

Функция ПолучитьПутьКФайлуШаблонаБазы() Экспорт
	
	ПутьКФайлуШаблонаБазы = ПолучитьВременныйРабочийКаталог() + "ШаблонБазыAccess.accdb";
	
	Возврат ПутьКФайлуШаблонаБазы;
	
КонецФункции

Функция ПолучитьВременныйКаталогВыгрузки(ИдентификаторВыгрузки) Экспорт
	
	ПутьКВременномуРабочемуКаталогуТекущийВыгрузки = ПолучитьВременныйРабочийКаталог() + ИдентификаторВыгрузки + "\";
	СоздатьКаталог(ПутьКВременномуРабочемуКаталогуТекущийВыгрузки);
	
	Возврат ПутьКВременномуРабочемуКаталогуТекущийВыгрузки;
	
КонецФункции

#КонецОбласти