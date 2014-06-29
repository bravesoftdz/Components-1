{ -------------------------------------------------------------------------------
  The contents of this file are subject to the Mozilla Public License
  Version 1.1 (the "License"); you may not use this file except in compliance
  with the License. You may obtain a copy of the License at
  http://www.mozilla.org/MPL/

  Software distributed under the License is distributed on an "AS IS" basis,
  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
  the specific language governing rights and limitations under the License.

  The Original Code is: SynUniHighlighter.pas, released 2003-01
  All Rights Reserved.

  Alternatively, the contents of this file may be used under the terms of the
  GNU General Public License Version 2 or later (the "GPL"), in which case
  the provisions of the GPL are applicable instead of those above.
  If you wish to allow use of your version of this file only under the terms
  of the GPL and not to allow others to use your version of this file
  under the MPL, indicate your decision by deleting the provisions above and
  replace them with the notice and other provisions required by the GPL.
  If you do not delete the provisions above, a recipient may use your version
  of this file under either the MPL or the GPL.

  {
  @abstract(TSynUniSyn classes source)
  @authors(Fantasist [walking_in_the_sky@yahoo.com], Vit [nevzorov@yahoo.com],
  Vitalik [vetal-x@mail.ru], Quadr0 [quadr02005@yahoo.com])
  @created(2003)
  @lastmod(2005-05-17)
}

unit SynUniClasses;

interface

uses
  SysUtils,
{$IFDEF SYN_CLX}
  Types, QGraphics,
{$ELSE}
  Windows, Graphics,
{$ENDIF}
  Classes,
  SynEditTypes,
  SynEditHighlighter,
  SynUniParser;

type
  { Set of symbols }
  TSymbSet = set of AnsiChar;

  { Class with information about highlighting scheme }
  TSynInfo = class;
  { Writes TSynUniSyn properties to stream }
  TStreamWriter = class;
  { Symbol class }
  TSynSymbol = class;
  { Symbol node class }
  TSymbolNode = class;
  { Symbol list class }
  TSymbolList = class;
  { Rule class }
  TSynRule = class;

  { Provides information about version type }
  TVersionType = (vtInternalTest, vtBeta, vtRelease);

  { Provides information about highlighting scheme author }
  TAuthorInfo = record
    Name: string;
    Email: string;
    Web: string;
    Copyright: string;
    Company: string;
    Remark: string;
  end;

  { Provides information about version }
  TVerInfo = record
    Version: integer;
    Revision: integer;
    VersionType: TVersionType;
    ReleaseDate: TDateTime;
  end;

  { Provides general information about highliting scheme }
  THighInfo = record
    Name: string;
    Extensions: string;
  end;

  { Base class to handle with highlighting schemes information }
  TSynInfo = class
    Author: TAuthorInfo;
    Version: TVerInfo;
    General: THighInfo;
    History: TStringList;
    Sample: TStringList;
    constructor Create();
    procedure Clear();
    { Loads information from XML }
    procedure LoadFromXml(xml: TXMLParser);
    { Loads information from stream }
    procedure LoadFromStream(Stream: TStream);
    { Saves information to stream }
    procedure SaveToStream(Stream: TStream; Ind: integer = 0); overload;
    procedure SaveToStream(StreamWriter: TStreamWriter; Ind: integer = 0); overload;
  end;

  TSynEditProperties = class

  end;

  { Start symbol type }
  TSymbStartType = (stUnspecified, stAny, stTerm);
  { symbol brake type }
  TSymbBrakeType = (btUnspecified, btAny, btTerm);
  { Start symbol line type }
  TSymbStartLine = (slNotFirst, slFirst, slFirstNonSpace);

  { Class for stream writing }
  TStreamWriter = class
    Stream: TStream;
    constructor Create(aStream: TStream);
    procedure WriteString(const Str: string);
    procedure InsertTag(Ind: integer; Name: string; Value: string);
    procedure WriteTag(Ind: integer; Name: string; EndLine: boolean = False);
    procedure WriteParam(Key, Value: string; CloseTag: string = '');
    procedure WriteBoolParam(Key: string; Value, Default: boolean; CloseTag: string = '');
  end;

  { Highlight attributes }
  TSynAttributes = class(TSynHighlighterAttributes)
  public
    // UseStyle: boolean;
    OldColorForeground: TColor;
    OldColorBackground: TColor;
    ParentForeground: boolean;
    ParentBackground: boolean;
    constructor Create(Name: string);
    // destructor Destroy(); override;
    procedure LoadFromString(Value: string);
    procedure SaveToStream(StreamWriter: TStreamWriter);
  end;

  { Abstract rule }
  TAbstractRule = class;

  { Class for symbols handling }
  TSynSymbol = class
  public
    Symbol: string;
    fOpenRule: TAbstractRule;
    StartType: TSymbStartType;
    BrakeType: TSymbBrakeType;
    StartLine: TSymbStartLine;
    Attributes: TSynHighlighterAttributes;
    { Constructor of TSynSymbol }
    constructor Create(st: string; Attribs: TSynHighlighterAttributes); virtual;
    { Destructor of TSynSymbol }
    destructor Destroy(); override;
  end;

  { Symbol node }
  TSymbolNode = class
    ch: WideChar;
    BrakeType: TSymbBrakeType;
    StartType: TSymbStartType;
    NextSymbs: TSymbolList;
    tkSynSymbol: TSynSymbol;
    { Constructor of TSymbolNode }
    constructor Create(AC: WideChar; SynSymbol: TSynSymbol; ABrakeType: TSymbBrakeType); overload; virtual;
    constructor Create(AC: WideChar); overload;
    { Destructor of TSymbolNode }
    destructor Destroy(); override;
  end;

  { Symbol list }
  TSymbolList = class
    SymbList: TList;
    { Add Node to SymbolList }
    procedure AddSymbol(symb: TSymbolNode);
    { Set Node in SymbolList bt index }
    procedure SetSymbolNode(Index: integer; Value: TSymbolNode);
    { Find Node in SymbolList by WideChar }
    function FindSymbol(ch: WideChar): TSymbolNode;
    function GetSymbolNode(Index: integer): TSymbolNode;
    function GetCount(): integer;
    property Nodes[index: integer]: TSymbolNode read GetSymbolNode write SetSymbolNode;
    property Count: integer read GetCount;
    { Constructor of TSymbolList }
    constructor Create(); virtual;
    { Destructor of TSymbolList }
    destructor Destroy(); override;
  end;

  { Highlight styles }
  TSynUniStyles = class(TObjectList)
  public
    FileName: string;
    { Constructor of TSynUniStyles }
    constructor Create();
    { Destructor of TSynUniStyles }
    destructor Destroy(); override;
    function GetStyle(const Name: string): TSynAttributes;
    function GetStyleDef(const Name: string; const Def: TSynAttributes): TSynAttributes;
    procedure AddStyle(Name: string; Foreground, Background: TColor; FontStyle: TFontStyles);
    procedure ListStylesNames(const AList: TStrings);
    function GetStylesAsXML(): string;
    procedure Load();
    procedure Save();
  end;

  TAbstractRule = class
    Enabled: boolean;
    constructor Create();
  end;

  { Syn rule }
  TSynRule = class(TAbstractRule)
  public
    Ind: integer; // temp
    Name: string;
    Attribs: TSynAttributes;
    Style: string;
    Styles: TSynUniStyles;
    { Constructor of TSynRule }
    constructor Create();
    { Destructor of TSynRule }
    destructor Destroy(); override;
    procedure LoadFromXml(xml: TXMLParser); virtual; abstract;
    procedure LoadFromStream(aSrc: TStream);
    procedure LoadFromFile(FileName: string);
    function GetAsStream(): TMemoryStream;
    procedure SaveToStream(Stream: TStream; Ind: integer = 0); overload;
    procedure SaveToStream(StreamWriter: TStreamWriter; Ind: integer = 0); overload; virtual; abstract;
  end;

function StrToSet(st: string): TSymbSet;
function SetToStr(st: TSymbSet): string;
function StrToFontStyle(Style: string): TFontStyles;
function FontStyleToStr(Style: TFontStyles): string;
procedure FreeList(var List: TList);
procedure ClearList(List: TList);
{ Creates indent of specified spaces }
function Indent(i: integer): string;

const
  AbsoluteTermSymbols: TSymbSet = [#0, #9, #10, #13, #32];
  EOL = #13#10;
  CloseEmptyTag = '/>';
  CloseStartTag = '>';

implementation

uses
  SynUniRules,
  SynEditStrConst;

{
  function Stream2PWideChar(Stream: TStream; var buf: PWideChar): boolean;
  var
  BufSize: Integer;
  begin
  if Assigned(buf) then
  FreeMem(buf);
  try
  Stream.Position := 0;
  BufSize := Stream.Size;
  GetMem(buf, BufSize+1);
  Stream.ReadBuffer(buf^, BufSize);
  buf[BufSize] := #0;
  Result := True;
  except
  FreeMem(buf);
  Result := False;
  end;
  end;
}
function StrToSet(st: string): TSymbSet;
var
  i: integer;
begin
  result := [];
  for i := 1 to length(st) do
    result := result + [st[i]];
end;

function SetToStr(st: TSymbSet): string;
var
  b: byte;
begin
  result := '';
  for b := 1 to 255 do
    if CharInSet(chr(b), st) and (not CharInSet(chr(b), AbsoluteTermSymbols)) then
      result := result + chr(b);
end;

function StrToFontStyle(Style: string): TFontStyles;
begin
  result := [];
  if Pos('B', Style) > 0 then
    Include(result, fsBold);
  if Pos('I', Style) > 0 then
    Include(result, fsItalic);
  if Pos('U', Style) > 0 then
    Include(result, fsUnderline);
  if Pos('S', Style) > 0 then
    Include(result, fsStrikeOut);
end;

function FontStyleToStr(Style: TFontStyles): string;
begin
  result := '';
  if fsBold in Style then
    result := result + 'B';
  if fsItalic in Style then
    result := result + 'I';
  if fsUnderline in Style then
    result := result + 'U';
  if fsStrikeOut in Style then
    result := result + 'S';
end;

procedure FreeList(var List: TList);
var
  i: integer;
begin
  if List = nil then
    exit;
  for i := 0 to List.Count - 1 do
    TObject(List[i]).Free;
  List.Free;
  List := nil;
end;

procedure ClearList(List: TList);
var
  i: integer;
begin
  if List = nil then
    exit;
  for i := 0 to List.Count - 1 do
    TObject(List[i]).Free;
  List.Clear;
end;

// ==== TInfo =================================================================
constructor TSynInfo.Create();
begin
  inherited;
end;

procedure TSynInfo.Clear();
begin
  General.Name := '';
  General.Extensions := '';
  Author.Name := '';
  Author.Email := '';
  Author.Web := '';
  Author.Copyright := '';
  Author.Company := '';
  Author.Remark := '';
  Version.Version := 0;
  Version.Revision := 0;
  Version.ReleaseDate := 0;
  Version.VersionType := vtInternalTest;
  History.Clear;
  Sample.Clear;
end;

procedure TSynInfo.LoadFromXml(xml: TXMLParser);
var
  i: integer;
  Key, Value: string;
  ds: Char;
begin
  while xml.Scan do
  begin
    if (xml.CurPartType = ptEmptyTag) or (xml.CurPartType = ptStartTag) then
      if SameText('General', xml.CurName) then
        for i := 0 to xml.CurAttr.Count - 1 do
        begin
          Key := xml.CurAttr.Name(i);
          Value := xml.CurAttr.Value(i);
          if SameText('Name', Key) then
            General.Name := Value
          else if SameText('Extensions', Key) then
            General.Extensions := Value
        end
      else if SameText('Author', xml.CurName) then
        for i := 0 to xml.CurAttr.Count - 1 do
        begin
          Key := xml.CurAttr.Name(i);
          Value := xml.CurAttr.Value(i);
          if SameText('Name', Key) then
            Author.Name := Value
          else if SameText('Email', Key) then
            Author.Email := Value
          else if SameText('Web', Key) then
            Author.Web := Value
          else if SameText('Copyright', Key) then
            Author.Copyright := Value
          else if SameText('Company', Key) then
            Author.Company := Value
          else if SameText('Remark', Key) then
            Author.Remark := Value
          else
        end
      else if SameText('Version', xml.CurName) then
        for i := 0 to xml.CurAttr.Count - 1 do
        begin
          Key := xml.CurAttr.Name(i);
          Value := xml.CurAttr.Value(i);
          if SameText('Version', Key) then
            Version.Version := StrToIntDef(Value, 0)
          else if SameText('Revision', Key) then
            Version.Revision := StrToIntDef(Value, 0)
          else if SameText('Date', Key) then
            try
              Version.ReleaseDate := StrToFloat(Value)
            except
              ds := FormatSettings.DecimalSeparator;
              FormatSettings.DecimalSeparator := '.';
              try
                Version.ReleaseDate := StrToFloat(Value);
              except
              end;
              FormatSettings.DecimalSeparator := ds;
            end
          else if SameText('Type', Key) then
            if Value = 'Beta' then
              Version.VersionType := vtBeta
            else if Value = 'Release' then
              Version.VersionType := vtRelease
            else
              Version.VersionType := vtInternalTest
        end
      else if SameText('History', xml.CurName) then
      begin
        History.Clear;
        Sample.Clear;
        while xml.Scan do
          if (xml.CurPartType = ptStartTag) and SameText('H', xml.CurName) then
            History.Add(xml.CurContent)
          else if (xml.CurPartType = ptEndTag) and SameText(xml.CurName, 'History') then
            break
      end
      else if SameText('Sample', xml.CurName) then
      begin
        Sample.Clear;
        while xml.Scan do
          if (xml.CurPartType = ptStartTag) and Verify('S', xml) then
            Sample.Add(xml.CurContent)
          else if (xml.CurPartType = ptEndTag) and SameText(xml.CurName, 'Sample') then
            break
      end
      else
    else if (xml.CurPartType = ptEndTag) and SameText(xml.CurName, 'Info') then
      exit;
  end;
end;

procedure TSynInfo.LoadFromStream(Stream: TStream);
var
  buf: PWideChar;
  BufSize: integer;
  xml: TXMLParser;
begin
  buf := nil; // Чтобы убрать Warning компилятора
  try
    BufSize := Stream.Size;
    GetMem(buf, BufSize);
    Stream.ReadBuffer(buf^, BufSize);
    xml := TXMLParser.Create;
    if xml.LoadFromBuffer(buf) then
    begin
      xml.StartScan;
      LoadFromXml(xml);
    end;
  finally
    FreeMem(buf);
  end;
end;

procedure TSynInfo.SaveToStream(Stream: TStream; Ind: integer);
var
  StreamWriter: TStreamWriter;
begin
  StreamWriter := TStreamWriter.Create(Stream);
  SaveToStream(StreamWriter, Ind);
  StreamWriter.Free;
end;

procedure TSynInfo.SaveToStream(StreamWriter: TStreamWriter; Ind: integer);
var
  i: integer;
begin
  with StreamWriter do
  begin
    WriteTag(Ind, 'Info', True);

    WriteTag(Ind + 2, 'General');
    WriteParam('Name', General.Name);
    WriteParam('Extensions', General.Extensions, CloseEmptyTag);

    WriteTag(Ind + 2, 'Author');
    WriteParam('Name', Author.Name);
    WriteParam('Email', Author.Email);
    WriteParam('Web', Author.Web);
    WriteParam('Copyright', Author.Copyright);
    WriteParam('Company', Author.Company);
    WriteParam('Remark', Author.Remark, CloseEmptyTag);

    WriteTag(Ind + 2, 'Version');
    WriteParam('Version', IntToStr(Version.Version));
    WriteParam('Revision', IntToStr(Version.Revision));
    WriteParam('Date', FloatToStr(Version.ReleaseDate), CloseEmptyTag);
    { case Version.VersionType of
      vtInternalTest: WriteParam('Type', 'Internal Test');
      vtBeta: WriteParam('Type', 'Beta');
      vtRelease: WriteParam('Type', 'Release');
      end; }

    WriteTag(Ind + 2, 'History', True);
    for i := 0 to History.Count - 1 do
      InsertTag(Ind + 4, 'H', History[i]);
    WriteTag(Ind + 2, '/History', True);

    WriteTag(Ind + 2, 'Sample', True);
    for i := 0 to Sample.Count - 1 do
      InsertTag(Ind + 4, 'S', Sample[i]);
    WriteTag(Ind + 2, '/Sample', True);

    WriteTag(Ind, '/Info', True);
  end;
end;

// ==== TStreamWriter =========================================================
function Indent(i: integer): string;
begin
  SetLength(result, i);
  // if i > 0 then !!!!!!!!!!!!!!!!!!!!!!!!!
  FillChar(result[1], i, #32);
end;

function GetValidValue(Value: string): string;
begin
  Value := StringReplace(Value, '&', '&amp;', [rfReplaceAll, rfIgnoreCase]);
  Value := StringReplace(Value, '<', '&lt;', [rfReplaceAll, rfIgnoreCase]);
  Value := StringReplace(Value, '"', '&quot;', [rfReplaceAll, rfIgnoreCase]);
  result := StringReplace(Value, '>', '&gt;', [rfReplaceAll, rfIgnoreCase]);
end;

constructor TStreamWriter.Create(aStream: TStream);
begin
  Stream := aStream;
end;

procedure TStreamWriter.WriteString(const Str: string);
begin
  Stream.Write(Str[1], length(Str));
end;

procedure TStreamWriter.InsertTag(Ind: integer; Name: string; Value: string);
begin
  WriteString(Format('%s<%s>%s</%s>' + EOL, [Indent(Ind), name, GetValidValue(Value), name]));
end;

{ procedure OpenTag(Ind: integer; Name: string; Param: string = ''; ParamValue: string = '');
  begin
  if Param = '' then
  WriteString(Format('%s<%s>', [Indent(Ind), Name]))
  else
  WriteString(Format('%s<%s %s="%s">', [Indent(Ind), Name, Param, GetValidValue(ParamValue)]));
  end; }

procedure TStreamWriter.WriteTag(Ind: integer; Name: string; EndLine: boolean = False);
begin
  WriteString(Format('%s<%s', [Indent(Ind), name]));
  if EndLine then
    WriteString('>' + EOL);
end;

{ procedure SaveColor(MainTag: string; Ind, Fore, Back: integer; Style: TFontStyles; PFore, PBack: boolean);
  procedure InsertTagBool(Ind: integer; Name: string; Value: Boolean);
  begin
  if Value then
  WriteString(Format('%s<%s>True</%s>', [Indent(Ind), Name, Name]))
  else
  WriteString(Format('%s<%s>False</%s>', [Indent(Ind), Name, Name]))
  end;
  begin
  OpenTag(Ind, MainTag);
  InsertTag(Ind+1, 'Back', Inttostr(Back));
  InsertTag(Ind+1, 'Fore', Inttostr(Fore));
  InsertTag(Ind+1, 'Style', Fs2String(Style));
  InsertTagBool(Ind+1, 'ParentForeground', PFore);
  InsertTagBool(Ind+1, 'ParentBackground', PBack);
  OpenTag(Ind, '/'+MainTag);
  end; }

procedure TStreamWriter.WriteParam(Key, Value: string; CloseTag: string = '');
begin
  WriteString(Format(' %s="%s"', [Key, GetValidValue(Value)]));
  if CloseTag <> '' then
    WriteString(CloseTag + EOL);
end;

procedure TStreamWriter.WriteBoolParam(Key: string; Value, Default: boolean; CloseTag: string = '');
begin
  if Value <> default then
    WriteParam(Key, BoolToStr(Value, True), CloseTag);
end;

// ==== TAttributes ===========================================================
constructor TSynAttributes.Create(Name: string);
begin
  // Std := TSynHighlighterAttributes.Create(SYNS_AttrDefaultPackage);
  inherited Create(name, SYNS_AttrDefaultPackage);
  // UseStyle := False;
end;

{ destructor TSynAttributes.Destroy;
  //var xml: TXMLParser;
  begin
  //  if not UseStyle then
  //Std.Free;
  //  xml := TXMLParser.Create;
  //  xml.Standalone
  inherited;
  end;
}
procedure TSynAttributes.LoadFromString(Value: string);
begin
  ParentForeground := False;
  ParentBackground := False;
  Foreground := StrToIntDef(Copy(Value, 1, Pos(',', Value) - 1), 0);
  OldColorForeground := Foreground;
  Background := StrToIntDef(Copy(Value, Pos(',', Value) + 1, Pos(';', Value) - Pos(',', Value) - 1), $FFFFFF);
  OldColorBackground := Background;
  ParentForeground := LowerCase(Copy(Value, Pos(';', Value) + 1, Pos(':', Value) - Pos(';', Value) - 1)) = 'true';
  ParentBackground := LowerCase(Copy(Value, Pos(':', Value) + 1, Pos('.', Value) - Pos(':', Value) - 1)) = 'true';
  Style := StrToFontStyle(Copy(Value, Pos('.', Value) + 1, length(Value) - Pos('.', Value)));
  // '12345,0;true:false.'
  { Std.Background := StrToIntDef(Value, $FFFFFF);
    OldColorBackground := Std.Background;
    Std.Foreground := StrToIntDef(Value, 0);
    OldColorForeground := Std.Foreground;
    Std.Style := String2Fs(Value)
    ParentForeground := LoweValue = 'true'
    ParentBackground := LowerValue = 'true'; }
end;

procedure TSynAttributes.SaveToStream(StreamWriter: TStreamWriter);
begin
  with StreamWriter do
    WriteParam('Attributes', IntToStr(Foreground) + ',' + IntToStr(Background) + ';' + BoolToStr(ParentForeground, True)
      + ':' + BoolToStr(ParentBackground, True) + '.' + FontStyleToStr(Style));
end;

// ==== TSynSymbol ============================================================
constructor TSynSymbol.Create(st: string; Attribs: TSynHighlighterAttributes);
begin
  Attributes := Attribs;
  Symbol := st;
  fOpenRule := nil;
  StartLine := slNotFirst;
  StartType := stUnspecified;
  BrakeType := btUnspecified;
end;

destructor TSynSymbol.Destroy;
// : Destructor of TSynSymbol
begin
  inherited;
end;

// ==== TSymbolNode ===========================================================
constructor TSymbolNode.Create(AC: WideChar; SynSymbol: TSynSymbol; ABrakeType: TSymbBrakeType);
begin
  ch := AC;
  NextSymbs := TSymbolList.Create;
  BrakeType := ABrakeType;
  StartType := SynSymbol.StartType;
  tkSynSymbol := SynSymbol;
end;

constructor TSymbolNode.Create(AC: WideChar);
begin
  ch := AC;
  NextSymbs := TSymbolList.Create;
  tkSynSymbol := nil;
end;

destructor TSymbolNode.Destroy;
begin
  NextSymbs.Free;
  inherited;
end;

// ==== TSymbolList ===========================================================
procedure TSymbolList.AddSymbol(symb: TSymbolNode);
begin
  SymbList.Add(symb);
end;

constructor TSymbolList.Create;
begin
  SymbList := TList.Create;
end;

destructor TSymbolList.Destroy;
begin
  FreeList(SymbList);
  inherited;
end;

function TSymbolList.FindSymbol(ch: WideChar): TSymbolNode;
var
  i: integer;
begin
  result := nil;
  for i := 0 to SymbList.Count - 1 do
    if TSymbolNode(SymbList[i]).ch = ch then
    begin
      result := TSymbolNode(SymbList[i]);
      break;
    end;
end;

function TSymbolList.GetCount: integer;
// : Return Node count in SymbolList
begin
  result := SymbList.Count
end;

function TSymbolList.GetSymbolNode(Index: integer): TSymbolNode;
// : Return Node in SymbolList by index
begin
  result := TSymbolNode(SymbList[index]);
end;

procedure TSymbolList.SetSymbolNode(Index: integer; Value: TSymbolNode);
begin
  if index < SymbList.Count then
    TSymbolNode(SymbList[index]).Free;
  SymbList[index] := Value;
end;

constructor TAbstractRule.Create();
begin
  Enabled := True;
end;

// ==== TSynRule ==============================================================
{ function TSynRule.GetAttribs: TAttributes;
  begin
  if (Ind < 0) or (Ind >= AttribsList.Count) then
  raise Exception.CreateFmt ('Invalid index: %d', [Ind]);
  Result := TAttributes(AttribsList[Ind]);
  end;

  function TSynRule.GetAttribsByIndex(Index: integer): TAttributes;
  begin
  if (Index < 0) or (Index >= AttribsList.Count) then
  raise Exception.CreateFmt ('Invalid index: %d', [Ind]);
  Result := TAttributes(AttribsList[Index]);
  end;
}
constructor TSynRule.Create;
begin
  inherited;
  Ind := -1;
  Attribs := TSynAttributes.Create('unknown');
  // AttribsList := TList.Create;
end;

destructor TSynRule.Destroy;
begin
  // FreeList(AttribsList);
  { if Attribs <> nil then begin
    Attribs.Free;
    Attribs := nil;
    end; }
  inherited;
end;

{ function TSynRule.AddAttribute(): integer;
  var
  i: integer;
  begin
  ind := AttribsList.Add(TAttributes.Create);
  Attribs.ParentForeground := True;
  Attribs.ParentBackground := True;
  Attribs.Std.Foreground := clBlack;
  Attribs.Std.Background := clWhite;
  Attribs.OldColorForeground := Attribs.Std.Foreground;
  Attribs.OldColorBackground := Attribs.Std.Background;
  Attribs.Std.Style := [];
  Result := ind;

  if self is TSynRange then
  with self as TSynRange do begin
  for i := 0 to RangeCount-1 do
  Ranges[i].AddAttribute();
  for i := 0 to KeyListCount-1 do
  KeyLists[i].AddAttribute();
  for i := 0 to SetCount-1 do
  Sets[i].AddAttribute();
  end;
  end;

  procedure TSynRule.DeleteAttributes(Index: integer);
  var
  i: integer;
  begin
  AttribsList.Delete(Index);
  if AttribsList.Count = Index then
  ind := Index-1
  else
  ind := Index;
  if self is TSynRange then
  with self as TSynRange do begin
  for i := 0 to RangeCount-1 do
  Ranges[i].DeleteAttributes(Index);
  for i := 0 to KeyListCount-1 do
  KeyLists[i].DeleteAttributes(Index);
  for i := 0 to SetCount-1 do
  Sets[i].DeleteAttributes(Index);
  end;
  end;

  procedure TSynRule.ClearAttributes();
  var
  i: integer;
  begin
  ClearList(AttribsList);
  ind := -1;

  if self is TSynRange then
  with self as TSynRange do begin
  for i := 0 to RangeCount-1 do
  Ranges[i].ClearAttributes();
  for i := 0 to KeyListCount-1 do
  KeyLists[i].ClearAttributes();
  for i := 0 to SetCount-1 do
  Sets[i].ClearAttributes();
  end;
  end;

  procedure TSynRule.SetAttributesIndex(Index: integer);
  var
  i: integer;
  begin
  ind := Index;

  if self is TSynRange then
  with self as TSynRange do begin
  for i := 0 to RangeCount-1 do
  Ranges[i].SetAttributesIndex(Index);
  for i := 0 to KeyListCount-1 do
  KeyLists[i].SetAttributesIndex(Index);
  for i := 0 to SetCount-1 do
  Sets[i].SetAttributesIndex(Index);
  end;
  end; }

function TSynRule.GetAsStream: TMemoryStream;
begin
  result := TMemoryStream.Create;
  SaveToStream(result);
end;

procedure TSynRule.SaveToStream(Stream: TStream; Ind: integer = 0);
var
  StreamWriter: TStreamWriter;
begin
  StreamWriter := TStreamWriter.Create(Stream);
  SaveToStream(StreamWriter, Ind);
  StreamWriter.Free;
end;

procedure TSynRule.LoadFromStream(aSrc: TStream);
var
  buf: PWideChar;
  BufSize: integer;
  xml: TXMLParser;
  TagName: string;
begin
  buf := nil; // Чтобы убрать Warning компилятора
  if ClassName = 'TSynRange' then
    TagName := 'Range'
  else if ClassName = 'TSynKeyList' then
    TagName := 'Keywords'
  else if ClassName = 'TSynSet' then
    TagName := 'Set'
  else
    raise Exception.Create(ClassName + '.LoadFromStream - Unknown rule to load!');
  try
    BufSize := aSrc.Size;
    GetMem(buf, BufSize + 1);
    aSrc.ReadBuffer(buf^, BufSize);
    buf[BufSize] := #0;
    xml := TXMLParser.Create;
    if xml.LoadFromBuffer(buf) then
    begin
      xml.StartScan;
      while xml.Scan do
        if (xml.CurPartType = ptStartTag) then
          if SameText(xml.CurName, TagName) then
            LoadFromXml(xml);
    end;
  finally
    FreeMem(buf);
  end;
end;

procedure TSynRule.LoadFromFile(FileName: string);
var
  xml: TXMLParser;
begin
  if not FileExists(FileName) then
    raise Exception.Create(ClassName + '.LoadFromFile - "' + FileName + '" does not exists.');
  xml := TXMLParser.Create;
  try
    if xml.LoadFromFile(FileName) then
    begin
      xml.StartScan;
      LoadFromXml(xml);
    end;
  finally
    xml.Free;
  end;
end;

// ------ TSynUniStyles ---------------------------------------------------------
constructor TSynUniStyles.Create;
begin
  // Self.OwnsObjects := True;
end;

destructor TSynUniStyles.Destroy;
begin
  inherited;
end;

function TSynUniStyles.GetStyle(const Name: string): { TSynHighlighter } TSynAttributes;
begin
  result := GetStyleDef(name, nil);
end;

function TSynUniStyles.GetStyleDef(const Name: string; const Def: TSynAttributes): { TSynHighlighter } TSynAttributes;
var
  i: integer;
begin
  result := Def;
  for i := 0 to Self.Count - 1 do
    if SameText(TSynAttributes(Self.Items[i]).Name, name) then
    begin
      result := TSynAttributes(Self.Items[i]);
      exit;
    end;
end;

procedure TSynUniStyles.AddStyle(Name: string; Foreground, Background: TColor; FontStyle: TFontStyles);
var
  Atr: TSynAttributes;
begin
  Atr := TSynAttributes.Create(name);
  Atr.Foreground := Foreground;
  Atr.Background := Background;
  Atr.Style := FontStyle;
  Self.Add(Atr);
end;

procedure TSynUniStyles.ListStylesNames(const AList: TStrings);
var
  i: integer;
begin
  AList.BeginUpdate;
  try
    AList.Clear;
    for i := 0 to Self.Count - 1 do
      AList.Add(TSynAttributes(Self.Items[i]).Name);
  finally
    AList.EndUpdate;
  end;
end;

function TSynUniStyles.GetStylesAsXML: string;
var
  i: integer;
begin
  // Result:= '<?xml version="1.0" encoding="ISO-8859-1"?>'#13#10#13#10';
  result := '<Schemes>'#13#10;
  result := result + '  <Scheme Name="Default">'#13#10;
  for i := 0 to Self.Count - 1 do
    with { TSynHighlighter } TSynAttributes(Self.Items[i]) do
      result := result + '    <Style Name="' + name + '" Fg="' + IntToStr(Foreground) + '" Bg="' + IntToStr(Background)
        + '" FontStyle="' + FontStyleToStr(Style) + '/>'#13#10;
  result := result + '  </Scheme>'#13#10 + '</Schemes>';
end;

procedure TSynUniStyles.Load;
var
  xml: TXMLParser;
  i: integer;
  Name, FontStyle, Key, Value: string;
  Foreground, Background: TColor;
  Style: { TSynHighlighter } TSynAttributes;
begin
  if not FileExists(FileName) then
    raise Exception.Create(ClassName + '.Load - "' + FileName + '" does not exists.');

  Clear;
  xml := TXMLParser.Create;
  try
    xml.LoadFromFile(FileName);
    xml.StartScan;
    while xml.Scan do
    begin
      if (xml.CurPartType = ptEmptyTag) or (xml.CurPartType = ptStartTag) then
        if SameText(xml.CurName, 'Style') then
        begin
          name := '';
          Foreground := clLime;
          Background := clFuchsia;
          FontStyle := '';
          for i := 0 to xml.CurAttr.Count - 1 do
          begin
            Key := xml.CurAttr.Name(i);
            Value := xml.CurAttr.Value(i);
            if SameText('Name', Key) then
              name := Value
            else if SameText('Foreground', Key) then
              Foreground := StrToIntDef(Value, clBlack)
            else if SameText('Background', Key) then
              Background := StrToIntDef(Value, clWhite)
            else if SameText('FontStyle', Key) then
              FontStyle := Value
            else
          end;
          Style := Self.GetStyle(name);
          if Style <> nil then
          begin
            Style.Foreground := Foreground;
            Style.Background := Background;
            Style.Style := StrToFontStyle(FontStyle);
          end
          else
            Self.AddStyle(name, Foreground, Background, StrToFontStyle(FontStyle));
        end;
    end;
  finally
    FreeAndNil(xml);
  end;
end;

procedure TSynUniStyles.Save;
var
  S: string;
begin
  if not FileExists(FileName) then
    raise Exception.Create(ClassName + '.Save - "' + FileName + '" does not exists.');

  S := Self.GetStylesAsXML;
  with TFileStream.Create(FileName, fmOpenWrite) do
    try
      write(Pointer(S)^, length(S));
    finally
      Free;
    end;
end;

end.
