{
@abstract(Provides Old Format 1.5 highlighters import)
@authors(Vitalik [just_vitalik@yahoo.com])
@created(2005)
@lastmod(2006-07-23)
}

{$IFNDEF QSynUniFormatNativeXml15}
unit SynUniFormatNativeXml15;
{$ENDIF}

{$I SynUniHighlighter.inc}

interface

uses
{$IFDEF SYN_CLX}
  QClasses,
  QGraphics,
  QSynUniFormat,
  QSynUniClasses,
  QSynUniRules,
  QSynUniHighlighter
{$ELSE}
  Classes,
  Graphics,
{$IFDEF SYN_COMPILER_6_UP}
  Variants,
{$ENDIF}
  SynUniFormat,
  SynUniFormatNativeXml,
  SynUniClasses,
  SynUniRules,
  SynUniHighlighter,
{$ENDIF}
  SysUtils,
  Dialogs,
  {XMLIntf; } // DW
  SimpleXML;
  
type
  TSynUniFormatNativeXml15 = class(TSynUniFormatNativeXml)
    class function ImportInfo(AInfo: TSynInfo; ANode: IXMLNode): Boolean; override;
    class function ExportInfo(AInfo: TSynInfo; ANode: IXMLNode): Boolean; override;
    class function ImportEditorProperties(AEditorProperties: TEditorProperties; ANode: IXMLNode): Boolean; override;
    class function ExportEditorProperties(AEditorProperties: TEditorProperties; ANode: IXMLNode): Boolean; override;
    class function ImportAttributes(Attributes: TSynAttributes; ANode: IXMLNode): Boolean; override;
    class function ExportAttributes(Attributes: TSynAttributes; ANode: IXMLNode): Boolean; override;
    class function ImportSchemes(ASchemes: TSynUniSchemes; ANode: IXMLNode): Boolean; override;
    class function ExportSchemes(ASchemes: TSynUniSchemes; ANode: IXMLNode): Boolean; override;
    class function ImportToken(AToken: TSynMultiToken; ANode: IXMLNode; Kind: string = ''): Boolean; reintroduce; overload;
    class function ExportToken(AToken: TSynMultiToken; ANode: IXMLNode; Kind: string = ''): Boolean; reintroduce; overload;
    class function ImportKeyList(AKeyList: TSynKeyList; ANode: IXMLNode): Boolean; override;
    class function ExportKeyList(AKeyList: TSynKeyList; ANode: IXMLNode): Boolean; override;
    class function ImportSet(ASet: TSynSet; ANode: IXMLNode): Boolean; override;
    class function ExportSet(ASet: TSynSet; ANode: IXMLNode): Boolean; override;
    class function ImportRange(ARange: TSynRange; ANode: IXMLNode): Boolean; override;
    class function ExportRange(ARange: TSynRange; ANode: IXMLNode): Boolean; override;
    class function ImportHighlighter(SynUniSyn: TSynUniSyn; ANode: IXMLNode): Boolean; override;
    class function ExportHighlighter(SynUniSyn: TSynUniSyn; ANode: IXMLNode): Boolean; override;
    class function ImportFromStream(AObject: TObject; AStream: TStream): Boolean; override;
    class function ExportToStream(AObject: TObject; AStream: TStream): Boolean; override;
    class function ImportFromFile(AObject: TObject; AFileName: string): Boolean; override;
    class function ExportToFile(AObject: TObject; AFileName: string): Boolean; override;
  end;

implementation

{$IFNDEF SYN_COMPILER_7_UP}
function StrToBoolDef(const S: string; const Default: Boolean): Boolean;
begin
  if (S = 'True') or (S = '1') or (S = '-1') then
    Result := True
  else if (S = 'False') or (S = '0') then
    Result := False
  else
    Result := Default;
end;
{$ENDIF}

//----------------------------------------------------------------------------
class function TSynUniFormatNativeXml15.ImportInfo(AInfo: TSynInfo; ANode: IXMLNode): Boolean;
var
  i: integer;
begin
  Result := True;
  with ANode, AInfo do
  begin
    with EnsureChild('General'), General do
    begin
      Name       := EnsureChild('Name').Text;
      Extensions := EnsureChild('FileTypeName').Text;
                    EnsureChild('Layout').Text;
    end;
    with EnsureChild('Author'), Author do
    begin
      Name      := EnsureChild('Name').Text;
      Email     := EnsureChild('Email').Text;
      Web       := EnsureChild('Web').Text;
      Copyright := EnsureChild('Copyright').Text;
      Company   := EnsureChild('Company').Text;
      Remark    := EnsureChild('Remark').Text;
    end;
    with EnsureChild('Version'), General do
    begin
      Version  := StrToInt(EnsureChild('Version').Text);
      Revision := StrToInt(EnsureChild('Revision').Text);
                  EnsureChild('Date').Text;
                  EnsureChild('Type').Text;
    end;
    with EnsureChild('Sample'), General do
      for i := 0 to ChildNodes.Count-1 do
        Sample := Sample + ChildNodes[i].Text + #13#10;
    with EnsureChild('History'), General do
      for i := 0 to ChildNodes.Count-1 do
        History := History + ChildNodes[i].Text + #13#10;
  end;
end;

//----------------------------------------------------------------------------
class function TSynUniFormatNativeXml15.ExportInfo(AInfo: TSynInfo; ANode: IXMLNode): Boolean;
var
  i: Integer;
  Buffer: TStringList;
  Node: IXMLNode;
begin
  with AInfo, ANode do
  begin
    with General, AppendElement('General') do
    begin
      AppendElement('Name').Text := Name;
      AppendElement('FileTypeName').Text := Extensions;
    end;
    with Author, AppendElement('Author') do
    begin
      AppendElement('Name').Text := Name;
      AppendElement('Email').Text := Email;
      AppendElement('Web').Text := Web;
      AppendElement('Copyright').Text := Copyright;
      AppendElement('Company').Text := Company;
      AppendElement('Remark').Text := Remark;
    end;
    with General, AppendElement('Version') do
    begin
      AppendElement('Version').Text := IntToStr(Version);
      AppendElement('Revision').Text := IntToStr(Revision);
    end;
    Buffer := TStringList.Create();
    with General, AppendElement('History') do
    begin
      Text := #13#10;
      Buffer.Text := History;
      for i := 0 to Buffer.Count-1 do
      begin
        Node := AppendElement('H');
        Node.Text := Buffer[i];
      end;
    end;
    with General, AppendElement('Sample') do
    begin
      Text := ' ';
      Buffer.Text := Sample;
      for i := 0 to Buffer.Count-1 do
      begin
        Node := AppendElement('S');
        Node.Text := Buffer[i];
      end;
    end;
    FreeAndNil(Buffer);
  end;
  Result := True;
end;

//----------------------------------------------------------------------------
class function TSynUniFormatNativeXml15.ImportEditorProperties(AEditorProperties:
  TEditorProperties; ANode: IXMLNode): Boolean;
begin
  // формат не поддерживает
  Result := True;
end;

//----------------------------------------------------------------------------
class function TSynUniFormatNativeXml15.ExportEditorProperties(AEditorProperties:
  TEditorProperties; ANode: IXMLNode): Boolean;
begin
  // формат не поддерживает
  Result := True;
end;

//----------------------------------------------------------------------------
class function TSynUniFormatNativeXml15.ImportAttributes(Attributes: TSynAttributes;
  ANode: IXMLNode): Boolean;
begin
  Result := True;
  with Attributes, ANode do begin
    if EnsureChild('Fore').Text <> '' then
      Foreground := StringToColor(EnsureChild('Fore').Text);
    if EnsureChild('Back').Text <> '' then
      Background := StringToColor(EnsureChild('Back').Text);
    Style := StrToFontStyle(EnsureChild('Style').Text);
    ParentForeground := StrToBoolDef(EnsureChild('ParentForeground').Text, False);
    ParentBackground := StrToBoolDef(EnsureChild('ParentBackground').Text, False);
  end;
end;

//----------------------------------------------------------------------------
class function TSynUniFormatNativeXml15.ExportAttributes(Attributes: TSynAttributes;
  ANode: IXMLNode): Boolean;
begin
  with Attributes, ANode do
  begin
    AppendElement('Back').Text := IntToStr(Background);
    AppendElement('Fore').Text := IntToStr(Foreground);
    AppendElement('Style').Text := FontStyleToStr(Style);
    AppendElement('ParentForeground').Text := BoolToStr(ParentForeground,True);
    AppendElement('ParentBackground').Text := BoolToStr(ParentBackground,True);
  end;
  Result := True;
end;

//----------------------------------------------------------------------------
class function TSynUniFormatNativeXml15.ImportSchemes(ASchemes: TSynUniSchemes; ANode: IXMLNode): Boolean;
begin
  //TODO: Add implementation here
  Result := True;
end;

//----------------------------------------------------------------------------
class function TSynUniFormatNativeXml15.ExportSchemes(ASchemes: TSynUniSchemes; ANode: IXMLNode): Boolean;
begin
  ANode.AppendElement('S').Text := 'Default';
  Result := True;
end;

//----------------------------------------------------------------------------
class function TSynUniFormatNativeXml15.ImportKeyList(AKeyList: TSynKeyList; ANode: IXMLNode): Boolean;
var
  i: integer;
begin
  with AKeyList, ANode do begin
    Name := VarToStr(GetVarAttr('Name',''));
    Result := ImportAttributes(AKeyList.Attributes, ChildNodes[0{%SchemeIndex}]); //TODO: Исправит?
    //???Enabled := StrToBoolDef(EnsureChild('Enabled').Text, True);
    for i := 0 to ChildNodes.Count-1 do
      if ChildNodes[i].NodeName = 'W' then
        KeyList.Add(ChildNodes[i].Text);
  end;
end;

//----------------------------------------------------------------------------
class function TSynUniFormatNativeXml15.ExportKeyList(AKeyList: TSynKeyList; ANode: IXMLNode): Boolean;
var
  i: Integer;
  Buffer: TStringList;
//  Node: IXMLNode;
begin
  with AKeyList, ANode do
  begin
    SetVarAttr('Name',Name);
    ExportAttributes(AKeyList.Attributes, AppendElement('Attri'));
    //???AppendElement('Enabled').Text := BoolToStr(Enabled, True);
    Buffer := TStringList.Create();
    Buffer.Text := KeyList.Text;
    for i := 0 to Buffer.Count-1 do
      AppendElement('W').Text := Buffer[i];
    FreeAndNil(Buffer);
  end;
  Result := True;
end;

//----------------------------------------------------------------------------
class function TSynUniFormatNativeXml15.ImportSet(ASet: TSynSet; ANode: IXMLNode): Boolean;
begin
  with ASet, ANode do begin
    Name := VarToStr(GetVarAttr('Name',''));
    Result := ImportAttributes(ASet.Attributes, ChildNodes[0{%SchemeIndex}]); //TODO: Исправит?
    //???Enabled := StrToBoolDef(EnsureChild('Enabled').Text, True);
    CharSet := StrToSet(EnsureChild('S').Text);
  end;
end;

//----------------------------------------------------------------------------
class function TSynUniFormatNativeXml15.ExportSet(ASet: TSynSet; ANode: IXMLNode): Boolean;
begin
  with ASet, ANode do
  begin
    SetVarAttr('Name', Name);
    ExportAttributes(ASet.Attributes, AppendElement('Attri'));
    //???AppendElement('Enabled').Text := BoolToStr(Enabled, True);
    AppendElement('S').Text := SetToStr(CharSet);
  end;
  Result := True;
end;

class function TSynUniFormatNativeXml15.ImportToken(AToken: TSynMultiToken; ANode: IXMLNode; Kind: string): Boolean; 
begin
  Result := True;
  with AToken, ANode do begin
    FinishOnEol := StrToBoolDef(EnsureChild(Kind+'FinishOnEol').Text, False);
    StartLine   := StrToStartLine(EnsureChild(Kind+'StartLine').Text);
    StartType   := StrToStartType(EnsureChild(Kind+'PartOfTerm').Text);
    BreakType   := StrToBreakType(EnsureChild(Kind+'PartOfTerm').Text);
  end;
end;

//----------------------------------------------------------------------------
class function TSynUniFormatNativeXml15.ExportToken(AToken: TSynMultiToken; ANode: IXMLNode; Kind: string = ''): Boolean;
begin
  with AToken, ANode do
  begin

  end;
  Result := True;
end;

//----------------------------------------------------------------------------
class function TSynUniFormatNativeXml15.ImportRange(ARange: TSynRange; ANode: IXMLNode): Boolean;
var
  i: integer;
  NewRange: TSynRange;
  NewKeyList: TSynKeyList;
  NewSet: TSynSet;
begin
  Result := True;
  with ARange, ANode do begin
    Name := VarToStr(GetVarAttr('Name',''));
    //TODO: Сделат?считывание Num ка?создание SynSet (если Num <> Def)
    ImportAttributes(ARange.Attributes, EnsureChild('Def'));
    ImportAttributes(ARange.Attributes, ChildNodes[0{%SchemeIndex}]); //TODO: Исправит?
    //???Enabled := StrToBoolDef(EnsureChild('Enabled').Text, True);
    OpenToken.Clear();
    CloseToken.Clear();
    AddCoupleTokens(EnsureChild('OpenSymbol').Text, EnsureChild('CloseSymbol').Text);
    Delimiters := StrToSet(EnsureChild('DelimiterChars').Text);

    CaseSensitive      := StrToBoolDef(EnsureChild('CaseSensitive').Text, False);
    CloseOnTerm        := StrToBoolDef(EnsureChild('CloseOnTerm').Text, False);
//      ShowMessage(ChildNodes['CloseOnEol'].Text);
//      b := StrToBoolDef(ChildNodes['CloseOnEol'].Text, False);
//      ShowMessage(BoolToStr(b));
//      ShowMessage(BoolToStr(StrToBoolDef(ChildNodes['CloseOnEol'].Text, False)));
    CloseOnEol         := StrToBoolDef(EnsureChild('CloseOnEol').Text, False);
//      ShowMessage(BoolToStr(CloseOnEol));
    AllowPreviousClose := StrToBoolDef(EnsureChild('AllowPredClose').Text, False);

    ImportToken(OpenToken, ANode, 'OpenSymbol');
    ImportToken(CloseToken, ANode, 'CloseSymbol');

    for i := 0 to ChildNodes.Count-1 do
      if ChildNodes[i].NodeName = 'Range' then begin
        NewRange := TSynRange.Create;
        Result := ImportRange(NewRange, ChildNodes[i]);
        AddRange(NewRange);
      end
      else if ChildNodes[i].NodeName = 'KW' then begin
        NewKeyList := TSynKeyList.Create();
        Result := ImportKeyList(NewKeyList, ChildNodes[i]);
        AddKeyList(NewKeyList);
      end
      else if ChildNodes[i].NodeName = 'Set' then begin
        NewSet := TSynSet.Create();
        Result := ImportSet(NewSet, ChildNodes[i]);
        AddSet(NewSet);
      end;
  end;
end;

//----------------------------------------------------------------------------
class function TSynUniFormatNativeXml15.ExportRange(ARange: TSynRange; ANode: IXMLNode): Boolean;
var
  i: Integer;
begin
  with ARange, ANode do
  begin
    SetVarAttr('Name', Name);
    ExportAttributes(Attributes, AppendElement('Attri'));
    //???AppendElement('Enabled').Text := BoolToStr(Enabled, True);
    if OpenToken.SymbolCount > 0 then
      AppendElement('OpenSymbol').Text := OpenToken.Symbols[0]
    else
      AppendElement('OpenSymbol').Text := ' ';
    AppendElement('OpenSymbolFinishOnEol').Text := BoolToStr(OpenToken.FinishOnEol, True);
    if CloseToken.SymbolCount > 0 then
      AppendElement('CloseSymbol').Text := CloseToken.Symbols[0]
    else
      AppendElement('CloseSymbol').Text := ' ';
    AppendElement('CloseSymbolFinishOnEol').Text := BoolToStr(CloseToken.FinishOnEol, True);
    ExportToken(CloseToken, ANode, 'CloseSymbol');
    if OpenToken.StartLine <> slNotFirst then
      AppendElement('OpenSymbolStartLine').Text := StartLineToStr(OpenToken.StartLine)
    else
      AppendElement('OpenSymbolStartLine').Text := 'False';
    if CloseToken.StartLine <> slNotFirst then
      AppendElement('CloseSymbolStartLine').Text := StartLineToStr(CloseToken.StartLine)
    else
      AppendElement('CloseSymbolStartLine').Text := 'False';

    AppendElement('DelimiterChars').Text := SetToStr(Delimiters);
    
    with OpenToken do
    begin
      if (StartType = stTerm) and (BreakType = btTerm) then
        AppendElement('OpenSymbolPartOfTerm').Text := 'False'
      else if (StartType = stAny) and (BreakType = btTerm) then
        AppendElement('OpenSymbolPartOfTerm').Text := 'Left'
      else if (StartType = stTerm) and (BreakType = btAny) then
        AppendElement('OpenSymbolPartOfTerm').Text := 'Right'
      else
        AppendElement('OpenSymbolPartOfTerm').Text := 'True'
    end;

    with CloseToken do
    begin
      if (StartType = stTerm) and (BreakType = btTerm) then
        AppendElement('CloseSymbolPartOfTerm').Text := 'False'
      else if (StartType = stAny) and (BreakType = btTerm) then
        AppendElement('CloseSymbolPartOfTerm').Text := 'Left'
      else if (StartType = stTerm) and (BreakType = btAny) then
        AppendElement('CloseSymbolPartOfTerm').Text := 'Right'
      else
        AppendElement('CloseSymbolPartOfTerm').Text := 'True'
    end;

    AppendElement('CloseOnTerm').Text := BoolToStr(CloseOnTerm, True);
    AppendElement('CloseOnEol').Text := BoolToStr(CloseOnEol, True);
    AppendElement('AllowPredClose').Text := BoolToStr(AllowPreviousClose, True);      
    AppendElement('CaseSensitive').Text := BoolToStr(CaseSensitive, True);

    for i := 0 to KeyListCount -1 do
      ExportKeyList(KeyLists[i], AppendElement('KW'));
    for i := 0 to SetCount -1 do
      ExportSet(Sets[i], AppendElement('Set'));
    for i := 0 to RangeCount -1 do
      ExportRange(Ranges[i], AppendElement('Range'));
  end;
  Result := True;
end;

//----------------------------------------------------------------------------
class function TSynUniFormatNativeXml15.ImportHighlighter(SynUniSyn: TSynUniSyn; ANode: IXMLNode): Boolean;
//var
//  Schemes: TStringList;
//  SchemeIndex: integer;
begin
  with ANode, SynUniSyn do begin
    Clear();
    ImportInfo(Info, EnsureChild('Info'));
    if EnsureChild('SchemeIndex').Text <> '' then begin  // DW
//      SchemeIndex := StrToInt(EnsureChild('SchemeIndex').Text);
      ImportSchemes(Schemes, EnsureChild('Schemes'));
    end;
    ImportRange(MainRules, EnsureChild('Range'));
    FormatVersion := '1.5';
  end;
  Result := True;
end;

function ExportImportantInfo(ANode: IXMLNode): Boolean;
begin
  ANode.Text := #13#10+
    #9#9'******* Please read carefully *************************'#13#10+
    #9#9'* Please, make any changes in this file very carefuly!*'#13#10+
    #9#9'* It is much more convinient to use native designer!  *'#13#10+
    #9#9'*******************************************************';
  Result := True;
end;

//----------------------------------------------------------------------------
class function TSynUniFormatNativeXml15.ExportHighlighter(SynUniSyn: TSynUniSyn; ANode: IXMLNode): Boolean;
begin
  with SynUniSyn, ANode do
  begin
    ExportImportantInfo(AppendElement('ImportantInfo'));
    ExportInfo(Info, AppendElement('Info'));
    AppendElement('SchemeIndex').Text := '0';
    ExportSchemes(Schemes, AppendElement('Schemes'));
    ExportRange(MainRules, AppendElement('Range'));
     // '<CopyRight>Rule file for UniHighlighter Delphi component (Copyright(C) Fantasist(walking_in_the_sky@yahoo.com), Vit(nevzorov@yahoo.com), Vitalik(vetal-x@mail.ru), 2002-2006)</CopyRight>'
  end;
  Result := True;
end;

//----------------------------------------------------------------------------
class function TSynUniFormatNativeXml15.ImportFromStream(AObject: TObject; AStream: TStream): Boolean;
var
  Buffer: TStringlist;
  Stream: TMemoryStream;
begin
  VerifyStream(AStream);

  Buffer := TStringList.Create();
  Buffer.LoadFromStream(AStream);
  Buffer.Text := StringReplace(Buffer.Text, '&qt;', '&quot;', [rfReplaceAll, rfIgnoreCase]);
  Buffer.Insert(0, '<?xml version="1.0" encoding="windows-1251"?>');
  Stream := TMemoryStream.Create();
  Buffer.SaveToStream(Stream);
  FreeAndNil(Buffer);

  Result := inherited ImportFromStream(AObject, Stream);
  FreeAndNil(Stream);
end;

//----------------------------------------------------------------------------
class function TSynUniFormatNativeXml15.ExportToStream(AObject: TObject; AStream: TStream): Boolean;
var
  Buffer: TStringlist;
  Stream: TMemoryStream;
  posEnd, tagStart, tagFinish: Integer;
  Line, TagName: string;
  Last: Integer;
begin
  Stream := TMemoryStream.Create();
  Result := inherited ExportToStream(AObject, Stream);
  Buffer := TStringList.Create();
  Stream.Position := 0;
  Buffer.LoadFromStream(Stream);
  Buffer.Delete(0);
  Line := Buffer[0];    Delete(Line, 2, 3); Buffer[0] := Line;
  Last := Buffer.Count-1;
  Line := Buffer[Last]; Delete(Line, 3, 3); Buffer[Last] := Line;
  Buffer.Text := StringReplace(Buffer.Text, '&quot;', '&qt;', [rfReplaceAll, rfIgnoreCase]);
  while True do
  begin
    posEnd := Pos('/>', Buffer.Text);
    if posEnd = 0 then Break;
    tagFinish := posEnd;
    for tagStart := posEnd downto posEnd-40 do
    begin
      if Buffer.Text[tagStart] = ' ' then
        tagFinish := tagStart
      else if Buffer.Text[tagStart] = '<' then
      begin
        TagName := Copy(Buffer.Text, tagStart+1, tagFinish-tagStart-1);
        Buffer.Text := StringReplace(Buffer.Text, '/>', '></'+TagName+'>', [rfIgnoreCase]);
        Break;
      end;
    end;
  end;
  Buffer.SaveToStream(AStream);
  FreeAndNil(Stream);
  FreeAndNil(Buffer);
end;

//----------------------------------------------------------------------------
class function TSynUniFormatNativeXml15.ImportFromFile(AObject: TObject; AFileName: string): Boolean;
begin
  Result := inherited ImportFromFile(AObject, AFileName);
end;

//----------------------------------------------------------------------------
class function TSynUniFormatNativeXml15.ExportToFile(AObject: TObject; AFileName: string): Boolean;
begin
  Result := inherited ExportToFile(AObject, AFileName);
end;

end.
