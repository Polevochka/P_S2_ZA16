unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, Unit2;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Memo1: TMemo;
    Memo2: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

  // Делаем матрицу и её размерность глобальными переменными
  // чтобы они были видны во всех функциях -
  // обработчиков нажатия кнопок
  M: TMatrix;
  rows: integer;
  cols: integer;

implementation

{$R *.lfm}

{ TForm1 }

// удобно будет создать процедуру вывода матрицы в объект типа TMemo
// 'var mem:TMemo' так как мы будем изменять объект Memo - записывать в него
// Хотя это не обязательно, работает и без, тупо для приличия делаем так
procedure PrintMatrix(M: TMatrix; rows: integer; cols: integer; var mem: TMemo);
var
  // строковое представление одного числа
  el_str: string;
  // вспомогательная строка, чтобы добавить элементы матрицы
  // то есть это сумма строковых представлений каждого элемента(el_str) матрциы
  tmp_str: string;
  // переменные для циклов обхода матрицы
  i,j: integer;
begin
  // перед записью чего-то в Memo очищаем его
  mem.Clear;

  // сначала мы будем собирать строку из элементов матрицы,
  // лежащих на i-ой строчке
  // Потом добавляем эту строку в Memo через Append
  for i:=1 to rows do
  begin
    // присваиваем пустую строку про обработке каждой строки матрицы
    // То есть обработали одну строку, очистили переменную, обработать другую
    // иначе элементы с другой (предыдущей) строки будут выводиться и в новой строке
    tmp_str:='';
    for j:=1 to cols do
    begin
      // преобразуем елемент матрицы в строку
      // число 4 - так же как и в writeln - ширина поля под число
      // чтобы не замарачиваться с пробелами при выводе
      str(M[i,j]:4, el_str);
      // по одному элементы i-ой строки собираем в одну строку
      tmp_str := tmp_str + el_str;
    end;
    // собрали одну строку, теперь добавляем её в Memo
    mem.Append(tmp_str);

  end;
end;

// Необязательно - по прихоти препода
{Считываем матрицу из Memo}
// 'var' чтобы изменить переменные передавааемые в функцию
// mem: TMemo без var т.к. мы только считываем оттуда
procedure InputMatrix(var M: TMatrix; var rows: integer; var cols: integer; mem:TMemo);
var i, j: integer;
    c: integer; // номер столбца элемента
    el_str: string; // чтобы перебирать строку посимвольно

begin

  // Перебираем строки из Memo
  for i:=0 to mem.Lines.Count-1 do
  begin

    j :=1;  // Счётчик СИМВОЛОВ в строке
    c := 0; // Счётчик ЭЛЕМЕНТОВ - найденных ЧИСЕЛ
    // Перебираем i-ую строку посимвольно
    while (j <= length(mem.Lines[i])) do
    begin
      // собираем из символов число
      el_str := ''; // cтрока цифр - элемент матрицы в виде строки
      while ((j <= length(mem.Lines[i])) and (mem.Lines[i][j] in ['0' .. '9'])) do
      begin
         el_str := el_str + mem.Lines[i][j];
         j:= j +1;
      end;

      // Нужно сделать проверку
      // Вдруг вначале стояли пробелы и мы даже не начали цикл выше
      // то есть mem.Lines[i][j] in ['0' .. '9'] - ЛОЖЬ

      // если строковое представление элемента - НЕ пустая строка
      if (not (el_str = '')) then
      begin
        // Мы смогли собрать число
        // Увеличиваем счётчик элементов в одной строке
        c:= c + 1;
        // И добавляем число в матрицу
        // i+1 - тк строки в Memo нумеруются с 0, а в матрице с 1
        M[i+1, c] := StrToInt(el_str); // нужно привести к целому типу

        // По поводу счётчика елементов 'с' - счётчика чисел в строке
        // мы не можем перебрать элементы из строки в цикле for
        // так как не известно их количество
        // так же мы не можем перебрать элемнты считывая их по одному
        // как в readln т.к. мы имеем только строки и мы должны преобразовать
        // последовательность символов в ЦЕЛОЧИСЛЕННЫЕ элементы матрицы
        // Счётчик элементов 'c' в строке будет увеличиваться каждый раз,
        // когда мы находим(собираем из символом) число в строке
        // и  он будет обнуляться при переходе на новую строку
      end;

      // если мы здесь то дальше каой-то символ - НЕ цифра

      // Перебираем строку до тех пор пока не попадём не цыфру
      // Нам нужны только цыфры, а остальные символы просто пропускаем
      while ((j <= length(mem.Lines[i])) and not (mem.Lines[i][j] in ['0' .. '9'])) do
        j := j + 1;
    end;
  end;
  // Нужно также задать РАЗМЕРНОСТЬ полученной матрицы
  rows:= mem.Lines.Count; // число строк = число строк в Memo
  // Число столбцов равно счётчику элементов в одной строке
  // Прричом заметь, что после завершения цикла с - не обнуляется
  // И равен как раз найденному числу элементов в строке
  cols:= c;
end;

{Нажали 'Ввести матрицу'}
procedure TForm1.Button1Click(Sender: TObject);
begin

  // Получаем размерность матрицы от пользователя
  // InputBox возвращает строку, но ГЛОБАЛЬНЫЕ переменные rows и cols типа integer
  // поэтому преобразуем возвращаем значение в целое число при помощи StrToInt
  rows := StrToInt(InputBox('Размерность матрицы', 'Введите число СТРОК', '5'));
  cols := StrToInt(InputBox('Размерность матрицы', 'Введите число СТОЛБЦОВ', '5'));

  randomize;
  // Теперь так как УЖЕ ЕСТЬ число строк и столбцов
  // Заполняем матрицу
  randomize; // для генератора случайных чисел
  FillMatrix(M, rows, cols);

  // выводим матрицу в Memo1 - исходная матрица
  PrintMatrix(M,rows,cols,Memo1);

end;

{Нажали кнопку 'Максимумы ВВЕРХ'}
procedure TForm1.Button2Click(Sender: TObject);
begin
  // Считывам матрицу из Memo1 и узнаём их число строк и столбцов
  // Здесь это не обязательно,
  // так как матрица сохранена уже в ГЛОБАЛЬНОЙ переменной M
  // Но если Препод вдруг ЗАХОЧЕТ, поменять какое-нибудь число в
  // В Memo1 и скажет, что в Memo2 оно тоже должно быть
  // Тогда нужна строчка кода ниже, если такой функционал не требуется
  // то закомментируйте её или удалите
   InputMatrix(M, rows, cols, Memo1);

  // Передвигаем максимумы в столбцах наверх
  MoveUp(M, rows, cols);
  // и выводим полученную матрицу в Memo2
  PrintMatrix(M, rows, cols, Memo2);
end;

{Нажали кнопку 'Максимумы ВНИЗ'}
procedure TForm1.Button3Click(Sender: TObject);
begin
  // Считывам матрицу из Memo1 и узнаём их число строк и столбцов
  // Здесь это не обязательно,
  // так как матрица сохранена уже в ГЛОБАЛЬНОЙ переменной M
  // Но если Препод вдруг ЗАХОЧЕТ, поменять какое-нибудь число в
  // В Memo1 и скажет, что в Memo2 оно тоже должно быть
  // Тогда нужна строчка кода ниже, если такой функционал не требуется
  // то закомментируйте её или удалите
   InputMatrix(M, rows, cols, Memo1);

  // Передвигаем максимумы в столбцах вниз
  MoveDown(M, rows, cols);
  // и выводим полученную матрицу в Memo2
  PrintMatrix(M, rows, cols, Memo2);
end;

{Нажали 'Закрыть' - выход из программы}
procedure TForm1.Button4Click(Sender: TObject);
begin
  close;
end;

end.

