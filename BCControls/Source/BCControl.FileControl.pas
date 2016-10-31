unit BCControl.FileControl;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils, System.Types, System.UITypes, Vcl.Controls,
  Vcl.Graphics, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ImgList, VirtualTrees, BCControl.Edit, sComboBox, sSkinManager;

type
  TBCFileTreeView = class;

  TDriveComboFile = class
    Drive: string;
    IconIndex: Integer;
    FileName: string;
  end;

  TBCCustomDriveComboBox = class(TsCustomComboBox)
  private
    FDrive: Char;
    FIconIndex: Integer;
    FFileTreeView: TBCFileTreeView;
    FSystemIconsImageList: TImageList;
    { Can't use Items.Objects because those objects can't be destroyed in destructor - control has no parent
      window anymore. }
    FDriveComboFileList: TList;
    function GetDrive: Char;
    procedure CMFontChanged(var AMessage: TMessage); message CM_FONTCHANGED;
    procedure CNDrawItem(var AMessage: TWMDrawItem); message CN_DRAWITEM;
    procedure GetSystemIcons;
    procedure ResetItemHeight;
    procedure SetDrive(ANewDrive: Char);
    procedure SetFileTreeView(AValue: TBCFileTreeView);
  protected
    procedure BuildList; virtual;
    procedure Change; override;
    procedure DrawItem(AIndex: Integer; ARect: TRect; AState: TOwnerDrawState); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ClearItems;
    property Drive: Char read GetDrive write SetDrive;
    property FileTreeView: TBCFileTreeView read FFileTreeView write SetFileTreeView;
    property IconIndex: Integer read FIconIndex;
    property SystemIconsImageList: TImageList read FSystemIconsImageList;
  end;

  TBCDriveComboBox = class(TBCCustomDriveComboBox)
  published
    property Align;
    property Anchors;
    property AutoComplete;
    property AutoDropDown;
    property Color;
    property Constraints;
    property FileTreeView;
    property DoubleBuffered;
    property DragMode;
    property DragCursor;
    property Drive;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentDoubleBuffered;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnChange;
    property OnClick;
    property OnCloseUp;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDropDown;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnSelect;
    property OnStartDock;
    property OnStartDrag;
  end;

  TBCCustomFileTypeComboBox = class(TsCustomComboBox)
  private
    FFileTreeViewUpdateDelay: Integer;
    FFileTreeView: TBCFileTreeView;
    FFileTreeViewUpdateTimer: TTimer;
    function GetFileType: string;
    procedure CMFontChanged(var AMessage: TMessage); message CM_FONTCHANGED;
    procedure CNDrawItem(var AMessage: TWMDrawItem); message CN_DRAWITEM;
    procedure ResetItemHeight;
    procedure SetFileTreeView(AValue: TBCFileTreeView);
    procedure SetFileTreeViewUpdateDelay(Value: Integer);
    procedure SetExtensions(const AValue: string);
    procedure SetFileType(const AValue: string);
    procedure UpdateVirtualTree;
    procedure OnFileTreeViewUpdateDelayTimer(Sender: TObject);
  protected
    procedure Change; override;
    procedure DrawItem(AIndex: Integer; ARect: TRect; AState: TOwnerDrawState); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Extensions: string write SetExtensions;
    property FileTreeViewUpdateDelay: Integer read FFileTreeViewUpdateDelay write SetFileTreeViewUpdateDelay;
    property FileTreeView: TBCFileTreeView read FFileTreeView write SetFileTreeView;
    property FileType: string read GetFileType write SetFileType;
  end;

  TBCFileTypeComboBox = class(TBCCustomFileTypeComboBox)
  published
    property Align;
    property Anchors;
    property AutoComplete;
    property AutoDropDown;
    property Color;
    property Constraints;
    property FileTreeViewUpdateDelay;
    property FileTreeView;
    property FileType;
    property DoubleBuffered;
    property DragMode;
    property DragCursor;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentDoubleBuffered;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property SkinData;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnChange;
    property OnClick;
    property OnCloseUp;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDropDown;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnSelect;
    property OnStartDock;
    property OnStartDrag;
  end;

  TBCFileTreeView = class(TVirtualDrawTree)
  private
    FDefaultDirectoryPath: string;
    FDrive: Char;
    FDriveComboBox: TBCCustomDriveComboBox;
    FExcludeOtherBranches: Boolean;
    FFileType: string;
    FFileTypeComboBox: TBCCustomFileTypeComboBox;
    FRootDirectory: string;
    FShowArchive: Boolean;
    FShowHidden: Boolean;
    FShowOverlayIcons: Boolean;
    FShowSystem: Boolean;
    FSkinManager: TsSkinManager;
    function GetAImageIndex(Path: string): Integer;
    function GetDrive: Char;
    function GetDriveRemote: Boolean;
    function GetFileType: string;
    function GetSelectedFile: string;
    function GetSelectedIndex(Path: string): Integer;
    function GetSelectedPath: string;
    function IsDirectoryEmpty(const Directory: string): Boolean;
    procedure BuildTree(RootDirectory: string; ExcludeOtherBranches: Boolean);
    procedure DriveChange(NewDrive: Char);
    procedure SetDrive(AValue: Char);
    procedure SetFileType(const AValue: string);
  protected
    function DeleteTreeNode(Node: PVirtualNode): Boolean;
    function DoCompare(Node1, Node2: PVirtualNode; Column: TColumnIndex): Integer; override;
    function DoCreateEditor(Node: PVirtualNode; Column: TColumnIndex): IVTEditLink; override;
    function DoGetImageIndex(Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var Index: TImageIndex): TCustomImageList; override;
    function DoGetNodeWidth(Node: PVirtualNode; Column: TColumnIndex; Canvas: TCanvas = nil): Integer; override;
    function DoInitChildren(Node: PVirtualNode; var ChildCount: Cardinal): Boolean; override;
    procedure DoFreeNode(ANode: PVirtualNode); override;
    procedure DoInitNode(Parent, Node: PVirtualNode; var InitStates: TVirtualNodeInitStates); override;
    procedure DoPaintNode(var PaintInfo: TVTPaintInfo); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure PaintImage(var PaintInfo: TVTPaintInfo; ImageInfoIndex: TVTImageInfoIndex; DoOverlay: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure OpenPath(ARootDirectory: string; ADirectoryPath: string; AExcludeOtherBranches: Boolean; ARefresh: Boolean = False);
    procedure RenameSelectedNode;
    procedure DeleteSelectedNode;
    property Drive: Char read GetDrive write SetDrive;
    property FileType: string read GetFileType write SetFileType;
    property ShowHiddenFiles: Boolean read FShowHidden write FShowHidden;
    property ShowSystemFiles: Boolean read FShowSystem write FShowSystem;
    property ShowArchiveFiles: Boolean read FShowArchive write FShowArchive;
    property ShowOverlayIcons: Boolean read FShowOverlayIcons write FShowOverlayIcons;
    property ExcludeOtherBranches: Boolean read FExcludeOtherBranches;
    property SelectedPath: string read GetSelectedPath;
    property SelectedFile: string read GetSelectedFile;
    property RootDirectory: string read FRootDirectory;
    property SkinManager: TsSkinManager read FSkinManager write FSkinManager;
  end;

  TEditLink = class(TInterfacedObject, IVTEditLink)
  private
    FEdit: TBCEdit;
    FTree: TBCFileTreeView; // A back reference to the tree calling.
    FNode: PVirtualNode; // The node being edited.
    FColumn: Integer; // The column of the node being edited.
  protected
    procedure EditKeyPress(Sender: TObject; var Key: Char);
  public
    destructor Destroy; override;
    function BeginEdit: Boolean; stdcall;
    function CancelEdit: Boolean; stdcall;
    function EndEdit: Boolean; stdcall;
    function GetBounds: TRect; stdcall;
    function PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
    procedure ProcessMessage(var AMessage: TMessage); stdcall;
    procedure SetBounds(ARect: TRect); stdcall;
    procedure Copy;
    procedure Paste;
    procedure Cut;
  end;

  TBCFileType = (ftNone, ftDirectory, ftFile, ftDirectoryAccessDenied, ftFileAccessDenied);

  TBCFileTreeNodeRecord = record
    FileType: TBCFileType;
    SaturateImage: Boolean;
    FullPath: string;
    Filename: string;
    ImageIndex: Integer;
    SelectedIndex: Integer;
    OverlayIndex: Integer;
  end;
  PBCFileTreeNodeRecord = ^TBCFileTreeNodeRecord;

implementation

uses
  Vcl.Forms, Winapi.ShellAPI, Vcl.Dialogs, BCControl.Utils, BCControl.Language, BCControl.ImageList,
  Winapi.CommCtrl, VirtualTrees.Utils, sGraphUtils, sVCLUtils, sDefaults;

const
  FILE_ATTRIBUTES = FILE_ATTRIBUTE_READONLY or FILE_ATTRIBUTE_HIDDEN or FILE_ATTRIBUTE_SYSTEM or FILE_ATTRIBUTE_ARCHIVE or FILE_ATTRIBUTE_NORMAL or FILE_ATTRIBUTE_DIRECTORY;

function GetItemHeight(Font: TFont): Integer;
var
  LDC: HDC;
  LSaveFont: HFont;
  LMetrics: TTextMetric;
begin
  LDC := GetDC(0);
  LSaveFont := SelectObject(LDC, Font.Handle);
  GetTextMetrics(LDC, LMetrics);
  SelectObject(LDC, LSaveFont);
  ReleaseDC(0, LDC);
  Result := LMetrics.tmHeight;
end;

{ TBCCustomDriveComboBox }

constructor TBCCustomDriveComboBox.Create(AOwner: TComponent);
var
  LDirectory: string;
begin
  inherited Create(AOwner);
  Autosize := False;
  Style := csOwnerDrawFixed;
  GetSystemIcons;
  GetDir(0, LDirectory);
  FDrive := LDirectory[1]; { make default drive selected }
  if FDrive = '\' then
    FDrive := #0;
  ResetItemHeight;
  FDriveComboFileList := TList.Create;
end;

destructor TBCCustomDriveComboBox.Destroy;
begin
  if not (csDesigning in ComponentState) then
  begin
    ClearItems;
    FreeAndNil(FDriveComboFileList);
  end;
  FreeAndNil(FSystemIconsImageList);
  inherited Destroy;
end;

procedure TBCCustomDriveComboBox.BuildList;
var
  LDrives: set of 0..25;
  LSHFileInfo: TSHFileInfo;
  LP1: Integer;
  LDrive: string;
  LDriveComboFile: TDriveComboFile;
begin
  Items.BeginUpdate;

  ClearItems;
  Integer(LDrives) := GetLogicalDrives;

  for LP1 := 0 to 25 do
  if LP1 in LDrives then
  begin
    LDrive := chr(ord('A') + LP1) + ':\';
    SHGetFileInfo(PChar(LDrive), 0, LSHFileInfo, SizeOf(LSHFileInfo), SHGFI_SYSICONINDEX or SHGFI_DISPLAYNAME or SHGFI_TYPENAME);
    LDriveComboFile := TDriveComboFile.Create;
    LDriveComboFile.Drive := chr(ord('A') + LP1);
    LDriveComboFile.IconIndex := LSHFileInfo.iIcon;
    LDriveComboFile.FileName := StrPas(LSHFileInfo.szDisplayName);
    Items.Add(StrPas(LSHFileInfo.szDisplayName));
    FDriveComboFileList.Add(LDriveComboFile);
    { destroy the icon, we are only using the index }
    DestroyIcon(LSHFileInfo.hIcon);
  end;
  Items.EndUpdate;
end;

function TBCCustomDriveComboBox.GetDrive: Char;
begin
  Result := FDrive;
end;

procedure TBCCustomDriveComboBox.SetDrive(ANewDrive: Char);
var
  LItem: Integer;
begin
  if (ItemIndex < 0) or (UpCase(ANewDrive) <> UpCase(FDrive)) then
  begin
    FDrive := ANewDrive;
    if ANewDrive = #0 then
      ItemIndex := -1
    else
    { change selected item }
    for LItem := 0 to Items.Count - 1 do
      if UpCase(ANewDrive) = TDriveComboFile(FDriveComboFileList[LItem]).Drive then
      begin
        ItemIndex := LItem;
        Break;
      end;
    if ItemIndex <> -1 then
      FIconIndex := TDriveComboFile(FDriveComboFileList[ItemIndex]).IconIndex;
    if Assigned(FFileTreeView) then
      FFileTreeView.DriveChange(ANewDrive);
    Change;
  end;
end;

procedure TBCCustomDriveComboBox.SetFileTreeView(AValue: TBCFileTreeView);
begin
  if Assigned(FFileTreeView) then
    FFileTreeView.FDriveComboBox := nil;
  FFileTreeView := AValue;
  if Assigned(FFileTreeView) then
  begin
    FFileTreeView.FDriveComboBox := Self;
    FFileTreeView.FreeNotification(Self);
  end;
end;

procedure TBCCustomDriveComboBox.DrawItem(AIndex: Integer; ARect: TRect; AState: TOwnerDrawState);
begin
  if AIndex = -1 then
    Exit;
  { ensure the correct highlite color is used }
  if Assigned(SkinData) and Assigned(SkinData.SkinManager) and SkinData.SkinManager.Active then
  begin
    if odSelected in AState then
    begin
      Canvas.Brush.Color := SkinData.SkinManager.GetHighLightColor;
      Canvas.Font.Color := SkinData.SkinManager.GetHighLightFontColor
    end
    else
    begin
      Canvas.Brush.Color := SkinData.SkinManager.gd[SkinData.SkinIndex].Props[0].Color;
      Canvas.Font.Color := SkinData.SkinManager.GetActiveEditFontColor;
    end;
  end;
  Canvas.FillRect(ARect);
  if FDriveComboFileList.Count > 0 then
  begin
    { draw the actual bitmap }
    FSystemIconsImageList.Draw(Canvas, ARect.Left + 3, ARect.Top, TDriveComboFile(FDriveComboFileList[AIndex]).IconIndex);
    { write the text }
    Canvas.TextOut(ARect.Left + FSystemIconsImageList.Width + 7, ARect.Top + 2,
      TDriveComboFile(FDriveComboFileList[AIndex]).FileName);
  end;
end;

procedure TBCCustomDriveComboBox.Change;
begin
  inherited;
  if ItemIndex >= 0 then
    if Assigned(FDriveComboFileList[ItemIndex]) then
      Drive := TDriveComboFile(FDriveComboFileList[ItemIndex]).Drive[1];
end;

procedure TBCCustomDriveComboBox.CMFontChanged(var AMessage: TMessage);
begin
  inherited;
  ResetItemHeight;
  RecreateWnd;
end;

procedure TBCCustomDriveComboBox.ResetItemHeight;
var
  LHeight: Integer;
begin
  LHeight := GetItemHeight(Font);
  if LHeight < FSystemIconsImageList.Height then
    LHeight := FSystemIconsImageList.Height;
  ItemHeight := LHeight;
end;

procedure TBCCustomDriveComboBox.GetSystemIcons;
begin
  FSystemIconsImageList := TImageList.Create(Self);
  FSystemIconsImageList.Handle := GetSysImageList;
end;

procedure TBCCustomDriveComboBox.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FFileTreeView) then
    FFileTreeView := nil;
end;

procedure TBCCustomDriveComboBox.ClearItems;
var
  LIndex: Integer;
begin
   if not (csDesigning in ComponentState) then
  begin
    for LIndex := 0 to FDriveComboFileList.Count - 1 do
      TDriveComboFile(FDriveComboFileList.Items[LIndex]).Free;
    FDriveComboFileList.Clear;
    if not (csDestroying in ComponentState) then
      Clear; // can't clear if the component is being destroyed or there is an exception, 'no parent window'
  end;
end;

procedure TBCCustomDriveComboBox.CNDrawItem(var AMessage: TWMDrawItem);
var
  LDrawState: TOwnerDrawState;
begin
  if csDesigning in ComponentState then
    Exit;
  with AMessage.DrawItemStruct^ do
  begin
    LDrawState := TOwnerDrawState(LoWord(itemState));
    if ItemState and ODS_COMBOBOXEDIT <> 0 then
      Include(LDrawState, odComboBoxEdit);
    if ItemState and ODS_DEFAULT <> 0 then
      Include(LDrawState, odDefault);
    Canvas.Handle := hDC;
    Canvas.Font := Font;

    if Assigned(SkinData) and Assigned(SkinData.SkinManager) and SkinData.SkinManager.Active then
    begin
      Canvas.Brush.Color := SkinData.SkinManager.gd[SkinData.SkinIndex].Props[0].Color;
      Canvas.Font.Color := SkinData.SkinManager.GetActiveEditFontColor
    end
    else
    begin
      Canvas.Brush := Brush;
      Canvas.Font.Color := clWindowText;
    end;
    if (Integer(itemID) >= 0) and (odSelected in LDrawState) then
    begin
      if Assigned(SkinData) and Assigned(SkinData.SkinManager) and SkinData.SkinManager.Active then
      begin
        Canvas.Brush.Color := SkinData.SkinManager.GetHighLightColor;
        Canvas.Font.Color := SkinData.SkinManager.GetHighLightFontColor
      end
      else
      begin
        Canvas.Brush.Color := clHighlight;
        Canvas.Font.Color := clHighlightText;
      end;
    end;
    if Integer(ItemID) >= 0 then
      DrawItem(ItemID, rcItem, LDrawState)
    else
      Canvas.FillRect(rcItem);
    //if odFocused in State then DrawFocusRect(hDC, rcItem);
    Canvas.Handle := 0;
  end;
end;

{ TBCCustomFileTypeComboBox }

constructor TBCCustomFileTypeComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Autosize := False;
  FFileTreeViewUpdateDelay := 500;
  FFileTreeViewUpdateTimer := TTimer.Create(nil);
  with FFileTreeViewUpdateTimer do
  begin
    OnTimer := OnFileTreeViewUpdateDelayTimer;
    Interval := FFileTreeViewUpdateDelay;
  end;
  ResetItemHeight;
end;

destructor TBCCustomFileTypeComboBox.Destroy;
begin
  FFileTreeViewUpdateTimer.Free;
  inherited;
end;

procedure TBCCustomFileTypeComboBox.UpdateVirtualTree;
begin
  if Assigned(FFileTreeView) then
    FFileTreeView.FileType := Text;
end;

procedure TBCCustomFileTypeComboBox.SetFileTreeView(AValue: TBCFileTreeView);
begin
  if Assigned(FFileTreeView) then
    FFileTreeView.FFileTypeComboBox := nil;
  FFileTreeView := AValue;
  if Assigned(FFileTreeView) then
  begin
    FFileTreeView.FFileTypeComboBox := Self;
    FFileTreeView.FreeNotification(Self);
  end;
end;

procedure TBCCustomFileTypeComboBox.SetFileTreeViewUpdateDelay(Value: Integer);
begin
  FFileTreeViewUpdateDelay := Value;
  if Assigned(FFileTreeViewUpdateTimer) then
    FFileTreeViewUpdateTimer.Interval := Value;
end;

procedure TBCCustomFileTypeComboBox.CMFontChanged(var AMessage: TMessage);
begin
  inherited;
  ResetItemHeight;
  RecreateWnd;
end;

function TBCCustomFileTypeComboBox.GetFileType: string;
begin
  Result := Text;
end;

procedure TBCCustomFileTypeComboBox.SetFileType(const AValue: string);
begin
  Text := AValue;
end;

procedure TBCCustomFileTypeComboBox.ResetItemHeight;
begin
  ItemHeight := GetItemHeight(Font);
end;

procedure TBCCustomFileTypeComboBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) and (AComponent = FFileTreeView) then
    FFileTreeView := nil;
end;

procedure TBCCustomFileTypeComboBox.Change;
begin
  inherited;
  with FFileTreeViewUpdateTimer do
  begin
    Enabled := False; { change starts the delay timer again }
    Enabled := True;
  end;
end;

procedure TBCCustomFileTypeComboBox.OnFileTreeViewUpdateDelayTimer(Sender: TObject);
begin
  FFileTreeViewUpdateTimer.Enabled := False;
  UpdateVirtualTree;
end;

procedure TBCCustomFileTypeComboBox.SetExtensions(const AValue: string);
var
  LValue: string;
begin
  LValue := AValue;
  with Items do
  begin
    Clear;
    while Pos('|', LValue) <> 0 do
    begin
      Add(Copy(LValue, 1, Pos('|', LValue) - 1));
      LValue := Copy(LValue, Pos('|', LValue) + 1, Length(LValue));
    end;
  end;
end;

procedure TBCCustomFileTypeComboBox.DrawItem(AIndex: Integer; ARect: TRect; AState: TOwnerDrawState);
begin
  { ensure the correct highlite color is used }
  Canvas.FillRect(ARect);
  { write the text }
  Canvas.TextOut(ARect.Left, ARect.Top + 2, Items[AIndex]);
end;

procedure TBCCustomFileTypeComboBox.CNDrawItem(var AMessage: TWMDrawItem);
var
  LDrawState: TOwnerDrawState;
begin
  with AMessage.DrawItemStruct{$IFNDEF CLR}^{$ENDIF} do
  begin
    LDrawState := TOwnerDrawState(LoWord(itemState));
    if ItemState and ODS_COMBOBOXEDIT <> 0 then
      Include(LDrawState, odComboBoxEdit);
    if ItemState and ODS_DEFAULT <> 0 then
      Include(LDrawState, odDefault);
    Canvas.Handle := hDC;
    Canvas.Font := Font;
    Canvas.Brush := Brush;

    if Assigned(SkinData) and Assigned(SkinData.SkinManager) and SkinData.SkinManager.Active then
      Canvas.Font.Color := SkinData.SkinManager.GetActiveEditFontColor
    else
      Canvas.Font.Color := clWindowText;
    if (Integer(itemID) >= 0) and (odSelected in LDrawState) then
    begin
      if Assigned(SkinData) and Assigned(SkinData.SkinManager) and SkinData.SkinManager.Active then
      begin
        Canvas.Brush.Color := SkinData.SkinManager.GetHighLightColor;
        Canvas.Font.Color := SkinData.SkinManager.GetHighLightFontColor
      end
      else
      begin
        Canvas.Brush.Color := clHighlight;
        Canvas.Font.Color := clHighlightText;
      end;
    end;
    if Integer(itemID) >= 0 then
      DrawItem(itemID, rcItem, LDrawState)
    else
      Canvas.FillRect(rcItem);
    //if odFocused in State then DrawFocusRect(hDC, rcItem);
    Canvas.Handle := 0;
  end;
end;

{ TBCFileTreeView }

constructor TBCFileTreeView.Create;
var
  LSysImageList: THandle;
begin
  inherited Create(AOwner);

  DragOperations := [];
  Header.Options := [];
  IncrementalSearch := isAll;
  Indent := 20;
  EditDelay := 500;

  TreeOptions.AutoOptions := [toAutoDropExpand, toAutoScroll, toAutoChangeScale, toAutoScrollOnExpand, toAutoTristateTracking, toAutoDeleteMovedNodes];
  TreeOptions.MiscOptions := [toEditable, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick];
  TreeOptions.PaintOptions := [toShowBackground, toShowButtons, toShowRoot, toThemeAware, toHideTreeLinesIfThemed, toUseExplorerTheme];

  FShowHidden := False;
  FShowArchive := True;
  FShowSystem := False;
  FShowOverlayIcons := True;

  Images := TImageList.Create(Self);
  LSysImageList := GetSysImageList;
  if LSysImageList <> 0 then
  begin
    Images.Handle := LSysImageList;
    Images.BkColor := clNone;
    Images.ShareImages := True;
  end;

  FDrive := #0;
  FFileType := '*.*';
end;

destructor TBCFileTreeView.Destroy;
begin
  Images.Free;

  inherited Destroy;
end;

procedure TBCFileTreeView.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
    if AComponent = FDriveComboBox then
      FDriveComboBox := nil
    else
    if AComponent = FFileTypeComboBox then
      FFileTypeComboBox := nil
  end;
end;

procedure TBCFileTreeView.DriveChange(NewDrive: Char);
begin
  if UpCase(NewDrive) <> UpCase(FDrive) then
  begin
    FDrive := NewDrive;
    FRootDirectory := NewDrive + ':\';
    if not (csDesigning in ComponentState) then
      BuildTree(FRootDirectory, False);
  end
end;

procedure TBCFileTreeView.SetFileType(const AValue: string);
begin
  if AnsiUpperCase(AValue) <> AnsiUpperCase(FFileType) then
  begin
    FFileType := AValue;
    if not (csDesigning in ComponentState) then
      OpenPath(FRootDirectory, SelectedPath, FExcludeOtherBranches);
  end
end;

function TBCFileTreeView.GetFileType: string;
begin
  Result := FFileType;
end;

procedure TBCFileTreeView.SetDrive(AValue: Char);
begin
  if (UpCase(AValue) <> UpCase(FDrive)) then
  begin
    FDrive := AValue;
    DriveChange(AValue);
  end;
end;

function TBCFileTreeView.GetDrive: Char;
begin
  Result := FDrive;
end;

function TBCFileTreeView.GetAImageIndex(Path: string): Integer;
begin
  Result := GetIconIndex(Path);
end;

function TBCFileTreeView.GetSelectedIndex(Path: string): Integer;
begin
  Result := GetIconIndex(Path, SHGFI_OPENICON);
end;

function TBCFileTreeView.GetDriveRemote: Boolean;
var
  LDrive: string;
  LDriveType: Cardinal;
begin
  { Access check for remote drive is impossible

    Even when performing AccessCheck(), you are doing an access check against an access token that is generated "locally",
    with the security descriptor associated with the object. When you directly access the object on a remote system, a network
    access token gets generated on the remote system. This network access token is used to perform access check on the object
    to determine whether access should be granted or denied. The object could be either a file or named pipe or AD object.

    e.g. If the user is member of Administrators group on the remote system, when you directly access the object on a remote
    system, the network access token that gets generated on the remote system will have Administrators group and will allow access.
    Whereas, when you call AccessCheck() with a local access token, you will get different results. }
  LDrive := GetDrive + ':\';
  LDriveType := GetDriveType(PChar(LDrive));
  Result := LDriveType = DRIVE_REMOTE;
end;

procedure TBCFileTreeView.BuildTree(RootDirectory: string; ExcludeOtherBranches: Boolean);
var
  LFindFile: Integer;
  LPNode: PVirtualNode;
  LSearchRec: TSearchRec;
  LFileName: string;
  LData: PBCFileTreeNodeRecord;
  LDriveRemote: Boolean;
  LRootDirectory: string;
begin
  BeginUpdate;
  Clear;
  NodeDataSize := SizeOf(TBCFileTreeNodeRecord);

  LDriveRemote := GetDriveRemote;
  {$WARNINGS OFF} { IncludeTrailingBackslash is specific to a platform }
  LRootDirectory := IncludeTrailingBackslash(RootDirectory);
  {$WARNINGS ON}

  if not ExcludeOtherBranches then
    LFindFile := FindFirst(GetDrive + ':\*.*', faAnyFile, LSearchRec)
  else
    LFindFile := FindFirst(LRootDirectory + '*.*', faAnyFile, LSearchRec);

  if LFindFile = 0 then
  try
    Screen.Cursor := crHourGlass;
    repeat
      {$WARNINGS OFF}
      if ((LSearchRec.Attr and faHidden <> 0) and not ShowHiddenFiles) or
          ((LSearchRec.Attr and faArchive <> 0) and not ShowArchiveFiles) or
          ((LSearchRec.Attr and faSysFile <> 0) and not ShowSystemFiles) then
          Continue;
      {$WARNINGS ON}
      if (LSearchRec.Name <> '.') and (LSearchRec.Name <> '..') then
        if (LSearchRec.Attr and faDirectory <> 0) or (FFileType = '*.*') or IsExtInFileType(ExtractFileExt(LSearchRec.Name), FFileType) then
        begin
          LPNode := AddChild(nil);
          LData := GetNodeData(LPNode);
          if not ExcludeOtherBranches then
            LFileName := GetDrive + ':\' + LSearchRec.Name
          else
            {$WARNINGS OFF}
            LFileName := LRootDirectory + LSearchRec.Name;
            {$WARNINGS ON}
          if (LSearchRec.Attr and faDirectory <> 0) then
          begin
            LData.FileType := ftDirectory;
            {$WARNINGS OFF}
            LData.FullPath := IncludeTrailingBackslash(LFileName);
            {$WARNINGS ON}
          end
          else
          begin
            LData.FileType := ftFile;
            if not ExcludeOtherBranches then
              LData.FullPath := GetDrive + ':\'
            else
              LData.FullPath := LRootDirectory;
          end;
          if not LDriveRemote then
            if not CheckAccessToFile(FILE_GENERIC_READ, LFileName) then //Data.FullPath) then
            begin
              if LData.FileType = ftDirectory then
                LData.FileType := ftDirectoryAccessDenied
              else
                LData.FileType := ftFileAccessDenied;
            end;
          {$WARNINGS OFF}
          LData.SaturateImage := (LSearchRec.Attr and faHidden <> 0) or (LSearchRec.Attr and faSysFile <> 0) or
            (LData.FileType = ftDirectoryAccessDenied) or (LData.FileType = ftFileAccessDenied);
          {$WARNINGS ON}
          LData.Filename := LSearchRec.Name;
          LData.ImageIndex := GetAImageIndex(LFileName);
          LData.SelectedIndex := GetSelectedIndex(LFileName);
          LData.OverlayIndex := GetIconOverlayIndex(LFileName);
        end;
    until FindNext(LSearchRec) <> 0;
  finally
    System.SysUtils.FindClose(LSearchRec);
    Screen.Cursor := crDefault;
  end;
  Sort(nil, 0, sdAscending, False);

  EndUpdate;
end;

function TBCFileTreeView.GetSelectedPath: string;
var
  LPNode: PVirtualNode;
  LData: PBCFileTreeNodeRecord;
begin
  Result := '';

  LPNode := GetFirstSelected;
  if not Assigned(LPNode) then
  begin
    if not FExcludeOtherBranches then
      Result := Drive + ':\'
    else
      Result := FDefaultDirectoryPath;
  end
  else
  begin
    LData := GetNodeData(LPNode);
    {$WARNINGS OFF} { IncludeTrailingBackslash is specific to a platform }
    Result := IncludeTrailingBackslash(LData.FullPath);
    {$WARNINGS ON}
  end;
end;

function TBCFileTreeView.GetSelectedFile: string;
var
  LPNode: PVirtualNode;
  LData: PBCFileTreeNodeRecord;
begin
  Result := '';
  LPNode := GetFirstSelected;
  if not Assigned(LPNode) then
    Exit;

  LData := GetNodeData(LPNode);
  if LData.FileType = ftDirectory then
    Exit;

  {$WARNINGS OFF} { IncludeTrailingBackslash is specific to a platform }
  Result := IncludeTrailingBackslash(LData.FullPath);
  {$WARNINGS ON}
  if System.SysUtils.FileExists(Result + LData.Filename) then
    Result := Result + LData.Filename;
end;

procedure TBCFileTreeView.OpenPath(ARootDirectory: string; ADirectoryPath: string; AExcludeOtherBranches: Boolean;
  ARefresh: Boolean = False);
var
  LPNode: PVirtualNode;
  LData: PBCFileTreeNodeRecord;
  LTempPath, LDirectory: string;
begin
  if not DirectoryExists(ARootDirectory) then
    Exit;
  if not DirectoryExists(ExtractFileDir(ADirectoryPath)) then
    Exit;
  BeginUpdate;
  FDriveComboBox.BuildList;
  FDriveComboBox.Drive := FDrive;
  FDefaultDirectoryPath := ADirectoryPath;
  if ARefresh or (FRootDirectory <> ARootDirectory) or (FExcludeOtherBranches <> ExcludeOtherBranches) then
  begin
    FRootDirectory := ARootDirectory;
    FExcludeOtherBranches := ExcludeOtherBranches;
    BuildTree(ARootDirectory, ExcludeOtherBranches);
  end;

  {$WARNINGS OFF} { IncludeTrailingBackslash is specific to a platform }
  LTempPath := IncludeTrailingBackslash(Copy(ADirectoryPath, 4, Length(ADirectoryPath)));
  {$WARNINGS ON}
  if ExcludeOtherBranches and (Pos('\', LTempPath) > 0) then
    LTempPath := Copy(LTempPath, Pos('\', LTempPath) + 1, Length(LTempPath));

  LPNode := GetFirst;
  while LTempPath <> '' do
  begin
    if Pos('\', LTempPath) <> 0 then
      LDirectory := Copy(LTempPath, 1, Pos('\', LTempPath) - 1)
    else
      LDirectory := LTempPath;

    if LDirectory <> '' then
    begin
      LData := GetNodeData(LPNode);
      while Assigned(LPNode) and (AnsiCompareText(LDirectory, LData.Filename) <> 0) do
      begin
        LPNode := LPNode.NextSibling;
        LData := GetNodeData(LPNode);
      end;

      if Assigned(LPNode) then
      begin
        Selected[LPNode] := True;
        Expanded[LPNode] := True;
        ScrollIntoView(LPNode, True);
        LPNode := LPNode.FirstChild;
      end;
    end;

    if Pos('\', LTempPath) <> 0 then
      LTempPath := Copy(LTempPath, Pos('\', LTempPath) + 1, Length(LTempPath))
    else
      LTempPath := '';
  end;
  EndUpdate;
end;

procedure TBCFileTreeView.RenameSelectedNode;
var
  LPNode: PVirtualNode;
begin
  LPNode := GetFirstSelected;
  if Assigned(LPNode) then
    Self.EditNode(LPNode, -1)
end;

function TBCFileTreeView.DeleteTreeNode(Node: PVirtualNode): Boolean;
var
  LFileName: string;
  LPreviousNode, LSelectedNode: PVirtualNode;
  LData: PBCFileTreeNodeRecord;
begin
  Result := False;
  LPreviousNode := Node.Parent;
  LSelectedNode := GetFirstSelected;
  if Assigned(Node) then
  try
    Screen.Cursor := crHourGlass;
    if Assigned(LSelectedNode) then
    begin
      LData := GetNodeData(LSelectedNode);
      if LData.FileType = ftDirectory then
        LFileName := SelectedPath
      else
        LFileName := SelectedFile;

      if LFileName = '' then
        Exit;
      {$WARNINGS OFF} { ExcludeTrailingBackslash is specific to a platform }
      LFileName := ExcludeTrailingBackslash(LFileName);
      {$WARNINGS ON}

      if LData.FileType = ftDirectory then
        Result := RemoveDirectory(LFileName)
      else
        Result := System.SysUtils.DeleteFile(LFileName);
    end;
    if Result then
    begin
      if Assigned(LPreviousNode) then
        Selected[LPreviousNode] := True;
      DeleteNode(Node);
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TBCFileTreeView.DeleteSelectedNode;
var
  LPNode: PVirtualNode;
begin
  LPNode := GetFirstSelected;
  if Assigned(LPNode) then
    DeleteTreeNode(LPNode);
end;

function TBCFileTreeView.IsDirectoryEmpty(const Directory: string): Boolean;
var
  LSearchRec: TSearchRec;
begin
  try
    Result := (FindFirst(Directory + '\*.*', faAnyFile, LSearchRec) = 0) and
      (FindNext(LSearchRec) = 0) and (FindNext(LSearchRec) <> 0);
  finally
    System.SysUtils.FindClose(LSearchRec);
  end;
end;

procedure TBCFileTreeView.DoInitNode(Parent, Node: PVirtualNode; var InitStates: TVirtualNodeInitStates);
var
  LData: PBCFileTreeNodeRecord;
begin
  inherited;
  LData := GetNodeData(Node);
  if LData.FileType = ftDirectory then
    if not IsDirectoryEmpty(LData.FullPath) then
      Include(InitStates, ivsHasChildren);
end;

procedure TBCFileTreeView.DoFreeNode(ANode: PVirtualNode);
var
  LData: PBCFileTreeNodeRecord;
begin
  LData := GetNodeData(ANode);
  Finalize(LData^);
  inherited;
end;

procedure TBCFileTreeView.DoPaintNode(var PaintInfo: TVTPaintInfo);
var
  LData: PBCFileTreeNodeRecord;
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
    if (LData.FileType = ftDirectoryAccessDenied) or (LData.FileType = ftFileAccessDenied) then
    begin
      Canvas.Font.Style := [fsItalic];
      if Assigned(SkinManager) then
        Canvas.Font.Color := BlendColors(ColorToRGB(Font.Color), GetControlColor(Parent), DefBlendDisabled)
      else
        Canvas.Font.Color := clBtnFace;
    end;

    SetBKMode(Canvas.Handle, TRANSPARENT);

    LRect := ContentRect;
    InflateRect(LRect, -TextMargin, 0);
    Dec(LRect.Right);
    Dec(LRect.Bottom);

    LString := LData.Filename;
    if Length(LString) > 0 then
    begin
      with LRect do
        if (NodeWidth - 2 * Margin) > (Right - Left) then
          LString := ShortenString(Canvas.Handle, LString, Right - Left);
      DrawTextW(Canvas.Handle, PWideChar(LString), Length(LString), LRect, DT_TOP or DT_LEFT or DT_VCENTER or DT_SINGLELINE);
    end;
  end;
end;

function TBCFileTreeView.DoGetImageIndex(Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var Index: TImageIndex): TCustomImageList;
var
  LData: PBCFileTreeNodeRecord;
begin
  Result := Images;
  if Assigned(Result) then
  begin
    LData := GetNodeData(Node);
    if Assigned(LData) then
    case Kind of
      ikNormal,
      ikSelected:
        begin
          if Expanded[Node] then
            Index := LData.SelectedIndex
          else
            Index := LData.ImageIndex;
        end;
      ikOverlay:
        if FShowOverlayIcons then
          Index := LData.OverlayIndex
    end;
  end;
end;

type
  TCustomImageListCast = class(TCustomImageList);

procedure DrawSaturatedImage(ImageList: TCustomImageList; Canvas: TCanvas; X, Y, Index: Integer);
var
  LParams: TImageListDrawParams;
begin
  FillChar(LParams, SizeOf(LParams), 0);
  LParams.cbSize := SizeOf(LParams);
  LParams.himl := ImageList.Handle;
  LParams.i := Index;
  LParams.hdcDst := Canvas.Handle;
  LParams.x := X;
  LParams.y := Y;
  LParams.fState := ILS_SATURATE;
  ImageList_DrawIndirect(@LParams);
end;

procedure TBCFileTreeView.PaintImage(var PaintInfo: TVTPaintInfo; ImageInfoIndex: TVTImageInfoIndex; DoOverlay: Boolean);
var
  LData: PBCFileTreeNodeRecord;
begin
  with PaintInfo do
  begin
    LData := GetNodeData(Node);

    if LData.SaturateImage then
    begin
      if DoOverlay then
        GetImageIndex(PaintInfo, ikOverlay, iiOverlay)
      else
        PaintInfo.ImageInfo[iiOverlay].Index := -1;
      with ImageInfo[ImageInfoIndex] do
      begin
        DrawSaturatedImage(Images, Canvas, XPos, YPos, Index);
        if ImageInfo[iiOverlay].Index >= 15 then
          DrawSaturatedImage(ImageInfo[iiOverlay].Images, Canvas, XPos, YPos, ImageInfo[iiOverlay].Index);
      end;
    end
    else
      inherited;
  end;
end;

function TBCFileTreeView.DoCompare(Node1, Node2: PVirtualNode; Column: TColumnIndex): Integer;
var
  LData1, LData2: PBCFileTreeNodeRecord;
begin
  Result := inherited;

  if Result = 0 then
  begin
    LData1 := GetNodeData(Node1);
    LData2 := GetNodeData(Node2);

    Result := -1;

    if not Assigned(LData1) or not Assigned(LData2) then
      Exit;

   if LData1.FileType <> LData2.FileType then
    begin
     if (LData1.FileType = ftDirectory) or (LData1.FileType = ftDirectoryAccessDenied) then
       Result := -1
     else
       Result := 1;
    end
    else
      Result := AnsiCompareText(LData1.Filename, LData2.Filename);
  end;
end;

function TBCFileTreeView.DoGetNodeWidth(Node: PVirtualNode; Column: TColumnIndex; Canvas: TCanvas = nil): Integer;
var
  LData: PBCFileTreeNodeRecord;
begin
  Result := inherited;
  LData := GetNodeData(Node);
  if not Assigned(Canvas) then
    Canvas := Self.Canvas;
  if Assigned(LData) then
    Result := Canvas.TextWidth(Trim(LData.FileName)) + 2 * TextMargin;
end;

function TBCFileTreeView.DoInitChildren(Node: PVirtualNode; var ChildCount: Cardinal): Boolean;
var
  LData, LChildData: PBCFileTreeNodeRecord;
  LSearchRec: TSearchRec;
  LPChildNode: PVirtualNode;
  LFileName: string;
  LDriveRemote: Boolean;
  LFullPath: string;
begin
  Result := True;

  LData := GetNodeData(Node);

  LDriveRemote := GetDriveRemote;

  {$WARNINGS OFF} { IncludeTrailingBackslash is specific to a platform }
  LFullPath := IncludeTrailingBackslash(LData.FullPath);
  {$WARNINGS OFF}
  if FindFirst(LFullPath + '*.*', faAnyFile, LSearchRec) = 0 then
  begin
    Screen.Cursor := crHourGlass;
    try
      repeat
        {$WARNINGS OFF}
        if ((LSearchRec.Attr and faHidden <> 0) and not ShowHiddenFiles) or
          ((LSearchRec.Attr and faArchive <> 0) and not ShowArchiveFiles) or
          ((LSearchRec.Attr and faSysFile <> 0) and not ShowSystemFiles) then
          Continue;
        {$WARNINGS ON}
        LFileName := LFullPath + LSearchRec.Name;

        if (LSearchRec.Name <> '.') and (LSearchRec.Name <> '..') then
          if (LSearchRec.Attr and faDirectory <> 0) or (FFileType = '*.*') or
            IsExtInFileType(ExtractFileExt(LSearchRec.Name), FFileType) then
          begin
            LPChildNode := AddChild(Node);
            LChildData := GetNodeData(LPChildNode);

            if (LSearchRec.Attr and faDirectory <> 0) then
            begin
              LChildData.FileType := ftDirectory;
              {$WARNINGS OFF}
              LChildData.FullPath := IncludeTrailingBackslash(LFileName);
              {$WARNINGS ON}
            end
            else
            begin
              LChildData.FileType := ftFile;
              {$WARNINGS OFF}
              LChildData.FullPath := LFullPath;
              {$WARNINGS ON}
            end;
            if not LDriveRemote then
              if not CheckAccessToFile(FILE_GENERIC_READ, LFileName) then
              begin
                if LChildData.FileType = ftDirectory then
                  LChildData.FileType := ftDirectoryAccessDenied
                else
                  LChildData.FileType := ftFileAccessDenied;
              end;
            {$WARNINGS OFF}
            LChildData.SaturateImage := (LSearchRec.Attr and faHidden <> 0) or (LSearchRec.Attr and faSysFile <> 0) or
              (LChildData.FileType = ftFileAccessDenied) or (LChildData.FileType = ftDirectoryAccessDenied);
            {$WARNINGS ON}
            LChildData.Filename := LSearchRec.Name;
            LChildData.ImageIndex := GetAImageIndex(LFileName);
            LChildData.SelectedIndex := GetSelectedIndex(LFileName);
            LChildData.OverlayIndex := GetIconOverlayIndex(LFileName);
          end;
      until FindNext(LSearchRec) <> 0;

      ChildCount := Self.ChildCount[Node];

      if ChildCount > 0 then
        Sort(Node, 0, sdAscending, False);
    finally
      System.SysUtils.FindClose(LSearchRec);
      Screen.Cursor := crDefault;
    end;
  end;
end;

function TBCFileTreeView.DoCreateEditor(Node: PVirtualNode; Column: TColumnIndex): IVTEditLink;
begin
  Result := TEditLink.Create;
end;

{ TEditLink }

destructor TEditLink.Destroy;
begin
  //FEdit.Free; This gives AV
  if FEdit.HandleAllocated then
    PostMessage(FEdit.Handle, CM_RELEASE, 0, 0);
  inherited;
end;

procedure TEditLink.EditKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    #27:
      begin
        FTree.CancelEditNode;
        Key := #0;
      end;
    #13:
      begin
        FTree.EndEditNode;
        Key := #0;
      end;
  else
    inherited;
  end;
end;

function TEditLink.BeginEdit: Boolean;
var
  LData: PBCFileTreeNodeRecord;
begin
  LData := FTree.GetNodeData(FNode);
  Result := (LData.FileType = ftDirectory) or (LData.FileType = ftFile);
  if Result then
  begin
    FEdit.Show;
    FEdit.SetFocus;
  end;
end;

function TEditLink.CancelEdit: Boolean;
begin
  Result := True;
  FEdit.Hide;
end;

function TEditLink.EndEdit: Boolean;
var
  LData: PBCFileTreeNodeRecord;
  LBuffer: array[0..254] of Char;
  LString, LOldDirName, LNewDirName, LFullPath: string;
begin
  Result := True;

  LData := FTree.GetNodeData(FNode);
  try
    GetWindowText(FEdit.Handle, LBuffer, 255);
    LString := LBuffer;
    if (Length(LString) = 0) or LString.IsDelimiter('\*?/="<>|:,;+^', 0) then
    begin
      MessageBeep(MB_ICONHAND);
      if Length(LString) > 0 then
        MessageDlg(Format('%s: %s', [SBCControlFileControlEndEditInvalidName, LString]), mtError, [mbOK], 0);
      Exit;
    end;

    if LData.FileType = ftDirectory then
    {$WARNINGS OFF}
      LFullPath := ExtractFilePath(ExcludeTrailingBackslash(LData.FullPath))
    {$WARNINGS ON}
    else
      LFullPath := LData.FullPath;
    LOldDirName := LFullPath + LData.Filename;
    LNewDirName := LFullPath + LString;
    if LOldDirName = LNewDirName then
      Exit;
    if MessageDlg(Format(SBCControlFileControlEndEditRename, [ExtractFileName(LOldDirName),
      ExtractFileName(LNewDirName)]), mtConfirmation, [mbYes, mbNo], 0) = mrNo then
      Exit;
    FTree.SetFocus;
    if System.SysUtils.RenameFile(LOldDirName, LNewDirName) then
    begin
      if LString <> LData.FileName then
      begin
        LData.FileName := LString;
        FTree.InvalidateNode(FNode);
      end;
    end
    else
      ShowMessage(Format(SBCControlFileControlEndEditRenameFailed, [LOldDirName]));
  finally
    FEdit.Hide;
    FTree.SetFocus;
  end;
end;

function TEditLink.GetBounds: TRect;
begin
  Result := FEdit.BoundsRect;
end;

function TEditLink.PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean;
var
  LData: PBCFileTreeNodeRecord;
begin
  Result := True;
  FTree := Tree as TBCFileTreeView;
  FNode := Node;
  FColumn := Column;

  if Assigned(FEdit) then
  begin
    FEdit.Free;
    FEdit := nil;
  end;
  LData := FTree.GetNodeData(Node);

  FEdit := TBCEdit.Create(nil);
  with FEdit do
  begin
    Visible := False;
    Parent := Tree;
    FEdit.Font.Name := FTree.Canvas.Font.Name;
    FEdit.Font.Size := FTree.Canvas.Font.Size;
    Text := LData.FileName;
    OnKeyPress := EditKeyPress;
  end;
end;

procedure TEditLink.ProcessMessage(var AMessage: TMessage);
begin
  FEdit.WindowProc(AMessage);
end;

procedure TEditLink.SetBounds(ARect: TRect);
var
  LDummy: Integer;
begin
  { Since we don't want to activate grid extensions in the tree (this would influence how the selection is drawn)
    we have to set the edit's width explicitly to the width of the column. }
  FTree.Header.Columns.GetColumnBounds(FColumn, LDummy, ARect.Right);
  FEdit.BoundsRect := ARect;
end;

procedure TEditLink.Copy;
begin
  FEdit.CopyToClipboard;
end;

procedure TEditLink.Paste;
begin
  FEdit.PasteFromClipboard;
end;

procedure TEditLink.Cut;
begin
  FEdit.CutToClipboard;
end;

end.

