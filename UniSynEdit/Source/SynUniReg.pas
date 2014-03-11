{
@abstract(TSynUniSyn rules source)
@authors(Fantasist [walking_in_the_sky@yahoo.com], Vit [nevzorov@yahoo.com],
         Vitalik [2vitalik@gmail.com], Quadr0 [quadr02005@gmail.com])
@created(2003)
@lastmod(01.08.2005 17:24:09)
}

{$IFNDEF QSYNUNIREG}
unit SynUniReg;
{$ENDIF}

interface

{$I SynUniHighlighter.inc}

uses
{$IFDEF SYN_COMPILER_6_UP}
  //DesignIntf,
  //DesignEditors,
{$ELSE}
  DsgnIntf,
{$ENDIF}
{$IFDEF SYN_CLX}
  Qt,
  QDialogs,
  QSynEditStrConst,
  QSynUniHighlighter;
{$ELSE}
  Classes,
  Dialogs,
  SynEditStrConst,
  SynUniHighlighter,
  Windows;
{$ENDIF}

procedure Register;

implementation

//------------------------------------------------------------------------------
procedure Register;
begin
  RegisterComponents(SYNS_ComponentsPage, [TSynUniSyn]);
end;

end.
