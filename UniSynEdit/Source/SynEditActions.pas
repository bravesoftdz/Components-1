{-------------------------------------------------------------------------------

   单元: SynEditActions.pas

   作者: 姚乔锋

   日期: 2004.11.26

   说明: 一些关于SynEdit的动作

   版本: 1.00

-------------------------------------------------------------------------------}


unit SynEditActions;

interface

{$I Synedit.inc}

uses
  Windows, Classes, Clipbrd, Forms, Controls, SysUtils, Dialogs, Graphics,
  SynEdit, SynMemo, SynEditTextBuffer, SynEditHighlighter, SynEditPrint,
  SynEditExport, SynEditTypes, SynEditKeyCmds, SynEditMiscClasses, ActnList,
  SynEditMiscProcs, SynMsgDialog, SynEditStrRes, SynEditSearcher, SynEditor,
  SynExportHTML, SynExportRTF, SynExportTeX, SynUniHighlighter, Printers,
  SynEditSource, IniFiles, SynCompletionProposal,
  SynUniFormatNativeXml20, SimpleXML, SynUniFormatNativeXml,
  {$IFDEF SPELLCHECK}
  SynSpellCheck,
  {$ENDIF}
  SynAutoCorrect;

type

  TSynCustomManager = class;

  TSynHighlighterItem = class(TCollectionItem)
  private
    FHighlighter: TSynCustomHighlighter;
    FCodeTemplate: TSynAutoComplete;
    FCodeInsight : TSynCompletionProposal;
    FFileName: string;
    FLoad : Boolean;
    FFullFileName : string;
    procedure SetHighlighter(const Value: TSynCustomHighlighter);
    procedure setCodeTemplate(const Value: TSynAutoComplete);
    procedure setCodeInsight(const Value: TSynCompletionProposal);
  protected
    function GetDisplayName: string; override;
  public
    procedure Assign(Source: TPersistent); override;
    procedure Load;
  published
    property FileName : string read FFileName write FFilename;
    property CodeInsight : TSynCompletionProposal read fCodeInsight write setCodeInsight;
    property CodeTemplate : TSynAutoComplete read fCodeTemplate write setCodeTemplate;
    property Highlighter : TSynCustomHighlighter read FHighlighter write SetHighlighter;
  end;

  TSynHighlighters = class(TCollection)
  private
    FManager : TSynCustomManager;
    FDefaultLanguage: string;
    function GetHighlighter(Index: Integer): TSynCustomHighlighter;
    procedure SetHighlighter(Index: Integer;
      const Value: TSynCustomHighlighter);
    function GetDefaultLanguageIndex: Integer;
    function GetItem(Index: Integer): TSynHighlighterItem;
    procedure SetItem(Index: Integer; const Value: TSynHighlighterItem);
  public
    procedure HighlighterAssignTo(Editor : TCustomSynEdit; NewIndex : Integer);
    function IndexOfFileName(FileName : string): Integer;
    function IndexOfLanguage(Language : string): Integer;
    procedure RemoveHighlighter(Highlighter: TSynCustomHighlighter);
    property Items[Index: Integer]: TSynHighlighterItem read GetItem write SetItem;
    property Highlighters[Index: Integer]: TSynCustomHighlighter read GetHighlighter write SetHighlighter;
    property DefaultLanguageIndex: Integer read GetDefaultLanguageIndex;
  published
    property DefaultLanguage: string read FDefaultLanguage write FDefaultLanguage;
  end;

  TSynManagerEditorEvent = procedure(Sender : TObject; index : Integer) of object;
  TSynManagerCreateIniEvent = procedure(Sender : TObject; const FileName : string;
    var Ini : TCustomIniFile) of object;

  TSynCustomManager = class(TComponent)
  private
    FSynEditors : TStrings;
    FOnAddEditor : TSynManagerEditorEvent;
    FOnDeleteEditor : TSynManagerEditorEvent;
    FSynEditor: TCustomSynEditor;

    FHighlighters: TSynHighlighters;
    FHighlightersPath: string;

    FFilter: string;

    fAutoCorrect : TSynAutoCorrect;
    FAutoCorrectIni : string;
    fAutoCorrectLoad : Boolean;

    FEditorSourceIni: string;
    FEditorSource: TSynEditSource;
    fEditorSourceLoad : Boolean;

    fOnCreateIniFile: TSynManagerCreateIniEvent;

    {$IFDEF SPELLCHECK}
    FSpellCheckIni: string;
    fSpellCheck : TSynSpellCheck;
    fSpellCheckLoad : Boolean;
    {$ENDIF}

    FLoaded : Boolean;
    FAutoLoad: Boolean;
    FAutoSave: Boolean;

    function GetSynEditorCount: integer;
    function GetSynEditors(Index: integer): TCustomSynEditor;
    procedure SetSynEditor(const Value: TCustomSynEditor);
    procedure SetEditorSource(const Value: TSynEditSource);
    procedure SetHighlighters(const Value: TSynHighlighters);
    procedure SetAutoCorrect(const Value: TSynAutoCorrect);
    {$IFDEF SPELLCHECK}
    procedure SetSpellCheck(const Value: TSynSpellCheck);
    {$ENDIF}
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure Loaded; override;
  public
    constructor Create(AOwner : TComponent); override;
    procedure BeforeDestruction; override;
    destructor Destroy; override;

    property AutoLoad : Boolean read FAutoLoad write FAutoLoad;
    property AutoSave : Boolean read FAutoSave write FAutoSave;

    property AutoCorrect : TSynAutoCorrect read fAutoCorrect write SetAutoCorrect;
    {$IFDEF SPELLCHECK}
    property SpellCheck : TSynSpellCheck read fSpellCheck write SetSpellCheck;
    {$ENDIF}
    property SynEditor : TCustomSynEditor read FSynEditor write SetSynEditor;
    property EditorSource : TSynEditSource read FEditorSource write SetEditorSource;
    property Highlighters : TSynHighlighters read FHighlighters write SetHighlighters;

    function GetFilters: string;
    property Filter : string read FFilter write FFilter;

    property Editors[Index : integer] : TCustomSynEditor read GetSynEditors;
    property EditorCount : integer read GetSynEditorCount;
    function AddEditor(SynEditor : TCustomSynEditor): integer;
    procedure DeleteEditor(SynEditor : TCustomSynEditor);
    property OnAddEditor : TSynManagerEditorEvent read FOnAddEditor write FOnAddEditor;
    property OnDeleteEditor : TSynManagerEditorEvent read FOnDeleteEditor write FOnDeleteEditor;

    procedure Load;
    procedure Save;
    function CreateIniFile(FileName : string) : TCustomIniFile;
    property HighlightersPath: string read FHighlightersPath write FHighlightersPath;
    procedure SaveHighlighters(Dir : string);
    procedure LoadHighlighters(Dir : string);
    property EditorSourceIni: string read FEditorSourceIni write FEditorSourceIni;
    procedure SaveEditorSource(FileName : string);
    procedure LoadEditorSource(FileName : string);
    property AutoCorrectIni: string read FAutoCorrectIni write FAutoCorrectIni;
    procedure SaveAutoCorrect(FileName : string);
    procedure LoadAutoCorrect(FileName : string);
    {$IFDEF SPELLCHECK}
    property SpellCheckIni: string read FSpellCheckIni write FSpellCheckIni;
    procedure SaveSpellCheck(FileName : string);
    procedure LoadSpellCheck(FileName : string);
    {$ENDIF}
    property OnCreateIniFile : TSynManagerCreateIniEvent read fOnCreateIniFile write fOnCreateIniFile;
  end;

  TSynManager = class(TSynCustomManager)
  published
    property AutoLoad;
    property AutoSave;
    property AutoCorrect;
    property AutoCorrectIni;
    {$IFDEF SPELLCHECK}
    property SpellCheck;
    property SpellCheckIni;
    {$ENDIF}
    property Highlighters;
    property HighlightersPath;
    property EditorSource;
    property EditorSourceIni;
    property Filter;
    property SynEditor;
    property OnAddEditor;
    property OnDeleteEditor;
    property OnCreateIniFile;
  end;

  TSynBaseAction = class(TCustomAction)
  public
    constructor Create(AOwner: TComponent); override;
    function HandlesTarget(Target: TObject): Boolean; override;
    procedure UpdateTarget(Target: TObject); override;
  published
    property AutoCheck;
    property Caption;
    property Checked;
    property Enabled;
    property GroupIndex;
    property HelpContext;
    property HelpKeyword;
    property HelpType;
    property Hint;
    property ImageIndex;
    property ShortCut;
    property SecondaryShortCuts;
    property Visible;
    property OnHint;
  end;

  TSynCustomAction = class(TSynBaseAction)
  private
    FSynEdit: TCustomSynEditor;
    procedure SetSynEdit(const Value: TCustomSynEditor);
  protected
    FActiveSynEdit : TCustomSynEditor;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    function SynEditAllocated(Target: TObject) : Boolean;
  public
    function HandlesTarget(Target: TObject): Boolean; override;
  published
    property SynEdit : TCustomSynEditor read FSynEdit write SetSynEdit;
  end;

  TSynAction = class(TAction)
  public
    function HandlesTarget(Target: TObject): Boolean; override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TSynEditExecuteEvent =
    procedure(Sender : TObject; SynEdit : TCustomSynEdit) of object;

  TSynEditUpdateEvent =
    function (Sender : TObject; SynEdit : TCustomSynEdit): Boolean of object;

  TSynEditAction = class(TSynCustomAction)
  private
    FOnExecute: TSynEditExecuteEvent;
    FOnUpdate: TSynEditUpdateEvent;
  public
    function HandlesTarget(Target: TObject): Boolean; override;
    procedure ExecuteTarget(Target: TObject); override;
  published
    property OnUpdate : TSynEditUpdateEvent read FOnUpdate write FOnUpdate;
    property OnExecute : TSynEditExecuteEvent read FOnExecute write FOnExecute;
  end;

  TSynChangeAction = class(TSynCustomAction)
  public
    function HandlesTarget(Target: TObject): Boolean; override;
  end;

  TSynChangeSelectAction = class(TSynCustomAction)
  public
    function HandlesTarget(Target: TObject): Boolean; override;
  end;

  TaSynReadOnly = class(TSynCustomAction)
  public
    procedure UpdateTarget(Target: TObject); override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynNormalSelect = class(TSynCustomAction)
  public
    procedure UpdateTarget(Target: TObject); override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynColumnSelect = class(TSynCustomAction)
  public
    procedure UpdateTarget(Target: TObject); override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynLineSelect = class(TSynCustomAction)
  public
    procedure UpdateTarget(Target: TObject); override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  //说明 执行synedit的undo(撒消)功能
  TaSynUndo = class(TSynCustomAction)
  public
    function HandlesTarget(Target: TObject): Boolean; override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  //说明 执行synedit的redo(重做)功能
  TaSynRedo = class(TSynCustomAction)
  public
    function HandlesTarget(Target: TObject): Boolean; override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  //说明 执行synedit的Cut(剪切)功能
  TaSynCut = class(TSynChangeSelectAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynAppendCut = class(TSynChangeSelectAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  //说明 执行synedit的Copy(复制)功能
  TaSynCopy = class(TSynCustomAction)
  public
    function HandlesTarget(Target: TObject): Boolean; override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynAppendCopy = class(TSynCustomAction)
  public
    function HandlesTarget(Target: TObject): Boolean; override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  //说明 执行synedit的Paste(粘贴)功能
  TaSynPaste = class(TSynCustomAction)
  public
    function HandlesTarget(Target: TObject): Boolean; override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  //删除下一个字符，相当于按delete键
  TaSynDeleteNextchar = class(TSynChangeAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  //删除上一个字符，相当于按BackSpace键
  TaSynDeleteLastChar = class(TSynChangeAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  //删除到当前词的词尾处
  TaSynDeleteWordToEnd = class(TSynChangeAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  //删除到当前词的词首处
  TaSynDeleteWordToStart = class(TSynChangeAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  //删除当前光标处的词
  TaSynDeleteWord = class(TSynChangeAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  //删除到当前行的行尾处
  TaSynDeleteLineToEnd = class(TSynChangeAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  //删除到当前行的行首处
  TaSynDeleteLineToStart = class(TSynChangeAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  //删除当前光标处的行
  TaSynDeleteLine = class(TSynChangeAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  //清除全部内容
  TaSynClearAll = class(TSynChangeAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  //选择全部
  TaSynSelectAll = class(TSynCustomAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  //选择当前行
  TaSynSelectLine = class(TSynCustomAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  //选择下一行
  TaSynSelectNextLine = class(TSynCustomAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  //选择上一行
  TaSynSelectLastLine = class(TSynCustomAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  //选择当前光标处的词
  TaSynSelectWrod = class(TSynCustomAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  //选择光标后下一个词
  TaSynSelectNextWord = class(TSynCustomAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  //选择光标前上一个词
  TaSynSelectLastWord = class(TSynCustomAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynGotoBookmark = class(TSynCustomAction)
  private
    fBookmark: Integer;
  public
    procedure ExecuteTarget(Target: TObject); override;
  published
    property Bookmark : Integer read fBookmark write FBookmark;
  end;

  TaSynSetBookmark = class(TSynCustomAction)
  private
    fBookmark: Integer;
  public
    procedure ExecuteTarget(Target: TObject); override;
  published
    property Bookmark : Integer read fBookmark write FBookmark;
  end;

  //清除书签，当指定书签号小于0则清除所有书签
  TaSynClearBookmark = class(TSynCustomAction)
  private
    fBookmark: Integer;
  public
    procedure ExecuteTarget(Target: TObject); override;
  published
    property Bookmark : Integer read fBookmark write FBookmark;
  end;

  TaSynGotoLastChange = class(TSynCustomAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynMatchBracket = class(TSynCustomAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynCommentBlock = class(TSynCustomAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynFind = class(TSynCustomAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynFindNext = class(TSynCustomAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynFindLast = class(TSynCustomAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynFindNextWord = class(TSynCustomAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynFindLastWord = class(TSynCustomAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynReplace = class(TSynChangeAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynReplaceNext = class(TSynChangeAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynReplaceLast = class(TSynChangeAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynUpperCase = class(TSynChangeAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynLowerCase = class(TSynChangeAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynToggleCase = class(TSynChangeAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynTitleCase = class(TSynChangeAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynBlockIndent = class(TSynChangeAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynBlockUnindent = class(TSynChangeAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynInsertLine = class(TSynChangeAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynLineBreak = class(TSynChangeAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynFileFormatDos = class(TSynCustomAction)
  public
    procedure UpdateTarget(Target: TObject); override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynFileFormatMac = class(TSynCustomAction)
  public
    procedure UpdateTarget(Target: TObject); override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynFileFormatUnix = class(TSynCustomAction)
  public
    procedure UpdateTarget(Target: TObject); override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynCustomPrint = class(TSynCustomAction)
  private
    fPrint: TSynEditPrint;
    procedure SetPrint(const Value: TSynEditPrint);
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    function HandlesTarget(Target: TObject): Boolean; override;
  published
    property Print : TSynEditPrint read fPrint write SetPrint;
  end;

  TaSynJump = class(TSynCustomAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynPrint = class(TaSynCustomPrint)
  public
    function HandlesTarget(Target: TObject): Boolean; override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynQuickPrint = class(TaSynCustomPrint)
  public
    function HandlesTarget(Target: TObject): Boolean; override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynPageSetup = class(TaSynCustomPrint)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynPreview = class(TaSynCustomPrint)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynExporter = class(TSynCustomAction)
  private
    fExporter: TSynCustomExporter;
    procedure SetExporter(const Value: TSynCustomExporter);
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    procedure ExecuteTarget(Target: TObject); override;
  published
    property Exporter : TSynCustomExporter read fExporter write SetExporter;
  end;

  TaSynSave = class(TSynCustomAction)
  private
    fSaveDialogTitle: string;
    fSaveDialogOptions: TOpenOptions;
  protected
    function Save(Savedialog : TSaveDialog) : boolean; virtual;
  public
    constructor Create(AOwner : TComponent); override;
    procedure ExecuteTarget(Target: TObject); override;
  published
    property SaveDialogTitle : string read fSaveDialogTitle
      write FSaveDialogTitle;
    property SaveDialogOptions : TOpenOptions read fSaveDialogOptions
      write fSaveDialogOptions;
  end;

  TaSynSaveAll = class(TSynBaseAction)
  private
    fSaveDialogTitle: string;
    fSaveDialogOptions: TOpenOptions;
  public
    constructor Create(AOwner : TComponent); override;
    function HandlesTarget(Target: TObject): Boolean; override;
    procedure ExecuteTarget(Target: TObject); override;
  published
    property SaveDialogTitle : string read fSaveDialogTitle
      write FSaveDialogTitle;
    property SaveDialogOptions : TOpenOptions read fSaveDialogOptions
      write fSaveDialogOptions;
  end;

  TaSynSaveAs = class(TaSynSave)
  protected
    function Save(Savedialog : TSaveDialog) : boolean; override;
  end;

  TaSynSaveSel = class(TaSynSave)
  protected
    function Save(Savedialog : TSaveDialog) : boolean; override;
  public
    function HandlesTarget(Target: TObject): Boolean; override;
  end;

  TSynCloseEvent =
    procedure(Sender: TObject; Editor : TCustomSynEditor) of object;

  TaSynClose = class(TSynCustomAction)
  private
    fSaveDialogTitle: string;
    fSaveDialogOptions: TOpenOptions;
    FOnClose: TSynCloseEvent;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    function CanClose(SynEditor : TCustomSynEditor): Boolean;
    procedure ExecuteTarget(Target: TObject); override;
  published
    property SaveDialogTitle : string read fSaveDialogTitle
      write FSaveDialogTitle;
    property SaveDialogOptions : TOpenOptions read fSaveDialogOptions
      write fSaveDialogOptions;
    property OnClose : TSynCloseEvent read FOnClose write FOnClose;
  end;

  TaSynCloseAll = class(TaSynSaveAll)
  private
    FOnClose: TSynCloseEvent;
  public
    function CanCloseAll: Boolean;
    procedure ExecuteTarget(Target: TObject); override;
  published
    property OnClose : TSynCloseEvent read FOnClose write FOnClose;
  end;

  TSynCreateEditorEvent =
    procedure(Sender : TObject; var Editor : TCustomSynEditor)of object;

  TaSynNew = class(TSynBaseAction)
  private
    FNewCount : integer;
    fDocumentName: string;
    FOnCreateEditor: TSynCreateEditorEvent;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure ExecuteTarget(Target: TObject); override;
    function GetNewDocName: string;
  published
    property DocumentName : string read fDocumentName write fDocumentName;
    property OnCreateEditor : TSynCreateEditorEvent read FOnCreateEditor
      write FOnCreateEditor;
  end;

  TaSynOpen = class(TSynBaseAction)
  private
    fOpenDialogOptions: TOpenOptions;
    fOpenDialogTitle: string;
    FOnCreateEditor: TSynCreateEditorEvent;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    function OpenDocument(Document : string) : TCustomSynEditor;
    procedure ExecuteTarget(Target: TObject); override;
  published
    property OpenDialogTitle : string read fOpenDialogTitle
      write FOpenDialogTitle;
    property OpenDialogOptions : TOpenOptions read fOpenDialogOptions
      write fOpenDialogOptions;
    property OnCreateEditor : TSynCreateEditorEvent read FOnCreateEditor
      write FOnCreateEditor;
  end;

  TaSynInsertFile = class(TSynChangeAction)
  private
    fOpenDialogTitle: string;
  public
    procedure ExecuteTarget(Target: TObject); override;
  published
    property OpenDialogTitle : string read fOpenDialogTitle
      write FOpenDialogTitle;
  end;

  TaSynOptionsSetting = class(TSynCustomAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynToggleHighlighter = class(TSynCustomAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynSpellCheckOptions = class(TSynCustomAction)
  private
    function HandlesTarget(Target: TObject): Boolean; override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynSpellCheck = class(TSynCustomAction)
  private
    FCheckWordDlg : TForm;
    FAutoCheckWord : TStrings;
    procedure SpellCheckWord(Sender: TObject; AWord: string;
      ASuggestions: TStringList; var ACorrectWord: string;
      var AAction: Integer; const AUndoEnabled: Boolean);
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    function HandlesTarget(Target: TObject): Boolean; override;
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TaSynHighlighterSetting = class(TSynAction)
  public
    procedure ExecuteTarget(Target: TObject); override;
  end;

  TSynEditorsEvent= class(TComponent)
  private
    fOnContextHelp: TContextHelpEvent;
    fOnDropFiles: TDropFilesEvent;
    fOnGutterClick: TGutterClickEvent;
    fOnGutterGetText: TGutterGetTextEvent;
    fOnGutterPaint: TGutterPaintEvent;
    fOnMouseCursor: TMouseCursorEvent;
    FOnChange: TNotifyEvent;
    FOnCloseDocument: TNotifyEvent;
    fOnPaint: TPaintEvent;
    fOnPaintTransient: TPaintTransient;
    FOnPlaceMark: TPlaceMarkEvent;
    fOnClearMark: TPlaceMarkEvent;
    FOnProcessCommand: TProcessCommandEvent;
    FOnProcessUserCommand: TProcessCommandEvent;
    fOnCommandProcessed: TProcessCommandEvent;
    fOnReplaceText: TReplaceTextEvent;
    fOnScroll: TScrollEvent;
    fOnSpecialLineColors: TSpecialLineColorsEvent;
    fOnStatusChange: TStatusChangeEvent;
    FOnSaveDocument: TSynDocumentEvent;
    FOnLoadDocument: TSynDocumentEvent;
    FOnDragDrop: TDragDropEvent;
    FOnDragOver: TDragOverEvent;
{$IFDEF SYN_CLX}
{$ELSE}
{$IFDEF SYN_COMPILER_4_UP}
    FOnEndDock: TEndDragEvent;
    FOnStartDock: TStartDockEvent;
{$ENDIF}
{$ENDIF}
    FOnEndDrag: TEndDragEvent;
    FOnKeyDown: TKeyEvent;
    FOnKeyUp: TKeyEvent;
    FOnKeyPress: TKeyPressEvent;
    FOnMouseUp: TMouseEvent;
    FOnMouseDown: TMouseEvent;
    FOnMouseMove: TMouseMoveEvent;
    FOnExit: TNotifyEvent;
    FOnClick: TNotifyEvent;
    FOnDblClick: TNotifyEvent;
    FOnEnter: TNotifyEvent;
    FOnStartDrag: TStartDragEvent;
    FDoCloseDocument: Boolean;
    FDoStatusChange: Boolean;
    FDoPaint: Boolean;
    FDoScroll: Boolean;
    FDoMouseMove: Boolean;
    FDoExit: Boolean;
    FDoMouseDown: Boolean;
    FDoGutterClick: Boolean;
    FDoDragOver: Boolean;
    FDoMouseUp: Boolean;
    FDoPaintTransient: Boolean;
    FDoStartDrag: Boolean;
    FDoKeyPress: Boolean;
    FDoGutterPaint: Boolean;
    FDoStartDock: Boolean;
    FDoCommandProcessed: Boolean;
    FDoProcessUserCommand: Boolean;
    FDoProcessCommand: Boolean;
    FDoLoadDocument: Boolean;
    FDoMouseCursor: Boolean;
    FDoSpecialLineColors: Boolean;
    FDoEnter: Boolean;
    FDoContextHelp: Boolean;
    FDoPlaceMark: Boolean;
    FDoKeyDown: Boolean;
    FDoChange: Boolean;
    FDoClearMark: Boolean;
    FDoDblClick: Boolean;
    FDoSaveDocument: Boolean;
    FDoDropFiles: Boolean;
    FDoGutterGetText: Boolean;
    FDoReplaceText: Boolean;
    FDoDragDrop: Boolean;
    FDoEndDock: Boolean;
    FDoKeyUp: Boolean;
    FDoEndDrag: Boolean;
    FDoClick: Boolean;
  public
    constructor Create(AOwner : TComponent);override;
    destructor destroy;override;
    procedure AssignTo(Edit : TSynEdit); 
  published

    property DoClick: Boolean read FDoClick write FDoClick;
    property DoDblClick: Boolean read FDoDblClick write FDoDblClick;
    property DoDragDrop: Boolean read FDoDragDrop write FDoDragDrop;
    property DoDragOver: Boolean read FDoDragOver write FDoDragOver;
{$IFDEF SYN_CLX}
{$ELSE}
{$IFDEF SYN_COMPILER_4_UP}
    property DoEndDock: Boolean read FDoEndDock write FDoEndDock;
    property DoStartDock: Boolean read FDoStartDock write FDoStartDock;
{$ENDIF}
{$ENDIF}
    property DoEndDrag: Boolean read FDoEndDrag write FDoEndDrag;
    property DoEnter: Boolean read FDoEnter write FDoEnter;
    property DoExit: Boolean read FDoExit write FDoExit;
    property DoKeyDown: Boolean read FDoKeyDown write FDoKeyDown;
    property DoKeyPress: Boolean read FDoKeyPress write FDoKeyPress;
    property DoKeyUp: Boolean read FDoKeyUp write FDoKeyUp;
    property DoMouseDown: Boolean read FDoMouseDown write FDoMouseDown;
    property DoMouseMove: Boolean read FDoMouseMove write FDoMouseMove;
    property DoMouseUp: Boolean read FDoMouseUp write FDoMouseUp;
    property DoStartDrag: Boolean read FDoStartDrag write FDoStartDrag;
    property DoLoadDocument : Boolean read FDoLoadDocument
      write FDoLoadDocument;
    property DoSaveDocument : Boolean read FDoSaveDocument
      write FDoSaveDocument;
    property DoCloseDocument : Boolean read FDoCloseDocument
      write FDoCloseDocument;
    property DoChange: Boolean read FDoChange write FDoChange;
    property DoClearBookmark: Boolean read FDoClearMark
      write FDoClearMark;
    property DoCommandProcessed: Boolean
      read FDoCommandProcessed write FDoCommandProcessed;
    property DoContextHelp: Boolean
      read FDoContextHelp write FDoContextHelp;
    property DoDropFiles: Boolean read FDoDropFiles write FDoDropFiles;
    property DoGutterClick: Boolean
      read FDoGutterClick write FDoGutterClick;
    property DoGutterGetText: Boolean read FDoGutterGetText
      write FDoGutterGetText;
    property DoGutterPaint: Boolean read FDoGutterPaint
      write FDoGutterPaint;
    property DoMouseCursor: Boolean read FDoMouseCursor
      write FDoMouseCursor;
    property DoPaint: Boolean read FDoPaint write FDoPaint;
    property DoPlaceBookmark: Boolean
      read FDoPlaceMark write FDoPlaceMark;
    property DoProcessCommand: Boolean
      read FDoProcessCommand write FDoProcessCommand;
    property DoProcessUserCommand: Boolean
      read FDoProcessUserCommand write FDoProcessUserCommand;
    property DoReplaceText: Boolean read FDoReplaceText
      write FDoReplaceText;
    property DoScroll: Boolean
      read FDoScroll write FDoScroll;
    property DoSpecialLineColors: Boolean
      read FDoSpecialLineColors write FDoSpecialLineColors;
    property DoStatusChange: Boolean
      read FDoStatusChange write FDoStatusChange;
    property DoPaintTransient: Boolean
      read FDoPaintTransient write FDoPaintTransient;

    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnDragDrop: TDragDropEvent read FOnDragDrop write FOnDragDrop;
    property OnDragOver: TDragOverEvent read FOnDragOver write FOnDragOver;
{$IFDEF SYN_CLX}
{$ELSE}
{$IFDEF SYN_COMPILER_4_UP}
    property OnEndDock: TEndDragEvent read FOnEndDock write FOnEndDock;
    property OnStartDock: TStartDockEvent read FOnStartDock write FOnStartDock;
{$ENDIF}
{$ENDIF}
    property OnEndDrag: TEndDragEvent read FOnEndDrag write FOnEndDrag;
    property OnEnter: TNotifyEvent read FOnEnter write FOnEnter;
    property OnExit: TNotifyEvent read FOnExit write FOnExit;
    property OnKeyDown: TKeyEvent read FOnKeyDown write FOnKeyDown;
    property OnKeyPress: TKeyPressEvent read FOnKeyPress write FOnKeyPress;
    property OnKeyUp: TKeyEvent read FOnKeyUp write FOnKeyUp;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
    property OnStartDrag: TStartDragEvent read FOnStartDrag write FOnStartDrag;

    property OnLoadDocument : TSynDocumentEvent read FOnLoadDocument
      write FOnLoadDocument;
    property OnSaveDocument : TSynDocumentEvent read FOnSaveDocument
      write FOnSaveDocument;
    property OnCloseDocument : TNotifyEvent read FOnCloseDocument
      write FOnCloseDocument;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClearBookmark: TPlaceMarkEvent read fOnClearMark
      write fOnClearMark;
    property OnCommandProcessed: TProcessCommandEvent
      read fOnCommandProcessed write fOnCommandProcessed;
    property OnContextHelp: TContextHelpEvent
      read fOnContextHelp write fOnContextHelp;
    property OnDropFiles: TDropFilesEvent read fOnDropFiles write fOnDropFiles;
    property OnGutterClick: TGutterClickEvent
      read fOnGutterClick write fOnGutterClick;
    property OnGutterGetText: TGutterGetTextEvent read fOnGutterGetText
      write fOnGutterGetText;
    property OnGutterPaint: TGutterPaintEvent read fOnGutterPaint
      write fOnGutterPaint;
    property OnMouseCursor: TMouseCursorEvent read fOnMouseCursor
      write fOnMouseCursor;
    property OnPaint: TPaintEvent read fOnPaint write fOnPaint;
    property OnPlaceBookmark: TPlaceMarkEvent
      read FOnPlaceMark write FOnPlaceMark;
    property OnProcessCommand: TProcessCommandEvent
      read FOnProcessCommand write FOnProcessCommand;
    property OnProcessUserCommand: TProcessCommandEvent
      read FOnProcessUserCommand write FOnProcessUserCommand;
    property OnReplaceText: TReplaceTextEvent read fOnReplaceText
      write fOnReplaceText;
    property OnScroll: TScrollEvent
      read fOnScroll write fOnScroll;
    property OnSpecialLineColors: TSpecialLineColorsEvent
      read fOnSpecialLineColors write fOnSpecialLineColors;
    property OnStatusChange: TStatusChangeEvent
      read fOnStatusChange write fOnStatusChange;
    property OnPaintTransient: TPaintTransient
      read fOnPaintTransient write fOnPaintTransient;
  end;

  TSynActionsEvent = class(TComponent)
  private
    FOnCloseEditor: TSynCloseEvent;
    FOnCreateEditor: TSynCreateEditorEvent;
    FOnActionsExecute: TSynEditExecuteEvent;
    FOnActionsUpdate: TSynEditUpdateEvent;
  public
    constructor Create(AOwner : TComponent);override;
    destructor destroy;override;
  published
    property OnActionsUpdate : TSynEditUpdateEvent read FOnActionsUpdate
      write FOnActionsUpdate;
    property OnActionsExecute : TSynEditExecuteEvent read FOnActionsExecute
      write FOnActionsExecute;
    property OnCreateEditor : TSynCreateEditorEvent read FOnCreateEditor
      write FOnCreateEditor;
    property OnCloseEditor : TSynCloseEvent read FOnCloseEditor
      write FOnCloseEditor;
  end;

var
  Manager : TSynCustomManager = nil;
  ActionsEvent : TSynActionsEvent = nil;
  EditorsEvent : TSynEditorsEvent = nil;

function ActiveSynEditor : TCustomSynEditor;
procedure ExecuteAction(Action : TSynCustomAction;
  SynEditor : TCustomSynEditor = nil);

implementation

uses
  SynPreviewDlg, SynPageSetupDlg, SynFindDlg, SynReplaceDlg, SynJumpDlg,
  SynOptionsDlg, SynToggleHighlighterDlg, SynSpellCheckDlg, SynSpellCheckOpDlg,
  SynHighlighterDlg;

var
  InitialDir : string;
  FilterIndex : Integer;

  aSynClose : TaSynClose;
  aSynNew : TaSynNew;
  aSynOpen: TaSynOpen;

procedure ExecuteAction(Action : TSynCustomAction;
  SynEditor : TCustomSynEditor = nil);
begin
  if SynEditor = nil then
    Action.ExecuteTarget(ActiveSynEditor)
  else
    Action.ExecuteTarget(SynEditor)
end;

function ActiveSynEditor : TCustomSynEditor;
var
  i : integer;
begin
  Result := nil;
  if Manager <> nil then
    for i := 0 to Manager.EditorCount-1 do
    begin
      if ((FocusSynEditor <> nil) and (Manager.Editors[i] = FocusSynEditor)) or
        (Manager.Editors[i].Focused) then
      begin
        result := Manager.Editors[i];
        exit;
      end;
    end;
end;

{ TSynCustomAction }

function TSynCustomAction.HandlesTarget(Target: TObject): Boolean;
begin
  result := SynEditAllocated(Target);
end;

procedure TSynCustomAction.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (AComponent = FSynEdit) and (Operation = opremove) then
    FSynEdit := nil;
end;

procedure TSynCustomAction.SetSynEdit(const Value: TCustomSynEditor);
begin
  if FSynEdit <> nil then
    FSynEdit.RemoveFreeNotification(self);
  FSynEdit := Value;
  if FSynEdit <> nil then
    FSynEdit.FreeNotification(self);
end;

function TSynCustomAction.SynEditAllocated(Target: TObject) : Boolean;
begin
  FActiveSynEdit := nil;
  if (FSynEdit <> nil) then
    FActiveSynEdit := FSynEdit
  else if (Manager <> nil) and (Manager.FSynEditor <> nil) then
    FActiveSynEdit := Manager.FSynEditor
  else if (Target <> nil) and (Target is TCustomSynEditor) then
    FActiveSynEdit := TCustomSynEditor(Target);
  Result := FActiveSynEdit <> nil;
end;

{ TSynEditUndo }

procedure TaSynUndo.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.Undo;
end;

function TaSynUndo.HandlesTarget(Target: TObject): Boolean;
begin
  result := SynEditAllocated(Target) and FActiveSynEdit.CanUndo;
end;

{ TSynEditRedo }

procedure TaSynRedo.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.Redo;
end;

function TaSynRedo.HandlesTarget(Target: TObject): Boolean;
begin
  result := SynEditAllocated(Target) and FActiveSynEdit.CanRedo;
end;

{ TSynEditCut }

procedure TaSynCut.ExecuteTarget(Target: TObject);
begin
  IF SynEditAllocated(Target) then
    FActiveSynEdit.CutToClipboard;
end;

{ TSynEditCopy }

procedure TaSynCopy.ExecuteTarget(Target: TObject);
begin
  If SynEditAllocated(Target) then
    FActiveSynEdit.CopyToClipboard;
end;

function TaSynCopy.HandlesTarget(Target: TObject): Boolean;
begin
  result := SynEditAllocated(Target) and FActiveSynEdit.SelAvail;
end;

{ TSynEditPaste }

procedure TaSynPaste.ExecuteTarget(Target: TObject);
begin
  If SynEditAllocated(Target) then
    FActiveSynEdit.PasteFromClipboard;
end;

function TaSynPaste.HandlesTarget(Target: TObject): Boolean;
begin
  result := SynEditAllocated(Target) and FActiveSynEdit.CanPaste;
end;

{ TSynEditAction }

procedure TSynEditAction.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) and Assigned(FOnExecute) then
    FOnExecute(Self, FActiveSynEdit)
  else if SynEditAllocated(Target) and (ActionsEvent <> nil) and
    Assigned(ActionsEvent.OnActionsExecute) then
    ActionsEvent.OnActionsExecute(Self, FActiveSynEdit)
end;

function TSynEditAction.HandlesTarget(Target: TObject): Boolean;
begin
  result := SynEditAllocated(Target);
  if SynEditAllocated(Target) and Assigned(FOnUpdate) then
    Result := FOnUpdate(Self, FActiveSynEdit)
  else if SynEditAllocated(Target) and (ActionsEvent <> nil) and
    Assigned(ActionsEvent.OnActionsUpdate) then
    Result := ActionsEvent.OnActionsUpdate(Self, FActiveSynEdit)
end;

{ TSynEditUpperCase }

procedure TaSynUpperCase.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecAutoUpperCase, #0, nil);
end;

{ TSynChangeAction }

function TSynChangeAction.HandlesTarget(Target: TObject): Boolean;
begin
  Result := SynEditAllocated(Target) and not FActiveSynEdit.ReadOnly;
end;

{ TSynEditLowerCase }

procedure TaSynLowerCase.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecAutoLowerCase, #0, nil);
end;

{ TSynEditToggleCase }

procedure TaSynToggleCase.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecAutoToggleCase, #0, nil);
end;

{ TSynEditTitleCase }

procedure TaSynTitleCase.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecAutoTitleCase, #0, nil);
end;

{ TSynEditFind }

procedure TaSynFind.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) and Assigned(FindDialogClass) then
    Searcher.Find(FActiveSynEdit);
end;

{ TSynEditFindNext }

procedure TaSynFindNext.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) and Assigned(FindDialogClass) then
    Searcher.FindNext(FActiveSynEdit);
end;

{ TSynEditFindLast }

procedure TaSynFindLast.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) and Assigned(FindDialogClass) then
    Searcher.FindLast(FActiveSynEdit);
end;

{ TSynEditFindNextWord }

procedure TaSynFindNextWord.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) and Assigned(FindDialogClass) then
    Searcher.FindNextForWord(FActiveSynEdit);
end;

{ TSynEditFindLastWord }

procedure TaSynFindLastWord.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) and Assigned(FindDialogClass) then
    Searcher.FindLastForWord(FActiveSynEdit);
end;

{ TSynEditReplace }

procedure TaSynReplace.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) and Assigned(ReplaceDialogClass) then
    Searcher.Replace(FActiveSynEdit);
end;

{ TSynEditReplaceNext }

procedure TaSynReplaceNext.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) and Assigned(ReplaceDialogClass) then
    Searcher.ReplaceNext(FActiveSynEdit);
end;

{ TSynEditReplaceLast }

procedure TaSynReplaceLast.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) and Assigned(ReplaceDialogClass) then
    Searcher.ReplaceLast(FActiveSynEdit);
end;

{ TSynEditGotoBookmark }

procedure TaSynGotoBookmark.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.GotoBookMark(fBookmark);
end;

{ TSynEditSetBookmark }

procedure TaSynSetBookmark.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecSetMarker0 + fBookmark, #0, nil);
end;

{ TSynEditClearBookmark }

procedure TaSynClearBookmark.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    if fBookmark >= 0 then
      FActiveSynEdit.ClearBookMark(fBookmark)
    else
      FActiveSynEdit.ExecuteCommand(ecClearMarkers, #0, nil);
end;

{ TSynEditIndent }

procedure TaSynBlockIndent.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
  begin
    if not FActiveSynEdit.SelAvail then
      FActiveSynEdit.ExecuteCommand(ecSelectLine, #0, nil);
    FActiveSynEdit.ExecuteCommand(ecBlockIndent, #0, nil);
  end;
end;

{ TSynEditUnindent }

procedure TaSynBlockUnindent.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
  begin
    if not FActiveSynEdit.SelAvail then
      FActiveSynEdit.ExecuteCommand(ecSelectLine, #0, nil);
    FActiveSynEdit.ExecuteCommand(ecBlockUnindent, #0, nil);
  end;
end;

{ TSynEditGotoLastChange }

procedure TaSynGotoLastChange.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecGotoLastChange, #0, nil);
end;

{ TSynEditMatchBracket }

procedure TaSynMatchBracket.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecMatchBracket, #0, nil);
end;

{ TSynEditCommentBlock }

procedure TaSynCommentBlock.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecCommentBlock, #0, nil);
end;

{ TaSynAppendCut }

procedure TaSynAppendCut.ExecuteTarget(Target: TObject);
begin
  IF SynEditAllocated(Target) then
  begin
    Clipboard.AsText := Clipboard.AsText + FActiveSynEdit.SelText;
    FActiveSynEdit.ClearSelection;
  end;
end;

{ TaSynAppendCopy }

procedure TaSynAppendCopy.ExecuteTarget(Target: TObject);
begin
  If SynEditAllocated(Target) then
    Clipboard.AsText := Clipboard.AsText + FActiveSynEdit.SelText
end;

function TaSynAppendCopy.HandlesTarget(Target: TObject): Boolean;
begin
  result := SynEditAllocated(Target) and FActiveSynEdit.SelAvail;
end;

{ TaSynDeleteNextchar }

procedure TaSynDeleteNextchar.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecDeleteChar, #0, nil);
end;

{ TaSynDeleteLastChar }

procedure TaSynDeleteLastChar.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecDeleteLastChar, #0, nil);
end;

{ TaSynDeleteWordToEnd }

procedure TaSynDeleteWordToEnd.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecDeleteWord, #0, nil);
end;

{ TaSynDeleteWordToStart }

procedure TaSynDeleteWordToStart.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecDeleteLastWord, #0, nil);
end;

{ TaSynDeleteCursorWord }

procedure TaSynDeleteWord.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecDeleteCursorWord, #0, nil);
end;

{ TaSynDeleteLineToEnd }

procedure TaSynDeleteLineToEnd.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecDeleteEOL, #0, nil);
end;

{ TaSynDeleteLineToStart }

procedure TaSynDeleteLineToStart.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecDeleteBOL, #0, nil);
end;

{ TaSynDeleteCursorLine }

procedure TaSynDeleteLine.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecDeleteLine, #0, nil);
end;

{ TaSynSelectAll }

procedure TaSynSelectAll.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.SelectAll;
end;

{ TaSynSelectLine }

procedure TaSynSelectLine.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecSelectLine, #0, nil);
end;

{ TaSynSelectNextLine }

procedure TaSynSelectNextLine.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecSelNextLine, #0, nil);
end;

{ TaSynSelectLastLine }

procedure TaSynSelectLastLine.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecSelPrevLine, #0, nil);
end;

{ TaSynSelectWrod }

procedure TaSynSelectWrod.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.SetSelWord;
end;

{ TaSynSelectNextWord }

procedure TaSynSelectNextWord.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecSelNextWord, #0, nil);
end;

{ TaSynSelectLastWord }

procedure TaSynSelectLastWord.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecSelPrevWord, #0, nil);
end;

{ TaSynClearAll }

procedure TaSynClearAll.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.Lines.Text := '';
end;

{ TaSynReadOnly }

procedure TaSynReadOnly.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ReadOnly := not Checked;
end;

procedure TaSynReadOnly.UpdateTarget(Target: TObject);
begin
  inherited;
  if SynEditAllocated(Target) then
    Checked := FActiveSynEdit.ReadOnly;
end;

{ TaSynNormalSelect }

procedure TaSynNormalSelect.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.SelectionMode := smNormal;
end;

procedure TaSynNormalSelect.UpdateTarget(Target: TObject);
begin
  inherited;
  if SynEditAllocated(Target) then
    Checked := FActiveSynEdit.SelectionMode = smNormal;
end;

{ TaSynColumnSelect }

procedure TaSynColumnSelect.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.SelectionMode := smColumn;
end;

procedure TaSynColumnSelect.UpdateTarget(Target: TObject);
begin
  inherited;
  if SynEditAllocated(Target) then
    Checked := FActiveSynEdit.SelectionMode = smColumn;
end;

{ TaSynLineSelect }

procedure TaSynLineSelect.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.SelectionMode := smLine;
end;

procedure TaSynLineSelect.UpdateTarget(Target: TObject);
begin
  inherited;
  if SynEditAllocated(Target) then
    Checked := FActiveSynEdit.SelectionMode = smLine;
end;

{ TaSynInsertLine }

procedure TaSynInsertLine.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecInsertLine, #0, nil);
end;

{ TaSynLineBreak }

procedure TaSynLineBreak.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExecuteCommand(ecLineBreak, #0, nil);
end;

{ TaSynFormatDos }

procedure TaSynFileFormatDos.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    TSynEditStringList(FActiveSynEdit.Lines).FileFormat := sffDos;
end;

procedure TaSynFileFormatDos.UpdateTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    Checked := TSynEditStringList(FActiveSynEdit.Lines).FileFormat = sffDos;
end;

{ TaSynFormatMac }

procedure TaSynFileFormatMac.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    TSynEditStringList(FActiveSynEdit.Lines).FileFormat := sffMac;
end;

procedure TaSynFileFormatMac.UpdateTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    Checked := TSynEditStringList(FActiveSynEdit.Lines).FileFormat = sffMac;
end;

{ TaSynFormatUnix }

procedure TaSynFileFormatUnix.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    TSynEditStringList(FActiveSynEdit.Lines).FileFormat := sffUnix;
end;

procedure TaSynFileFormatUnix.UpdateTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    Checked := TSynEditStringList(FActiveSynEdit.Lines).FileFormat = sffUnix;
end;

{ TaSynPrint }

procedure TaSynPrint.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) and (Print <> nil) and (Printer.Printers.Count > 0) then
    FActiveSynEdit.ExecuteCommand(ecPrint, '1', fPrint);
end;

function TaSynPrint.HandlesTarget(Target: TObject): Boolean;
begin
  result :=  SynEditAllocated(Target) and (Printer.Printers.Count > 0);
end;

{ TaSynQuickPrint }

procedure TaSynQuickPrint.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) and (Print <> nil) and (Printer.Printers.Count > 0) then
    FActiveSynEdit.ExecuteCommand(ecPrint, #0, fPrint);
end;

function TaSynQuickPrint.HandlesTarget(Target: TObject): Boolean;
begin
  result := SynEditAllocated(Target) and (Printer.Printers.Count > 0);
end;

{ TaSynExporter }

procedure TaSynExporter.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    FActiveSynEdit.ExportDocument('', fExporter, [doDefine]);
end;

procedure TaSynExporter.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (AComponent = fExporter) and (Operation = opRemove) then
    fExporter := nil; 
end;

procedure TaSynExporter.SetExporter(const Value: TSynCustomExporter);
begin
  if fExporter <> nil then
    fExporter.RemoveFreeNotification(self);
  fExporter := Value;
  if fExporter <> nil then
    fExporter.FreeNotification(self);
end;

{ TSynCustomManager }

function TSynCustomManager.AddEditor(SynEditor: TCustomSynEditor): integer;
begin
  result := -1;
  if FSynEditors.IndexOfObject(SynEditor) < 0 then
  begin
    result := FSynEditors.AddObject('', SynEditor);
    SynEditor.FreeNotification(self);
    if EditorsEvent <> nil then
      EditorsEvent.AssignTo(SynEditor);
    IF EditorSource <> nil then
      EditorSource.AssignTo(SynEditor);
    IF AutoCorrect <> nil then
      AutoCorrect.AddEditor(SynEditor);
//    {$IFDEF SPELLCHECK}
//    IF SpellCheck <> nil then
//      SpellCheck.AddEditor(SynEditor);
//    {$ENDIF}
    Highlighters.HighlighterAssignTo(SynEditor, Highlighters.DefaultLanguageIndex);
    if Assigned(FOnAddEditor) then
      FOnAddEditor(Self, Result);
  end;
end;

constructor TSynCustomManager.Create(AOwner: TComponent);
begin
  inherited;
  FSynEditors := TStringList.Create;
  FHighlighters := TSynHighlighters.Create(TSynHighlighterItem);
  FHighlighters.FManager := Self;
  Manager := Self;
end;

function TSynCustomManager.CreateIniFile(FileName : string): TCustomIniFile;
begin
  Result := nil;
  if Assigned(fOnCreateIniFile) then
    fOnCreateIniFile(self, FileName, Result);
  if not Assigned(Result) then
    Result := TIniFile.Create(FileName);
end;

function TSynHighlighters.GetDefaultLanguageIndex: Integer;
begin
  for Result := 0 to Count -1 do
    if LowerCase(Highlighters[Result].LanguageName) = LowerCase(FDefaultLanguage) then
      exit;
  Result := -1;
end;

procedure TSynCustomManager.DeleteEditor(SynEditor: TCustomSynEditor);
var
  i : integer;
begin
  i := FSynEditors.IndexOfObject(SynEditor);
  if i >= 0 then
  begin
    IF fAutoCorrect <> nil then
      fAutoCorrect.RemoveEditor(SynEditor);
    {$IFDEF SPELLCHECK}
    IF fSpellCheck <> nil then
      fSpellCheck.RemoveEditor(SynEditor);
    {$ENDIF}
    if Assigned(FOnDeleteEditor) then
      FOnDeleteEditor(Self, I);
    FSynEditors.Delete(i);
    SynEditor.RemoveFreeNotification(self);
  end;
end;

destructor TSynCustomManager.Destroy;
begin
  if Manager = self then
    Manager := nil;
  FSynEditors.Free;
  FHighlighters.Free;
  inherited;
end;

function TSynCustomManager.GetFilters: string;
var
  i : integer;
  s : string;
begin
  result := FFilter;
  if (Result <> '') and (Result[Length(Result)] <> '|') then
    Result := Result + '|';
  for I := 0 to Highlighters.count-1 do
  begin
    s := Highlighters.Highlighters[i].DefaultFilter;
    if s <> '' then
      result := result + s;
    if (Length(Result)>0) and (Result[Length(Result)] <> '|') then
      Result := Result + '|';
  end;
end;

function TSynCustomManager.GetSynEditorCount: integer;
begin
  result := FSynEditors.Count;
end;

function TSynCustomManager.GetSynEditors(Index: integer): TCustomSynEditor;
begin
  result := TCustomSynEditor(FSynEditors.Objects[Index]);
end;

procedure TSynCustomManager.Load;
begin
  if not (csDesigning in ComponentState) then
  begin
    SetCurrentDir(ExtractFileDir(ParamStr(0)));
    LoadHighlighters(HighlightersPath);
    if EditorSourceIni <> '' then
      LoadEditorSource(EditorSourceIni);
    if AutoCorrectIni <> '' then
      LoadAutoCorrect(AutoCorrectIni);
    {$IFDEF SPELLCHECK}
    if SpellCheckIni <> '' then
      LoadSpellCheck(SpellCheckIni);
    {$ENDIF}
  end;
end;

procedure TSynCustomManager.LoadAutoCorrect(FileName: string);
var
  IniFile : TCustomIniFile;
begin
  if FileName = '' then exit;
  FileName := ExpandFile(FileName);
  IniFile := CreateIniFile(FileName);
  try
    if Assigned(FAutoCorrect) then
    begin
      FAutoCorrect.LoadFromINI(IniFile, 'Auto Correct');
      fAutoCorrectLoad := true;
    end;
  finally
    IniFile.free;
  end;
end;

procedure TSynCustomManager.LoadEditorSource(FileName: string);
var
  IniFile : TCustomIniFile;
begin
  if FileName = '' then exit;
  FileName := ExpandFile(FileName);
  IniFile := CreateIniFile(FileName);
  try
    if Assigned(FEditorSource) and Assigned(IniFile) then
    begin
      FEditorSource.LoadFromIni(IniFile, 'Editor Store');
      fEditorSourceLoad := true;
    end;
  finally
    IniFile.free;
  end;
end;

procedure TSynCustomManager.LoadHighlighters(Dir: string);
var
  R : TSearchRec;
  F : Integer;
  I : Integer;

  function FindFileName(str : string): integer;
  begin
    for result := 0 to Highlighters.Count-1 do
      if LowerCase( Highlighters.Items[result].FileName) = LowerCase(str) then
        Exit;
    result := -1;
  end;
var
  XMLDocument : IXMLDocument;
  Ini : TCustomIniFile;
begin
  Dir := ExpandPath(Dir);
  XMLDocument := simpleXML.CreateXmlDocument('', '2.0');
  F := FindFirst(Dir + '*.xml', faDirectory, R);
  INI := nil;
  if FileExists(dir+'syntax.ini') then
    INI := CreateIniFile(dir+'syntax.ini');
//  L := TStringList.Create;
  try
    while F = 0 do
    begin
      I := FindFileName(R.Name);
      if i = -1 then
      begin
        with TSynHighlighterItem(Highlighters.Add) do
        begin
          Highlighter := TSynUniSyn.Create(Self);
          I := Index;
          FileName := R.Name;
        end;
      end;
      with Highlighters.Items[i] do
      begin
        FFullFileName := Dir + FileName;
        FLoad := False;
        if Highlighter is TSynUniSyn then
        begin
          if ini <> nil then
          begin
            TSynUniSyn(Highlighter).Info.General.Name :=
            ini.ReadString('syntax', R.Name +'.Name','');
            TSynUniSyn(Highlighter).Info.General.Extensions :=
            ini.ReadString('syntax', R.Name +'.Extensions','');
          end;
          if TSynUniSyn(Highlighter).Info.General.Name = '' then
          begin
            XMLDocument.Load(FFullFileName);
            with XMLDocument.DocumentElement do
              with EnsureChild('SyntaxColoring') do
                TSynUniFormatNativeXml20.ImportInfo(
                TSynUniSyn(Highlighter).Info, EnsureChild('Info'));
          end;
        end;
//        if FileExists(Dir + FileName) then
//          Highlighter.LoadFromFile(Dir + FileName);
        IF not Assigned(fCodeTemplate) then
          fCodeTemplate := TSynAutoComplete.Create(Self);
        IF not Assigned(fCodeInsight) then
          fCodeInsight := TSynCompletionProposal.Create(Self);
      end;
      F := FindNext(R);
    end;
  finally
    Ini.Free;
    FindClose(R);
  end;
end;

{$IFDEF SPELLCHECK}
procedure TSynCustomManager.LoadSpellCheck(FileName: string);
var
  IniFile : TCustomIniFile;
begin
  if FileName = '' then exit;
  FileName := ExpandFile(FileName);
  IniFile := CreateIniFile(FileName);
  try
    if Assigned(FSpellCheck) and Assigned(IniFile) then
    begin
      FSpellCheck.LoadFromIni(IniFile, 'Spell Check');
      fSpellCheckLoad := true;
    end;
  finally
    IniFile.free;
  end;
end;
{$ENDIF}

procedure TSynCustomManager.Notification(AComponent: TComponent;
  Operation: TOperation);
var
  I : Integer;
begin
  inherited;
  if (Operation = opRemove) then
    if (AComponent = FSynEditor) then
    begin
      FSynEditor := nil;
      DeleteEditor(TCustomSynEditor(AComponent));
    end else if (AComponent = fAutoCorrect) then
      fAutoCorrect := nil
    else if (AComponent = fSpellCheck) then
      fSpellCheck := nil
    else if (AComponent is TCustomSynEditor) then
      DeleteEditor(TCustomSynEditor(AComponent))
    else if (AComponent = FEditorSource) then
      FEditorSource := nil
    else if (AComponent is TSynCustomHighlighter) then
      Highlighters.RemoveHighlighter(TSynCustomHighlighter(AComponent))
    else if (AComponent is TSynAutoComplete) then
    begin
      for I := 0 to Highlighters.Count - 1 do
        if Highlighters.Items[i].CodeTemplate = AComponent then
          Highlighters.Items[i].CodeTemplate := nil;        
    end
    else if (AComponent is TSynCompletionProposal) then
    begin
      for I := 0 to Highlighters.Count - 1 do
        if Highlighters.Items[i].CodeInsight = AComponent then
          Highlighters.Items[i].CodeInsight := nil;        
    end
end;

procedure TSynCustomManager.Save;
begin
  if not (csDesigning in ComponentState) then
  begin
    SaveHighlighters(HighlightersPath);
    if EditorSourceIni <> '' then
      SaveEditorSource(EditorSourceIni);
    if AutoCorrectIni <> '' then
      SaveAutoCorrect(AutoCorrectIni);
    {$IFDEF SPELLCHECK}
    if SpellCheckIni <> '' then
      SaveSpellCheck(SpellCheckIni);
    {$ENDIF}
  end;
end;

procedure TSynCustomManager.SaveAutoCorrect(FileName: string);
var
  IniFile : TCustomIniFile;
begin
  if FileName = '' then exit;
  FileName := ExpandFile(FileName);
  IniFile := CreateIniFile(FileName);
  try
    if Assigned(FAutoCorrect) and Assigned(IniFile) then
      FAutoCorrect.SaveToIni(IniFile, 'Auto Correct');
  finally
    IniFile.free;
  end;
end;

procedure TSynCustomManager.SaveEditorSource(FileName: string);
var
  IniFile : TCustomIniFile;
begin
  if FileName = '' then exit;
  FileName := ExpandFile(FileName);
  IniFile := CreateIniFile(FileName);
  try
    if Assigned(FEditorSource) and Assigned(IniFile) then
      FEditorSource.SaveToIni(IniFile, 'Editor Store');
  finally
    IniFile.free;
  end;
end;

procedure TSynCustomManager.SaveHighlighters(Dir: string);
var
  I : integer;
  N : string;
  J : Integer;
  S : TStrings;
  INI : TCustomIniFile;
begin
  Dir := ExpandPath(Dir);
  INI := CreateIniFile(dir+'syntax.ini');
  try
    for I := 0 to Highlighters.Count-1 do
      with Highlighters.Items[i] do
      begin
        if highlighter is TSynUniSyn then
        begin
          INI.WriteString('syntax', FileName+'.Name',
          TSynUniSyn(Highlighter).Info.General.Name);
          INI.WriteString('syntax', FileName+'.Extensions',
          TSynUniSyn(Highlighter).Info.General.Extensions);
        end;

        if Not FLoad Then continue;

        N := Dir + FileName;
        Highlighter.SaveToFile(ChangeFileExt(N, '.xml'));

        S := TStringList.Create;
        try
          if Assigned(fCodeTemplate) then
          begin
            S.Add('[CodeTemplate]');
            s.AddStrings(CodeTemplate.AutoCompleteList);
            S.Add('');
          end;
          if Assigned(fCodeInsight) then
          begin
            S.Add('[CodeInsightItems]');
            s.AddStrings(CodeInsight.ItemList);
            S.Add('');
            S.Add('[CodeInsightInserts]');
            s.AddStrings(CodeInsight.InsertList);
            S.Add('');
          end;
          S.SaveToFile(ChangeFileExt(N, '.ini'));
        finally
          S.Free;
        end;  // try
      end;
  finally
    ini.Free;
  end;
end;

{$IFDEF SPELLCHECK}
procedure TSynCustomManager.SaveSpellCheck(FileName: string);
var
  IniFile : TCustomIniFile;
begin
  if FileName = '' then exit;
  FileName := ExpandFile(FileName);
  IniFile := CreateIniFile(FileName);
  try
    if Assigned(FSpellCheck) and Assigned(IniFile) then
    begin
      FSpellCheck.SaveToIni(IniFile, 'Spell Check');
      if fSpellCheck.OpenDictionary then
      begin
        fSpellCheck.SaveSkipList(fSpellCheck.UserDirectory +
          fSpellCheck.Language.Name + '.SkipWord.dic');
        fSpellCheck.SaveUserDictionary;
      end;
    end;
  finally
    IniFile.free;
  end;
end;
{$ENDIF}

procedure TSynCustomManager.SetEditorSource(const Value: TSynEditSource);
begin
  if FEditorSource <> nil then
    FEditorSource.RemoveFreeNotification(self);
  FEditorSource := Value;
  if FEditorSource <> nil then
  begin
    if not fEditorSourceLoad and FLoaded and (EditorSourceIni <> '') then
      LoadEditorSource(EditorSourceIni);
    FEditorSource.FreeNotification(self);
  end;
end;

procedure TSynCustomManager.SetAutoCorrect(const Value: TSynAutoCorrect);
begin
  if fAutoCorrect <> nil then
    fAutoCorrect.RemoveFreeNotification(Self);
  fAutoCorrect := value;
  if fAutoCorrect <> nil then
  begin
    if not fAutoCorrectLoad and FLoaded and (AutoCorrectIni <> '') then
      LoadAutoCorrect(AutoCorrectIni);
    fAutoCorrect.FreeNotification(Self);
  end;
end;

procedure TSynCustomManager.SetHighlighters(const Value: TSynHighlighters);
begin
  if value <> nil then
    FHighlighters.Assign(Value);
end;

{$IFDEF SPELLCHECK}
procedure TSynCustomManager.SetSpellCheck(const Value: TSynSpellCheck);
begin
  if fSpellCheck <> nil then
    fSpellCheck.RemoveFreeNotification(Self);
  fSpellCheck := value;
  if fSpellCheck <> nil then
  begin
    if not fSpellCheckLoad and FLoaded and (SpellCheckIni <> '') then
      LoadSpellCheck(SpellCheckIni);
    fSpellCheck.FreeNotification(Self)
  end;
end;
{$ENDIF}

procedure TSynCustomManager.SetSynEditor(const Value: TCustomSynEditor);
begin
  if FSynEditor <> nil then
    FSynEditor.RemoveFreeNotification(self);
  FSynEditor := Value;
  if FSynEditor <> nil then
    FSynEditor.FreeNotification(self);
end;

procedure TSynCustomManager.Loaded;
begin
  inherited;
  FLoaded := true;
  if AutoLoad then
    Load;
end;

procedure TSynCustomManager.BeforeDestruction;
begin
  if AutoSave then
    Save;
  inherited;
end;

{ TaSynSave }

constructor TaSynSave.Create(AOwner: TComponent);
begin
  inherited;
  fSaveDialogOptions := [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing];
end;

procedure TaSynSave.ExecuteTarget(Target: TObject);
var
  Savedialog : TSaveDialog;
begin
  if SynEditAllocated(Target) then
  begin
    savedialog := TSaveDialog.Create(self);
    try
      if (Manager <> nil) then
        savedialog.Filter := Manager.GetFilters;
      savedialog.InitialDir := InitialDir;
      savedialog.FilterIndex := FilterIndex;
      savedialog.Title := Format(fSaveDialogTitle, [FActiveSynEdit.DocumentName]);
      savedialog.Options := fSaveDialogOptions;
      if save(SaveDialog) then
      begin
        InitialDir := savedialog.InitialDir;
        FilterIndex := Savedialog.FilterIndex;
      end;
    finally
      savedialog.Free;
    end;
  end;
end;

function TaSynSave.Save(Savedialog : TSaveDialog) : boolean;
begin
  if FActiveSynEdit.DocumentState = smsNormal then
    result := FActiveSynEdit.SaveDocument(FActiveSynEdit.DocumentName,
      savedialog, [doDefine, doReset])
  else
    result := FActiveSynEdit.SaveDocument(FActiveSynEdit.DocumentName,
      SaveDialog, [doReset]);
end;

{ TaSynSaveAs }

function TaSynSaveAs.Save(Savedialog : TSaveDialog): boolean;
begin
  result := FActiveSynEdit.SaveDocument(FActiveSynEdit.DocumentName,
    savedialog, [doDefine, doReset])
end;

{ TaSynSaveSel }

function TaSynSaveSel.HandlesTarget(Target: TObject): Boolean;
begin
  Result := SynEditAllocated(Target) and FActiveSynEdit.SelAvail;
end;

function TaSynSaveSel.Save(Savedialog : TSaveDialog): boolean;
begin
  result := FActiveSynEdit.SaveDocument(FActiveSynEdit.DocumentName,
    savedialog, [doDefine, doSelection])
end;

{ TaSynSaveNew }

constructor TaSynNew.Create(AOwner: TComponent);
begin
  inherited;
  aSynNew := Self;
end;

destructor TaSynNew.Destroy;
begin
  if aSynNew = self then
    aSynNew := nil;
  inherited;
end;

procedure TaSynNew.ExecuteTarget(Target: TObject);
var
  editor : TCustomSynEditor;
begin
  if Assigned(OnCreateEditor) or
    ((ActionsEvent <> nil) and Assigned(ActionsEvent.OnCreateEditor)) then
  begin
    editor := nil;
    if Assigned(OnCreateEditor) then
      OnCreateEditor(Self, Editor);
    if (editor = nil) and ((ActionsEvent <> nil) and Assigned(ActionsEvent.OnCreateEditor)) then
      ActionsEvent.OnCreateEditor(Self, Editor);
    if editor <> nil then
    begin
      if (Manager <> nil) then
        Manager.AddEditor(Editor)
      else if EditorsEvent <> nil then
        EditorsEvent.AssignTo(editor);
      editor.DocumentName := GetNewDocName;
      editor.Reset;
    end;
  end;
end;

{ TSynBaseAction }

constructor TSynBaseAction.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DisableIfNoHandler := True;
end;

{ TaSynSaveOpen }

constructor TaSynOpen.Create(AOwner: TComponent);
begin
  inherited;
  fOpenDialogOptions := [ofHideReadOnly, ofEnableSizing];
  aSynOpen := self;
end;

destructor TaSynOpen.Destroy;
begin
  if aSynOpen = Self then
    aSynOpen := nil;
  inherited;
end;

procedure TaSynOpen.ExecuteTarget(Target: TObject);
var
  opendialog : TOpenDialog;
  i : integer;
begin
  if Assigned(OnCreateEditor) or
    ((ActionsEvent <> nil) and Assigned(ActionsEvent.OnCreateEditor)) then
  begin
    opendialog := TOpenDialog.Create(self);
    try
      opendialog.Title := fOpenDialogTitle;
      if (Manager <> nil) then
        opendialog.Filter := Manager.GetFilters;
      opendialog.Options := fOpenDialogOptions;
      opendialog.InitialDir := InitialDir;
      opendialog.FilterIndex := FilterIndex;
      if opendialog.Execute then
      begin
        for i := 0 to opendialog.Files.Count- 1 do
          OpenDocument(opendialog.Files[i]);
        InitialDir := opendialog.InitialDir;
        FilterIndex := opendialog.FilterIndex;
      end;
    finally
      opendialog.Free;
    end;
  end;
end;

function TSynBaseAction.HandlesTarget(Target: TObject): Boolean;
begin
  result := true;
end;

procedure TSynBaseAction.UpdateTarget(Target: TObject);
begin
  Enabled := true;
end;

{ TaSynInsertFile }

procedure TaSynInsertFile.ExecuteTarget(Target: TObject);
var
  opendialog : TOpenDialog;
begin
  if SynEditAllocated(Target) then
  begin
    opendialog := TOpenDialog.Create(self);
    try
      opendialog.Title := Format(fOpenDialogTitle, [FActiveSynEdit.DocumentName]);
      if (Manager <> nil) then
        opendialog.Filter := Manager.GetFilters;
      opendialog.InitialDir := InitialDir;
      opendialog.FilterIndex := FilterIndex;
      if FActiveSynEdit.LoadDocument('', opendialog, [doSelection, doDefine]) then
      begin
        InitialDir := opendialog.InitialDir;
        FilterIndex := opendialog.FilterIndex;
      end;
    finally
      opendialog.Free;
    end;
  end;
end;

{ TaSynCustomPrint }

function TaSynCustomPrint.HandlesTarget(Target: TObject): Boolean;
begin
  result := SynEditAllocated(Target) and (fPrint <> nil) and
    (Printer.Printers.Count > 0);
end;

procedure TaSynCustomPrint.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (AComponent = fPrint) and (Operation = OpRemove) then
    fPrint := nil; 
end;

procedure TaSynCustomPrint.SetPrint(const Value: TSynEditPrint);
begin
  if fPrint <> nil then
    fPrint.RemoveFreeNotification(Self);
  fPrint := Value;
  if fPrint <> nil then
    fPrint.FreeNotification(Self);
end;

{ TaSynPageSetup }

procedure TaSynPageSetup.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) and (Print <> nil) then
  begin
    Print.SynEdit := FActiveSynEdit;
    with TSynPageSetupDlg.Create(Self) do
    begin
      Execute(self.Print);
      Free;
    end;
  end;
end;

{ TaSynPreview }

procedure TaSynPreview.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) and (Print <> nil) then
  begin
    Print.SynEdit := FActiveSynEdit;
    with TSynPreviewDlg.Create(Self) do
    begin
      Execute(self.Print);
      Free;
    end;
  end;
end;

{ TaSynClose }

function TaSynClose.CanClose(SynEditor : TCustomSynEditor): Boolean;
var
  Savedialog : TSaveDialog;
begin
  Result := false;
  if SynEditor <> nil then
  begin
    savedialog := TSaveDialog.Create(self);
    try
      if (Manager <> nil) then
        savedialog.Filter := Manager.GetFilters;
      savedialog.InitialDir := InitialDir;
      Savedialog.FilterIndex := FilterIndex;
      savedialog.Title := Format(fSaveDialogTitle, [SynEditor.DocumentName]);
      savedialog.Options := fSaveDialogOptions;
      if SynEditor.CloseDocument(savedialog, true) then
      begin
        if (Manager <> nil) then Manager.DeleteEditor(SynEditor);
        InitialDir := savedialog.InitialDir;
        FilterIndex := Savedialog.FilterIndex;
        if Assigned(FOnClose) then
          FOnClose(Self, SynEditor)
        else if ((ActionsEvent<> nil) and Assigned(ActionsEvent.OnCloseEditor)) then
          ActionsEvent.OnCloseEditor(Self, SynEditor);
        Result := True;
      end;
    finally
      savedialog.Free;
    end;
  end;
end;

constructor TaSynClose.Create(AOwner: TComponent);
begin
  inherited;
  fSaveDialogOptions := [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing];
  aSynClose := self;
end;

destructor TaSynClose.Destroy;
begin
  if aSynClose = self then
    aSynClose := nil;
  inherited;
end;

procedure TaSynClose.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
    try
      CanClose(FActiveSynEdit);
    except
    end;
end;

{ TaSynJump }

procedure TaSynJump.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
  begin
    with TSynJumpDlg.Create(self) do
    begin
      Execute(FActiveSynEdit);
      free;
    end;
  end;
end;

{ TaSynSaveAll }

constructor TaSynSaveAll.Create(AOwner: TComponent);
begin
  inherited;
  fSaveDialogOptions := [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing];
end;

procedure TaSynSaveAll.ExecuteTarget(Target: TObject);
var
  Action : TaSynSave;
  i : Integer;
begin
  if (Manager <> nil) and (Manager.EditorCount > 0 ) then
  begin
    Action := TaSynSave.Create(self);
    Action.fSaveDialogTitle := fSaveDialogTitle;
    Action.fSaveDialogOptions := fSaveDialogOptions;
    for i := 0 to manager.EditorCount-1 do
    begin
      Action.SynEdit := Manager.Editors[i];
      Action.ExecuteTarget(nil);
    end;
    Action.Free;
  end;
end;

function TaSynSaveAll.HandlesTarget(Target: TObject): Boolean;
begin
  Result := (Manager <> nil) and (Manager.EditorCount > 0 );
end;

{ TaSynCloseAll }

function TaSynCloseAll.CanCloseAll: Boolean;
var
  Savedialog : TSaveDialog;
  SynEdit : TCustomSynEditor;
  i : Integer;
begin
  Result := False or ((Manager <> nil) and (Manager.EditorCount = 0));
  if (Manager <> nil) and (Manager.EditorCount > 0 ) then
  begin
    savedialog := TSaveDialog.Create(self);
    try
      savedialog.Filter := Manager.GetFilters;
      savedialog.InitialDir := InitialDir;
      Savedialog.FilterIndex := FilterIndex;
      savedialog.Options := fSaveDialogOptions;
      for i := manager.EditorCount-1 downto 0 do
      begin
        SynEdit := Manager.Editors[0];
        savedialog.Title := Format(fSaveDialogTitle, [SynEdit.DocumentName]);
        if SynEdit.CloseDocument(savedialog, true) then
        begin
          Manager.DeleteEditor(SynEdit);
          if Assigned(FOnClose) then
            FOnClose(Self, SynEdit)
          else if ((ActionsEvent<> nil) and Assigned(ActionsEvent.OnCloseEditor)) then
            ActionsEvent.OnCloseEditor(Self, SynEdit);
        end else Exit;
        SynEdit := nil;
      end;
      InitialDir := savedialog.InitialDir;
      FilterIndex := Savedialog.FilterIndex;
      result := true;
    finally
      savedialog.Free;
    end;
  end;
end;

procedure TaSynCloseAll.ExecuteTarget(Target: TObject);
begin
  try
    CanCloseAll;
  except
  end;
end;

{ TSynChangeSelectAction }

function TSynChangeSelectAction.HandlesTarget(Target: TObject): Boolean;
begin
  result := SynEditAllocated(Target) and FActiveSynEdit.SelAvail
    and not FActiveSynEdit.ReadOnly;
end;

{ TaSynOptionsSetting }

procedure TaSynOptionsSetting.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) then
  begin
    with TSynOptionsForm.Create(self) do
    begin
      if (Manager <> nil) and (Manager.EditorSource <> nil) then
      begin
        Execute(Manager.EditorSource, FActiveSynEdit);
//        Manager.SaveEditorSource(Manager.EditorSourceIni);
      end else
        Execute(nil, FActiveSynEdit);
      Free;
    end;
  end;
end;

{ TSynHighlighterItem }

procedure TSynHighlighterItem.Assign(Source: TPersistent);
begin
  If Source is TSynHighlighterItem then
    with TSynHighlighterItem(Source) do
    begin
      self.Highlighter := Highlighter;
      Self.CodeTemplate := CodeTemplate;
      self.CodeInsight := CodeInsight;
      self.FileName := Filename;
    end
  else inherited;
end;

function TSynHighlighterItem.GetDisplayName: string;
begin
  if assigned( Highlighter) then
    result := Highlighter.LanguageName;
end;

procedure TSynHighlighterItem.setCodeTemplate(const Value: TSynAutoComplete);
begin
  if FCodeTemplate <> nil then
    FCodeTemplate.RemoveFreeNotification(TSynHighlighters(Collection).FManager);
  fCodeTemplate := value;
  if FCodeTemplate <> nil then
    FCodeTemplate.FreeNotification(TSynHighlighters(Collection).FManager);
end;

procedure TSynHighlighterItem.setCodeInsight(const Value: TSynCompletionProposal);
begin
  if FCodeInsight <> nil then
    FCodeInsight.RemoveFreeNotification(TSynHighlighters(Collection).FManager);
  FCodeInsight := value;
  if FCodeInsight <> nil then
    FCodeInsight.FreeNotification(TSynHighlighters(Collection).FManager);
end;

procedure TSynHighlighterItem.SetHighlighter(
  const Value: TSynCustomHighlighter);
begin
  if FHighlighter <> nil then
    FHighlighter.RemoveFreeNotification(TSynHighlighters(Collection).FManager);
  FHighlighter := Value;
  if FHighlighter <> nil then
    FHighlighter.FreeNotification(TSynHighlighters(Collection).FManager);
end;

procedure TSynHighlighterItem.Load;
var
  INI : TCustomIniFile;
  L : TStrings;
begin
  if not FLoad then
  begin
    if FileExists(FFullFileName) then
      Highlighter.LoadFromFile(FFullFileName);
    Ini := TSynHighlighters(Collection).FManager.CreateIniFile(
      ChangeFileExt(FFullFileName, 'Ini'));
    L := TStringList.Create;
    try
      if Assigned(Ini) then
      begin
        L.Clear;
        Ini.ReadSectionValues('CodeTemplate', L);
        if L.Count > 0 then CodeTemplate.AutoCompleteList.AddStrings(L);

        L.Clear;
        Ini.ReadSectionValues('CodeInsightItems', L);
        if L.Count > 0 then CodeInsight.ItemList.AddStrings(L);

        L.Clear;
        Ini.ReadSectionValues('CodeInsightInserts', L);
        if L.Count > 0 then CodeInsight.InsertList.AddStrings(L);
      end;
      FLoad := True;
    finally
      Ini.Free;
      L.Free;
    end;
  end;
end;

{ TSynHighlighters }

function TSynHighlighters.GetHighlighter(Index: Integer): TSynCustomHighlighter;
begin
  Result := nil;
  if index in [0..(Count-1)]  then
    result := Items[index].Highlighter;
end;

function TSynHighlighters.GetItem(Index: Integer): TSynHighlighterItem;
begin
  Result := nil;
  if index in [0..(Count-1)]  then
    Result := TSynHighlighterItem(inherited Items[index]);
end;

procedure TSynHighlighters.HighlighterAssignTo(Editor: TCustomSynEdit;
  NewIndex: Integer);
var
  I : integer;
begin
  if Editor.Highlighter <> nil then
    for i := 0 to Count - 1 do
      if Highlighters[i] = Editor.Highlighter then
      begin
        if Assigned(Items[i].FCodeTemplate) then
          Items[i].CodeTemplate.RemoveEditor(Editor);
        if Assigned(Items[i].fCodeInsight) then
          Items[i].CodeInsight.RemoveEditor(Editor);
      end;
  if Items[NewIndex] <> nil then
  begin
    if not Items[NewIndex].FLoad then Items[NewIndex].Load;
    Editor.Highlighter := Highlighters[NewIndex];
    if Assigned(Items[NewIndex].FCodeTemplate) then
      Items[NewIndex].CodeTemplate.AddEditor(Editor);
    if Assigned(Items[NewIndex].FCodeInsight) then
      Items[NewIndex].CodeInsight.AddEditor(Editor);
    {$IFDEF CODEFOLDING}
    //### Code Folding ###
    Editor.InitCodeFolding;
    //### End Code Folding ###
    {$ENDIF}
  end else Editor.Highlighter := nil;
end;

function TSynHighlighters.IndexOfFileName(FileName: string): Integer;
begin
  for result := 0 to Count-1 do
    if Highlighters[result].CanHighlighter(FileName) then
      exit;
  Result := -1;
end;

function TSynHighlighters.IndexOfLanguage(Language: string): Integer;
begin
  for result := 0 to Count-1 do
    if LowerCase( Highlighters[result].LanguageName) = LowerCase(Language ) then
      exit;
  Result := -1;
end;

procedure TSynHighlighters.SetHighlighter(Index: Integer;
  const Value: TSynCustomHighlighter);
begin
  if index in [0..(Count-1)]  then
    Items[index].Highlighter := Value;
end;

procedure TSynHighlighters.SetItem(Index: Integer;
  const Value: TSynHighlighterItem);
begin
  if index in [0..(Count-1)]  then
    inherited Items[index] := Value;
end;

procedure TSynHighlighters.RemoveHighlighter(
  Highlighter: TSynCustomHighlighter);
var
  I : integer;
begin
  for I := Count-1 downto 0 do
    If Highlighters[I] = Highlighter then
    begin
      Delete(I);
    end;
end;

{ TaSynToggleHighlighter }
function ExtractFileName(
  const Filename: string; Extension : boolean = true): string;
var
  i : integer;
begin
  Result := SysUtils.ExtractFileName(Filename);
  if not Extension then
  begin
    for I := Length(Result) downto 1 do
      If Result[I]='.' then Break;
    if I > 1 then
      Delete(Result, I, MaxInt);
  end;
end;

procedure TaSynToggleHighlighter.ExecuteTarget(Target: TObject);
var
  i : integer;
begin
  if SynEditAllocated(Target) and (Manager <> nil) then
  begin
    with Manager.Highlighters, TToggleHighlighterDlg.Create(self) do
    begin
      ListBox1.Items.Add(sNoHighlighter);
      for i := 0 to Count - 1 do
      begin
//        if Highlighters[i].LanguageName = '' then
//          ListBox1.Items.Add(ExtractFileName(Items[i].FileName, False))
//          else
        ListBox1.Items.Add(Highlighters[i].LanguageName);
        if (Highlighters[i] = FActiveSynEdit.Highlighter) then
          ListBox1.ItemIndex := i+1;
      end;
      If ShowModal = mrok then
        Manager.Highlighters.HighlighterAssignTo(FActiveSynEdit, ListBox1.ItemIndex-1);
      Free;
    end;
  end;
end;

function TaSynNew.GetNewDocName: string;
begin
  Inc(FNewCount);
  Result := Format(fDocumentName, [FNewCount]);
end;

{ TSynActionsEvent }

constructor TSynActionsEvent.Create(AOwner: TComponent);
begin
  inherited;
  ActionsEvent := self;
end;

destructor TSynActionsEvent.destroy;
begin
  If ActionsEvent = self then
    ActionsEvent := nil;
  inherited;
end;

{ TSynEditorsEvent }

procedure TSynEditorsEvent.AssignTo(Edit: TSynEdit);
begin
  If (FDoClick) then
    Edit.OnClick := FOnClick;
  If (FDoDblClick) then
    Edit.OnDblClick := OnDblClick;
  If (FDoDragDrop) then
    Edit.OnDragDrop := OnDragDrop;
  If (FDoDragOver) then
    Edit.OnDragOver := OnDragOver;
{$IFDEF SYN_CLX}
{$ELSE}
{$IFDEF SYN_COMPILER_4_UP}
  If (FDoEndDock) then
    Edit.OnEndDock := OnEndDock;
  If (FDoStartDock) then
    Edit.OnStartDock := OnStartDock;
{$ENDIF}
{$ENDIF}
  If (FDoEndDrag) then
    Edit.OnEndDrag := OnEndDrag;
  If (FDoEnter) then
    Edit.OnEnter := OnEnter;
  If (FDoExit) then
    Edit.OnExit := OnExit;
  If (FDoKeyDown) then
    Edit.OnKeyDown := OnKeyDown;
  If (FDoKeyPress) then
    Edit.OnKeyPress := OnKeyPress;
  If (FDoKeyUp) then
    Edit.OnKeyUp := OnKeyUp;
  If (FDoMouseDown) then
    Edit.OnMouseDown := OnMouseDown;
  If (FDoMouseMove) then
    Edit.OnMouseMove := OnMouseMove;
  If (FDoMouseUp) then
    Edit.OnMouseUp := OnMouseUp;
  If (FDoStartDrag) then
    Edit.OnStartDrag := OnStartDrag;
  If (FDoChange) then
    Edit.OnChange := fOnChange;
  If (FDoClearMark) then
    Edit.OnClearBookmark := fOnClearMark;
  If (FDoCommandProcessed) then
    Edit.OnCommandProcessed := fOnCommandProcessed;
  If (FDoContextHelp) then
    Edit.OnContextHelp := fOnContextHelp;
  If (FDoDropFiles) then
    Edit.OnDropFiles := fOnDropFiles;
  If (FDoGutterGetText) then
    Edit.OnGutterGetText := fOnGutterGetText;
  If (FDoGutterClick) then
    Edit.OnGutterClick := fOnGutterClick;
  If (FDoGutterPaint) then
    Edit.OnGutterPaint := fOnGutterPaint;
  If (FDoMouseCursor) then
    Edit.OnMouseCursor := fOnMouseCursor;
  If (FDoPaint) then
    Edit.OnPaint := fOnPaint;
  If (FDoPlaceMark) then
    Edit.OnPlaceBookmark := FOnPlaceMark;
  If (FDoProcessCommand) then
    Edit.OnProcessCommand := fOnProcessCommand;
  If (FDoProcessUserCommand) then
    Edit.OnProcessUserCommand := fOnProcessUserCommand;
  If (FDoReplaceText) then
    Edit.OnReplaceText := fOnReplaceText;
  If (FDoScroll) then
    Edit.OnScroll := fOnScroll;
  If (FDoSpecialLineColors) then
    Edit.OnSpecialLineColors := fOnSpecialLineColors;
  If (FDoStatusChange) then
    Edit.OnStatusChange := fOnStatusChange;
  If (FDoPaintTransient) then
    Edit.OnPaintTransient := fOnPaintTransient;
  If Edit is TCustomSynEditor then
  begin
    If (FDoLoadDocument) then
      TCustomSynEditor(Edit).OnLoadDocument := fOnLoadDocument;
    If (FDoSaveDocument) then
      TCustomSynEditor(Edit).OnSaveDocument := fOnSaveDocument;
    If (FDoCloseDocument) then
      TCustomSynEditor(Edit).OnCloseDocument := fOnCloseDocument;
  end;
end;

constructor TSynEditorsEvent.Create(AOwner: TComponent);
begin
  inherited;
  EditorsEvent := Self;
end;

destructor TSynEditorsEvent.destroy;
begin
  if EditorsEvent = Self then
    EditorsEvent := nil;
  inherited;
end;

function TaSynOpen.OpenDocument(Document: string): TCustomSynEditor;
begin
  result := nil;
  If FileExists(Document) then
  begin
    if Assigned(OnCreateEditor) then
      OnCreateEditor(Self, result);
    if (result = nil) and ((ActionsEvent <> nil) and Assigned(ActionsEvent.OnCreateEditor)) then
      ActionsEvent.OnCreateEditor(Self, result);
    if result <> nil then
    begin
      Result.BeginUpdate;
      if (Manager <> nil) then
      begin
        Manager.AddEditor(result);
        Manager.Highlighters.HighlighterAssignTo(result, Manager.Highlighters.IndexOfFileName(Document));
      end
      else if EditorsEvent <> nil then
        EditorsEvent.AssignTo(result);
      if not result.LoadDocument(Document, nil, [doReset]) then
      begin
        if (aSynClose <> nil) and Assigned(aSynClose.FOnClose) then
          aSynClose.FOnClose(Self, result)
        else if ((ActionsEvent<> nil) and Assigned(ActionsEvent.OnCloseEditor)) then
          ActionsEvent.OnCloseEditor(Self, result);
        result := nil;
        exit;
      end;
      if Result <> nil then
      begin
        Result.EndUpdate;
        //包伟
        result.InitCodeFolding;
      end;
    end;
  end;
end;

{ TSynAction }

procedure TSynAction.ExecuteTarget(Target: TObject);
begin
  if Assigned(OnExecute) then
    inherited
  else if (ActionsEvent <> nil) and Assigned(ActionsEvent.OnActionsExecute) then
    ActionsEvent.OnActionsExecute(Self, nil);
end;

function TSynAction.HandlesTarget(Target: TObject): Boolean;
begin
  Result := True;
  if Assigned(OnUpdate) then
    Result := inherited HandlesTarget(Target)
  else if (ActionsEvent <> nil) and Assigned(ActionsEvent.OnActionsUpdate) then
    Result := ActionsEvent.OnActionsUpdate(Self, nil);
end;

{ TaSynSpellCheck }

constructor TaSynSpellCheck.Create(AOwner: TComponent);
begin
  inherited;
  if not (csDesigning in ComponentState) then
  begin
    FCheckWordDlg := TCheckWordDlg.Create(Self);
    FAutoCheckWord := TStringList.Create;
  end;
end;

destructor TaSynSpellCheck.Destroy;
begin
  FAutoCheckWord.free;
  inherited;
end;

procedure TaSynSpellCheck.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) and Assigned(Manager) and Assigned(Manager.fSpellCheck) then
  begin
    FAutoCheckWord.clear;
    IF not Manager.SpellCheck.OpenDictionary then
      Manager.SpellCheck.LoadDictionary(Manager.SpellCheck.Dictionary);
    Manager.SpellCheck.OnCheckWord := SpellCheckWord;
    Manager.SpellCheck.Options := Manager.SpellCheck.Options+ [sscoSelectWord];
    Manager.SpellCheck.Editor := FActiveSynEdit;
    Manager.SpellCheck.SpellCheck;
    ShowMessage('拼写检查完毕!');
  end;
end;

function TaSynSpellCheck.HandlesTarget(Target: TObject): Boolean;
begin
  result := SynEditAllocated(Target) and Assigned(Manager) and Assigned(Manager.fSpellCheck);
end;

procedure TaSynSpellCheck.SpellCheckWord(Sender: TObject; AWord: string;
  ASuggestions: TStringList; var ACorrectWord: string; var AAction: Integer;
  const AUndoEnabled: Boolean);
var
  i : integer;
  BP, EP : TPoint;
begin
  if Assigned(Manager.SpellCheck.Editor) then
  begin
    With TCheckWordDlg(FCheckWordDlg) do
    begin
      i := FAutoCheckWord.IndexOf(AWord);
      if (i >= 0) and ((I+1) < FAutoCheckWord.Count) then
      begin
        ACorrectWord := FAutoCheckWord[i+1];
        AAction := ACTION_CORRECT;
        exit;
      end;
      Edit1.Text := AWord;
      ListBox1.Items := ASuggestions;
      Edit2.Text := TSynSpellCheck(Sender).Dictionary;
      with Manager.SpellCheck.Editor do
      begin
        BP := ClientToScreen(RowColumnToPixels(BufferToDisplayPos(BlockBegin)));
        EP := ClientToScreen(RowColumnToPixels(BufferToDisplayPos(BlockEnd)));
        if FCheckWordDlg.Width + BP.X > Screen.WorkAreaWidth then
          FCheckWordDlg.Left := EP.X - FCheckWordDlg.Width
        else
          FCheckWordDlg.Left := BP.X;
        if FCheckWordDlg.Height + BP.Y > Screen.WorkAreaHeight then
          FCheckWordDlg.Top := EP.y - FCheckWordDlg.Height
        else
          FCheckWordDlg.Top := BP.Y + LineHeight;
      end;
      ShowModal;
      ACorrectWord := Edit3.Text;
      case ModalResult of
        mrCancel : AAction := ACTION_ABORT;
        mrOk : AAction := ACTION_CORRECT;
        mrIgnore : AAction := ACTION_SKIP;
        mrNoToAll : AAction := ACTION_SKIPALL;
        mrYes : AAction := ACTION_ADD;
        mrRetry : if Assigned( Manager.fAutoCorrect ) then
          Manager.AutoCorrect.Add(AWord, ACorrectWord);
        mrAbort : AAction := ACTION_UNDO;
        mrYesToAll :
        begin
          AAction := ACTION_CORRECT;
          FAutoCheckWord.Add(AWord);
          FAutoCheckWord.Add(ACorrectWord);
        end;
      end;
    end;
  end;
end;

{ TaSynSpellCheckOptions }

procedure TaSynSpellCheckOptions.ExecuteTarget(Target: TObject);
begin
  if SynEditAllocated(Target) and Assigned(Manager) and Assigned(Manager.SpellCheck) then
  begin
    with TSpellCheckOpForm.Create(self) do
      Execute(Manager.SpellCheck);
  end;
end;

function TaSynSpellCheckOptions.HandlesTarget(Target: TObject): Boolean;
begin
  result := SynEditAllocated(Target) and Assigned(Manager) and Assigned(Manager.SpellCheck);
end;

{ TaSynHighlighterSetting }

procedure TaSynHighlighterSetting.ExecuteTarget(Target: TObject);
begin
  TCustomHLDlg.Create(self).ShowModal;
end;

end.
