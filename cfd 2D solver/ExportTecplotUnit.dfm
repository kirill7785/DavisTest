object ExportTecplotForm: TExportTecplotForm
  Left = 461
  Top = 218
  Caption = #1087#1077#1088#1077#1076#1072#1095#1072' '#1082#1072#1088#1090#1080#1085#1082#1080' '#1074' '#1087#1088#1086#1075#1088#1072#1084#1084#1091' tecplot'
  ClientHeight = 329
  ClientWidth = 620
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 16
    Top = 8
    Width = 233
    Height = 305
    Color = clMoneyGreen
    TabOrder = 0
    object RadioGroup1: TRadioGroup
      Left = 16
      Top = 8
      Width = 201
      Height = 257
      Caption = 'Export Tecplot'
      Color = clSkyBlue
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ItemIndex = 4
      Items.Strings = (
        #1043#1086#1088#1080#1079#1086#1085#1090#1072#1083#1100#1085#1072#1103' '#1089#1082#1086#1088#1086#1089#1090#1100
        #1042#1077#1088#1090#1080#1082#1072#1083#1100#1085#1072#1103' '#1089#1082#1086#1088#1086#1089#1090#1100
        #1042#1080#1093#1088#1100' '#1080' '#1060#1091#1085#1082#1094#1080#1103' '#1090#1086#1082#1072
        #1044#1072#1074#1083#1077#1085#1080#1077
        #1058#1077#1084#1087#1077#1088#1072#1090#1091#1088#1072
        'Custom Field Functions'
        #1092#1091#1085#1082#1094#1080#1103' '#1094#1074#1077#1090#1072' (VOF)'
        'User-Defined Memory'
        'User-Defined Scalar')
      ParentColor = False
      ParentFont = False
      TabOrder = 0
    end
    object Bapply: TButton
      Left = 56
      Top = 272
      Width = 161
      Height = 25
      Caption = #1087#1077#1088#1077#1076#1072#1090#1100' '#1082#1072#1088#1090#1080#1085#1082#1091
      TabOrder = 1
      OnClick = BapplyClick
    end
  end
  object Panelmean: TPanel
    Left = 264
    Top = 160
    Width = 337
    Height = 153
    Color = clMoneyGreen
    TabOrder = 1
    object BFlow: TButton
      Left = 176
      Top = 120
      Width = 145
      Height = 25
      Caption = #1087#1077#1088#1077#1076#1072#1090#1100' '#1082#1072#1088#1090#1080#1085#1082#1080
      TabOrder = 0
      OnClick = BFlowClick
    end
    object GroupBox1: TGroupBox
      Left = 16
      Top = 16
      Width = 305
      Height = 97
      Caption = #1054#1089#1088#1077#1076#1085#1105#1085#1085#1099#1077' '#1074#1077#1083#1080#1095#1080#1085#1099
      Color = clSkyBlue
      ParentColor = False
      TabOrder = 1
      object Label1: TLabel
        Left = 16
        Top = 24
        Width = 109
        Height = 13
        Caption = 'mean-Stream-Function,'
      end
      object Label2: TLabel
        Left = 136
        Top = 24
        Width = 50
        Height = 13
        Caption = 'mean-Curl,'
      end
      object LmeanT: TLabel
        Left = 136
        Top = 72
        Width = 86
        Height = 13
        Caption = ',mean-Tempreture'
      end
      object Label4: TLabel
        Left = 192
        Top = 24
        Width = 79
        Height = 13
        Caption = 'mean-X-Velocity,'
      end
      object Label5: TLabel
        Left = 16
        Top = 48
        Width = 78
        Height = 13
        Caption = 'mean-Y-velocity,'
      end
      object Label6: TLabel
        Left = 104
        Top = 48
        Width = 121
        Height = 13
        Caption = 'mean-Velocity-Magnityde,'
      end
      object Label3: TLabel
        Left = 16
        Top = 72
        Width = 103
        Height = 13
        Caption = 'mean-velocity-vectors'
      end
    end
  end
  object PexportTecplot: TPanel
    Left = 264
    Top = 16
    Width = 337
    Height = 137
    Color = clMoneyGreen
    TabOrder = 2
    object Bextec: TButton
      Left = 176
      Top = 104
      Width = 145
      Height = 25
      Caption = #1087#1077#1088#1077#1076#1072#1090#1100' '#1082#1072#1088#1090#1080#1085#1082#1080
      TabOrder = 0
      OnClick = BextecClick
    end
    object GroupBox2: TGroupBox
      Left = 16
      Top = 16
      Width = 305
      Height = 81
      Caption = #1055#1077#1088#1077#1076#1072#1095#1072' '#1082#1072#1088#1090#1080#1085#1086#1082' '#1074' '#1087#1088#1086#1075#1088#1072#1084#1084#1091' Tecplot 360'
      Color = clSkyBlue
      ParentColor = False
      TabOrder = 1
      object Label7: TLabel
        Left = 16
        Top = 24
        Width = 233
        Height = 13
        Caption = 'Stream-Function, Curl, Vx, Vy, velocity-magnityde,'
      end
      object Label8: TLabel
        Left = 16
        Top = 48
        Width = 127
        Height = 13
        Caption = 'velocity vectors, Pressure  '
      end
      object LT: TLabel
        Left = 144
        Top = 48
        Width = 69
        Height = 13
        Caption = ', Temperature.'
      end
      object lblVOF: TLabel
        Left = 224
        Top = 48
        Width = 24
        Height = 13
        Caption = 'VOF.'
      end
    end
  end
end
