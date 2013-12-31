unit BCControls.UnicodeStringHolder;

interface

uses
  System.SysUtils, System.Classes, System.WideStrings;

type
  EBCMultiStringHolderException = class(Exception);

  TBCMultiStringHolderCollectionItem = class(TCollectionItem)
  private
    FName: string;
    FStrings: TWideStrings;
    procedure SetName(Value: string);
    procedure SetStrings(const Value: TWideStrings);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
  published
    property Name: string read FName write SetName;
    property Strings: TWideStrings read FStrings write SetStrings;
  end;

  TBCMultiStringHolderCollection = class(TOwnedCollection)
  protected
    function GetItem(Index: Integer): TBCMultiStringHolderCollectionItem;
    procedure SetItem(Index: Integer; Value: TBCMultiStringHolderCollectionItem);
  public
    function DoesNameExist(const Name: string): Boolean;
    property Items[Index: Integer]: TBCMultiStringHolderCollectionItem read GetItem write SetItem;
    function Add: TBCMultiStringHolderCollectionItem;
    function Insert(Index: Integer): TBCMultiStringHolderCollectionItem;
  end;

  TBCMultiStringHolder = class(TComponent)
  private
    FMultipleStrings: TBCMultiStringHolderCollection;
    procedure SetMultipleStrings(Value: TBCMultiStringHolderCollection);
    function GetItemByName(const Name: string): TBCMultiStringHolderCollectionItem;
    function GetStringsByName(const Name: string): TWideStrings;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property ItemByName[const Name: string]: TBCMultiStringHolderCollectionItem read GetItemByName;
    property StringsByName[const Name: string]: TWideStrings read GetStringsByName;
  published
    property MultipleStrings: TBCMultiStringHolderCollection read FMultipleStrings write SetMultipleStrings;
  end;

procedure Register;

implementation

uses
  System.RTLConsts;

resourcestring
  RsENoItemFoundWithName = 'No item found with name "%s"';

procedure Register;
begin
  RegisterComponents('bonecode', [TBCMultiStringHolder]);
end;

{ TBCMultiStringHolderCollectionItem }

procedure TBCMultiStringHolderCollectionItem.SetName(Value: string);
begin
  Value := Trim(Value);
  if Value = '' then
    FName := ''
  else
  begin
    if not TBCMultiStringHolderCollection(Collection).DoesNameExist(Value) then
      FName := Value
    else
      raise EBCMultiStringHolderException.CreateRes(@SDuplicateString);
  end;
end;

procedure TBCMultiStringHolderCollectionItem.SetStrings(const Value: TWideStrings);
begin
  if Value <> FStrings then
    FStrings.Assign(Value);
end;

function TBCMultiStringHolderCollectionItem.GetDisplayName: string;
begin
  if FName <> '' then
    Result := FName
  else
    Result := '(unnamed)';
end;

constructor TBCMultiStringHolderCollectionItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FStrings := TWideStringList.Create;
end;

destructor TBCMultiStringHolderCollectionItem.Destroy;
begin
  FStrings.Free;
  inherited Destroy;
end;

{ TBCMultiStringHolderCollection }

function TBCMultiStringHolderCollection.GetItem(Index: Integer): TBCMultiStringHolderCollectionItem;
begin
  Result := TBCMultiStringHolderCollectionItem(inherited GetItem(Index));
end;

procedure TBCMultiStringHolderCollection.SetItem(Index: Integer; Value: TBCMultiStringHolderCollectionItem);
begin
  inherited SetItem(Index, Value);
end;

function TBCMultiStringHolderCollection.DoesNameExist(const Name: string): Boolean;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    if CompareText(Items[I].Name, Name) = 0 then
      Exit(True);
  Result := False;
end;

function TBCMultiStringHolderCollection.Add: TBCMultiStringHolderCollectionItem;
begin
  Result := TBCMultiStringHolderCollectionItem(inherited Add);
end;

function TBCMultiStringHolderCollection.Insert(Index: Integer): TBCMultiStringHolderCollectionItem;
begin
  Result := Add;
  Result.Index := Index;
end;

{ TBCMultiStringHolder }

constructor TBCMultiStringHolder.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMultipleStrings := TBCMultiStringHolderCollection.Create(Self, TBCMultiStringHolderCollectionItem);
end;

destructor TBCMultiStringHolder.Destroy;
begin
  FMultipleStrings.Free;
  inherited Destroy;
end;

procedure TBCMultiStringHolder.SetMultipleStrings(Value: TBCMultiStringHolderCollection);
begin
  if Value <> FMultipleStrings then
    FMultipleStrings.Assign(Value);
end;

function TBCMultiStringHolder.GetItemByName(const Name: string): TBCMultiStringHolderCollectionItem;
var
  i: Integer;
begin
  for i := 0 to MultipleStrings.Count - 1 do
    if CompareText(MultipleStrings.Items[I].Name, Name) = 0 then
      Exit(MultipleStrings.Items[I]);
  raise EBCMultiStringHolderException.CreateResFmt(@RsENoItemFoundWithName, [Name]);
end;

function TBCMultiStringHolder.GetStringsByName(const Name: string): TWideStrings;
begin
  Result := GetItemByName(Name).Strings;
end;

end.
