object Form1: TForm1
  Left = 433
  Top = 151
  AutoSize = True
  Caption = 'my Way to SIMPLER'
  ClientHeight = 393
  ClientWidth = 705
  Color = clMoneyGreen
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object MainPaintBox: TPaintBox
    Left = 184
    Top = 0
    Width = 521
    Height = 281
  end
  object mainMemo: TMemo
    Left = 184
    Top = 288
    Width = 521
    Height = 105
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object TreeView1: TTreeView
    Left = 0
    Top = 0
    Width = 169
    Height = 393
    Color = clInactiveBorder
    Indent = 19
    ParentShowHint = False
    ShowHint = False
    TabOrder = 1
    OnDblClick = TreeView1DblClick
    Items.NodeData = {
      0303000000260000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF000000
      000200000001044D00650073006800340000000000000000000000FFFFFFFFFF
      FFFFFFFFFFFFFF0000000000000000010B430072006500610074006500200047
      0065006F006D00360000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF00
      00000000000000010C440079006E0061006D006900630020004D006500730068
      00380000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF00000000040000
      00010D500072006F0062006C0065006D002000530065007400750070002C0000
      000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000010747
      0065006E006500720061006C002E0000000000000000000000FFFFFFFFFFFFFF
      FFFFFFFFFF000000000000000001084500710075006100740069006F006E0030
      0000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF000000000000000001
      094D006100740065007200690061006C007300420000000000000000000000FF
      FFFFFFFFFFFFFFFFFFFFFF0000000000000000011242006F0075006E00640061
      0072007900200043006F006E0064006900740069006F006E002E000000000000
      0000000000FFFFFFFFFFFFFFFFFFFFFFFF0000000007000000010853006F006C
      007500740069006F006E00380000000000000000000000FFFFFFFFFFFFFFFFFF
      FFFFFF0000000000000000010D530065006C00650063007400200053006F006C
      007600650072002C0000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF00
      0000000000000001074D006500740068006F00640073002E0000000000000000
      000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000010843006F006E0074
      0072006F006C0073003A0000000000000000000000FFFFFFFFFFFFFFFFFFFFFF
      FF0000000000000000010E43006F006E00740072006F006C002000530049004D
      0050004C004500380000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF00
      00000000000000010D520065006C0061007800200046006100630074006F0072
      007300320000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000000002
      000000010A49006E0069007400690061006C0069007A00650032000000000000
      0000000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000010A49006E0069
      007400690061006C0069007A006500280000000000000000000000FFFFFFFFFF
      FFFFFFFFFFFFFF00000000000000000105500061007400630068003C00000000
      00000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000010F520075
      006E002000430061006C00630075006C006100740069006F006E00}
  end
  object cbbdisplay: TComboBox
    Left = 176
    Top = 0
    Width = 81
    Height = 21
    ItemIndex = 0
    TabOrder = 2
    Text = 'Residual'
    OnChange = cbbdisplayChange
    Items.Strings = (
      'Residual'
      'Monitors')
  end
  object MainMenu1: TMainMenu
    object File1: TMenuItem
      Caption = 'File'
      object Read1: TMenuItem
        Caption = 'Read'
        object Mesh3: TMenuItem
          Caption = 'Mesh'
          OnClick = Mesh3Click
        end
      end
      object Write1: TMenuItem
        Caption = 'Write'
        object Mesh4: TMenuItem
          Caption = 'Mesh'
          OnClick = Mesh4Click
        end
      end
      object Export1: TMenuItem
        Caption = 'Export'
        object ecplot1: TMenuItem
          Caption = 'Tecplot'
          OnClick = ecplot1Click
        end
        object AliceFlow2D1: TMenuItem
          Caption = 'AliceFlow2D'
          OnClick = AliceFlow2D1Click
        end
      end
      object Close1: TMenuItem
        Caption = 'Close'
        OnClick = Close1Click
      end
    end
    object Mesh1: TMenuItem
      Caption = 'Mesh'
      object CreateGeom1: TMenuItem
        Caption = 'CreateGeom'
        OnClick = CreateGeom1Click
      end
      object DynamicMesh1: TMenuItem
        Caption = 'Dynamic Mesh'
        OnClick = DynamicMesh1Click
      end
    end
    object Define1: TMenuItem
      Caption = 'Define'
      object General1: TMenuItem
        Caption = 'General'
        OnClick = General1Click
      end
      object Equation1: TMenuItem
        Caption = 'Equation'
        OnClick = Equation1Click
      end
      object Materials1: TMenuItem
        Caption = 'Materials'
        OnClick = Materials1Click
      end
      object BoundaryCondition1: TMenuItem
        Caption = 'Boundary Condition'
        OnClick = BoundaryCondition1Click
      end
      object Source1: TMenuItem
        Caption = 'Source'
        OnClick = Source1Click
      end
      object Gravity1: TMenuItem
        Caption = 'Gravity'
        OnClick = Gravity1Click
      end
      object UserDefined1: TMenuItem
        Caption = 'User-Defined'
        object Memory1: TMenuItem
          Caption = 'Memory...'
          OnClick = Memory1Click
        end
        object Scalars1: TMenuItem
          Caption = 'Scalars...'
          OnClick = Scalars1Click
        end
      end
      object CustomFieldFunctions1: TMenuItem
        Caption = 'Custom Field Functions...'
        OnClick = CustomFieldFunctions1Click
      end
      object rials1: TMenuItem
        Caption = 'Trials'
        OnClick = rials1Click
      end
    end
    object Solve1: TMenuItem
      Caption = 'Solve'
      object SelectSolver1: TMenuItem
        Caption = 'Select Solver'
        OnClick = SelectSolver1Click
      end
      object ApproxConvection1: TMenuItem
        Caption = 'Methods'
        OnClick = ApproxConvection1Click
      end
      object Controls1: TMenuItem
        Caption = 'Controls'
        object Solution1: TMenuItem
          Caption = 'Solution'
          OnClick = Solution1Click
        end
        object SoprGrad1: TMenuItem
          Caption = 'SoprGrad'
          OnClick = SoprGrad1Click
        end
        object SIMPLE1: TMenuItem
          Caption = 'SIMPLE'
          OnClick = SIMPLE1Click
        end
        object Pressure1: TMenuItem
          Caption = 'Pressure'
          OnClick = Pressure1Click
        end
        object Limits1: TMenuItem
          Caption = 'Limits'
          OnClick = Limits1Click
        end
      end
      object RelaxationFactors1: TMenuItem
        Caption = 'Relaxation Factors'
        OnClick = RelaxationFactors1Click
      end
      object Initialize1: TMenuItem
        Caption = 'Initialize'
        object initialize2: TMenuItem
          Caption = 'Initialize'
          OnClick = initialize2Click
        end
        object Patch1: TMenuItem
          Caption = 'Patch'
          OnClick = Patch1Click
        end
      end
      object Run1: TMenuItem
        Caption = 'Run'
        OnClick = Run1Click
      end
    end
    object Display1: TMenuItem
      Caption = 'Display'
      object Mesh2: TMenuItem
        Caption = 'Mesh'
        OnClick = Mesh2Click
      end
      object N2Dplot1: TMenuItem
        Caption = '2Dplot'
        OnClick = N2Dplot1Click
      end
      object UseInterpolate1: TMenuItem
        Caption = 'UseInterpolate'
        OnClick = UseInterpolate1Click
      end
      object Animation1: TMenuItem
        Caption = 'Animation'
        OnClick = Animation1Click
      end
    end
    object guiParallel1: TMenuItem
      Caption = 'Parallel'
      object guilanguage1: TMenuItem
        Caption = 'language'
        OnClick = guilanguage1Click
      end
    end
    object guiInterpritator1: TMenuItem
      Caption = 'Interpritator'
      object guiest1: TMenuItem
        Caption = 'Test'
        OnClick = guiest1Click
      end
      object guinotepad1: TMenuItem
        Caption = 'notepad'
        OnClick = guinotepad1Click
      end
      object Help1: TMenuItem
        Caption = 'Help'
        OnClick = Help1Click
      end
      object guiBenarFLOW1: TMenuItem
        Caption = 'BenarFLOW'
        OnClick = guiBenarFLOW1Click
      end
    end
    object Report1: TMenuItem
      Caption = 'Report'
      object SurfaceIntegrals1: TMenuItem
        Caption = 'Surface Integrals'
        OnClick = SurfaceIntegrals1Click
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Top = 32
  end
end
