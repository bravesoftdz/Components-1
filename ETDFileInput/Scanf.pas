(* E. Sorokin  2001, ver 1.4 *)
(* Version for Delphi 4 and above*)
(* Text scanning routines *)

{$WRITEABLECONST OFF} {$EXTENDEDSYNTAX ON}

unit Scanf;

interface

  //uses
  //  Classes;

  //function fscanf(const buffer, format: PAnsiChar; Args: array of Pointer): Integer; cdecl; varargs; external 'msvcrt.dll';
  //function fscanf(F: TStream; const Format: PAnsiChar; Pointers: array of Pointer): Integer; cdecl; varargs; external 'msvcrt.dll';
uses Scanf_c, sysutils, classes;

{ (Almost) compatible to C/C++ scanf}
function sscanf(Str : PAnsiChar; Format : PAnsiChar; Pointers : array of Pointer): Integer;
function fscanf(F : TStream; Format : PAnsiChar; Pointers : array of Pointer) : Integer;

{ Formatted scan  � la scanf, but using FormatBuf syntax.}
function StrDeFmt(Buffer, Format : PAnsiChar; Args : array of const) : integer;
function DeFormat(const Str : AnsiString; const Format: AnsiString; Args : array of const) : integer;
function DeFormatBuf(const Buffer; BufLen: Cardinal; const Format; FmtLen: Cardinal; const Args: array of const): integer;

{Decimal, hex, and octal representations of an int64 (Comp) type}
function int64ToStr(c : int64) : String; // for compatibility with scanf 1.0
function int64ToHex(c : int64) : String; // for compatibility with scanf 1.0
function int64ToOct(c : int64) : String;

{RTL extensions, accepting ThousandSeparator}
function TextToFloatS(Buffer: PAnsiChar; var Value; ValueType: TFloatValue): Boolean;
function StrToCurrS(const S: AnsiString): Currency;
function StrToFloatS(const S: AnsiString): Extended;

{RTL extension, accepting formatted currency string}
function StrToCurrF(const S: AnsiString): Currency;

implementation


function StrDeFmt(Buffer, Format : PAnsiChar; Args : array of const) : integer;
begin
  StrDeFmt:=DeFormat_core(Buffer, Length(Buffer), Format, Length(Format), Args,
                          AnsiChar(FormatSettings.DecimalSeparator), AnsiChar(FormatSettings.ThousandSeparator));
end;

function DeFormat(const Str : AnsiString; const Format: AnsiString; Args : array of const) : integer;
var Buf, Fmt : PAnsiChar;
begin
  Buf:=PAnsiChar(Str);
  Fmt:=PAnsiChar(Format);
  DeFormat:=DeFormat_core(Buf, Length(Str), Fmt, Length(Format), Args,
                          AnsiChar(FormatSettings.DecimalSeparator), AnsiChar(FormatSettings.ThousandSeparator));
end;

function DeFormatBuf(const Buffer; BufLen: Cardinal; const Format; FmtLen: Cardinal; const Args: array of const): integer;
var Buf, Fmt : PAnsiChar;
begin
  Buf:=PAnsiChar(Buffer);
  Fmt:=PAnsiChar(Format);
  DeFormatBuf:=DeFormat_core(Buf, BufLen, Fmt, FmtLen, Args, AnsiChar(FormatSettings.DecimalSeparator), AnsiChar(FormatSettings.ThousandSeparator));
end;

function sscanf;
begin
  Sscanf := Scanf_core(Str, Format, Pointers);
  if (Result = 0) and (Str^=#0) then Result:=scEOF; // C scanf would have done this...
end;

function fscanf;
begin
  fscanf := Scanf_stream(F, Format, Pointers);
end;

function TextToFloatS;
var EsRes : integer;
    Buf : PAnsiChar;
    {$IFOPT Q+} Save CW, NewCW : word; {$ENDIF}
    Neg : boolean;
begin
  Buf:=Buffer;
  while (Buf^ <= ' ') and (Buf^ > #0) do Inc(Buf);
  Neg:= (Buf^='-'); If Neg then Inc(Buf);
  EsRes:=Ext_scanner(Buf, Maxlongint, Ord(ValueType)*4, AnsiChar(FormatSettings.DecimalSeparator), AnsiChar(FormatSettings.ThousandSeparator));
  if (EsRes and scOK) <> 0 then begin
    If Neg then asm fchs; end;
    Case ValueType of
      fvExtended : asm mov eax,[Value]; fstp  tbyte ptr [eax]; end;
      fvCurrency : asm
                 {$IFOPT Q+}
                    fstcw SaveCW
                    mov    NewCW,$33f     // Mask exceptions
                    fldcw  NewCW
                 {$ENDIF}
                    mov    eax,[Value]
                    fistp qword ptr [eax];
                 {$IFOPT Q+}
                    fnstsw ax
                    and   eax,8+1        // FPU overflow and invalidop mask
                    jz    @@OK
                    or    [Result],scOverflow
                    @@OK: fclex
                    fldcw SaveCW
                 {$ENDIF}
                   end;
    end;
    Result:=True;
  end else Result:=False;
{$IFOPT Q+}
  if (EsRes and scOverflow) <> 0 then
  raise EOverflow.Create(SOverflow + ' while scanning ' + Copy(Buffer,1, Buf-Buffer));
{$ENDIF}
end;

function StrToCurrS;
begin
  if not TextToFloatS(PAnsiChar(S), Result, fvCurrency) then
    raise EConvertError.CreateFmt(SInvalidFloat, [S]);
end;

function StrToFloatS;
begin
  if not TextToFloatS(PAnsiChar(S), Result, fvExtended) then
    raise EConvertError.CreateFmt(SInvalidFloat, [S]);
end;

function StrToCurrF;
var Buf : PAnsiChar;
begin
  Buf:=PAnsiChar(S);
  If StrToCurrF_core(Buf, Length(S), Result, PAnsiChar(AnsiString(FormatSettings.CurrencyString)),
     FormatSettings.CurrencyFormat, FormatSettings.NegCurrFormat, AnsiChar(FormatSettings.DecimalSeparator), AnsiChar(FormatSettings.ThousandSeparator)) <=0
  then raise EConvertError.CreateFmt(SInvalidFloat, [S]);
end;

type Ti64 = record Lo, Hi : integer; end;

function int64ToStr;
begin
  Result:=IntToStr(C);
end;

function int64ToHex;
begin
  Result:=IntToHex(C,1);
end;

function int64ToOct;
var Temp : String[23];
    b : byte;
    i64 : Ti64 absolute c;
begin
  SetLength(Temp,23);
  b:=23;
  while (i64.Lo <> 0) or (i64.Hi <> 0) do begin
    Temp[b]:=AnsiChar( (i64.Lo and $07) + Ord('0') );
    asm
      MOV     EAX,DWORD PTR [C+4];
      SHRD    DWORD PTR [C],EAX,3
      SHR     EAX,3
      MOV     DWORD PTR[C+4],EAX
    end;
    Dec(b);
  end;
  Temp[b]:='0';
  Result:=Copy(string(Temp), b, 255);
end;

{Scanf unit}
end.

