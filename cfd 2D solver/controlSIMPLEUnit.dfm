object controlSIMPLEForm: TcontrolSIMPLEForm
  Left = 501
  Top = 279
  AutoSize = True
  Caption = #1089#1090#1088#1091#1082#1090#1091#1088#1072' '#1086#1076#1085#1086#1081' '#1080#1090#1077#1088#1072#1094#1080#1080' '#1072#1083#1075#1086#1088#1080#1090#1084#1072' SIMPLE'
  ClientHeight = 217
  ClientWidth = 433
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object btnBapply: TButton
    Left = 320
    Top = 192
    Width = 105
    Height = 25
    Caption = 'Apply'
    TabOrder = 0
    OnClick = btnBapplyClick
  end
  object grpmainpanel: TGroupBox
    Left = 0
    Top = 0
    Width = 433
    Height = 185
    Caption = 'Set the maximum number of iterations'
    TabOrder = 1
    object grpvelocitycomponent: TGroupBox
      Left = 8
      Top = 24
      Width = 201
      Height = 73
      Caption = 'velocity component'
      TabOrder = 0
      object lbl1: TLabel
        Left = 8
        Top = 16
        Width = 47
        Height = 13
        Caption = 'X-Velocity'
      end
      object lbl2: TLabel
        Left = 106
        Top = 16
        Width = 47
        Height = 13
        Caption = 'Y-Velocity'
      end
      object edtEVxlin: TEdit
        Left = 8
        Top = 40
        Width = 81
        Height = 21
        TabOrder = 0
      end
      object edtEVylin: TEdit
        Left = 104
        Top = 40
        Width = 81
        Height = 21
        TabOrder = 1
      end
    end
    object grpcorrection_to_the_pressure: TGroupBox
      Left = 216
      Top = 32
      Width = 145
      Height = 49
      Caption = 'correction to the pressure'
      TabOrder = 1
      object edtEPamendment: TEdit
        Left = 8
        Top = 16
        Width = 81
        Height = 21
        TabOrder = 0
      end
    end
    object grpStreamFunction: TGroupBox
      Left = 8
      Top = 104
      Width = 105
      Height = 49
      Caption = 'Stream Function'
      TabOrder = 2
      object edtStreamFunction: TEdit
        Left = 8
        Top = 16
        Width = 81
        Height = 21
        TabOrder = 0
      end
    end
    object grptemperature: TGroupBox
      Left = 120
      Top = 104
      Width = 81
      Height = 49
      Caption = 'Temperature'
      TabOrder = 3
      object edtTemperature: TEdit
        Left = 8
        Top = 16
        Width = 65
        Height = 21
        TabOrder = 0
      end
    end
    object grppressure: TGroupBox
      Left = 216
      Top = 88
      Width = 113
      Height = 41
      Caption = 'Pressure (SIMPLER)'
      TabOrder = 4
      object edtPressure: TEdit
        Left = 8
        Top = 16
        Width = 89
        Height = 21
        TabOrder = 0
      end
    end
    object grpUDS: TGroupBox
      Left = 216
      Top = 136
      Width = 185
      Height = 41
      Caption = 'UDS'
      TabOrder = 5
      object lbluds: TLabel
        Left = 8
        Top = 16
        Width = 26
        Height = 13
        Caption = 'Index'
      end
      object cbbuds: TComboBox
        Left = 40
        Top = 8
        Width = 49
        Height = 21
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 0
        Text = '1'
        OnChange = cbbudsChange
        Items.Strings = (
          '1'
          '2'
          '3'
          '4')
      end
      object edtuds: TEdit
        Left = 96
        Top = 8
        Width = 81
        Height = 21
        TabOrder = 1
      end
    end
    object GBVOF: TGroupBox
      Left = 336
      Top = 88
      Width = 81
      Height = 41
      Caption = 'VOF'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 6
      object EVOF: TEdit
        Left = 8
        Top = 16
        Width = 65
        Height = 21
        TabOrder = 0
      end
    end
  end
end
