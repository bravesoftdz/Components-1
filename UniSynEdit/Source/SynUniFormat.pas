{
@abstract(Provides highlighters import and export)
@authors(Vitalik [2vitalik@gmail.com])
@created(2005)
@lastmod(2006-06-30)
}

{$IFNDEF QSynUniFormat}
unit SynUniFormat;
{$ENDIF}

interface

uses
{$IFDEF SYN_CLX}
  QClasses,
  QSynUniHighlighter,
{$ELSE}
  Classes,
  SysUtils,
  SynUniHighlighter;
{$ENDIF}

type
  TSynUniFormat = class
  protected
    class function VerifyStream(AStream: TStream): boolean;
    class function VerifyFileName(AFileName: string): boolean;
    class function VerifyEmptyFileName(AFileName: string): boolean;
  public
    class function ImportFromStream(AObject: TObject; AStream: TStream): boolean; virtual; abstract;
    class function ImportFromFile(AObject: TObject; AFileName: string): boolean; virtual; abstract;
    class function ExportToStream(AObject: TObject; AStream: TStream): boolean; virtual; abstract;
    class function ExportToFile(AObject: TObject; AFileName: string): boolean; virtual; abstract;
  end;

implementation

class function TSynUniFormat.VerifyStream(AStream: TStream): boolean;
begin
  Result := True;
  if not Assigned(aStream) then
    raise Exception.Create(ClassName + '.ImportFromStream: AStream property can not be nil');
end;

class function TSynUniFormat.VerifyFileName(AFileName: string): boolean;
begin
  Result := True;
  if not FileExists(AFileName) then
    raise Exception.Create(ClassName + '.ImportFromFile: File "' + AFileName + '" does not exists!');
end;

class function TSynUniFormat.VerifyEmptyFileName(AFileName: string): boolean;
begin
  Result := True;
  if AFileName = '' then
    raise Exception.Create(ClassName + '.ExportToFile: AFileName property can not be empty');
end;

end.

