object fmEditorOptionsDialog: TfmEditorOptionsDialog
  Left = 580
  Top = 154
  BorderStyle = bsDialog
  Caption = 'Editor Options'
  ClientHeight = 485
  ClientWidth = 454
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object PageControl1: TPageControl
    Left = 7
    Top = 10
    Width = 437
    Height = 424
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ActivePage = Display
    TabOrder = 0
    object Display: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Display'
      object gbRightEdge: TGroupBox
        Left = 10
        Top = 167
        Width = 196
        Height = 109
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Right Edge'
        TabOrder = 1
        object Label3: TLabel
          Left = 11
          Top = 69
          Width = 69
          Height = 16
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Caption = 'Edge color:'
        end
        object Label10: TLabel
          Left = 11
          Top = 32
          Width = 84
          Height = 16
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Caption = 'Edge Column:'
        end
        object pRightEdgeBack: TPanel
          Left = 98
          Top = 66
          Width = 64
          Height = 26
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          BorderWidth = 1
          TabOrder = 1
          object pRightEdgeColor: TPanel
            Left = 2
            Top = 2
            Width = 47
            Height = 21
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            Align = alClient
            BevelOuter = bvLowered
            Color = clGray
            TabOrder = 0
            OnClick = pRightEdgeColorClick
          end
          object btnRightEdge: TPanel
            Left = 49
            Top = 2
            Width = 13
            Height = 21
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            Align = alRight
            BevelOuter = bvNone
            TabOrder = 1
            OnMouseDown = btnRightEdgeMouseDown
            object Image1: TImage
              Left = 4
              Top = 7
              Width = 6
              Height = 7
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              Picture.Data = {
                07544269746D61708A000000424D8A0000000000000076000000280000000500
                0000050000000100040000000000140000000000000000000000100000001000
                0000000000000000800000800000008080008000000080008000808000008080
                8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
                FF00DDDDD000DD0DD000D000D00000000000DDDDD000}
              Transparent = True
              OnMouseDown = btnRightEdgeMouseDown
            end
          end
        end
        object eRightEdge: TEdit
          Left = 98
          Top = 28
          Width = 63
          Height = 21
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          TabOrder = 0
          Text = '0'
        end
      end
      object gbGutter: TGroupBox
        Left = 10
        Top = 10
        Width = 406
        Height = 149
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Gutter'
        TabOrder = 0
        object Label1: TLabel
          Left = 217
          Top = 110
          Width = 71
          Height = 16
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Caption = 'Gutter color:'
        end
        object ckGutterAutosize: TCheckBox
          Left = 11
          Top = 46
          Width = 148
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Autosize'
          TabOrder = 1
        end
        object ckGutterShowLineNumbers: TCheckBox
          Left = 11
          Top = 69
          Width = 148
          Height = 21
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Show line numbers'
          TabOrder = 2
        end
        object ckGutterShowLeaderZeros: TCheckBox
          Left = 11
          Top = 116
          Width = 148
          Height = 21
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Show leading zeros'
          TabOrder = 4
        end
        object ckGutterStartAtZero: TCheckBox
          Left = 11
          Top = 92
          Width = 148
          Height = 21
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Start at zero'
          TabOrder = 3
        end
        object ckGutterVisible: TCheckBox
          Left = 11
          Top = 22
          Width = 148
          Height = 21
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Visible'
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
        object cbGutterFont: TCheckBox
          Left = 217
          Top = 22
          Width = 147
          Height = 21
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Use Gutter Font'
          TabOrder = 5
          OnClick = cbGutterFontClick
        end
        object btnGutterFont: TButton
          Left = 347
          Top = 16
          Width = 49
          Height = 31
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Font'
          TabOrder = 6
          OnClick = btnGutterFontClick
        end
        object pGutterBack: TPanel
          Left = 310
          Top = 105
          Width = 64
          Height = 25
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          BorderWidth = 1
          TabOrder = 8
          object pGutterColor: TPanel
            Left = 2
            Top = 2
            Width = 47
            Height = 21
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            Align = alClient
            BevelOuter = bvLowered
            Color = clGray
            TabOrder = 0
            OnClick = pGutterColorClick
          end
          object btnGutterColor: TPanel
            Left = 49
            Top = 2
            Width = 13
            Height = 21
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            Align = alRight
            BevelOuter = bvNone
            TabOrder = 1
            OnMouseDown = btnGutterColorMouseDown
            object Image2: TImage
              Left = 4
              Top = 7
              Width = 6
              Height = 7
              Margins.Left = 4
              Margins.Top = 4
              Margins.Right = 4
              Margins.Bottom = 4
              Picture.Data = {
                07544269746D61708A000000424D8A0000000000000076000000280000000500
                0000050000000100040000000000140000000000000000000000100000001000
                0000000000000000800000800000008080008000000080008000808000008080
                8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
                FF00DDDDD000DD0DD000D000D00000000000DDDDD000}
              Transparent = True
              OnMouseDown = btnGutterColorMouseDown
            end
          end
        end
        object pnlGutterFontDisplay: TPanel
          Left = 217
          Top = 49
          Width = 178
          Height = 41
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          BevelOuter = bvNone
          TabOrder = 7
          object lblGutterFont: TLabel
            Left = 23
            Top = 11
            Width = 120
            Height = 16
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Caption = 'Courier New 8pt'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
          end
        end
      end
      object gbBookmarks: TGroupBox
        Left = 10
        Top = 286
        Width = 196
        Height = 97
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Bookmarks'
        TabOrder = 3
        object ckBookmarkKeys: TCheckBox
          Left = 11
          Top = 30
          Width = 119
          Height = 20
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Bookmark keys'
          TabOrder = 0
        end
        object ckBookmarkVisible: TCheckBox
          Left = 11
          Top = 59
          Width = 149
          Height = 21
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Bookmarks visible'
          TabOrder = 1
        end
      end
      object gbEditorFont: TGroupBox
        Left = 222
        Top = 286
        Width = 195
        Height = 97
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Editor Font'
        TabOrder = 4
        object btnFont: TButton
          Left = 79
          Top = 60
          Width = 103
          Height = 31
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Font'
          TabOrder = 0
          OnClick = btnFontClick
        end
        object Panel3: TPanel
          Left = 10
          Top = 23
          Width = 176
          Height = 37
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          BevelOuter = bvNone
          TabOrder = 1
          object labFont: TLabel
            Left = 2
            Top = 1
            Width = 160
            Height = 18
            Margins.Left = 4
            Margins.Top = 4
            Margins.Right = 4
            Caption = 'Courier New 10pt'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Courier New'
            Font.Style = []
            ParentFont = False
          end
        end
      end
      object gbLineSpacing: TGroupBox
        Left = 222
        Top = 167
        Width = 195
        Height = 109
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Line spacing / Tab spacing'
        TabOrder = 2
        object Label8: TLabel
          Left = 11
          Top = 33
          Width = 68
          Height = 16
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Caption = 'Extra Lines:'
        end
        object Label9: TLabel
          Left = 11
          Top = 69
          Width = 65
          Height = 16
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Caption = 'Tab Width:'
        end
        object eLineSpacing: TEdit
          Left = 98
          Top = 28
          Width = 64
          Height = 21
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          TabOrder = 0
          Text = '0'
        end
        object eTabWidth: TEdit
          Left = 98
          Top = 65
          Width = 64
          Height = 21
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          TabOrder = 1
          Text = '8'
        end
      end
    end
    object Options: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Options'
      object gbOptions: TGroupBox
        Left = 10
        Top = 0
        Width = 406
        Height = 304
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Options'
        TabOrder = 0
        object ckAutoIndent: TCheckBox
          Left = 11
          Top = 18
          Width = 160
          Height = 21
          Hint = 
            'Will indent the caret on new lines with the same amount of leadi' +
            'ng white space as the preceding line'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Auto indent'
          TabOrder = 0
        end
        object ckDragAndDropEditing: TCheckBox
          Left = 11
          Top = 65
          Width = 160
          Height = 21
          Hint = 
            'Allows you to select a block of text and drag it within the docu' +
            'ment to another location'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Drag and drop editing'
          TabOrder = 2
        end
        object ckAutoSizeMaxWidth: TCheckBox
          Left = 11
          Top = 42
          Width = 160
          Height = 21
          Hint = 'Allows the editor accept OLE file drops'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Auto size scroll width'
          TabOrder = 1
        end
        object ckHalfPageScroll: TCheckBox
          Left = 217
          Top = 18
          Width = 160
          Height = 21
          Hint = 
            'When scrolling with page-up and page-down commands, only scroll ' +
            'a half page at a time'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Half page scroll'
          TabOrder = 12
        end
        object ckEnhanceEndKey: TCheckBox
          Left = 11
          Top = 229
          Width = 160
          Height = 21
          Hint = 'Makes it so the caret is never visible'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Enhance End Key'
          TabOrder = 9
        end
        object ckScrollByOneLess: TCheckBox
          Left = 217
          Top = 42
          Width = 160
          Height = 21
          Hint = 'Forces scrolling to be one less'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Scroll by one less'
          TabOrder = 13
        end
        object ckScrollPastEOF: TCheckBox
          Left = 217
          Top = 65
          Width = 160
          Height = 21
          Hint = 'Allows the cursor to go past the end of file marker'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Scroll past end of file'
          TabOrder = 14
        end
        object ckScrollPastEOL: TCheckBox
          Left = 217
          Top = 89
          Width = 160
          Height = 21
          Hint = 
            'Allows the cursor to go past the last character into the white s' +
            'pace at the end of a line'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Scroll past end of line'
          TabOrder = 15
        end
        object ckShowScrollHint: TCheckBox
          Left = 217
          Top = 112
          Width = 160
          Height = 21
          Hint = 
            'Shows a hint of the visible line numbers when scrolling vertical' +
            'ly'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Show scroll hint'
          TabOrder = 16
        end
        object ckSmartTabs: TCheckBox
          Left = 11
          Top = 159
          Width = 160
          Height = 21
          Hint = 
            'When tabbing, the cursor will go to the next non-white space cha' +
            'racter of the previous line'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Smart tabs'
          TabOrder = 6
        end
        object ckTabsToSpaces: TCheckBox
          Left = 217
          Top = 159
          Width = 160
          Height = 21
          Hint = 'Converts a tab character to the number of spaces in Tab Width'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Tabs to spaces'
          TabOrder = 18
        end
        object ckTrimTrailingSpaces: TCheckBox
          Left = 217
          Top = 182
          Width = 160
          Height = 21
          Hint = 'Spaces at the end of lines will be trimmed and not saved'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Trim trailing spaces'
          TabOrder = 19
        end
        object ckWantTabs: TCheckBox
          Left = 11
          Top = 135
          Width = 160
          Height = 21
          Hint = 
            'Let the editor accept tab characters instead of going to the nex' +
            't control'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Want tabs'
          TabOrder = 5
        end
        object ckAltSetsColumnMode: TCheckBox
          Left = 11
          Top = 89
          Width = 160
          Height = 21
          Hint = 
            'Holding down the Alt Key will put the selection mode into column' +
            'ar format'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Alt sets column mode'
          TabOrder = 3
        end
        object ckKeepCaretX: TCheckBox
          Left = 11
          Top = 112
          Width = 160
          Height = 21
          Hint = 
            'When moving through lines the X position will always stay the sa' +
            'me'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Maintain caret column'
          TabOrder = 4
        end
        object ckScrollHintFollows: TCheckBox
          Left = 217
          Top = 135
          Width = 187
          Height = 21
          Hint = 'The scroll hint follows the mouse when scrolling vertically'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Scroll hint follows mouse'
          TabOrder = 17
        end
        object ckGroupUndo: TCheckBox
          Left = 218
          Top = 206
          Width = 160
          Height = 20
          Hint = 
            'When undoing/redoing actions, handle all continous changes of th' +
            'e same kind in one call instead undoing/redoing each command sep' +
            'arately'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Group undo'
          TabOrder = 20
        end
        object ckSmartTabDelete: TCheckBox
          Left = 11
          Top = 182
          Width = 160
          Height = 21
          Hint = 'similar to Smart Tabs, but when you delete characters'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Smart tab delete'
          TabOrder = 7
        end
        object ckRightMouseMoves: TCheckBox
          Left = 218
          Top = 229
          Width = 180
          Height = 21
          Hint = 
            'When clicking with the right mouse for a popup menu, move the cu' +
            'rsor to that location'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Right mouse moves cursor'
          TabOrder = 21
        end
        object ckEnhanceHomeKey: TCheckBox
          Left = 11
          Top = 206
          Width = 180
          Height = 20
          Hint = 'enhances home key positioning, similar to visual studio'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Enhance Home Key'
          TabOrder = 8
        end
        object ckHideShowScrollbars: TCheckBox
          Left = 11
          Top = 252
          Width = 192
          Height = 21
          Hint = 
            'if enabled, then the scrollbars will only show when necessary.  ' +
            'If you have ScrollPastEOL, then it the horizontal bar will alway' +
            's be there (it uses MaxLength instead)'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Hide scrollbars as necessary'
          TabOrder = 10
        end
        object ckDisableScrollArrows: TCheckBox
          Left = 11
          Top = 276
          Width = 160
          Height = 21
          Hint = 
            'Disables the scroll bar arrow buttons when you can'#39't scroll in t' +
            'hat direction any more'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Disable scroll arrows'
          TabOrder = 11
        end
        object ckShowSpecialChars: TCheckBox
          Left = 218
          Top = 252
          Width = 160
          Height = 21
          Hint = 'Shows linebreaks, spaces and tabs using special symbols'
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Caption = 'Show special chars'
          TabOrder = 22
        end
      end
      object gbCaret: TGroupBox
        Left = 10
        Top = 306
        Width = 406
        Height = 77
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Caret'
        TabOrder = 1
        object Label2: TLabel
          Left = 20
          Top = 21
          Width = 68
          Height = 16
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Caption = 'Insert caret:'
        end
        object Label4: TLabel
          Left = 20
          Top = 50
          Width = 92
          Height = 16
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Caption = 'Overwrite caret:'
        end
        object cInsertCaret: TComboBox
          Left = 148
          Top = 16
          Width = 229
          Height = 24
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Style = csDropDownList
          TabOrder = 0
          Items.Strings = (
            'Vertical Line'
            'Horizontal Line'
            'Half Block'
            'Block')
        end
        object cOverwriteCaret: TComboBox
          Left = 148
          Top = 46
          Width = 229
          Height = 24
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Style = csDropDownList
          TabOrder = 1
          Items.Strings = (
            'Vertical Line'
            'Horizontal Line'
            'Half Block'
            'Block')
        end
      end
    end
    object Keystrokes: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Keystrokes'
      object btnAddKey: TButton
        Left = 118
        Top = 187
        Width = 92
        Height = 31
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = '&Add'
        TabOrder = 2
        OnClick = btnAddKeyClick
      end
      object btnRemKey: TButton
        Left = 217
        Top = 187
        Width = 92
        Height = 31
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = '&Remove'
        TabOrder = 3
        OnClick = btnRemKeyClick
      end
      object gbKeyStrokes: TGroupBox
        Left = 10
        Top = 236
        Width = 406
        Height = 147
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Keystroke Options'
        TabOrder = 4
        object Label5: TLabel
          Left = 20
          Top = 34
          Width = 65
          Height = 16
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Caption = 'Command:'
        end
        object Label6: TLabel
          Left = 20
          Top = 112
          Width = 63
          Height = 16
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Caption = 'Keystroke:'
        end
        object Label7: TLabel
          Left = 20
          Top = 73
          Width = 63
          Height = 16
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Caption = 'Keystroke:'
        end
        object cKeyCommand: TComboBox
          Left = 148
          Top = 28
          Width = 229
          Height = 21
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          TabOrder = 0
          OnExit = cKeyCommandExit
          OnKeyPress = cKeyCommandKeyPress
          OnKeyUp = cKeyCommandKeyUp
        end
      end
      object btnUpdateKey: TButton
        Left = 20
        Top = 187
        Width = 92
        Height = 31
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = '&Update'
        TabOrder = 1
        OnClick = btnUpdateKeyClick
      end
      object pnlCommands: TPanel
        Left = 10
        Top = 16
        Width = 406
        Height = 162
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        BevelInner = bvRaised
        BevelOuter = bvLowered
        Caption = 'pnlCommands'
        TabOrder = 0
        object KeyList: TListView
          Left = 2
          Top = 2
          Width = 402
          Height = 158
          Margins.Left = 4
          Margins.Top = 4
          Margins.Right = 4
          Margins.Bottom = 4
          Align = alClient
          BorderStyle = bsNone
          Columns = <
            item
              Caption = 'Command'
              Width = 206
            end
            item
              Caption = 'Keystroke'
              Width = 175
            end>
          ColumnClick = False
          HideSelection = False
          ReadOnly = True
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
          OnChanging = KeyListChanging
        end
      end
    end
  end
  object btnOk: TButton
    Left = 246
    Top = 446
    Width = 92
    Height = 30
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 345
    Top = 446
    Width = 92
    Height = 30
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object ColorDialog: TColorDialog
    Left = 8
    Top = 368
  end
  object ColorPopup: TPopupMenu
    Left = 40
    Top = 368
    object None1: TMenuItem
      Tag = -1
      Caption = 'None'
      OnClick = PopupMenuClick
    end
    object Scrollbar1: TMenuItem
      Caption = 'Scrollbar'
      OnClick = PopupMenuClick
    end
    object Background1: TMenuItem
      Tag = 1
      Caption = 'Background'
      OnClick = PopupMenuClick
    end
    object ActiveCaption1: TMenuItem
      Tag = 2
      Caption = 'Active Caption'
      OnClick = PopupMenuClick
    end
    object InactiveCaption1: TMenuItem
      Tag = 3
      Caption = 'Inactive Caption'
      OnClick = PopupMenuClick
    end
    object Menu1: TMenuItem
      Tag = 4
      Caption = 'Menu'
      OnClick = PopupMenuClick
    end
    object Window1: TMenuItem
      Tag = 5
      Caption = 'Window'
      OnClick = PopupMenuClick
    end
    object WindowFrame1: TMenuItem
      Tag = 6
      Caption = 'Window Frame'
      OnClick = PopupMenuClick
    end
    object MEnu2: TMenuItem
      Tag = 7
      Caption = 'Menu Text'
      OnClick = PopupMenuClick
    end
    object WindowText1: TMenuItem
      Tag = 8
      Caption = 'Window Text'
      OnClick = PopupMenuClick
    end
    object CaptionText1: TMenuItem
      Tag = 9
      Caption = 'Caption Text'
      OnClick = PopupMenuClick
    end
    object ActiveBorder1: TMenuItem
      Tag = 10
      Caption = 'Active Border'
      OnClick = PopupMenuClick
    end
    object InactiveBorder1: TMenuItem
      Tag = 11
      Caption = 'Inactive Border'
      OnClick = PopupMenuClick
    end
    object ApplicationWorkspace1: TMenuItem
      Tag = 12
      Caption = 'Application Workspace'
      OnClick = PopupMenuClick
    end
    object Highlight1: TMenuItem
      Tag = 13
      Caption = 'Highlight'
      OnClick = PopupMenuClick
    end
    object HighlightText1: TMenuItem
      Tag = 14
      Caption = 'Highlight Text'
      OnClick = PopupMenuClick
    end
    object ButtonFace1: TMenuItem
      Tag = 15
      Caption = 'Button Face'
      OnClick = PopupMenuClick
    end
    object ButtonShadow1: TMenuItem
      Tag = 16
      Caption = 'Button Shadow'
      OnClick = PopupMenuClick
    end
    object GrayText1: TMenuItem
      Tag = 17
      Caption = 'Gray Text'
      OnClick = PopupMenuClick
    end
    object ButtonText1: TMenuItem
      Tag = 18
      Caption = 'Button Text'
      OnClick = PopupMenuClick
    end
    object InactiveCaptionText1: TMenuItem
      Tag = 19
      Caption = 'Inactive Caption Text'
      OnClick = PopupMenuClick
    end
    object Highlight2: TMenuItem
      Tag = 20
      Caption = 'Highlight'
      OnClick = PopupMenuClick
    end
    object N3dDarkShadow1: TMenuItem
      Tag = 21
      Caption = '3D Dark Shadow'
      OnClick = PopupMenuClick
    end
    object N3DLight1: TMenuItem
      Tag = 22
      Caption = '3D Light'
      OnClick = PopupMenuClick
    end
    object InfoTipText1: TMenuItem
      Tag = 23
      Caption = 'Info Tip Text'
      OnClick = PopupMenuClick
    end
    object InfoTipBackground1: TMenuItem
      Tag = 24
      Caption = 'Info Tip Background'
      OnClick = PopupMenuClick
    end
  end
  object ImageList1: TImageList
    Left = 72
    Top = 368
  end
  object FontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Options = [fdEffects, fdFixedPitchOnly]
    Left = 104
    Top = 368
  end
end
