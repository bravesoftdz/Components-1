unit BCControl.ObjectInspector;

interface

uses
  System.Classes, System.TypInfo, VirtualTrees, sComboBox, sSkinManager;

type
  TBCObjectInspector = class(TVirtualDrawTree)
  strict private
    FInspectedObject: TObject;
    FSkinManager: TsSkinManager;
    function PropertyValueAsString(AInstance: TObject; APropertyInfo: PPropInfo): string;
    procedure DoObjectChange;
    procedure SetInspectedObject(const AValue: TObject);
  protected
    procedure DoCanEdit(Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean); override;
    procedure DoFreeNode(ANode: PVirtualNode); override;
    procedure DoInitNode(Parent, Node: PVirtualNode; var InitStates: TVirtualNodeInitStates); override;
    procedure DoPaintNode(var PaintInfo: TVTPaintInfo); override;
  public
    constructor Create(AOwner: TComponent); override;

    property InspectedObject: TObject read FInspectedObject write SetInspectedObject;
    property SkinManager: TsSkinManager read FSkinManager write FSkinManager;
  end;

implementation

uses
  Winapi.Windows, System.Types, System.SysUtils, System.Variants, Vcl.Graphics;

type
  TPropertyArray = array of PPropInfo;

  TBCObjectInspectorNodeRecord = record
    PropInfo: PPropInfo;
    TypeInfo: PTypeInfo;
    PropName: string;
    PropStrValue: string;
    HasChildren: Boolean;
    Instance: TObject;
  end;
  PBCObjectInspectorNodeRecord = ^TBCObjectInspectorNodeRecord;

constructor TBCObjectInspector.Create;
var
  LColumn: TVirtualTreeColumn;
begin
  inherited Create(AOwner);

  DragOperations := [];
  Header.Options := [hoColumnResize];
  { property column }
  LColumn := Header.Columns.Add;
  LColumn.Width := 160;
  { value column }
  Header.Columns.Add;

  IncrementalSearch := isAll;
  Indent := 20;
  EditDelay := 0;

  TreeOptions.AutoOptions := [toAutoDropExpand, toAutoScroll, toAutoChangeScale, toAutoScrollOnExpand, toAutoTristateTracking, toAutoDeleteMovedNodes];
  TreeOptions.MiscOptions := [toEditable, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick];
  TreeOptions.PaintOptions := [toShowBackground, toShowButtons, toShowRoot, toThemeAware, toHideTreeLinesIfThemed];
end;

procedure TBCObjectInspector.DoCanEdit(Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  Allowed := Column > 0;
end;

procedure TBCObjectInspector.DoInitNode(Parent, Node: PVirtualNode; var InitStates: TVirtualNodeInitStates);
var
  LData: PBCObjectInspectorNodeRecord;
begin
  inherited;
  LData := GetNodeData(Node);
  if LData.HasChildren then
    Include(InitStates, ivsHasChildren);
end;

procedure TBCObjectInspector.DoFreeNode(ANode: PVirtualNode);
var
  LData: PBCObjectInspectorNodeRecord;
begin
  LData := GetNodeData(ANode);
  Finalize(LData^);
  inherited;
end;

procedure TBCObjectInspector.DoPaintNode(var PaintInfo: TVTPaintInfo);
var
  LData: PBCObjectInspectorNodeRecord;
  LString: string;
  LRect: TRect;
begin
  inherited;
  with PaintInfo do
  begin
    LData := GetNodeData(Node);
    if not Assigned(LData) then
      Exit;

    Canvas.Font.Style := [];

   if Assigned(SkinManager) then
     Canvas.Font.Color := SkinManager.GetActiveEditFontColor
   else
     Canvas.Font.Color := clWindowText;

    if vsSelected in PaintInfo.Node.States then
    begin
      if Assigned(SkinManager) and SkinManager.Active then
      begin
        Canvas.Brush.Color := SkinManager.GetHighLightColor;
        Canvas.Font.Color := SkinManager.GetHighLightFontColor
      end
      else
      begin
        Canvas.Brush.Color := clHighlight;
        Canvas.Font.Color := clHighlightText;
      end;
    end;
    Canvas.Font.Style := [];

    SetBKMode(Canvas.Handle, TRANSPARENT);

    LRect := ContentRect;
    InflateRect(LRect, -TextMargin, 0);
    Dec(LRect.Right);
    Dec(LRect.Bottom);

    if PaintInfo.Column = 0 then
      LString := LData.PropName
    else
      LString := LData.PropStrValue;

    if Length(LString) > 0 then
      DrawTextW(Canvas.Handle, PWideChar(LString), Length(LString), LRect, DT_TOP or DT_LEFT or DT_VCENTER or DT_SINGLELINE);
  end;
end;

procedure TBCObjectInspector.SetInspectedObject(const AValue: TObject);
begin
  if AValue <> FInspectedObject then
  begin
    FInspectedObject := AValue;
    DoObjectChange;
  end;
end;

procedure TBCObjectInspector.DoObjectChange;
var
  LPropertyCount: Integer;
  LPropertyArray: TPropertyArray;
  LIndex: Integer;
  LPNode: PVirtualNode;
  LData: PBCObjectInspectorNodeRecord;
begin
  if not Assigned(FInspectedObject) then
    Exit;

  LPropertyCount := GetPropList(FInspectedObject.ClassInfo, tkProperties, nil);
  SetLength(LPropertyArray, LPropertyCount);
  GetPropList(FInspectedObject.ClassInfo, tkProperties, PPropList(LPropertyArray));

  BeginUpdate;
  Clear;
  NodeDataSize := SizeOf(TBCObjectInspectorNodeRecord);

  for LIndex := 0 to LPropertyCount - 1 do
  begin
    LPNode := AddChild(nil);
    LData := GetNodeData(LPNode);
    LData.PropInfo := LPropertyArray[LIndex];
    LData.TypeInfo := LData.PropInfo^.PropType^;
    LData.PropName := string(LPropertyArray[LIndex].Name);
    LData.PropStrValue := PropertyValueAsString(FInspectedObject, LPropertyArray[LIndex]);
    LData.HasChildren := (LData.TypeInfo.Kind = tkSet) or ((LData.TypeInfo.Kind = tkClass) and (LData.PropStrValue <> ''));
    if LData.TypeInfo.Kind = tkClass then
      LData.Instance := GetObjectProp(FInspectedObject, LData.PropInfo);
  end;

  EndUpdate;
end;

function TBCObjectInspector.PropertyValueAsString(AInstance: TObject; APropertyInfo: PPropInfo): string;
var
  LPropertyType: PTypeInfo;
  LTypeKind: TTypeKind;

  function SetAsString(AValue: Longint): string;
  var
    LIndex: Integer;
    LBaseType: PTypeInfo;
  begin
    LBaseType := GetTypeData(LPropertyType)^.CompType^;
    Result := '[';
    for LIndex := 0 to SizeOf(TIntegerSet) * 8 - 1 do
      if LIndex in TIntegerSet(AValue) then
      begin
        if Length(Result) <> 1 then
          Result := Result + ',';
        Result := Result + GetEnumName(LBaseType, LIndex);
      end;
    Result := Result + ']';
  end;

  function IntegerAsString(ATypeInfo: PTypeInfo; AValue: Longint): String;
  var
    LIdent: string;
    LIntToIdent: TIntToIdent;
  begin
    LIntToIdent := FindIntToIdent(ATypeInfo);
    if Assigned(LIntToIdent) and LIntToIdent(AValue, LIdent) then
      Result := LIdent
    else
      Result := IntToStr(AValue);
  end;

  function CollectionAsString(Collection: TCollection): String;
  begin
    Result := '(' + Collection.ClassName + ')';
  end;

  function OrdAsString: String;
  var
    LValue: Longint;
  begin
    LValue := GetOrdProp(AInstance, APropertyInfo);
    case LTypeKind of
      tkInteger:
        Result := IntegerAsString(LPropertyType, LValue);
      tkChar:
        Result := Chr(LValue);
      tkSet:
        Result := SetAsString(LValue);
      tkEnumeration:
        Result := GetEnumName(LPropertyType, LValue);
    end;
  end;

  function FloatAsString: String;
  var
    LValue: Extended;
  begin
    LValue := GetFloatProp(AInstance, APropertyInfo);
    Result := FloatToStr(LValue);
  end;

  function Int64AsString: String;
  var
    LValue: Int64;
  begin
    LValue := GetInt64Prop(AInstance, APropertyInfo);
    Result := IntToStr(LValue);
  end;

  function StrAsString: String;
  begin
    Result := GetWideStrProp(AInstance, APropertyInfo);
  end;

  function MethodAsString: String;
  var
    LValue: TMethod;
  begin
    LValue := GetMethodProp(AInstance, APropertyInfo);
    if LValue.Code = nil then
      Result := ''
    else
      Result := AInstance.MethodName(LValue.Code);
  end;

  function ObjectAsString: String;
  var
    LValue: TObject;
  begin
    LValue := GetObjectProp(AInstance, APropertyInfo);
    if not Assigned(LValue) then
      Result := ''
    else
      Result := '(' + LValue.ClassName + ')';
  end;

  function VariantAsString: String;
  var
    LValue: Variant;
  begin
    LValue := GetVariantProp(AInstance, APropertyInfo);
    Result := VarToStr(LValue);
  end;

  function InterfaceAsString: String;
  var
    LInterface: IInterface;
    Value: TComponent;
    SR: IInterfaceComponentReference;
  begin
    LInterface := GetInterfaceProp(AInstance, APropertyInfo);
    if not Assigned(LInterface) then
      Result := ''
    else
    if Supports(LInterface, IInterfaceComponentReference, SR) then
    begin
      Value := SR.GetComponent;
      Result := Value.Name;
    end;
  end;

begin
  LPropertyType := APropertyInfo^.PropType^;
  LTypeKind := LPropertyType^.Kind;
  case LTypeKind of
    tkInteger, tkChar, tkEnumeration, tkSet:
      Result := OrdAsString;
    tkFloat:
      Result := FloatAsString;
    tkString, tkLString, tkWString, tkUString:
      Result := StrAsString;
    tkClass:
      Result := ObjectAsString;
    tkMethod:
      Result := MethodAsString;
    tkVariant:
      Result := VariantAsString;
    tkInt64:
      Result := Int64AsString;
    tkInterface:
      Result := InterfaceAsString;
  end;
end;

end.
