unit BCControl.ObjectInspector;

interface

uses
  Winapi.Messages, System.Classes, System.Types, System.UITypes, System.TypInfo, Vcl.Controls, Vcl.Graphics,
  VirtualTrees, sSkinManager;

type
  TBCObjectInspector = class(TVirtualDrawTree)
  strict private
    FInspectedObject: TObject;
    FSkinManager: TsSkinManager;
    function PropertyValueAsString(AInstance: TObject; APropertyInfo: PPropInfo): string;
    procedure DoObjectChange;
    procedure SetInspectedObject(const AValue: TObject);
  protected
    function DoCreateEditor(Node: PVirtualNode; Column: TColumnIndex): IVTEditLink; override;
    function DoInitChildren(Node: PVirtualNode; var ChildCount: Cardinal): Boolean; override;
    procedure Click; override;
    procedure DoAfterCellPaint(Canvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect); override;
    procedure DoCanEdit(Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean); override;
    procedure DoFreeNode(ANode: PVirtualNode); override;
    procedure DoInitNode(Parent, Node: PVirtualNode; var InitStates: TVirtualNodeInitStates); override;
    procedure DoNodeClick(const HitInfo: THitInfo); override;
    procedure DoPaintNode(var PaintInfo: TVTPaintInfo); override;
  public
    constructor Create(AOwner: TComponent); override;

    property InspectedObject: TObject read FInspectedObject write SetInspectedObject;
    property SkinManager: TsSkinManager read FSkinManager write FSkinManager;
  end;

  TBCObjectInspectorEditLink = class(TInterfacedObject, IVTEditLink)
  strict private
    FEditor: TWinControl;
    FObjectInspector: TBCObjectInspector;
    FNode: PVirtualNode;
    FColumn: Integer;
  protected
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditExit(Sender: TObject);
  public
    destructor Destroy; override;
    function BeginEdit: Boolean; stdcall;
    function CancelEdit: Boolean; stdcall;
    function EndEdit: Boolean; stdcall;
    function GetBounds: TRect; stdcall;
    function PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
    procedure ProcessMessage(var Message: TMessage); stdcall;
    procedure SetBounds(R: TRect); stdcall;
  end;

implementation

uses
  Winapi.Windows, Winapi.UxTheme, System.SysUtils, System.Math, System.Variants, Vcl.Themes, sComboBox, sEdit;

type
  TPropertyArray = array of PPropInfo;

  TBCObjectInspectorNodeRecord = record
    PropertyInfo: PPropInfo;
    PropertyName: string;
    PropertyValue: string;
    PropertyObject: TObject;
    TypeInfo: PTypeInfo;
    HasChildren: Boolean;
    IsBoolean: Boolean;
    IsSetValue: Boolean;
    SetIndex: Integer;
    ReadOnly: Boolean;
  end;
  PBCObjectInspectorNodeRecord = ^TBCObjectInspectorNodeRecord;

{ TBCObjectInspector }

constructor TBCObjectInspector.Create;
var
  LColumn: TVirtualTreeColumn;
begin
  inherited Create(AOwner);

  DragOperations := [];
  Header.AutoSizeIndex := 1;
  Header.Options := [hoAutoResize, hoColumnResize, hoVisible];
  { property column }
  LColumn := Header.Columns.Add;
  LColumn.Text := 'Property';
  LColumn.Width := 160;
  LColumn.Options := [coAllowClick, coParentColor, coEnabled, coParentBidiMode, coResizable, coVisible, coAllowFocus];
  { value column }
  LColumn := Header.Columns.Add;
  LColumn.Text := 'Value';
  LColumn.Options := [coAllowClick, coParentColor, coEnabled, coParentBidiMode, coResizable, coVisible, coAllowFocus, coEditable];

  IncrementalSearch := isAll;
  Indent := 16;
  EditDelay := 0;
  TextMargin := 4;

  TreeOptions.AutoOptions := [toAutoDropExpand, toAutoScroll, toAutoScrollOnExpand, toAutoTristateTracking, toAutoChangeScale];
  TreeOptions.MiscOptions := [toEditable, toFullRepaintOnResize, toGridExtensions, toWheelPanning, toEditOnClick];
  TreeOptions.PaintOptions := [toHideFocusRect, toShowButtons, toShowRoot, toShowVertGridLines, toThemeAware, toUseExplorerTheme];
  TreeOptions.SelectionOptions := [toExtendedFocus];
end;

procedure TBCObjectInspector.Click;
var
  LPNode: PVirtualNode;
  LData: PBCObjectInspectorNodeRecord;
begin
  LPNode := GetFirstSelected;
  if Assigned(LPNode) then
    EditNode(LPNode, Header.Columns.ClickIndex);
  { Checkbox }
  if Header.Columns.ClickIndex > -1 then
    // Toggle
end;

procedure TBCObjectInspector.DoAfterCellPaint(Canvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect);
var
  LCheckBoxRect: TRect;
  LData: PBCObjectInspectorNodeRecord;
  LSize: TSize;
  LHandle: THandle;
begin
  inherited;

  if Column = 0 then
    Exit;

  { Checkbox }
  LData := GetNodeData(Node);
  if LData.IsBoolean then
  begin
    LCheckBoxRect := CellRect;
    Inc(LCheckBoxRect.Left, 2);

    if UseThemes then
    begin
      LHandle := OpenThemeData(Handle, 'BUTTON');
      if LHandle <> 0 then
      try
        GetThemePartSize(LHandle, Canvas.Handle, BP_CHECKBOX, CBS_CHECKEDNORMAL, nil, TS_DRAW, LSize);
        LCheckBoxRect.Right  := LCheckBoxRect.Left + LSize.cx;
        DrawThemeBackground(LHandle, Canvas.Handle, BP_CHECKBOX, IfThen(CompareText(LData.PropertyValue, 'True') = 0,
          CBS_CHECKEDNORMAL, CBS_UNCHECKEDNORMAL), LCheckBoxRect, nil);
      finally
        CloseThemeData(LHandle);
      end;
    end
    else
    begin
      LCheckBoxRect.Right  := LCheckBoxRect.Left + GetSystemMetrics(SM_CXMENUCHECK);
      DrawFrameControl(Canvas.Handle, LCheckBoxRect, DFC_BUTTON, IfThen(CompareText(LData.PropertyValue, 'True') = 0,
        DFCS_CHECKED, DFCS_BUTTONCHECK));
    end;
  end;
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
  LData, LDataParent: PBCObjectInspectorNodeRecord;
  LString: string;
  LRect: TRect;
  LHandle: THandle;
  LSize: TSize;
  LParentPropertyObject: TObject;
begin
  inherited;
  with PaintInfo do
  begin
    LData := GetNodeData(Node);
    LParentPropertyObject := nil;
    if Assigned(Node.Parent) then
    begin
      LDataParent := GetNodeData(Node.Parent);
      if Assigned(LDataParent) then
        LParentPropertyObject := LDataParent.PropertyObject;
    end;
    if not Assigned(LParentPropertyObject) then
      LParentPropertyObject := FInspectedObject;

    if not Assigned(LData) then
      Exit;

    Canvas.Font.Style := [];

    case Column of
      0:
        if Assigned(SkinManager) then
          Canvas.Font.Color := SkinManager.GetActiveEditFontColor
        else
          Canvas.Font.Color := clWindowText;
      1:
        begin
          Canvas.Font.Color := SysColorToSkin(clNavy);

          if Assigned(LParentPropertyObject) and Assigned(LData.PropertyInfo) and
            IsStoredProp(LParentPropertyObject, LData.PropertyInfo) then
            if not IsDefaultPropertyValue(LParentPropertyObject, LData.PropertyInfo, nil) then
              Canvas.Font.Style := [fsBold];
        end;
    end;

    if LData.ReadOnly then
      Canvas.Font.Color := SysColorToSkin(clGray);

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

    SetBKMode(Canvas.Handle, TRANSPARENT);

    LRect := ContentRect;
    InflateRect(LRect, -TextMargin, 0);
    Dec(LRect.Right);
    Dec(LRect.Bottom);

    if PaintInfo.Column = 0 then
      LString := LData.PropertyName
    else
    begin
      if LData.IsBoolean then
      begin
        if UseThemes then
        begin
          LHandle := OpenThemeData(Handle, 'BUTTON');
          if LHandle <> 0 then
          try
            GetThemePartSize(LHandle, Canvas.Handle, BP_CHECKBOX, CBS_CHECKEDNORMAL, nil, TS_DRAW, LSize);
            Inc(LRect.Left, LSize.cx + 2);
          finally
            CloseThemeData(LHandle);
          end;
        end
        else
          Inc(LRect.Left, GetSystemMetrics(SM_CXMENUCHECK) + 2);
      end;

      LString := LData.PropertyValue;
    end;

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

function IsBooleanValue(const AValue: string): Boolean;
begin
  Result := (CompareText(AValue, 'True') = 0) or (CompareText(AValue, 'False') = 0);
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
    LData.PropertyInfo := LPropertyArray[LIndex];
    LData.TypeInfo := LData.PropertyInfo^.PropType^;
    LData.PropertyName := string(LPropertyArray[LIndex].Name);
    LData.PropertyValue := PropertyValueAsString(FInspectedObject, LPropertyArray[LIndex]);
    LData.IsBoolean := (LData.TypeInfo.Kind = tkEnumeration) and IsBooleanValue(LData.PropertyValue);
    LData.HasChildren := (LData.TypeInfo.Kind = tkSet) or ((LData.TypeInfo.Kind = tkClass) and (LData.PropertyValue <> ''));
    if LData.TypeInfo.Kind = tkClass then
      LData.PropertyObject := GetObjectProp(FInspectedObject, LData.PropertyInfo);
    LData.ReadOnly := Assigned(LData.PropertyInfo) and not Assigned(LData.PropertyInfo.SetProc);
  end;

  EndUpdate;
end;

function TBCObjectInspector.DoInitChildren(Node: PVirtualNode; var ChildCount: Cardinal): Boolean;
var
  LIndex: Integer;
  LData, LParentData, LNewData: PBCObjectInspectorNodeRecord;
  LObject: TObject;
  LCollection: TCollection;
  LPNode: PVirtualNode;
  LPropertyArray: TPropertyArray;
  LPropertyCount: Integer;
  LSetTypeData: PTypeData;
  LSetAsIntValue: Longint;
  LParentObject: TObject;
begin
  Result := True;

  LData := GetNodeData(Node);

  LParentData := GetNodeData(Node.Parent);
  if Assigned(LParentData) then
    LParentObject := LParentData.PropertyObject
  else
    LParentObject := FInspectedObject;

  if (LData.TypeInfo.Kind = tkClass) and (LData.PropertyValue <> '') then
  begin
    if LParentObject is TCollection then
      LObject := LData.PropertyObject
    else
      LObject := GetObjectProp(LParentObject, LData.PropertyInfo);

    if LObject is TCollection then
    begin
      LCollection := LObject as TCollection;
      for LIndex := 0 to LCollection.Count - 1 do
      begin
        LPNode := AddChild(Node);
        LNewData := GetNodeData(LPNode);
        LNewData.PropertyInfo := nil;
        LNewData.PropertyName := 'Item[' + IntToStr(LIndex) + ']';
        LNewData.PropertyValue := '(' + LCollection.ItemClass.ClassName +')';
        LNewData.TypeInfo := LCollection.ItemClass.ClassInfo;
        LNewData.HasChildren := True;
        LNewData.PropertyObject := LCollection.Items[LIndex];
      end;
    end
    else
    if Assigned(LObject) then
    begin
      LPropertyCount := GetPropList(LObject.ClassInfo, tkProperties, nil);
      SetLength(LPropertyArray, LPropertyCount);
      GetPropList(LObject.ClassInfo, tkProperties, PPropList(LPropertyArray));

      for LIndex := 0 to LPropertyCount - 1 do
      begin
        LPNode := AddChild(Node);
        LNewData := GetNodeData(LPNode);
        LNewData.PropertyInfo := LPropertyArray[LIndex];
        LNewData.PropertyName := string(LPropertyArray[LIndex].Name);
        LNewData.PropertyValue := PropertyValueAsString(LObject, LPropertyArray[LIndex]);
        LNewData.TypeInfo := LNewData.PropertyInfo^.PropType^;
        LNewData.IsBoolean := (LNewData.TypeInfo.Kind = tkEnumeration) and IsBooleanValue(LNewData.PropertyValue);
        LNewData.HasChildren := (LNewData.TypeInfo.Kind = tkSet) or ((LNewData.TypeInfo.Kind = tkClass) and (LNewData.PropertyValue <> ''));
        if LNewData.TypeInfo.Kind = tkClass then
          LNewData.PropertyObject := GetObjectProp(LObject, LNewData.PropertyInfo);
        LNewData.ReadOnly := Assigned(LNewData.PropertyInfo) and not Assigned(LNewData.PropertyInfo.SetProc);
      end;
    end;
  end
  else
  if LData.TypeInfo.Kind = tkSet then
  begin
    LSetTypeData := GetTypeData(GetTypeData(LData.TypeInfo)^.CompType^);
    LSetAsIntValue := GetOrdProp(LParentObject, LData.PropertyInfo);

    for LIndex := LSetTypeData.MinValue to LSetTypeData.MaxValue do
    begin
      LPNode := AddChild(Node);
      LNewData := GetNodeData(LPNode);
      LNewData.PropertyInfo := nil;
      LNewData.PropertyName := GetEnumName(GetTypeData(LData.TypeInfo)^.CompType^, LIndex);
      LNewData.PropertyValue := BooleanIdents[LIndex in TIntegerSet(LSetAsIntValue)];
      LNewData.TypeInfo := nil;
      LNewData.IsBoolean := IsBooleanValue(LNewData.PropertyValue);
      LNewData.HasChildren := False;
      LNewData.IsSetValue := True;
      LNewData.SetIndex := LIndex;
    end;
  end;
  ChildCount := Self.ChildCount[Node];
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

  {function Int64AsString: String;
  var
    LValue: Int64;
  begin
    LValue := GetInt64Prop(AInstance, APropertyInfo);
    Result := IntToStr(LValue);
  end;  }

  function StrAsString: String;
  begin
    Result := GetWideStrProp(AInstance, APropertyInfo);
  end;

  {function MethodAsString: String;
  var
    LValue: TMethod;
  begin
    LValue := GetMethodProp(AInstance, APropertyInfo);
    if LValue.Code = nil then
      Result := ''
    else
      Result := AInstance.MethodName(LValue.Code);
  end;  }

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

  {function VariantAsString: String;
  var
    LValue: Variant;
  begin
    LValue := GetVariantProp(AInstance, APropertyInfo);
    Result := VarToStr(LValue);
  end;

  function InterfaceAsString: String;
  var
    LInterface: IInterface;
    LValue: TComponent;
    LComponentReference: IInterfaceComponentReference;
  begin
    LInterface := GetInterfaceProp(AInstance, APropertyInfo);
    if not Assigned(LInterface) then
      Result := ''
    else
    if Supports(LInterface, IInterfaceComponentReference, LComponentReference) then
    begin
      LValue := LComponentReference.GetComponent;
      Result := LValue.Name;
    end;
  end; }

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
    {tkMethod:
      Result := MethodAsString;
    tkVariant:
      Result := VariantAsString;
    tkInt64:
      Result := Int64AsString;
    tkInterface:
      Result := InterfaceAsString;}
  end;
end;

procedure TBCObjectInspector.DoNodeClick(const HitInfo: THitInfo);
var
  LData: PBCObjectInspectorNodeRecord;
begin
  inherited;

  ClearSelection;
  Selected[HitInfo.HitNode] := True;

  LData := GetNodeData(HitInfo.HitNode);
  if (HitInfo.HitColumn = 0) and not (hiOnItemButton in HitInfo.HitPositions) or
    (HitInfo.HitColumn = 1) and (LData.TypeInfo.Kind in [tkClass, tkEnumeration, tkSet]) then
    Expanded[HitInfo.HitNode] := not Expanded[HitInfo.HitNode];
end;

procedure TBCObjectInspector.DoCanEdit(Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
var
  LData: PBCObjectInspectorNodeRecord;
begin
  LData := GetNodeData(Node);
  Allowed := (Column > 0) and not LData.ReadOnly and not LData.IsBoolean and not LData.IsSetValue and
    (LData.TypeInfo.Kind <> tkClass) and (LData.TypeInfo.Kind <> tkEnumeration) and (LData.TypeInfo.Kind <> tkSet);
end;

function TBCObjectInspector.DoCreateEditor(Node: PVirtualNode; Column: TColumnIndex): IVTEditLink;
begin
  //inherited;
  Result := TBCObjectInspectorEditLink.Create;
end;

{ TSTVirtualGridEditLink }

destructor TBCObjectInspectorEditLink.Destroy;
begin
  if Assigned(FEditor) then
    if FEditor.HandleAllocated then
      PostMessage(FEditor.Handle, CM_RELEASE, 0, 0);
  inherited;
end;

procedure TBCObjectInspectorEditLink.EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  LCanAdvance: Boolean;
  LPNode: PVirtualNode;
begin
  case Key of
    VK_ESCAPE:
      begin
        Key := 0;//ESC will be handled in EditKeyUp()
      end;
    VK_RETURN:
      begin
        Key := 0;
        FObjectInspector.EndEditNode;
      end;
    VK_UP,
    VK_DOWN:
      begin
        // Consider special cases before finishing edit mode.
        LCanAdvance := Shift = [];
        if FEditor is TsComboBox then
          LCanAdvance := LCanAdvance and not TsComboBox(FEditor).DroppedDown;
        if LCanAdvance then
        begin
          // Forward the keypress to the tree. It will asynchronously change the focused node.
          with FObjectInspector do
          begin
            LPNode := FocusedNode;
            Selected[FocusedNode] := False;
            if Key = VK_UP then
              FocusedNode := FocusedNode.PrevSibling
            else
            if Key = VK_DOWN then
              FocusedNode := FocusedNode.NextSibling;
            if not Assigned(FocusedNode) then
              FocusedNode := LPNode;
            Selected[FocusedNode] := True;
            LPNode := GetFirstSelected;
            if Assigned(LPNode) then
              EditNode(LPNode, Header.Columns.ClickIndex);
          end;
          Key := 0;
        end;
      end;
  end;
end;

procedure TBCObjectInspectorEditLink.EditExit(Sender: TObject);
begin
  FObjectInspector.EndEditNode;
end;

procedure TBCObjectInspectorEditLink.EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      begin
        FObjectInspector.CancelEditNode;
        Key := 0;
      end;
  end;
end;

function TBCObjectInspectorEditLink.BeginEdit: Boolean;
begin
  Result := True;
  if Assigned(FEditor) then
  begin
    FEditor.Show;
    FEditor.SetFocus;
  end;
end;

function TBCObjectInspectorEditLink.CancelEdit: Boolean;
begin
  Result := True;
  if Assigned(FEditor) then
    FEditor.Hide;
end;

function TBCObjectInspectorEditLink.PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean;
var
  LPNode: PBCObjectInspectorNodeRecord;
begin
  Result := True;

  FObjectInspector := Tree as TBCObjectInspector;
  FNode := Node;
  FColumn := Column;

  if Assigned(FEditor) then
  begin
    FEditor.Free;
    FEditor := nil;
  end;

  LPNode := FObjectInspector.GetNodeData(Node);

  case LPNode.TypeInfo.Kind of
    tkInteger, tkInt64, tkChar, tkFloat, tkString, tkLString, tkWString, tkUString:
      begin
        FEditor := TsEdit.Create(nil);
        with FEditor as TsEdit do
        begin
          Visible := False;
          Parent := Tree;
          Font.Name := FObjectInspector.Canvas.Font.Name;
          Font.Size := FObjectInspector.Canvas.Font.Size;
          Text := LPNode.PropertyValue;
        end;
      end;
  end;
  // TODO: Create FEditors depending on TypeKind
end;

function TBCObjectInspectorEditLink.EndEdit: Boolean;
var
  LPNode: PBCObjectInspectorNodeRecord;
begin
  Result := True;

  LPNode := FObjectInspector.GetNodeData(FNode);

  if not Assigned(FEditor) then
    Exit;

  // TODO: Get value from FEditor, set it to node, and update control

  FEditor.Hide;
end;

function TBCObjectInspectorEditLink.GetBounds: TRect;
begin
  if Assigned(FEditor) then
    Result := FEditor.BoundsRect
  else
    Result := Rect(0, 0, 0, 0);
end;

procedure TBCObjectInspectorEditLink.ProcessMessage(var Message: TMessage);
begin
  if Assigned(FEditor) then
    FEditor.WindowProc(Message);
end;

procedure TBCObjectInspectorEditLink.SetBounds(R: TRect);
var
  LLeft: Integer;
begin
  // Since we don't want to activate grid extensions in the tree (this would influence how the selection is drawn)
  // we have to set the edit's width explicitly to the width of the column.
  FObjectInspector.Header.Columns.GetColumnBounds(FColumn, LLeft, R.Right);
  if Assigned(FEditor) then
    FEditor.BoundsRect := R;
end;

end.
