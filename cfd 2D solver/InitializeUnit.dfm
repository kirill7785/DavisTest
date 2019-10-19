object myInitialize: TmyInitialize
  Left = 468
  Top = 165
  Caption = 'Initialize'
  ClientHeight = 510
  ClientWidth = 313
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object PAllFunction: TPanel
    Left = 0
    Top = 0
    Width = 313
    Height = 505
    Color = clMoneyGreen
    TabOrder = 0
    object Label1: TLabel
      Left = 48
      Top = 16
      Width = 69
      Height = 13
      Caption = 'Initialization'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object PFlow: TPanel
      Left = 24
      Top = 40
      Width = 273
      Height = 81
      Color = clMoneyGreen
      TabOrder = 0
      object Lxvel: TLabel
        Left = 24
        Top = 16
        Width = 81
        Height = 13
        Caption = 'Horizontal Speed'
      end
      object Lyvel: TLabel
        Left = 24
        Top = 48
        Width = 69
        Height = 13
        Caption = 'Vertical Speed'
      end
      object EinitXvel: TEdit
        Left = 112
        Top = 16
        Width = 145
        Height = 21
        TabOrder = 0
        Text = '0'
      end
      object EinitYvel: TEdit
        Left = 112
        Top = 48
        Width = 145
        Height = 21
        TabOrder = 1
        Text = '0'
      end
    end
    object PTempreture: TPanel
      Left = 24
      Top = 128
      Width = 185
      Height = 49
      Color = clMoneyGreen
      TabOrder = 1
      object Ltempreture: TLabel
        Left = 16
        Top = 16
        Width = 60
        Height = 13
        Caption = 'Temperature'
      end
      object EinitTemp: TEdit
        Left = 96
        Top = 16
        Width = 73
        Height = 21
        TabOrder = 0
        Text = '0'
      end
    end
    object Binitialize: TButton
      Left = 24
      Top = 472
      Width = 251
      Height = 25
      Caption = 'Initialize'
      TabOrder = 2
      OnClick = BinitializeClick
    end
    object PanelVof: TPanel
      Left = 24
      Top = 184
      Width = 185
      Height = 49
      Color = clMoneyGreen
      TabOrder = 3
      object LabelVOF: TLabel
        Left = 16
        Top = 16
        Width = 65
        Height = 13
        Caption = 'Color function'
      end
      object cbbvof: TComboBox
        Left = 104
        Top = 16
        Width = 73
        Height = 21
        ItemIndex = 0
        TabOrder = 0
        Text = '0.0'
        Items.Strings = (
          '0.0'
          '1.0')
      end
    end
    object grpuds1: TGroupBox
      Left = 24
      Top = 248
      Width = 273
      Height = 49
      Caption = 'UDS1'
      Color = clMoneyGreen
      ParentColor = False
      TabOrder = 4
      object edtuds1: TEdit
        Left = 8
        Top = 16
        Width = 257
        Height = 21
        TabOrder = 0
      end
    end
    object grpuds2: TGroupBox
      Left = 24
      Top = 304
      Width = 273
      Height = 49
      Caption = 'UDS2'
      Color = clMoneyGreen
      ParentColor = False
      TabOrder = 5
      object edtuds2: TEdit
        Left = 8
        Top = 16
        Width = 257
        Height = 21
        TabOrder = 0
      end
    end
    object grpuds3: TGroupBox
      Left = 24
      Top = 360
      Width = 273
      Height = 49
      Caption = 'UDS3'
      Color = clMoneyGreen
      ParentColor = False
      TabOrder = 6
      object edtuds3: TEdit
        Left = 8
        Top = 16
        Width = 257
        Height = 21
        TabOrder = 0
      end
    end
    object grpuds4: TGroupBox
      Left = 24
      Top = 416
      Width = 273
      Height = 49
      Caption = 'UDS4'
      Color = clMoneyGreen
      ParentColor = False
      TabOrder = 7
      object edtuds4: TEdit
        Left = 8
        Top = 16
        Width = 257
        Height = 21
        TabOrder = 0
      end
    end
  end
end
