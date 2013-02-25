object mainFrm: TmainFrm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Text search in files'
  ClientHeight = 309
  ClientWidth = 582
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  GlassFrame.Enabled = True
  GlassFrame.Top = 46
  KeyPreview = True
  OldCreateOrder = False
  Position = poDesktopCenter
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    582
    309)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    AlignWithMargins = True
    Left = 8
    Top = 4
    Width = 565
    Height = 45
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'Please select parameters'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHighlightText
    Font.Height = 40
    Font.Name = 'Tahoma'
    Font.Style = []
    Font.Quality = fqAntialiased
    ParentFont = False
    Layout = tlCenter
  end
  object PageControl1: TPageControl
    Left = 8
    Top = 56
    Width = 441
    Height = 250
    ActivePage = TabSheet1
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'Name and Location'
      DesignSize = (
        433
        222)
      object Label2: TLabel
        Left = 17
        Top = 25
        Width = 48
        Height = 13
        Caption = 'File Types'
      end
      object Label4: TLabel
        Left = 17
        Top = 66
        Width = 30
        Height = 13
        Caption = 'Folder'
      end
      object ComboBox1: TComboBox
        Left = 104
        Top = 22
        Width = 313
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
      end
      object ComboBox2: TComboBox
        Left = 104
        Top = 63
        Width = 289
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
      end
      object CheckBox1: TCheckBox
        Left = 104
        Top = 88
        Width = 121
        Height = 17
        Caption = 'Search Subfolders'
        TabOrder = 2
      end
      object Button3: TButton
        Left = 394
        Top = 61
        Width = 23
        Height = 25
        Anchors = [akTop, akRight]
        Caption = '...'
        TabOrder = 3
        OnClick = Button3Click
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Date, Size and Attributes'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        433
        222)
      object GroupBox2: TGroupBox
        Left = 17
        Top = 25
        Width = 240
        Height = 110
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Date'
        TabOrder = 0
        DesignSize = (
          240
          110)
        object Label6: TLabel
          Left = 31
          Top = 55
          Width = 42
          Height = 13
          Caption = 'between'
        end
        object Label7: TLabel
          Left = 55
          Top = 79
          Width = 18
          Height = 13
          Alignment = taRightJustify
          Caption = 'and'
        end
        object ComboBox4: TComboBox
          Left = 16
          Top = 21
          Width = 209
          Height = 21
          Style = csDropDownList
          Anchors = [akLeft, akTop, akRight]
          ItemIndex = 0
          TabOrder = 0
          Text = 'Ignore date'
          OnClick = ComboBox4Click
          Items.Strings = (
            'Ignore date'
            'Files modified'
            'Files created'
            'Files last accessed')
        end
        object DateTimePicker1: TDateTimePicker
          Left = 80
          Top = 50
          Width = 145
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          Date = 41328.411226134260000000
          Format = 'dd/MM/yyyy HH:mm'
          Time = 41328.411226134260000000
          Enabled = False
          ParseInput = True
          TabOrder = 1
        end
        object DateTimePicker2: TDateTimePicker
          Left = 80
          Top = 77
          Width = 145
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          Date = 41328.411226134260000000
          Format = 'dd/MM/yyyy HH:mm'
          Time = 41328.411226134260000000
          Enabled = False
          ParseInput = True
          TabOrder = 2
        end
      end
      object GroupBox3: TGroupBox
        Left = 272
        Top = 25
        Width = 140
        Height = 184
        Anchors = [akTop, akRight]
        Caption = ' File Attributes '
        TabOrder = 1
        object CheckBox5: TCheckBox
          Left = 16
          Top = 23
          Width = 116
          Height = 17
          AllowGrayed = True
          Caption = 'Archive'
          State = cbGrayed
          TabOrder = 0
        end
        object CheckBox6: TCheckBox
          Left = 16
          Top = 41
          Width = 116
          Height = 17
          AllowGrayed = True
          Caption = 'Read-only'
          State = cbGrayed
          TabOrder = 1
        end
        object CheckBox7: TCheckBox
          Left = 16
          Top = 60
          Width = 116
          Height = 17
          AllowGrayed = True
          Caption = 'System'
          State = cbGrayed
          TabOrder = 2
        end
        object CheckBox8: TCheckBox
          Left = 16
          Top = 78
          Width = 116
          Height = 17
          AllowGrayed = True
          Caption = 'Hidden'
          State = cbGrayed
          TabOrder = 3
        end
        object CheckBox9: TCheckBox
          Left = 16
          Top = 97
          Width = 116
          Height = 17
          AllowGrayed = True
          Caption = 'Compressed'
          State = cbGrayed
          TabOrder = 4
        end
        object CheckBox10: TCheckBox
          Left = 16
          Top = 115
          Width = 116
          Height = 17
          AllowGrayed = True
          Caption = 'Encrypted'
          State = cbGrayed
          TabOrder = 5
        end
        object CheckBox11: TCheckBox
          Left = 16
          Top = 134
          Width = 116
          Height = 17
          AllowGrayed = True
          Caption = 'Offline'
          State = cbGrayed
          TabOrder = 6
        end
        object CheckBox12: TCheckBox
          Left = 16
          Top = 153
          Width = 116
          Height = 17
          AllowGrayed = True
          Caption = 'Reparse point'
          State = cbGrayed
          TabOrder = 7
        end
      end
      object GroupBox4: TGroupBox
        Left = 17
        Top = 141
        Width = 240
        Height = 68
        Anchors = [akLeft, akTop, akRight]
        Caption = ' Size '
        TabOrder = 2
        DesignSize = (
          240
          68)
        object Edit1: TEdit
          Left = 79
          Top = 16
          Width = 89
          Height = 21
          Enabled = False
          TabOrder = 0
        end
        object ComboBox5: TComboBox
          Left = 176
          Top = 16
          Width = 56
          Height = 21
          Style = csDropDownList
          Anchors = [akTop, akRight]
          Enabled = False
          ItemIndex = 0
          TabOrder = 1
          Text = 'Bytes'
          Items.Strings = (
            'Bytes'
            'KiB'
            'MiB'
            'GiB')
        end
        object CheckBox13: TCheckBox
          Left = 12
          Top = 18
          Width = 61
          Height = 17
          Caption = 'Minimum'
          TabOrder = 2
        end
        object CheckBox14: TCheckBox
          Left = 12
          Top = 42
          Width = 61
          Height = 17
          Caption = 'Maximum'
          TabOrder = 3
        end
        object Edit2: TEdit
          Left = 80
          Top = 41
          Width = 89
          Height = 21
          Enabled = False
          TabOrder = 4
        end
        object ComboBox6: TComboBox
          Left = 176
          Top = 41
          Width = 56
          Height = 21
          Style = csDropDownList
          Anchors = [akTop, akRight]
          Enabled = False
          ItemIndex = 0
          TabOrder = 5
          Text = 'Bytes'
          Items.Strings = (
            'Bytes'
            'KiB'
            'MiB'
            'GiB')
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Advanced'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        433
        222)
      object GroupBox1: TGroupBox
        Left = 17
        Top = 25
        Width = 392
        Height = 184
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = '  Find text  '
        TabOrder = 0
        DesignSize = (
          392
          184)
        object Label3: TLabel
          Left = 23
          Top = 35
          Width = 22
          Height = 13
          Caption = 'Text'
        end
        object ComboBox3: TComboBox
          Left = 53
          Top = 32
          Width = 329
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
        end
        object CheckBox2: TCheckBox
          Left = 53
          Top = 65
          Width = 97
          Height = 17
          Caption = 'Case sensitive'
          Enabled = False
          TabOrder = 1
        end
        object CheckBox3: TCheckBox
          Left = 217
          Top = 65
          Width = 136
          Height = 17
          Anchors = [akTop, akRight]
          Caption = 'ASCII Charset (DOS)'
          TabOrder = 2
        end
        object CheckBox4: TCheckBox
          Left = 217
          Top = 87
          Width = 97
          Height = 17
          Anchors = [akTop, akRight]
          Caption = 'UTF-8'
          TabOrder = 3
        end
        object CheckBox15: TCheckBox
          Left = 217
          Top = 110
          Width = 97
          Height = 17
          Anchors = [akTop, akRight]
          Caption = 'UTF-16'
          TabOrder = 4
        end
      end
    end
  end
  object Button1: TButton
    Left = 462
    Top = 80
    Width = 110
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Search'
    Default = True
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 462
    Top = 112
    Width = 110
    Height = 25
    Anchors = [akTop, akRight]
    Cancel = True
    Caption = 'Stop'
    Enabled = False
    TabOrder = 2
    OnClick = Button2Click
  end
  object IL: TImageList
    DrawingStyle = dsTransparent
    Left = 472
    Top = 248
  end
  object XPManifest1: TXPManifest
    Left = 512
    Top = 248
  end
  object BindingsList1: TBindingsList
    Methods = <>
    OutputConverters = <>
    UseAppManager = True
    Left = 508
    Top = 205
    object LinkControlToProperty1: TLinkControlToProperty
      Category = 'Quick Bindings'
      Control = CheckBox13
      Track = True
      Component = Edit1
      ComponentProperty = 'Enabled'
    end
    object LinkControlToProperty2: TLinkControlToProperty
      Category = 'Quick Bindings'
      Control = CheckBox13
      Track = True
      Component = ComboBox5
      ComponentProperty = 'Enabled'
      InitializeControlValue = False
    end
    object LinkControlToProperty3: TLinkControlToProperty
      Category = 'Quick Bindings'
      Control = CheckBox14
      Track = True
      Component = Edit2
      ComponentProperty = 'Enabled'
    end
    object LinkControlToProperty4: TLinkControlToProperty
      Category = 'Quick Bindings'
      Control = CheckBox14
      Track = True
      Component = ComboBox6
      ComponentProperty = 'Enabled'
      InitializeControlValue = False
    end
  end
end
