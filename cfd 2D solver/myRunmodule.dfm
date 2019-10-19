object myRun: TmyRun
  Left = 341
  Top = 172
  AutoSize = True
  Caption = 'Launching the decision'
  ClientHeight = 273
  ClientWidth = 267
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 267
    Height = 235
    AutoSize = True
    Color = clMoneyGreen
    TabOrder = 0
    object Label4: TLabel
      Left = 1
      Top = 1
      Width = 129
      Height = 13
      Caption = 'calculation parameters'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Panel1: TPanel
      Left = 1
      Top = 33
      Width = 265
      Height = 145
      Color = clSkyBlue
      TabOrder = 0
      Visible = False
      object Lrealtimenow: TLabel
        Left = 16
        Top = 24
        Width = 57
        Height = 13
        Caption = 'present time'
      end
      object Ltimestepnow: TLabel
        Left = 16
        Top = 64
        Width = 81
        Height = 13
        Caption = #1096#1072#1075' '#1087#1086' '#1074#1088#1077#1084#1077#1085#1080
      end
      object Lnumbertimestep: TLabel
        Left = 16
        Top = 104
        Width = 129
        Height = 13
        Caption = #1082#1086#1083'-'#1074#1086' '#1096#1072#1075#1086#1074' '#1087#1086' '#1074#1088#1077#1084#1077#1085#1080
      end
      object ErealFlowTimeVal: TEdit
        Left = 128
        Top = 16
        Width = 57
        Height = 21
        TabOrder = 0
        Text = '0'
      end
      object Etimestep: TEdit
        Left = 200
        Top = 56
        Width = 57
        Height = 21
        TabOrder = 1
        Text = '1e-1'
      end
      object Enumbertimestep: TEdit
        Left = 200
        Top = 96
        Width = 57
        Height = 21
        TabOrder = 2
        Text = '10'
      end
    end
    object Panel3: TPanel
      Left = 1
      Top = 193
      Width = 257
      Height = 41
      Color = clSkyBlue
      TabOrder = 1
      object Liternumber: TLabel
        Left = 16
        Top = 12
        Width = 87
        Height = 13
        Caption = 'number of iteration'
      end
      object Eitercount: TEdit
        Left = 152
        Top = 12
        Width = 65
        Height = 21
        TabOrder = 0
        Text = '20'
      end
    end
  end
  object Biterate: TButton
    Left = 144
    Top = 248
    Width = 123
    Height = 25
    Caption = 'Start Calculation'
    TabOrder = 1
    OnClick = BiterateClick
  end
end
