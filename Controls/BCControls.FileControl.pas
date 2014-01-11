unit BCControls.FileControl;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Graphics, Vcl.StdCtrls, Winapi.Messages, System.Types,
  Winapi.Windows, VirtualTrees, Vcl.ImgList, BCControls.Edit, Vcl.ExtCtrls;

type
  TBCFileTreeView = class;

  TDriveComboFile = class
    Drive: string;
    IconIndex: Integer;
    FileName: string;
  end;

  TBCCustomDriveComboBox = class(TCustomComboBox)
  private
    { Private declarations }
    FDrive: Char;
    FIconIndex: Integer;
    FFileTreeView: TBCFileTreeView;
    FSystemIconsImageList: TImageList;
    { Can't use Items.Objects because those objects can't be destroyed in destructor because control has no parent
      window anymore. }
    FDriveComboFileList: TList;
    procedure SetFileTreeView(Value: TBCFileTreeView);
    procedure GetSystemIcons;
    procedure ResetItemHeight;
    function GetDrive: Char;
    procedure SetDrive(NewDrive: Char);
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
  protected
    { Protected declarations }
    procedure CreateWnd; override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
    procedure Change; override;
    procedure BuildList; virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ClearItems;
    property Drive: Char read GetDrive write SetDrive;
    property FileTreeView: TBCFileTreeView read FFileTreeView write SetFileTreeView;
    property SystemIconsImageList: TImageList read FSystemIconsImageList;
    property IconIndex: Integer read FIconIndex;
  end;

  TBCDriveComboBox = class(TBCCustomDriveComboBox)
  published
    { Published declarations }
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

  TBCCustomFileTypeComboBox = class(TCustomComboBox)
  private
    { Private declarations }
    FFileTreeViewUpdateDelay: Integer;
    FFileTreeView: TBCFileTreeView;
    FFileTreeViewUpdateTimer: TTimer;
    function GetFileType: string;
    procedure ResetItemHeight;
    procedure SetFileTreeView(Value: TBCFileTreeView);
    procedure SetFileTreeViewUpdateDelay(Value: Integer);
    procedure SetExtensions(Value: string);
    procedure SetFileType(Value: string);
    procedure UpdateVirtualTree;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure OnFileTreeViewUpdateDelayTimer(Sender: TObject);
  protected
    { Protected declarations }
    procedure Change; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Extensions: string write SetExtensions;
    property FileTreeViewUpdateDelay: Integer read FFileTreeViewUpdateDelay write SetFileTreeViewUpdateDelay;
    property FileTreeView: TBCFileTreeView read FFileTreeView write SetFileTreeView;
    property FileType: string read GetFileType write SetFileType;
  end;

  TBCFileTypeComboBox = class(TBCCustomFileTypeComboBox)
  published
    { Published declarations }
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

  TBCFileType = (ftNone, ftDirectory, ftFile, ftDirectoryAccessDenied, ftFileAccessDenied);

  PBCFileTreeNodeRec = ^TBCFileTreeNodeRec;
  TBCFileTreeNodeRec = record
    FileType: TBCFileType;
    FullPath, Filename: UnicodeString;
    ImageIndex, SelectedIndex, OverlayIndex: Integer;
  end;

  TBCFileTreeView = class(TVirtualDrawTree)
  private
    FDrive: Char;
    FDriveComboBox: TBCCustomDriveComboBox;
    FFileType: string;
    FFileTypeComboBox: TBCCustomFileTypeComboBox;
    FShowHidden: Boolean;
    FShowSystem: Boolean;
    FShowArchive: Boolean;
    FShowOverlayIcons: Boolean;
    FRootDirectory: string;
    FDefaultDirectoryPath: string;
    FExcludeOtherBranches: Boolean;
    procedure DriveChange(NewDrive: Char);
    procedure SetDrive(Value: Char);
    procedure SetFileType(NewFileType: string);
    function GetAImageIndex(Path: string): Integer;
    function GetSelectedIndex(Path: string): Integer;
    function GetFileType: string;
    function GetDrive: Char;
    procedure BuildTree(RootDirectory: string; ExcludeOtherBranches: Boolean);
    function GetSelectedPath: string;
    function GetSelectedFile: string;
    function IsDirectoryEmpty(const Directory: string): Boolean;
  protected
    function DeleteTreeNode(Node: PVirtualNode): Boolean;
    procedure DoInitNode(Parent, Node: PVirtualNode; var InitStates: TVirtualNodeInitStates); override;
    procedure DoFreeNode(Node: PVirtualNode); override;
    procedure DoPaintNode(var PaintInfo: TVTPaintInfo); override;
    function DoGetImageIndex(Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var Index: Integer): TCustomImageList; override;
    function DoCompare(Node1, Node2: PVirtualNode; Column: TColumnIndex): Integer; override;
    function DoGetNodeWidth(Node: PVirtualNode; Column: TColumnIndex; Canvas: TCanvas = nil): Integer; override;
    procedure DoInitChildren(Node: PVirtualNode; var ChildCount: Cardinal); override;
    function DoCreateEditor(Node: PVirtualNode; Column: TColumnIndex): IVTEditLink; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
  { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure OpenPath(RootDirectory: string; DirectoryPath: string; ExcludeOtherBranches: Boolean);
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
    procedure ProcessMessage(var Message: TMessage); stdcall;
    procedure SetBounds(R: TRect); stdcall;
  end;

procedure Register;

implementation

uses
  Vcl.Forms, Winapi.ShellAPI, Vcl.Dialogs, Vcl.Themes, BCCommon.LanguageStrings, BCCommon.StringUtils,
  BCCommon.Fileutils, BCControls.ImageList, System.UITypes;

const
  FILE_ATTRIBUTES = FILE_ATTRIBUTE_READONLY or FILE_ATTRIBUTE_HIDDEN or FILE_ATTRIBUTE_SYSTEM or FILE_ATTRIBUTE_ARCHIVE or FILE_ATTRIBUTE_NORMAL or FILE_ATTRIBUTE_DIRECTORY;

procedure Register;
begin
  RegisterComponents('bonecode', [TBCDriveComboBox]);
  RegisterComponents('bonecode', [TBCFileTypeComboBox]);
  RegisterComponents('bonecode', [TBCFileTreeView]);
end;

function GetItemHeight(Font: TFont): Integer;
var
  DC: HDC;
  SaveFont: HFont;
  Metrics: TTextMetric;
begin
  DC := GetDC(0);
  SaveFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
  Result := Metrics.tmHeight;
end;

{ TBCCustomDriveComboBox }

constructor TBCCustomDriveComboBox.Create(AOwner: TComponent);
var
  Temp: string;
begin
  inherited Create(AOwner);
  Style := csOwnerDrawFixed;
  GetSystemIcons;
  GetDir(0, Temp);
  FDrive := Temp[1]; { make default drive selected }
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
  Drives: set of 0..25;
  SHFileInfo: TSHFileInfo;
  lp1: Integer;
  Drv: string;
  DriveComboFile: TDriveComboFile;
begin
  Items.BeginUpdate;

  ClearItems;
  Integer(Drives) := GetLogicalDrives;

  for lp1 := 0 to 25 do
  begin
    if (lp1 in Drives) then
    begin
      Drv := chr(ord('A') + lp1) + ':\';
      SHGetFileInfo(PChar(Drv), 0, SHFileInfo, SizeOf(SHFileInfo), SHGFI_SYSICONINDEX or SHGFI_DISPLAYNAME or SHGFI_TYPENAME);
      DriveComboFile := TDriveComboFile.Create;
      DriveComboFile.Drive := chr(ord('A') + lp1);
      DriveComboFile.IconIndex := SHFileInfo.iIcon;
      DriveComboFile.FileName := StrPas(SHFileInfo.szDisplayName);
      Items.Add(StrPas(SHFileInfo.szDisplayName));
      FDriveComboFileList.Add(DriveComboFile);
    end;
  end;
  Items.EndUpdate;
end;

function TBCCustomDriveComboBox.GetDrive: Char;
begin
  Result := FDrive;
end;

procedure TBCCustomDriveComboBox.SetDrive(NewDrive: Char);
var
  Item: Integer;
begin
  if (ItemIndex < 0) or (UpCase(NewDrive) <> UpCase(FDrive)) then
  begin
    FDrive := NewDrive;
    if NewDrive = #0 then
      ItemIndex := -1
    else
    { change selected item }
    for Item := 0 to Items.Count - 1 do
      if UpCase(NewDrive) = TDriveComboFile(FDriveComboFileList[Item]).Drive then
      begin
        ItemIndex := Item;
        break;
      end;
    FIconIndex := TDriveComboFile(FDriveComboFileList[ItemIndex]).IconIndex;
    if Assigned(FFileTreeView) then
      FFileTreeView.DriveChange(NewDrive);
    Change;
  end;
end;

procedure TBCCustomDriveComboBox.SetFileTreeView(Value: TBCFileTreeView);
begin
  if Assigned(FFileTreeView) then
    FFileTreeView.FDriveComboBox := nil;
  FFileTreeView := Value;
  if Assigned(FFileTreeView) then
  begin
    FFileTreeView.FDriveComboBox := Self;
    FFileTreeView.FreeNotification(Self);
  end;
end;

procedure TBCCustomDriveComboBox.CreateWnd;
begin
  inherited CreateWnd;
  BuildList;
  SetDrive(FDrive);
end;

procedure TBCCustomDriveComboBox.DrawItem(Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
begin
  { ensure the correct highlite color is used }
  Canvas.FillRect(Rect);
  { draw the actual bitmap }
  FSystemIconsImageList.Draw(Canvas, Rect.Left + 3, Rect.Top, TDriveComboFile(FDriveComboFileList[Index]).IconIndex);
  { write the text }
  Canvas.TextOut(Rect.Left + FSystemIconsImageList.width + 7, Rect.Top + 2,
    TDriveComboFile(FDriveComboFileList[Index]).FileName);
end;

procedure TBCCustomDriveComboBox.Change;
begin
  if ItemIndex >= 0 then
    if Assigned(FDriveComboFileList[ItemIndex]) then
      Drive := TDriveComboFile(FDriveComboFileList[ItemIndex]).Drive[1];
end;

procedure TBCCustomDriveComboBox.CMFontChanged(var Message: TMessage);
begin
  inherited;
  ResetItemHeight;
  RecreateWnd;
end;

procedure TBCCustomDriveComboBox.ResetItemHeight;
var
  nuHeight: Integer;
begin
  nuHeight := GetItemHeight(Font);
  if nuHeight < FSystemIconsImageList.Height then
    nuHeight := FSystemIconsImageList.Height;
  ItemHeight := nuHeight;
end;

procedure TBCCustomDriveComboBox.GetSystemIcons;
var
  SHFileInfo: TSHFileInfo;
  PathInfo: string;
begin
  FileIconInit(True);
  FSystemIconsImageList := TImageList.Create(Self);
  FSystemIconsImageList.Handle := SHGetFileInfo(PChar(PathInfo), 0, SHFileInfo, SizeOf(SHFileInfo), SHGFI_ICON or SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
end;

procedure TBCCustomDriveComboBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FFileTreeView) then
    FFileTreeView := nil;
end;

procedure TBCCustomDriveComboBox.ClearItems;
var
  i: Integer;
begin
   if not (csDesigning in ComponentState) then
  begin
    for i := 0 to FDriveComboFileList.Count - 1 do
      TDriveComboFile(FDriveComboFileList.Items[i]).Free;
    FDriveComboFileList.Clear;
    if not (csDestroying in ComponentState) then
      Clear; // can't clear if the component is being destroyed or there is an exception, 'no parent window'
  end;
end;

procedure TBCCustomDriveComboBox.CNDrawItem(var Message: TWMDrawItem);
const
  ColorStates: array[Boolean] of TStyleColor = (scComboBoxDisabled, scComboBox);
  FontStates: array[Boolean] of TStyleFont = (sfComboBoxItemDisabled, sfComboBoxItemNormal);
var
  State: TOwnerDrawState;
  LStyles: TCustomStyleServices;
begin
  LStyles := StyleServices;
  with Message.DrawItemStruct{$IFNDEF CLR}^{$ENDIF} do
  begin
    State := TOwnerDrawState(LoWord(itemState));
    if itemState and ODS_COMBOBOXEDIT <> 0 then
      Include(State, odComboBoxEdit);
    if itemState and ODS_DEFAULT <> 0 then
      Include(State, odDefault);
    Canvas.Handle := hDC;
    Canvas.Font := Font;
    if LStyles.Enabled then
    begin
      if seClient in StyleElements then
        Canvas.Brush.Color := StyleServices.GetStyleColor(ColorStates[Enabled])
      else
        Canvas.Brush := Brush;
      if seFont in StyleElements then
        Canvas.Font.Color := StyleServices.GetStyleFontColor(FontStates[Enabled]);
    end
    else
      Canvas.Brush := Brush;
    if (Integer(itemID) >= 0) and (odSelected in State) then
    begin
      if LStyles.Enabled then
      begin
         Canvas.Brush.Color := LStyles.GetSystemColor(clHighlight);
         Canvas.Font.Color := LStyles.GetStyleFontColor(sfMenuItemTextSelected);// GetSystemColor(clHighlightText);
      end
      else
      begin
        Canvas.Brush.Color := clHighlight;
        Canvas.Font.Color := clHighlightText;
      end;
    end;
    if Integer(itemID) >= 0 then
      DrawItem(itemID, rcItem, State)
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
  FFileTreeViewUpdateDelay := 500;
  FFileTreeViewUpdateTimer := TTimer.Create(nil);
  with FFileTreeViewUpdateTimer do
  begin
    OnTimer := OnFileTreeViewUpdateDelayTimer;
    Interval := FFileTreeViewUpdateDelay;
  end;
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

procedure TBCCustomFileTypeComboBox.SetFileTreeView(Value: TBCFileTreeView);
begin
  {FFileTreeView := Value;
  UpdateVirtualTree; }
  if Assigned(FFileTreeView) then
    FFileTreeView.FFileTypeComboBox := nil;
  FFileTreeView := Value;
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

procedure TBCCustomFileTypeComboBox.CMFontChanged(var Message: TMessage);
begin
  inherited;
  ResetItemHeight;
  RecreateWnd;
end;

function TBCCustomFileTypeComboBox.GetFileType: string;
begin
  Result := Text;
end;

procedure TBCCustomFileTypeComboBox.SetFileType(Value: string);
begin
  Text := Value;
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

procedure TBCCustomFileTypeComboBox.SetExtensions(Value: string);
var
  Temp: string;
begin
  Temp := Value;
  with Items do
  begin
    Clear;
    while Pos('|', Temp) <> 0 do
    begin
      Add(Copy(Temp, 1, Pos('|', Temp) - 1));
      Temp := Copy(Temp, Pos('|', Temp) + 1, Length(Temp));
    end;
  end;
end;

{ TBCFileTreeView }

constructor TBCFileTreeView.Create;
var
  SHFileInfo: TSHFileInfo;
  PathInfo: String;
  SysImageList: THandle;
begin
  inherited Create(AOwner);

  DragOperations := [];
  Header.Options := [];
  IncrementalSearch := isAll;
  Indent := 20; //16;
  EditDelay := 500;

  TreeOptions.AutoOptions := [toAutoDropExpand, toAutoScroll, toAutoChangeScale, toAutoScrollOnExpand, toAutoTristateTracking, toAutoDeleteMovedNodes];
  TreeOptions.MiscOptions := [toEditable, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning, toEditOnClick];
  TreeOptions.PaintOptions := [toShowBackground, toShowButtons, toShowRoot, toUseBlendedSelection, {toUseBlendedImages,} toThemeAware, toHideTreeLinesIfThemed, toUseExplorerTheme];

  FShowHidden := False;
  FShowArchive := True;
  FShowSystem := False;
  FShowOverlayIcons := True;

  FileIconInit(True);
  Images := TBCImageList.Create(Self);
  SysImageList := SHGetFileInfo(PChar(PathInfo), 0, SHFileInfo, SizeOf(SHFileInfo), SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_ADDOVERLAYS);
  if SysImageList <> 0 then
  begin
    Images.Handle := SysImageList;
    Images.BkColor := ClNone;
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

procedure TBCFileTreeView.SetFileType(NewFileType: string);
begin
  if UpperCase(NewFileType) <> UpperCase(FFileType) then
  begin
    FFileType := NewFileType;
    if not (csDesigning in ComponentState) then
      OpenPath(FRootDirectory, SelectedPath, FExcludeOtherBranches);
  end
end;

function TBCFileTreeView.GetFileType: string;
begin
  Result := FFileType;
end;

procedure TBCFileTreeView.SetDrive(Value: Char);
begin
  if (UpCase(Value) <> UpCase(FDrive)) then
  begin
    FDrive := Value;
    DriveChange(Value);
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

procedure TBCFileTreeView.BuildTree(RootDirectory: string; ExcludeOtherBranches: Boolean);
var
  FindFile: Integer;
  ANode: PVirtualNode;
  SR: TSearchRec;
  FileName: string;
  Data: PBCFileTreeNodeRec;
begin
  BeginUpdate;
  Clear;
  NodeDataSize := SizeOf(TBCFileTreeNodeRec);

  if not ExcludeOtherBranches then
    FindFile := FindFirst(GetDrive + ':\*.*', faAnyFile, SR)
  else
    {$WARNINGS OFF} { IncludeTrailingBackslash is specific to a platform }
    FindFile := FindFirst(IncludeTrailingBackslash(RootDirectory) + '*.*', faAnyFile, SR);
    {$WARNINGS ON}

  if FindFile = 0 then
  try
    Screen.Cursor := crHourGlass;
    repeat
      {$WARNINGS OFF}
      if ((SR.Attr and faHidden <> 0) and not ShowHiddenFiles) or
          ((SR.Attr and faArchive <> 0) and not ShowArchiveFiles) or
          ((SR.Attr and faSysFile <> 0) and not ShowSystemFiles) then
          Continue;
      {$WARNINGS ON}
      if (SR.Name <> '.') and (SR.Name <> '..') then
        if (SR.Attr and faDirectory <> 0) or (GetFileType = '*.*') or IsExtInFileType(ExtractFileExt(SR.Name), GetFileType) then
        begin
          ANode := AddChild(nil);

          Data := GetNodeData(ANode);
          if not ExcludeOtherBranches then
            FileName := GetDrive + ':\' + SR.Name
          else
            {$WARNINGS OFF}
            FileName := IncludeTrailingBackslash(RootDirectory) + SR.Name;
            {$WARNINGS ON}
          if (SR.Attr and faDirectory <> 0) then
          begin
            Data.FileType := ftDirectory;
            {$WARNINGS OFF}
            Data.FullPath := IncludeTrailingBackslash(FileName);
            {$WARNINGS ON}
          end
          else
          begin
            Data.FileType := ftFile;
            if not ExcludeOtherBranches then
              Data.FullPath := GetDrive + ':\'
            else
              {$WARNINGS OFF}
              Data.FullPath := IncludeTrailingBackslash(RootDirectory);
              {$WARNINGS ON}
          end;
          if not CheckAccessToFile(FILE_GENERIC_READ, Data.FullPath) then
          begin
            if Data.FileType = ftDirectory then
              Data.FileType := ftDirectoryAccessDenied
            else
              Data.FileType := ftFileAccessDenied;
          end;

          Data.Filename := SR.Name;
          Data.ImageIndex := GetAImageIndex(Filename);
          Data.SelectedIndex := GetSelectedIndex(Filename);
          Data.OverlayIndex := GetIconOverlayIndex(Filename);
        end;
    until FindNext(SR) <> 0;
  finally
    System.SysUtils.FindClose(SR);
    Screen.Cursor := crDefault;
  end;
  Sort(nil, 0, sdAscending, False);

  EndUpdate;
end;

function TBCFileTreeView.GetSelectedPath: string;
var
  TreeNode: PVirtualNode;
  Data: PBCFileTreeNodeRec;
begin
  Result := '';

  TreeNode := GetFirstSelected;
  if not Assigned(TreeNode) then
  begin
    if not FExcludeOtherBranches then
      Result := Drive + ':\'
    else
      Result := FDefaultDirectoryPath;
  end
  else
  begin
    Data := GetNodeData(TreeNode);
    {$WARNINGS OFF} { IncludeTrailingBackslash is specific to a platform }
    Result := IncludeTrailingBackslash(Data.FullPath);
    {$WARNINGS ON}
  end;
end;

function TBCFileTreeView.GetSelectedFile: string;
var
  TreeNode: PVirtualNode;
  Data: PBCFileTreeNodeRec;
begin
  Result := '';
  TreeNode := GetFirstSelected;
  if not Assigned(TreeNode) then
    Exit;
  if TreeNode.ChildCount > 0 then
    Exit;

  Data := GetNodeData(TreeNode);

  {$WARNINGS OFF} { IncludeTrailingBackslash is specific to a platform }
  Result := IncludeTrailingBackslash(Data.FullPath);
  {$WARNINGS ON}
  if System.SysUtils.FileExists(Result + Data.Filename) then
    Result := Result + Data.Filename;
end;

procedure TBCFileTreeView.OpenPath(RootDirectory: string; DirectoryPath: string; ExcludeOtherBranches: Boolean);
var
  CurNode: PVirtualNode;
  Data: PBCFileTreeNodeRec;
  TempPath, Directory: string;
begin
  if not DirectoryExists(RootDirectory) then
    Exit;
  if not DirectoryExists(ExtractFileDir(DirectoryPath)) then
    Exit;
  BeginUpdate;
  FDefaultDirectoryPath := DirectoryPath;
  FExcludeOtherBranches := ExcludeOtherBranches;
  FRootDirectory := RootDirectory;
  BuildTree(RootDirectory, ExcludeOtherBranches);

  {$WARNINGS OFF} { IncludeTrailingBackslash is specific to a platform }
  TempPath := IncludeTrailingBackslash(Copy(DirectoryPath, 4, Length(DirectoryPath)));
  {$WARNINGS ON}
  if ExcludeOtherBranches and (Pos('\', TempPath) > 0) then
    TempPath := Copy(TempPath, Pos('\', TempPath) + 1, Length(TempPath));

  CurNode := GetFirst;
  while TempPath <> '' do //Pos('\', TempPath) > 0 do
  begin
    if Pos('\', TempPath) <> 0 then
      Directory := Copy(TempPath, 1, Pos('\', TempPath)-1)
    else
      Directory := TempPath;

    if Directory <> '' then
    begin
      Data := GetNodeData(CurNode);
      while Assigned(CurNode) and (AnsiCompareText(Directory, Data.Filename) <> 0) do
      begin
        CurNode := CurNode.NextSibling;
        Data := GetNodeData(CurNode);
      end;

      if Assigned(CurNode) then
      begin
        Selected[CurNode] := True;
        Expanded[CurNode] := True;
        CurNode := CurNode.FirstChild;
      end;
    end;

    if Pos('\', TempPath) <> 0 then
      TempPath := Copy(TempPath, Pos('\', TempPath) + 1, Length(TempPath))
    else
      TempPath := '';
  end;
  EndUpdate;
end;

function AddNullToStr(Path: string): string;
begin
  if Path = '' then
    Exit('');
  if Path[Length(Path)] <> #0 then
    Result := Path + #0
  else
    Result := Path;
end;

procedure TBCFileTreeView.RenameSelectedNode;
var
  SelectedNode: PVirtualNode;
begin
  SelectedNode := GetFirstSelected;
  if Assigned(SelectedNode) then
    Self.EditNode(SelectedNode, -1)
end;

function TBCFileTreeView.DeleteTreeNode(Node: PVirtualNode): Boolean;
var
  DelName: string;
  PrevNode, SelectedNode: PVirtualNode;
  Data: PBCFileTreeNodeRec;
begin
  Result := False;
  PrevNode := Node.Parent;
  SelectedNode := GetFirstSelected;
  if Assigned(Node) then
  try
    Screen.Cursor := crHourGlass;
    if Assigned(SelectedNode) then
    begin
      Data := GetNodeData(SelectedNode);
      if Data.FileType = ftDirectory then
        DelName := SelectedPath
      else
        DelName := SelectedFile;

      if DelName = '' then
        Exit;
      {$WARNINGS OFF} { ExcludeTrailingBackslash is specific to a platform }
      DelName := ExcludeTrailingBackslash(DelName);
      {$WARNINGS ON}

      if Data.FileType = ftDirectory then
        Result := RemoveDirectory(DelName)
      else
        Result := System.SysUtils.DeleteFile(DelName);
    end;
    if Result then
    begin
      if Assigned(PrevNode) then
        Selected[PrevNode] := True;
      DeleteNode(Node);
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TBCFileTreeView.DeleteSelectedNode;
var
  SelectedNode: PVirtualNode;
begin
  SelectedNode := GetFirstSelected;
  if Assigned(SelectedNode) then
    DeleteTreeNode(SelectedNode);
end;

function TBCFileTreeView.IsDirectoryEmpty(const Directory: string): Boolean;
var
  SearchRec :TSearchRec;
begin
  try
    Result := (FindFirst(directory+'\*.*', faAnyFile, searchRec) = 0) and
      (FindNext(searchRec) = 0) and (FindNext(searchRec) <> 0);
  finally
    System.SysUtils.FindClose(searchRec);
  end;
end;

procedure TBCFileTreeView.DoInitNode(Parent, Node: PVirtualNode; var InitStates: TVirtualNodeInitStates);
var
  Data: PBCFileTreeNodeRec;
begin
  inherited;
  Data := GetNodeData(Node);
  if Data.FileType = ftDirectory then
    if not IsDirectoryEmpty(Data.FullPath) then
      Include(InitStates, ivsHasChildren);
end;

procedure TBCFileTreeView.DoFreeNode(Node: PVirtualNode);
var
  Data: PBCFileTreeNodeRec;
begin
  inherited;
  Data := GetNodeData(Node);
  Finalize(Data^);
end;

procedure TBCFileTreeView.DoPaintNode(var PaintInfo: TVTPaintInfo);
var
  Data: PBCFileTreeNodeRec;
  S: UnicodeString;
  R: TRect;
  LStyles: TCustomStyleServices;
  LDetails: TThemedElementDetails;
  LColor: TColor;
begin
  inherited;
  LStyles := StyleServices;
  with PaintInfo do
  begin
    Data := GetNodeData(Node);
    if not Assigned(Data) then
      Exit;

    Canvas.Font.Color := clWindowText;
    Canvas.Font.Style := [];
    if LStyles.Enabled then
      Color := LStyles.GetStyleColor(scEdit);

    if LStyles.Enabled and (vsSelected in PaintInfo.Node.States) then
    begin
      R := ContentRect;
      R.Right := R.Left + NodeWidth;

      LDetails := LStyles.GetElementDetails(tgCellSelected);
      LStyles.DrawElement(Canvas.Handle, LDetails, R);
    end;

    if not LStyles.GetElementColor(LStyles.GetElementDetails(tgCellNormal), ecTextColor, LColor) or  (LColor = clNone) then
      LColor := LStyles.GetSystemColor(clWindowText);
    //get and set the background color
    Canvas.Brush.Color := LStyles.GetStyleColor(scEdit);
    Canvas.Font.Color := LColor;

    if LStyles.Enabled and (vsSelected in PaintInfo.Node.States) then
    begin
       Canvas.Brush.Color := LStyles.GetSystemColor(clHighlight);
       Canvas.Font.Color := LStyles.GetStyleFontColor(sfMenuItemTextSelected);// GetSystemColor(clHighlightText);
    end
    else
    if not LStyles.Enabled and (vsSelected in PaintInfo.Node.States) then
    begin
      Canvas.Brush.Color := clHighlight;
      Canvas.Font.Color := clHighlightText;
    end;
    Canvas.Font.Style := [];
    if (Data.FileType = ftDirectoryAccessDenied) or (Data.FileType = ftFileAccessDenied) then
    begin
      Canvas.Font.Style := [fsItalic];

      if LStyles.Enabled then
        Canvas.Font.Color := LStyles.GetStyleFontColor(sfMenuItemTextDisabled)
      else
        Canvas.Font.Color := clBtnFace;
    end;

    SetBKMode(Canvas.Handle, TRANSPARENT);

    R := ContentRect;
    InflateRect(R, -TextMargin, 0);
    Dec(R.Right);
    Dec(R.Bottom);

    S := Data.Filename;
    if Length(S) > 0 then
    begin
      with R do
      begin
        if (NodeWidth - 2 * Margin) > (Right - Left) then
          S := ShortenString(Canvas.Handle, S, Right - Left);
      end;
      DrawTextW(Canvas.Handle, PWideChar(S), Length(S), R, DT_TOP or DT_LEFT or DT_VCENTER or DT_SINGLELINE);
    end;
  end;
end;

function TBCFileTreeView.DoGetImageIndex(Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var Index: Integer): TCustomImageList;
var
  Data: PBCFileTreeNodeRec;
begin
  Result := inherited;
  if not Assigned(Result) then
  begin
    Data := GetNodeData(Node);
    if Assigned(Data) then
    case Kind of
      ikNormal,
      ikSelected:
        begin
          if Expanded[Node] then
            Index := Data.SelectedIndex
          else
            Index := Data.ImageIndex;
        end;
      ikOverlay:
        if FShowOverlayIcons then
          Index := Data.OverlayIndex
    end;
  end;
end;

function TBCFileTreeView.DoCompare(Node1, Node2: PVirtualNode; Column: TColumnIndex): Integer;
var
  Data1, Data2: PBCFileTreeNodeRec;
begin
  Result := inherited;

  if Result = 0 then
  begin
    Data1 := GetNodeData(Node1);
    Data2 := GetNodeData(Node2);

    Result := -1;

    if not Assigned(Data1) or not Assigned(Data2) then
      Exit;

   if Data1.FileType <> Data2.FileType then
    begin
     if (Data1.FileType = ftDirectory) or (Data1.FileType = ftDirectoryAccessDenied) then
       Result := -1
     else
       Result := 1;
    end
    else
      Result := AnsiCompareText(Data1.Filename, Data2.Filename);
  end;
end;

function TBCFileTreeView.DoGetNodeWidth(Node: PVirtualNode; Column: TColumnIndex; Canvas: TCanvas = nil): Integer;
var
  Data: PBCFileTreeNodeRec;
begin
  Result := inherited;
  Data := GetNodeData(Node);
  if Canvas = nil then
    Canvas := Self.Canvas;
  if Assigned(Data) then
    Result := Canvas.TextWidth(Trim(Data.FileName)) + 2 * TextMargin;
end;

procedure TBCFileTreeView.DoInitChildren(Node: PVirtualNode; var ChildCount: Cardinal);
var
  Data, ChildData: PBCFileTreeNodeRec;
  SR: TSearchRec;
  ChildNode: PVirtualNode;
  FName: String;
begin
  Data := GetNodeData(Node);

  {$WARNINGS OFF} { IncludeTrailingBackslash is specific to a platform }
  if FindFirst(IncludeTrailingBackslash(Data.FullPath) + '*.*', faAnyFile, SR) = 0 then
  {$WARNINGS OFF}
  begin
    Screen.Cursor := crHourGlass;
    try
      repeat
        {$WARNINGS OFF}
        if ((SR.Attr and faHidden <> 0) and not ShowHiddenFiles) or
          ((SR.Attr and faArchive <> 0) and not ShowArchiveFiles) or
          ((SR.Attr and faSysFile <> 0) and not ShowSystemFiles) then
          Continue;

        FName := IncludeTrailingBackslash(Data.FullPath) + SR.Name; //StrPas(Win32FD.cFileName);
        {$WARNINGS ON}
        if (SR.Name <> '.') and (SR.Name <> '..') then
          if (SR.Attr and faDirectory <> 0) or (GetFileType = '*.*') or IsExtInFileType(ExtractFileExt(SR.Name), GetFileType) then
          begin
            ChildNode := AddChild(Node);
            ChildData := GetNodeData(ChildNode);

            if (SR.Attr and faDirectory <> 0) then
            begin
              ChildData.FileType := ftDirectory;
              {$WARNINGS OFF}
              ChildData.FullPath := IncludeTrailingBackslash(FName);
              {$WARNINGS ON}
            end
            else
            begin
              ChildData.FileType := ftFile;
              {$WARNINGS OFF}
              ChildData.FullPath := IncludeTrailingBackslash(Data.FullPath);
              {$WARNINGS ON}
            end;
            if not CheckAccessToFile(FILE_GENERIC_READ, ChildData.FullPath) then
            begin
              if ChildData.FileType = ftDirectory then
                ChildData.FileType := ftDirectoryAccessDenied
              else
                ChildData.FileType := ftFileAccessDenied;
            end;
            ChildData.Filename := SR.Name;
            ChildData.ImageIndex := GetAImageIndex(FName);
            ChildData.SelectedIndex := GetSelectedIndex(FName);
            ChildData.OverlayIndex := GetIconOverlayIndex(FName);
            ValidateNode(Node, False);
          end;
      until FindNext(SR) <> 0;

      ChildCount := Self.ChildCount[Node];

      if ChildCount > 0 then
        Sort(Node, 0, sdAscending, False);
    finally
      System.SysUtils.FindClose(SR);
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
  //FEdit.Free;
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
  end;
end;

function TEditLink.BeginEdit: Boolean;
var
  Data: PBCFileTreeNodeRec;
begin
  Data := FTree.GetNodeData(FNode);
  Result := (Data.FileType = ftDirectory) or (Data.FileType = ftFile);
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
  Data: PBCFileTreeNodeRec;
  Buffer: array[0..254] of Char;
  S, OldDirName, NewDirName, FullPath: UnicodeString;
begin
  Result := True;

  Data := FTree.GetNodeData(FNode);
  try
    GetWindowText(FEdit.Handle, Buffer, 255);
    S := Buffer;

    if (Length(S) = 0) or (StrContainsChar('\*?/="<>|:,;+^', S)) then
    begin
      MessageBeep(MB_ICONHAND);
      if Length(S) > 0 then
        MessageDlg(Format('%s %s', [LanguageDataModule.GetConstant('InvalidName'), S]), mtError, [mbOK], 0);
      Exit;
    end;

    if Data.FileType = ftDirectory then
    {$WARNINGS OFF}
      FullPath := ExtractFilePath(ExcludeTrailingBackslash(Data.FullPath))
    {$WARNINGS ON}
    else
      FullPath := Data.FullPath;
    OldDirName := FullPath + Data.Filename;
    NewDirName := FullPath + S;
    if OldDirName = NewDirName then
      Exit;
    if MessageDlg(Format(LanguageDataModule.GetConstant('Rename'), [ExtractFileName(OldDirName),
      ExtractFileName(NewDirName)]), mtConfirmation, [mbYes, mbNo], 0) = mrNo then
      Exit;
    FTree.SetFocus;
    if System.SysUtils.RenameFile(OldDirName, NewDirName) then
    begin
      if S <> Data.FileName then
      begin
        Data.FileName := S;
        FTree.InvalidateNode(FNode);
      end;
    end
    else
      ShowMessage(Format('%s rename failed.', [OldDirName]));
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
  Data: PBCFileTreeNodeRec;
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
  Data := FTree.GetNodeData(Node);

  FEdit := TBCEdit.Create(nil);
  with FEdit do
  begin
    Visible := False;
    Parent := Tree;
    FEdit.Font.Name := FTree.Canvas.Font.Name;
    FEdit.Font.Size := FTree.Canvas.Font.Size;
    Text := Data.FileName;
    OnKeyPress := EditKeyPress;
  end;
end;

procedure TEditLink.ProcessMessage(var Message: TMessage);
begin
  FEdit.WindowProc(Message);
end;

procedure TEditLink.SetBounds(R: TRect);
var
  Dummy: Integer;
begin
  // Since we don't want to activate grid extensions in the tree (this would influence how the selection is drawn)
  // we have to set the edit's width explicitly to the width of the column.
  FTree.Header.Columns.GetColumnBounds(FColumn, Dummy, R.Right);
  FEdit.BoundsRect := R;
end;

end.

