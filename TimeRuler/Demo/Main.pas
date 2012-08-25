unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, TimeRuler, ComCtrls, JvComCtrls, JvxSlider, StdCtrls,
  JvEdit, JvValidateEdit, JvComponent, JvCombobox, JvColorCombo, JvExStdCtrls, Buttons;

type
  TForm1 = class(TForm)
    TimeRuler1: TTimeRuler;
    StatusBar1: TStatusBar;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    JvIntegerEdit2: TJvValidateEdit;
    JvIntegerEdit1: TJvValidateEdit;
    JvIntegerEdit3: TJvValidateEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    JvIntegerEdit4: TJvValidateEdit;
    JvIntegerEdit5: TJvValidateEdit;
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    JvIntegerEdit6: TJvValidateEdit;
    JvIntegerEdit7: TJvValidateEdit;
    Label10: TLabel;
    Label11: TLabel;
    JvIntegerEdit8: TJvValidateEdit;
    JvIntegerEdit9: TJvValidateEdit;
    JvCCBLastLineColor: TJvColorComboBox;
    Label12: TLabel;
    Label13: TLabel;
    JvColorComboBox1: TJvColorComboBox;
    Label14: TLabel;
    Label15: TLabel;
    JvColorComboBox2: TJvColorComboBox;
    JvColorComboBox3: TJvColorComboBox;
    Label19: TLabel;
    JvColorComboBox7: TJvColorComboBox;
    Label20: TLabel;
    JvColorComboBox8: TJvColorComboBox;
    Label22: TLabel;
    JvColorComboBox9: TJvColorComboBox;
    Label26: TLabel;
    Label27: TLabel;
    JvColorComboBox13: TJvColorComboBox;
    JvColorComboBox14: TJvColorComboBox;
    CheckBox1: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    JvColorComboBox10: TJvColorComboBox;
    JvColorComboBox11: TJvColorComboBox;
    JvColorComboBox12: TJvColorComboBox;
    JvColorComboBox4: TJvColorComboBox;
    JvColorComboBox5: TJvColorComboBox;
    JvColorComboBox6: TJvColorComboBox;
    procedure TimeRuler1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure TimeRuler1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.TimeRuler1Change(Sender: TObject);
begin
  JvIntegerEdit3.Value := TimeRuler1.CurrentTime;
  
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  TimeRuler1.CurrentTime := JvIntegerEdit3.value;
  TimeRuler1.EDTStart := JvIntegerEdit2.value;
  TimeRuler1.EDTLength := JvIntegerEdit1.value;
  TimeRuler1.AviStart := JvIntegerEdit4.Value;
  TimeRuler1.AviLength := JvIntegerEdit5.Value;
  TimeRuler1.Enabled := CheckBox1.Checked;
  TimeRuler1.ShowCurrentArrow := CheckBox2.Checked;
  TimeRuler1.AviFilename := Edit2.Text;
  TimeRuler1.EyedatFilename := Edit1.Text;
  TimeRuler1.ScrollChangeButtons := JvIntegerEdit6.Value;
  TimeRuler1.ScrollChangeKeyDown := JvIntegerEdit7.Value;
  TimeRuler1.AviEnabled := CheckBox4.Checked;
  TimeRuler1.ShowRange := CheckBox3.Checked;
  TimeRuler1.Background1 := JvCCBLastLineColor.ColorValue;
  TimeRuler1.Background2 := JvColorComboBox1.ColorValue;
  TimeRuler1.EyedatBackground := JvColorComboBox2.ColorValue;
  TimeRuler1.AviBackground := JvColorComboBox3.ColorValue;
  TimeRuler1.EyedatText := JvColorComboBox4.ColorValue;
  TimeRuler1.AviText := JvColorComboBox5.ColorValue;
  TimeRuler1.TimelineText := JvColorComboBox6.ColorValue;
  TimeRuler1.CurrentArrow := JvColorComboBox9.ColorValue;
  TimeRuler1.EyedatBorders := JvColorComboBox7.ColorValue;
  TimeRuler1.AviBorders := JvColorComboBox8.ColorValue;
  TimeRuler1.RulerLines := JvColorComboBox13.ColorValue;
  TimeRuler1.DisabledBackground := JvColorComboBox14.ColorValue;
  TimeRuler1.RangeSelectLeft := JvColorComboBox10.ColorValue;
  TimeRuler1.RangeSelectRight := JvColorComboBox11.ColorValue;
  TimeRuler1.RangeSelect := JvColorComboBox12.ColorValue;
  TimeRuler1.RangeStart := JvIntegerEdit9.Value;
  TimeRuler1.RangeEnd := JvIntegerEdit8.Value;
  TimeRuler1.Refresh
end;

procedure TForm1.TimeRuler1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  JvIntegerEdit4.Value := TimeRuler1.AviStart;
  JvIntegerEdit5.Value := TimeRuler1.AviLength;

  JvIntegerEdit9.Value := TimeRuler1.RangeStart;
  JvIntegerEdit8.Value := TimeRuler1.RangeEnd;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  Button1.Click;
  JvColorComboBox1.ColorValue := clInfoBk
end;

end.
