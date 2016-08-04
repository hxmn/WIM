Imports TalismanEnergy.WIM.Common
Imports TalismanEnergy.WIM.Common.AppConstants
Imports TalismanEnergy.WIM.GatewayProxy
Imports ComponentArt.Web.UI

Partial Public Class WellVersionDetail
  Inherits System.Web.UI.MasterPage

  ' The Master FindControl seems to be completely broken for nester Masters.
  ' Override with or implementation, falling back to the default if the control is not found
  Public Overrides Function FindControl(ByVal id As String) As Control
    Dim c As Control
    c = Master.FindControl("form1").FindControl("ContentPlaceHolder1").FindControl(id)
    If c Is Nothing Then
      c = MyBase.FindControl(id)
    End If
    Return c
  End Function

  Public ReadOnly Property ControlCausedCallback() As Boolean
    Get

      Return ddlSource.CausedCallback _
        OrElse ddlCountry.CausedCallback _
        OrElse ddlProvState.CausedCallback _
        OrElse ddlCounty.CausedCallback _
        OrElse ddlOnOffShoreInd.CausedCallback _
        OrElse ddlWellProfileType.CausedCallback _
        OrElse ddlCurrentStatus.CausedCallback _
        OrElse ddlOperator.CausedCallback _
        OrElse ddlLicensee.CausedCallback _
        OrElse ddlGroundElevUnits.CausedCallback _
        OrElse ddlKBElevUnits.CausedCallback _
        OrElse ddlDerrickFloorUnits.CausedCallback _
        OrElse ddlWaterDepthUnits.CausedCallback _
        OrElse ddlCasingFlangeUnits.CausedCallback _
        OrElse ddlTotalDepthUnits.CausedCallback _
        OrElse DataGrid1.CausedCallback _
        OrElse ddlOldestStratAge.CausedCallback _
        OrElse ddlTDStratAge.CausedCallback _
        OrElse ddlPlugbackDepthUnits.CausedCallback _
        OrElse ddlMaxTVDUnits.CausedCallback _
        OrElse ddlNodePos.CausedCallback _
        OrElse ddlNodeDatum.CausedCallback _
        OrElse ddlBasinName.CausedCallback _
        OrElse ddlRigType.CausedCallback



    End Get
  End Property

#Region "Source"

  Private Sub LoadSourceItems(ByVal iStartIndex As Integer, _
                              ByVal iNumItems As Integer, _
                              ByVal sFilter As String)

    Dim SourceLookUpList As DataTable = CType(Session("UserPermissions"), DataSet).Tables(Permission)

    ddlSource.Items.Clear()

    If sFilter.Length > 0 Then
      If sFilter.IndexOf("'") > 0 Then
        sFilter = sFilter.Replace("'", "''")
      End If
      SourceLookUpList.DefaultView.RowFilter = "SHORT_NAME LIKE '" + sFilter + "%'"
    ElseIf sFilter.Length = 0 Then
      SourceLookUpList.DefaultView.RowFilter = "SHORT_NAME LIKE '%'"
    End If

    SourceLookUpList.DefaultView.Sort = "SHORT_NAME ASC"

    Dim rowViewCount As Integer = SourceLookUpList.DefaultView.Count
    Dim i As Integer = iStartIndex
    Dim iEndIndex As Integer = Math.Min(iStartIndex + iNumItems, rowViewCount)
    Dim oRow As DataRowView
    Dim oItem As ComboBoxItem

    Do While (i < iEndIndex And i < rowViewCount)
      oRow = SourceLookUpList.DefaultView(i)
      oItem = New ComboBoxItem
      oItem.Value = oRow("SOURCE").ToString()
      oItem.Text = oRow("SHORT_NAME").ToString()
      ddlSource.Items.Add(oItem)
      i += 1
    Loop

    ddlSource.ItemCount = Math.Min(rowViewCount, iEndIndex + ddlSource.DropDownPageSize)

  End Sub

  Private _permission As String
  Public Property Permission() As String
    Get
      Return _permission
    End Get
    Set(ByVal value As String)
      _permission = value
    End Set
  End Property

  Public Sub ddlSource_DataRequested(ByVal sender As System.Object, _
                                     ByVal e As ComponentArt.Web.UI.ComboBoxDataRequestedEventArgs) _
  Handles ddlSource.DataRequested

    LoadSourceItems(e.StartIndex, e.NumItems, e.Filter)

  End Sub

#End Region

#Region "Country"

  Private Sub LoadCountryItems(ByVal iStartIndex As Integer, ByVal iNumItems As Integer, ByVal sFilter As String)

    Dim CountryLookUpList As DataTable = GetLookUpList(APP_COUNTRY_LOOKUP_DATA)

    ddlCountry.Items.Clear()

    If sFilter.Length > 0 Then
      If sFilter.IndexOf("'") > 0 Then
        sFilter = sFilter.Replace("'", "''")
      End If
      CountryLookUpList.DefaultView.RowFilter = "LONG_NAME LIKE '" + sFilter + "%'"
    ElseIf sFilter.Length = 0 Then
      CountryLookUpList.DefaultView.RowFilter = "LONG_NAME LIKE '%'"
    End If

    CountryLookUpList.DefaultView.Sort = "LONG_NAME ASC"

    Dim rowViewCount As Integer = CountryLookUpList.DefaultView.Count
    Dim i As Integer = iStartIndex
    Dim iEndIndex As Integer = Math.Min(iStartIndex + iNumItems, rowViewCount)
    Dim oRow As DataRowView
    Dim oItem As ComboBoxItem

    Do While (i < iEndIndex And i < rowViewCount)
      oRow = CountryLookUpList.DefaultView(i)
      oItem = New ComboBoxItem
      oItem.Value = oRow("COUNTRY").ToString()
      oItem.Text = oRow("LONG_NAME").ToString()
      ddlCountry.Items.Add(oItem)
      i += 1
    Loop

    ddlCountry.ItemCount = Math.Min(rowViewCount, iEndIndex + ddlCountry.DropDownPageSize)

  End Sub

  Public Sub ddlCountry_DataRequested(ByVal sender As System.Object, ByVal e As ComponentArt.Web.UI.ComboBoxDataRequestedEventArgs) Handles ddlCountry.DataRequested

    LoadCountryItems(e.StartIndex, e.NumItems, e.Filter)

  End Sub

#End Region

#Region "Province State"

  Private Sub LoadProvStateItems(ByVal iStartIndex As Integer, ByVal iNumItems As Integer, ByVal sFilter As String)

    Dim ProvStateLookUpList As DataTable = GetLookUpList(APP_PROVINCESTATE_LOOKUP_DATA)
    Dim oRow As DataRowView
    Dim oItem As ComboBoxItem

    ddlProvState.Items.Clear()

    If sFilter.Length > 0 Then
      ProvStateLookUpList.DefaultView.RowFilter = "COUNTRY = '" & sFilter & "'"
      ProvStateLookUpList.DefaultView.Sort = "LONG_NAME ASC"

      For Each oRow In ProvStateLookUpList.DefaultView
        oItem = New ComboBoxItem
        oItem.Value = String.Format("{0},{1}", oRow("COUNTRY"), oRow("PROVINCE_STATE"))
        oItem.Text = oRow("LONG_NAME").ToString()
        ddlProvState.Items.Add(oItem)
      Next

      ddlProvState.ItemCount = ddlProvState.Items.Count

    End If

  End Sub

  Public Sub ddlProvState_DataRequested(ByVal sender As System.Object, ByVal e As ComponentArt.Web.UI.ComboBoxDataRequestedEventArgs) Handles ddlProvState.DataRequested

    LoadProvStateItems(e.StartIndex, e.NumItems, e.Filter)

  End Sub

#End Region

#Region "County"

  Private Sub LoadCountyItems(ByVal iStartIndex As Integer, ByVal iNumItems As Integer, ByVal sFilter As String)

    Dim CountyLookUpList As DataTable = GetLookUpList(APP_COUNTY_LOOKUP_DATA)
    Dim oRow As DataRowView
    Dim oItem As ComboBoxItem

    ddlCounty.Items.Clear()

    If sFilter.Length > 0 Then
      Dim Filter() As String = sFilter.Split(",")
      CountyLookUpList.DefaultView.RowFilter = "(COUNTRY = '" & Filter(0) & "') AND (PROVINCE_STATE = '" & Filter(1) & "')"
      CountyLookUpList.DefaultView.Sort = "LONG_NAME ASC"

      For Each oRow In CountyLookUpList.DefaultView
        oItem = New ComboBoxItem
        oItem.Value = oRow("COUNTY").ToString()
        oItem.Text = oRow("LONG_NAME").ToString()
        ddlCounty.Items.Add(oItem)
      Next

      ddlCounty.ItemCount = ddlCounty.Items.Count

    End If

  End Sub

  Public Sub ddlCounty_DataRequested(ByVal sender As System.Object, ByVal e As ComponentArt.Web.UI.ComboBoxDataRequestedEventArgs) Handles ddlCounty.DataRequested

    LoadCountyItems(e.StartIndex, e.NumItems, e.Filter)

  End Sub

#End Region

#Region "Well Profile Type"

  Private Sub LoadWellProfileTypeItems(ByVal iStartIndex As Integer, ByVal iNumItems As Integer, ByVal sFilter As String)

    Dim WellProfileTypeLookUpList As DataTable = GetLookUpList(APP_WELL_PROFILE_TYPE_LOOKUP_DATA)

    ddlWellProfileType.Items.Clear()

    If sFilter.Length > 0 Then
      If sFilter.IndexOf("'") > 0 Then
        sFilter = sFilter.Replace("'", "''")
      End If
      WellProfileTypeLookUpList.DefaultView.RowFilter = "LONG_NAME LIKE '" + sFilter + "%'"
    ElseIf sFilter.Length = 0 Then
      WellProfileTypeLookUpList.DefaultView.RowFilter = "LONG_NAME LIKE '%'"
    End If

    WellProfileTypeLookUpList.DefaultView.Sort = "LONG_NAME ASC"

    Dim rowViewCount As Integer = WellProfileTypeLookUpList.DefaultView.Count
    Dim i As Integer = iStartIndex
    Dim iEndIndex As Integer = Math.Min(iStartIndex + iNumItems, rowViewCount)
    Dim oRow As DataRowView
    Dim oItem As ComboBoxItem

    Do While (i < iEndIndex And i < rowViewCount)
      oRow = WellProfileTypeLookUpList.DefaultView(i)
      oItem = New ComboBoxItem
      oItem.Value = oRow("WELL_PROFILE_TYPE").ToString()
      oItem.Text = oRow("LONG_NAME").ToString()
      ddlWellProfileType.Items.Add(oItem)
      i += 1
    Loop

    ddlWellProfileType.ItemCount = Math.Min(rowViewCount, iEndIndex + ddlWellProfileType.DropDownPageSize)

  End Sub

  Public Sub ddlWellProfileType_DataRequested(ByVal sender As System.Object, ByVal e As ComponentArt.Web.UI.ComboBoxDataRequestedEventArgs) Handles ddlWellProfileType.DataRequested

    LoadWellProfileTypeItems(e.StartIndex, e.NumItems, e.Filter)

  End Sub

#End Region

#Region "Current Status"

  Private Sub LoadCurrentStatusItems(ByVal iStartIndex As Integer, ByVal iNumItems As Integer, ByVal sFilter As String)

    Dim CurrentStatusLookUpList As DataTable = GetLookUpList(APP_CURRENT_STATUS_LOOKUP_DATA)

    ddlCurrentStatus.Items.Clear()

    If sFilter.Length > 0 Then
      If sFilter.IndexOf("'") > 0 Then
        sFilter = sFilter.Replace("'", "''")
      End If
      CurrentStatusLookUpList.DefaultView.RowFilter = "LONG_NAME LIKE '" + sFilter + "%'"
    ElseIf sFilter.Length = 0 Then
      CurrentStatusLookUpList.DefaultView.RowFilter = "LONG_NAME LIKE '%'"
    End If

    CurrentStatusLookUpList.DefaultView.Sort = "LONG_NAME ASC"

    Dim rowViewCount As Integer = CurrentStatusLookUpList.DefaultView.Count
    Dim i As Integer = iStartIndex
    Dim iEndIndex As Integer = Math.Min(iStartIndex + iNumItems, rowViewCount)
    Dim oRow As DataRowView
    Dim oItem As ComboBoxItem

    Do While (i < iEndIndex And i < rowViewCount)
      oRow = CurrentStatusLookUpList.DefaultView(i)
      oItem = New ComboBoxItem
      oItem.Value = oRow("STATUS").ToString()
      oItem.Text = oRow("LONG_NAME").ToString()
      ddlCurrentStatus.Items.Add(oItem)
      i += 1
    Loop

    ddlCurrentStatus.ItemCount = Math.Min(rowViewCount, iEndIndex + ddlCurrentStatus.DropDownPageSize)

  End Sub

  Public Sub ddlCurrentStatus_DataRequested(ByVal sender As System.Object, ByVal e As ComponentArt.Web.UI.ComboBoxDataRequestedEventArgs) Handles ddlCurrentStatus.DataRequested

    LoadCurrentStatusItems(e.StartIndex, e.NumItems, e.Filter)

  End Sub

#End Region

#Region "FilterMethod"

  Sub FilterMethodChanged(ByVal sender As Object, ByVal e As EventArgs)
    Session("FilterOnDB") = (rblFilter.SelectedIndex = 1)
  End Sub

#End Region

#Region "Operator"

  Private Sub LoadOperatorItems(ByVal iStartIndex As Integer, _
                                ByVal iNumItems As Integer, _
                                ByVal sFilter As String)

    Dim useDefaultView = False
    If useDefaultView Then
      Application.Lock()
      Try
        Dim LookUpList As DataTable = GetLookUpList(APP_TLM_BUSINESS_ASSOCIATE_LOOKUP_DATA)

        If sFilter.Length > 0 Then
          If sFilter.IndexOf("'") > 0 Then
            sFilter = sFilter.Replace("'", "''")
          End If
                    LookUpList.DefaultView.RowFilter = "DISPLAY_TEXT LIKE '" + sFilter + "%'"
        Else
          LookUpList.DefaultView.RowFilter = "DISPLAY_TEXT LIKE '%'"
        End If

        LookUpList.DefaultView.Sort = "DISPLAY_TEXT ASC"

        Dim rowViewCount As Integer = LookUpList.DefaultView.Count
        Dim i As Integer = iStartIndex
        Dim iEndIndex As Integer = Math.Min(iStartIndex + iNumItems, rowViewCount)
        Dim oRow As DataRowView
        Dim oItem As ComboBoxItem

        ddlOperator.Items.Clear()
        Do While (i < iEndIndex And i < rowViewCount)
          oRow = LookUpList.DefaultView(i)
          oItem = New ComboBoxItem
          oItem.Value = oRow("VALUE").ToString()
          oItem.Text = oRow("DISPLAY_TEXT").ToString()
          ddlOperator.Items.Add(oItem)
          i += 1
        Loop

        ddlOperator.ItemCount = Math.Min(rowViewCount, iEndIndex + ddlOperator.DropDownPageSize)
      Finally
        Application.UnLock()
      End Try

    Else
      Dim tbl As DataTable = GetLookUpList(APP_TLM_BUSINESS_ASSOCIATE_LOOKUP_DATA)
      Dim rows() As DataRow

      If sFilter.Length > 0 Then
        rows = tbl.Select("DISPLAY_TEXT LIKE '" + sFilter.Replace("'", "''") + "%'")
      Else
        rows = tbl.Select()
      End If
      Dim rowCount As Integer = rows.Length
      Dim i As Integer = iStartIndex
      Dim iEndIndex As Integer = Math.Min(iStartIndex + iNumItems, rowCount)
      Dim oItem As ComboBoxItem

      ddlOperator.Items.Clear()
      Do While (i < iEndIndex)
        oItem = New ComboBoxItem(rows(i)("DISPLAY_TEXT").ToString())
        oItem.Value = rows(i)("VALUE").ToString()
        ddlOperator.Items.Add(oItem)
        i += 1
      Loop

      ddlOperator.ItemCount = Math.Min(rowCount, iEndIndex + ddlOperator.DropDownPageSize)
    End If

  End Sub

  Public Sub ddlOperator_DataRequested(ByVal sender As System.Object, _
                                       ByVal e As ComponentArt.Web.UI.ComboBoxDataRequestedEventArgs) _
  Handles ddlOperator.DataRequested

    Dim filterInDB As Boolean = Session("FilterOnDB")
    'LoadOperatorItems(e.StartIndex, e.NumItems, e.Filter)
    LoadBAListItems(ddlOperator, filterInDB, e.StartIndex, e.NumItems, e.Filter)
  End Sub

#End Region

  Private Sub LoadBAListItems(ByVal ddl As ComboBox, _
                              ByVal filterInDB As Boolean, _
                              ByVal iStartIndex As Integer, _
                              ByVal iNumItems As Integer, _
                              ByVal sFilter As String)

    Dim rows() As DataRow
    Dim maxRows = iStartIndex + iNumItems + ddl.DropDownPageSize

    If filterInDB Then
      If sFilter.Length > 0 Then
        sFilter = "UPPER(BA_NAME) || ' #' || BUSINESS_ASSOCIATE LIKE '" + sFilter.ToUpper().Replace("'", "''") + "%'"
      End If
      Dim WIMDbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
      Dim gw As New GatewayAccess(WIMDbconnection)
      rows = gw.GetFilteredBAList(sFilter, maxRows)
    Else
      If sFilter.Length > 0 Then
        sFilter = "DISPLAY_TEXT LIKE '" + sFilter.Replace("'", "''") + "%'"
      End If
      Dim tbl As DataTable = GetLookUpList(APP_TLM_BUSINESS_ASSOCIATE_LOOKUP_DATA)
      rows = tbl.Select(sFilter)
    End If
    Dim rowCount As Integer = rows.Length
    Dim i As Integer = iStartIndex
    Dim iEndIndex As Integer = Math.Min(iStartIndex + iNumItems, rowCount)
    Dim oItem As ComboBoxItem

    ddl.Items.Clear()
    Do While (i < iEndIndex)
      oItem = New ComboBoxItem(rows(i)("DISPLAY_TEXT").ToString())
      oItem.Value = rows(i)("VALUE").ToString()
      ddl.Items.Add(oItem)
      i += 1
    Loop

    ddl.ItemCount = Math.Min(rowCount, maxRows)

  End Sub


#Region "Licensee"

  Private Sub LoadLicenseeItems(ByVal iStartIndex As Integer, ByVal iNumItems As Integer, ByVal sFilter As String)

    Application.Lock()
    Try
      Dim LicenseeLookUpList As DataTable = GetLookUpList(APP_TLM_BUSINESS_ASSOCIATE_LOOKUP_DATA)

      If sFilter.Length > 0 Then
        If sFilter.IndexOf("'") > 0 Then
          sFilter = sFilter.Replace("'", "''")
        End If
        LicenseeLookUpList.DefaultView.RowFilter = "DISPLAY_TEXT LIKE '" + sFilter + "%'"
      Else
        LicenseeLookUpList.DefaultView.RowFilter = "DISPLAY_TEXT LIKE '%'"
      End If

      LicenseeLookUpList.DefaultView.Sort = "DISPLAY_TEXT ASC"

      Dim rowViewCount As Integer = LicenseeLookUpList.DefaultView.Count
      Dim i As Integer = iStartIndex
      Dim iEndIndex As Integer = Math.Min(iStartIndex + iNumItems, rowViewCount)
      Dim oRow As DataRowView
      Dim oItem As ComboBoxItem

      ddlLicensee.Items.Clear()
      Do While (i < iEndIndex And i < rowViewCount)
        oRow = LicenseeLookUpList.DefaultView(i)
        oItem = New ComboBoxItem
        oItem.Value = oRow("VALUE").ToString()
        oItem.Text = oRow("DISPLAY_TEXT").ToString()
        ddlLicensee.Items.Add(oItem)
        i += 1
      Loop

      ddlLicensee.ItemCount = Math.Min(rowViewCount, iEndIndex + ddlLicensee.DropDownPageSize)
    Finally
      Application.UnLock()
    End Try

  End Sub

  Public Sub ddlLicensee_DataRequested(ByVal sender As System.Object, ByVal e As ComponentArt.Web.UI.ComboBoxDataRequestedEventArgs) Handles ddlLicensee.DataRequested

    Dim filterInDB As Boolean = Session("FilterOnDB")
    'LoadLicenseeItems(e.StartIndex, e.NumItems, e.Filter)
    LoadBAListItems(ddlLicensee, filterInDB, e.StartIndex, e.NumItems, e.Filter)

  End Sub

#End Region

#Region "Oldest Strat Age"

  Private Sub LoadOldestStratAgeItems(ByVal iStartIndex As Integer, ByVal iNumItems As Integer, ByVal sFilter As String)

    Dim OldestStratAgeLookUpList As DataTable = GetLookUpList(APP_STRAT_AGE_LOOKUP_DATA)

    ddlOldestStratAge.Items.Clear()

    If sFilter.Length > 0 Then
      If sFilter.IndexOf("'") > 0 Then
        sFilter = sFilter.Replace("'", "''")
      End If
      OldestStratAgeLookUpList.DefaultView.RowFilter = "STRAT_UNIT_ID LIKE '" + sFilter + "%'"
    ElseIf sFilter.Length = 0 Then
      OldestStratAgeLookUpList.DefaultView.RowFilter = "STRAT_UNIT_ID LIKE '%'"
    End If

    OldestStratAgeLookUpList.DefaultView.Sort = "STRAT_UNIT_ID ASC"

    Dim rowViewCount As Integer = OldestStratAgeLookUpList.DefaultView.Count
    Dim i As Integer = iStartIndex
    Dim iEndIndex As Integer = Math.Min(iStartIndex + iNumItems, rowViewCount)
    Dim oRow As DataRowView
    Dim oItem As ComboBoxItem

    Do While (i < iEndIndex And i < rowViewCount)
      oRow = OldestStratAgeLookUpList.DefaultView(i)
      oItem = New ComboBoxItem
      oItem.Value = oRow("ORDINAL_AGE_CODE").ToString()
      oItem.Text = oRow("STRAT_UNIT_ID").ToString()
      ddlOldestStratAge.Items.Add(oItem)
      i += 1
    Loop

    ddlOldestStratAge.ItemCount = Math.Min(rowViewCount, iEndIndex + ddlOldestStratAge.DropDownPageSize)

  End Sub

  Public Sub ddlOldestStratAge_DataRequested(ByVal sender As System.Object, ByVal e As ComponentArt.Web.UI.ComboBoxDataRequestedEventArgs) Handles ddlOldestStratAge.DataRequested

    LoadOldestStratAgeItems(e.StartIndex, e.NumItems, e.Filter)

  End Sub

#End Region

#Region "TD Strat Age"

  Private Sub LoadTDStratAgeItems(ByVal iStartIndex As Integer, ByVal iNumItems As Integer, ByVal sFilter As String)

    Dim TDStratAgeLookUpList As DataTable = GetLookUpList(APP_STRAT_AGE_LOOKUP_DATA)

    ddlTDStratAge.Items.Clear()

    If sFilter.Length > 0 Then
      If sFilter.IndexOf("'") > 0 Then
        sFilter = sFilter.Replace("'", "''")
      End If
      TDStratAgeLookUpList.DefaultView.RowFilter = "STRAT_UNIT_ID LIKE '" + sFilter + "%'"
    ElseIf sFilter.Length = 0 Then
      TDStratAgeLookUpList.DefaultView.RowFilter = "STRAT_UNIT_ID LIKE '%'"
    End If

    TDStratAgeLookUpList.DefaultView.Sort = "STRAT_UNIT_ID ASC"

    Dim rowViewCount As Integer = TDStratAgeLookUpList.DefaultView.Count
    Dim i As Integer = iStartIndex
    Dim iEndIndex As Integer = Math.Min(iStartIndex + iNumItems, rowViewCount)
    Dim oRow As DataRowView
    Dim oItem As ComboBoxItem

    Do While (i < iEndIndex And i < rowViewCount)
      oRow = TDStratAgeLookUpList.DefaultView(i)
      oItem = New ComboBoxItem
      oItem.Value = oRow("ORDINAL_AGE_CODE").ToString()
      oItem.Text = oRow("STRAT_UNIT_ID").ToString()
      ddlTDStratAge.Items.Add(oItem)
      i += 1
    Loop

    ddlTDStratAge.ItemCount = Math.Min(rowViewCount, iEndIndex + ddlTDStratAge.DropDownPageSize)

  End Sub

  Public Sub ddlTDStratAge_DataRequested(ByVal sender As System.Object, ByVal e As ComponentArt.Web.UI.ComboBoxDataRequestedEventArgs) Handles ddlTDStratAge.DataRequested

    LoadTDStratAgeItems(e.StartIndex, e.NumItems, e.Filter)

  End Sub

#End Region

#Region "Basin"

  Private Sub LoadBasinItems(ByVal iStartIndex As Integer, ByVal iNumItems As Integer, ByVal sFilter As String)

    Application.Lock()
    Try
      Dim BasinLookUpList As DataTable = GetLookUpList(APP_BASIN_LOOKUP_DATA)

      BasinLookUpList.DefaultView.RowFilter = "COUNTRY = '" & sFilter & "'"
      BasinLookUpList.DefaultView.Sort = "BASIN_NAME ASC"

      Dim rowViewCount As Integer = BasinLookUpList.DefaultView.Count
      Dim i As Integer = iStartIndex
      Dim iEndIndex As Integer = Math.Min(iStartIndex + iNumItems, rowViewCount)
      Dim oRow As DataRowView
      Dim oItem As ComboBoxItem

      ddlBasinName.Items.Clear()
      'Do While (i < iEndIndex And i < rowViewCount)
      Do While (i < rowViewCount)
        oRow = BasinLookUpList.DefaultView(i)
        oItem = New ComboBoxItem
        oItem.Value = oRow("AREA_ID").ToString()
        oItem.Text = oRow("BASIN_NAME").ToString()
        ddlBasinName.Items.Add(oItem)
        i += 1
      Loop

      'ddlBasinName.ItemCount = Math.Min(rowViewCount, iEndIndex + ddlBasinName.DropDownPageSize)
      ddlBasinName.ItemCount = rowViewCount
    Finally
      Application.UnLock()
    End Try

  End Sub

  Public Sub ddlBasinName_DataRequested(ByVal sender As System.Object, ByVal e As ComponentArt.Web.UI.ComboBoxDataRequestedEventArgs) Handles ddlBasinName.DataRequested

    Dim filterInDB As Boolean = Session("FilterOnDB")
    LoadBasinItems(e.StartIndex, e.NumItems, e.Filter)
    'LoadBasinItems(ddlBasinName, filterInDB, e.StartIndex, e.NumItems, e.Filter)

  End Sub
#End Region


#Region "RigType"

  Private Sub LoadRigTypeItems(ByVal iStartIndex As Integer, ByVal iNumItems As Integer, ByVal sFilter As String)

    Dim RigTypeLookUpList As DataTable = GetLookUpList(APP_RIG_TYPE_LOOKUP_DATA)

    ddlRigType.Items.Clear()

    If sFilter.Length > 0 Then
      If sFilter.IndexOf("'") > 0 Then
        sFilter = sFilter.Replace("'", "''")
      End If
      RigTypeLookUpList.DefaultView.RowFilter = "RIG_TYPE_NAME LIKE '" + sFilter + "%'"
    ElseIf sFilter.Length = 0 Then
      RigTypeLookUpList.DefaultView.RowFilter = "RIG_TYPE_NAME LIKE '%'"
    End If

    RigTypeLookUpList.DefaultView.Sort = "RIG_TYPE_NAME ASC"

    Dim rowViewCount As Integer = RigTypeLookUpList.DefaultView.Count
    Dim i As Integer = iStartIndex
    Dim iEndIndex As Integer = Math.Min(iStartIndex + iNumItems, rowViewCount)
    Dim oRow As DataRowView
    Dim oItem As ComboBoxItem

    Do While (i < iEndIndex And i < rowViewCount)
      oRow = RigTypeLookUpList.DefaultView(i)
      oItem = New ComboBoxItem
      oItem.Value = oRow("RIG_TYPE_CODE").ToString()
      oItem.Text = oRow("RIG_TYPE_NAME").ToString()
      ddlRigType.Items.Add(oItem)
      i += 1
    Loop

    ddlRigType.ItemCount = Math.Min(rowViewCount, iEndIndex + ddlRigType.DropDownPageSize)

  End Sub

  Public Sub ddlRigType_DataRequested(ByVal sender As System.Object, ByVal e As ComponentArt.Web.UI.ComboBoxDataRequestedEventArgs) Handles ddlRigType.DataRequested

    LoadRigTypeItems(e.StartIndex, e.NumItems, e.Filter)

  End Sub

#End Region



#Region "Location Grid"

  Protected Sub DataGrid1_NeedDataSource(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles DataGrid1.NeedDataSource
    BindLocationGrid()
  End Sub

  Protected Sub DataGrid1_NeedRebind(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles DataGrid1.NeedRebind
    DataGrid1.DataBind()
  End Sub

  Protected Sub DataGrid1_UpdateCommand(ByVal sender As System.Object, ByVal e As ComponentArt.Web.UI.GridItemEventArgs) Handles DataGrid1.UpdateCommand
    If (String.IsNullOrEmpty(e.Item("LIST_ID"))) Then
      UpdateLocationGrid(e.Item, "INSERT")
    Else
      UpdateLocationGrid(e.Item, "UPDATE")
    End If
  End Sub

  Protected Sub DataGrid1_DeleteCommand(ByVal sender As System.Object, ByVal e As ComponentArt.Web.UI.GridItemEventArgs) Handles DataGrid1.DeleteCommand
    UpdateLocationGrid(e.Item, "DELETE")
  End Sub

  Protected Sub DataGrid1_InsertCommand(ByVal sender As System.Object, ByVal e As ComponentArt.Web.UI.GridItemEventArgs) Handles DataGrid1.InsertCommand
    UpdateLocationGrid(e.Item, "INSERT")
  End Sub

  Private Sub UpdateLocationGrid(ByVal item As ComponentArt.Web.UI.GridItem, ByVal Action As String)

    Dim ds As DataSet = CType(Session("WIM_LocationInfo"), DataSet)
    Dim params As New NameValueCollection
    params("NODE_POSITION") = IIf(String.IsNullOrEmpty(item("NODE_POSITION")), Nothing, item("NODE_POSITION"))
    params("LATITUDE") = IIf(String.IsNullOrEmpty(item("LATITUDE")), System.DBNull.Value, item("LATITUDE"))
    params("LONGITUDE") = IIf(String.IsNullOrEmpty(item("LONGITUDE")), System.DBNull.Value, item("LONGITUDE"))
    params("GEOG_COORD_SYSTEM_ID") = IIf(String.IsNullOrEmpty(item("GEOG_COORD_SYSTEM_ID")), Nothing, item("GEOG_COORD_SYSTEM_ID"))
    params("REMARK") = IIf(String.IsNullOrEmpty(item("REMARK")), Nothing, item("REMARK"))
    params("LOCATION_ACCURACY") = IIf(String.IsNullOrEmpty(item("LOCATION_ACCURACY")), Nothing, item("LOCATION_ACCURACY"))

    Select Case (Action)
      Case "INSERT"
        addLocationGridRow(ds, params)
      Case "UPDATE"
        updateLocationGridRow(ds, item("LIST_ID"), params)
      Case "DELETE"
        removeLocationGridRow(ds, item("LIST_ID"))
    End Select

  End Sub

  Shared Sub addLocationGridRow(ByVal ds As DataSet, _
                                ByVal params As NameValueCollection)
    Dim dr As DataRow = ds.Tables("LocationInfo").NewRow()
    If dr.Table.PrimaryKey(0).AutoIncrementSeed = 0 Then
      dr.Item("WIM_ACTION_CD") = NODE_ACTION_CREATE_VERSION
    Else
      dr.Item("WIM_ACTION_CD") = NODE_ACTION_ADD_VERSION
    End If
    dr.Item("NODE_POSITION") = params("NODE_POSITION")
    dr.Item("LATITUDE") = params("LATITUDE")
    dr.Item("LONGITUDE") = params("LONGITUDE")
    dr.Item("GEOG_COORD_SYSTEM_ID") = params("GEOG_COORD_SYSTEM_ID")
    dr.Item("REMARK") = params("REMARK")


    If params("LOCATION_ACCURACY") = String.Empty Then
      dr.Item("LOCATION_ACCURACY") = DBNull.Value
    Else
      dr.Item("LOCATION_ACCURACY") = params("LOCATION_ACCURACY")
    End If


    ds.Tables("LocationInfo").Rows.Add(dr)
  End Sub

  Shared Sub updateLocationGridRow(ByVal ds As DataSet, _
                                   ByVal listId As String, _
                                   ByVal params As NameValueCollection)
    Dim dr As DataRow = ds.Tables("LocationInfo").Rows.Find(listId)
    If Not dr Is Nothing Then
      If dr.Item("LIST_ID") <= dr.Table.PrimaryKey(0).AutoIncrementSeed Then
        ' Did the user change a PK field?
        ' (The Gateway treats NODE_POSITION as a PK field, since the last digit
        '  of the NODE_ID is 0/1 depending on the NODE_POSITION)
        ' If so, we need to send the gateway an inactivate of the old node version
        ' and an insert of a new node version
        If (IIf(dr.IsNull("GEOG_COORD_SYSTEM_ID"), "", dr.Item("GEOG_COORD_SYSTEM_ID")) <> params("GEOG_COORD_SYSTEM_ID").ToString()) _
        OrElse (IIf(dr.IsNull("NODE_POSITION"), "", dr.Item("NODE_POSITION")) <> params("NODE_POSITION").ToString()) Then
          dr.Item("WIM_ACTION_CD") = NODE_ACTION_INACTIVATE_VERSION
          addLocationGridRow(ds, params)
          Return
        End If
        dr.Item("WIM_ACTION_CD") = NODE_ACTION_UPDATE_VERSION
        ' If this row does not have an OBS_NO, it is not yet known at the DB, so treat as in INSERT
        If dr.Item("NODE_OBS_NO") Is Nothing OrElse dr.Item("NODE_OBS_NO") Is DBNull.Value Then
          If dr.Table.PrimaryKey(0).AutoIncrementSeed = 0 Then
            dr.Item("WIM_ACTION_CD") = NODE_ACTION_CREATE_VERSION
          Else
            dr.Item("WIM_ACTION_CD") = NODE_ACTION_ADD_VERSION
          End If
        End If
      End If
      dr.Item("NODE_POSITION") = params("NODE_POSITION")
      dr.Item("LATITUDE") = params("LATITUDE")
      dr.Item("LONGITUDE") = params("LONGITUDE")
      dr.Item("GEOG_COORD_SYSTEM_ID") = params("GEOG_COORD_SYSTEM_ID")
      dr.Item("REMARK") = params("REMARK")


      If params("LOCATION_ACCURACY") = String.Empty Then
        dr.Item("LOCATION_ACCURACY") = DBNull.Value
      Else
        dr.Item("LOCATION_ACCURACY") = params("LOCATION_ACCURACY")
      End If


    End If
  End Sub

  Shared Sub removeLocationGridRow(ByVal ds As DataSet, _
                                   ByVal listId As String)
    Dim dr As DataRow = ds.Tables("LocationInfo").Rows.Find(listId)
    If Not dr Is Nothing Then
      'delete row if newly added; otherwise just inactivate it
      If dr.Item("LIST_ID") > dr.Table.PrimaryKey(0).AutoIncrementSeed Then
        ds.Tables("LocationInfo").Rows.Find(listId).Delete()
      Else
        dr.Item("WIM_ACTION_CD") = NODE_ACTION_INACTIVATE_VERSION
      End If
    End If
  End Sub

  Private Sub BindLocationGrid()

    If Session("WIM_LocationInfo") Is Nothing Then
      Dim wa As WellActionDTO = CType(Session("WellActionDTO"), WellActionDTO)
      SetLocationValues(wa.WELL_NODE_VERSION)
    End If

    Dim ds As DataSet = CType(Session("WIM_LocationInfo"), DataSet)

    'ds.Tables("LocationInfo").DefaultView.RowFilter = "IsNull(WIM_ACTION_CD, '') <> '" & NODE_ACTION_INACTIVATE_VERSION & "'"
    'DataGrid1.DataSource = ds.Tables("LocationInfo").DefaultView

    Dim sRowFilter As String = "IsNull(WIM_ACTION_CD, '') <> '" & NODE_ACTION_INACTIVATE_VERSION & "'"
    Dim dv As DataView = New DataView(ds.Tables("LocationInfo"), sRowFilter, "List_Id asc", DataViewRowState.CurrentRows)
    DataGrid1.DataSource = dv

  End Sub

  Private Sub DataGrid1_SortCommand(ByVal sender As Object, ByVal e As ComponentArt.Web.UI.GridSortCommandEventArgs) Handles DataGrid1.SortCommand

    Try
      Dim ds As DataSet = CType(Session("WIM_LocationInfo"), DataSet)
      ds.Tables("LocationInfo").DefaultView.Sort = e.SortExpression
      Session("WIM_LocationInfo") = ds

    Catch ex As Exception
      'Sort not done

    End Try

  End Sub

  Private Function GetGeographicDatumLookUp() As DataTable

    Dim dt As DataTable
    Dim dr As DataRow

    If Session(APP_COORD_SYSTEM_LOOKUP_DATA) Is Nothing Then

      dt = New DataTable("CoordinateSystemLookUp")
      dt.Columns.Add("DISPLAY_TEXT")
      dt.Columns.Add("VALUE")

      dr = dt.NewRow
      dr("DISPLAY_TEXT") = ""
      dr("VALUE") = ""
      dt.Rows.Add(dr)
      dt.Merge(GetLookUpList(APP_COORD_SYSTEM_LOOKUP_DATA))

      Session(APP_COORD_SYSTEM_LOOKUP_DATA) = dt
    Else
      dt = CType(Session(APP_COORD_SYSTEM_LOOKUP_DATA), DataTable)
    End If

    Return dt

  End Function

  Private Function GetPositionLookUp() As DataTable

    Dim dt As DataTable
    Dim dr As DataRow

    If Session("PositionLookUpList") Is Nothing Then

      dt = New DataTable("PositionLookUp")

      dt.Columns.Add("NODE_POSITION")
      dt.Columns.Add("NODE_POSITION_LONGNAME")

      dr = dt.NewRow
      dr("NODE_POSITION") = ""
      dr("NODE_POSITION_LONGNAME") = ""
      dt.Rows.Add(dr)

      dr = dt.NewRow
      dr("NODE_POSITION") = "B"
      dr("NODE_POSITION_LONGNAME") = "Bottom"
      dt.Rows.Add(dr)

      dr = dt.NewRow
      dr("NODE_POSITION") = "S"
      dr("NODE_POSITION_LONGNAME") = "Surface"
      dt.Rows.Add(dr)

      Session("PositionLookUpList") = dt
    Else
      dt = CType(Session("PositionLookUpList"), DataTable)
    End If

    Return dt

  End Function

#End Region

#Region "Node Position"

  Private Sub LoadNodePositionItems(ByVal iStartIndex As Integer, ByVal iNumItems As Integer, ByVal sFilter As String)

    Dim nodePositionLookUpList As DataTable = GetPositionLookUp()

    ddlNodePos.Items.Clear()

    Dim rowViewCount As Integer = nodePositionLookUpList.DefaultView.Count
    Dim oRow As DataRowView
    Dim oItem As ComboBoxItem
    Dim i As Integer = 0

    Do While (i < rowViewCount)
      oRow = nodePositionLookUpList.DefaultView(i)
      oItem = New ComboBoxItem
      oItem.Value = oRow("NODE_POSITION").ToString()
      oItem.Text = oRow("NODE_POSITION_LONGNAME").ToString()
      ddlNodePos.Items.Add(oItem)
      i += 1
    Loop

  End Sub

  Public Sub ddlNodePos_DataRequested(ByVal sender As System.Object, ByVal e As ComponentArt.Web.UI.ComboBoxDataRequestedEventArgs) Handles ddlNodePos.DataRequested

    LoadNodePositionItems(e.StartIndex, e.NumItems, e.Filter)

  End Sub

#End Region

#Region "Node Datum"

  Private Sub LoadNodeDatumItems(ByVal iStartIndex As Integer, ByVal iNumItems As Integer, ByVal sFilter As String)

    Dim lookupList As DataTable = GetGeographicDatumLookUp()

    ddlNodeDatum.Items.Clear()

    Dim rowViewCount As Integer = lookupList.DefaultView.Count
    Dim oRow As DataRowView
    Dim oItem As ComboBoxItem
    Dim i As Integer = 0

    Do While (i < rowViewCount)
      oRow = lookupList.DefaultView(i)
      oItem = New ComboBoxItem
      oItem.Value = oRow("VALUE").ToString()
      oItem.Text = oRow("DISPLAY_TEXT").ToString()
      ddlNodeDatum.Items.Add(oItem)
      i += 1
    Loop

  End Sub

  Public Sub ddlNodeDatum_DataRequested(ByVal sender As System.Object, ByVal e As ComponentArt.Web.UI.ComboBoxDataRequestedEventArgs) Handles ddlNodeDatum.DataRequested

    LoadNodeDatumItems(e.StartIndex, e.NumItems, e.Filter)

  End Sub

#End Region


#Region "Public Functions"

  Public Sub SetReadOnly()

    ddlSource.Enabled = False
    txtUWI.Enabled = False
    ddlCountry.Enabled = False
    txtWellName.Enabled = False
    txtPlotName.Enabled = False
    ddlOnOffShoreInd.Enabled = False
    ddlWellProfileType.Enabled = False
    ddlCurrentStatus.Enabled = False
    ddlOperator.Enabled = False
    ddlLicensee.Enabled = False
    txtGroundElev.Enabled = False
    ddlGroundElevUnits.Enabled = False
    txtKBElev.Enabled = False
    ddlKBElevUnits.Enabled = False
    txtRotaryTableElev.Enabled = False
    txtDerrickFloor.Enabled = False
    ddlDerrickFloorUnits.Enabled = False
    txtWaterDepth.Enabled = False
    ddlWaterDepthUnits.Enabled = False
    txtCasingFlange.Enabled = False
    ddlCasingFlangeUnits.Enabled = False
    txtTotalDepth.Enabled = False
    ddlTotalDepthUnits.Enabled = False
    txtLicenseNumber.Enabled = False
    txtLicenseDate.Enabled = False
    txtRigReleaseDate.Enabled = False
    txtSpudDate.Enabled = False
    txtFinalDrillDate.Enabled = False
    txtArea.Enabled = False
    txtBlock.Enabled = False
    ddlProvState.Enabled = False
    ddlBasinName.Enabled = False
    ddlCounty.Enabled = False
    txtDistrict.Enabled = False
    txtAssignedField.Enabled = False
    txtPool.Enabled = False
    taRemark.Enabled = False
    ddlOldestStratAge.Enabled = False
    txtLeaseName.Enabled = False
    ddlTDStratAge.Enabled = False
    txtPlugbackDepth.Enabled = False
    ddlPlugbackDepthUnits.Enabled = False
    txtPlugbackTVD.Enabled = False
    txtMaxTVD.Enabled = False
    ddlMaxTVDUnits.Enabled = False
    ddlRigType.Enabled = False
    txtRigName.Enabled = False


    GridRowsControlsBar.Visible = False

    DataGrid1.Enabled = False
    '' Hide the last column = the actions
    'DataGrid1.Levels(0).Columns(DataGrid1.Levels(0).Columns.Count - 1).Visible = False

  End Sub

  Public Sub SetControlValues(ByVal wa As WellActionDTO, _
                              ByVal setVersionFields As Boolean)

    lblTLMIDval.Text = wa.UWI
    lblTLMID2val.Text = wa.UWI
    lblTLMID3val.Text = wa.UWI

    txtUWI.Text = wa.IPL_UWI_LOCAL
    lblUWI2val.Text = wa.IPL_UWI_LOCAL
    lblUWI3val.Text = wa.IPL_UWI_LOCAL

    txtWellName.Text = wa.WELL_NAME
    lblWellName2val.Text = wa.WELL_NAME
    lblWellName3val.Text = wa.WELL_NAME

    ddlCountry.Text = wa.COUNTRY_NAME
    lblCountry2val.Text = wa.COUNTRY_NAME
    lblCountry3val.Text = wa.COUNTRY_NAME

    If Not wa.COUNTRY = String.Empty Then
      LoadProvStateItems(0, ddlProvState.DropDownPageSize * 2, wa.COUNTRY)
      LoadBasinItems(0, ddlBasinName.DropDownPageSize * 2, wa.COUNTRY)

      ddlProvState.Enabled = (ddlProvState.ItemCount > 0)
      ddlBasinName.Enabled = (ddlBasinName.ItemCount > 0)
    End If


    If setVersionFields Then

      ddlSource.Text = wa.SOURCE_NAME
      lblSource2val.Text = wa.SOURCE_NAME
      lblSource3val.Text = wa.SOURCE_NAME

      txtPlotName.Text = wa.PLOT_NAME
      lblPlotName2val.Text = wa.PLOT_NAME
      lblPlotName3val.Text = wa.PLOT_NAME

      ddlOnOffShoreInd.Text = wa.IPL_OFFSHORE_IND
      ddlWellProfileType.Text = wa.PROFILE_TYPE_NAME
      ddlCurrentStatus.Text = wa.CURRENT_STATUS_NAME
      'ddlOperator.Text = wa.WV_OPERATOR_NAME
      Dim item As ComboBoxItem
      If Not String.IsNullOrEmpty(wa.WV_OPERATOR) Then
        item = New ComboBoxItem(wa.WV_OPERATOR_NAME)
        item.Value = wa.WV_OPERATOR
        ddlOperator.Items.Add(item)
        ddlOperator.SelectedItem = item
      End If
      'ddlLicensee.Text = wa.IPL_LICENSEE_NAME
      If Not String.IsNullOrEmpty(wa.IPL_LICENSEE) Then
        item = New ComboBoxItem(wa.IPL_LICENSEE_NAME)
        item.Value = wa.IPL_LICENSEE
        ddlLicensee.Items.Add(item)
        ddlLicensee.SelectedItem = item
      End If
      txtGroundElev.Text = wa.GROUND_ELEV
      ddlGroundElevUnits.Text = wa.GROUND_ELEV_OUOM

      txtKBElev.Text = wa.KB_ELEV
      ddlKBElevUnits.Text = wa.KB_ELEV_OUOM

      txtRotaryTableElev.Text = wa.ROTARY_TABLE_ELEV

      txtDerrickFloor.Text = wa.DERRICK_FLOOR_ELEV
      ddlDerrickFloorUnits.Text = wa.DERRICK_FLOOR_ELEV_OUOM

      txtWaterDepth.Text = wa.WATER_DEPTH
      ddlWaterDepthUnits.Text = wa.WATER_DEPTH_OUOM

      txtCasingFlange.Text = wa.CASING_FLANGE_ELEV
      ddlCasingFlangeUnits.Text = wa.CASING_FLANGE_ELEV_OUOM

      txtTotalDepth.Text = wa.DRILL_TD
      ddlTotalDepthUnits.Text = wa.DRILL_TD_OUOM

      txtLicenseNumber.Text = wa.LICENSE_NUM
      txtLicenseDate.Text = wa.LICENSE_DATE

      txtRigName.Text = wa.RIG_NAME
      ddlRigType.Text = wa.RIG_TYPE_NAME

      txtRigReleaseDate.Text = wa.RIG_RELEASE_DATE
      txtSpudDate.Text = wa.SPUD_DATE
      txtFinalDrillDate.Text = wa.FINAL_DRILL_DATE

      'txtBasin.Text = wa.IPL_BASIN
      txtArea.Text = wa.IPL_AREA
      txtBlock.Text = wa.IPL_BLOCK

      'ddlBasinName.Text = wa.IPL_BASIN_NAME
      ddlBasinName.SelectedValue = wa.IPL_BASIN


      ddlProvState.Text = wa.PROVINCE_STATE_NAME
      ddlRigType.Text = wa.RIG_TYPE_NAME
      ddlCounty.Text = wa.COUNTY_NAME
      txtDistrict.Text = wa.DISTRICT

      txtLeaseName.Text = wa.LEASE_NAME
      txtAssignedField.Text = wa.ASSIGNED_FIELD
      txtPool.Text = wa.IPL_POOL
      taRemark.Text = wa.REMARK

      ddlOldestStratAge.Text = wa.OLDEST_STRAT_UNIT_ID
      ddlTDStratAge.Text = wa.TD_STRAT_UNIT_ID

      txtPlugbackDepth.Text = wa.PLUGBACK_DEPTH
      ddlPlugbackDepthUnits.Text = wa.PLUGBACK_DEPTH_OUOM

      txtPlugbackTVD.Text = wa.IPL_PLUGBACK_TVD

      txtMaxTVD.Text = wa.MAX_TVD
      ddlMaxTVDUnits.Text = wa.MAX_TVD_OUOM

      If Not wa.PROVINCE_STATE = String.Empty Then
        LoadCountyItems(0, ddlCounty.DropDownPageSize * 2, wa.COUNTRY & "," & wa.PROVINCE_STATE)
        ddlCounty.Enabled = ddlCounty.ItemCount > 0
      End If

      If wa.PROFILE_TYPE = VERTICAL Then
        txtPlugbackTVD.Enabled = False
        txtMaxTVD.Enabled = False
      Else
        txtPlugbackTVD.Enabled = True
        txtMaxTVD.Enabled = True
      End If

      ddlGroundElevUnits.Enabled = Not wa.GROUND_ELEV = String.Empty
      ddlKBElevUnits.Enabled = Not wa.KB_ELEV = String.Empty
      ddlDerrickFloorUnits.Enabled = Not wa.DERRICK_FLOOR_ELEV = String.Empty
      ddlWaterDepthUnits.Enabled = Not wa.WATER_DEPTH = String.Empty
      ddlCasingFlangeUnits.Enabled = Not wa.CASING_FLANGE_ELEV = String.Empty
      ddlTotalDepthUnits.Enabled = Not wa.DRILL_TD = String.Empty
      ddlPlugbackDepthUnits.Enabled = Not wa.PLUGBACK_DEPTH = String.Empty
      ddlMaxTVDUnits.Enabled = wa.MAX_TVD <> String.Empty Or txtMaxTVD.Enabled

      ' Date is a value type, so this does not work:
      'If IsNothing(wa.ROW_CHANGED_DATE) Then
      If DateTime.MinValue = wa.ROW_CHANGED_DATE Then
        lblLastUpdateValue.Text = "None recorded"
        lblLastUpdateValue.Enabled = False
      Else
        lblLastUpdateValue.Text = wa.ROW_CHANGED_DATE.ToString("dd/MMM/yyyy h:mm:ss tt") + " (" + wa.ROW_CHANGED_BY + ")"
        lblLastUpdateValue.Enabled = True
      End If

      SetLocationValues(wa.WELL_NODE_VERSION)

    End If

  End Sub

  Public Function PopulateWellActionDTO(ByRef wa As WellActionDTO) As WellActionDTO

    wa.SOURCE = GetDropDownListSelectedValue(ddlSource)
    wa.ACTIVE_IND = WELL_ACTIVE_IND
    wa.IPL_UWI_LOCAL = GetTextBoxText(txtUWI)
    wa.COUNTRY = GetDropDownListSelectedValue(ddlCountry, wa.COUNTRY, wa.COUNTRY_NAME)
    wa.COUNTRY_NAME = GetDropDownListText(ddlCountry)
    wa.WELL_NAME = GetTextBoxText(txtWellName)
    wa.PLOT_NAME = GetTextBoxText(txtPlotName)
    wa.IPL_OFFSHORE_IND = GetDropDownListSelectedValue(ddlOnOffShoreInd)
    wa.PROFILE_TYPE = GetDropDownListSelectedValue(ddlWellProfileType)
    wa.PROFILE_TYPE_NAME = GetDropDownListText(ddlWellProfileType)

    wa.CURRENT_STATUS = GetDropDownListSelectedValue(ddlCurrentStatus)
    wa.CURRENT_STATUS_NAME = GetDropDownListText(ddlCurrentStatus)

    If Not String.IsNullOrEmpty(wa.CURRENT_STATUS) Then
      wa.WELL_VERSION.Rows(0)("STATUS_TYPE") = STATUS_TYPE_WELL
    End If

    wa.WV_OPERATOR = GetDropDownListSelectedValue(ddlOperator)
    wa.WV_OPERATOR_NAME = GetDropDownListText(ddlOperator)
    wa.IPL_LICENSEE = GetDropDownListSelectedValue(ddlLicensee)
    wa.IPL_LICENSEE_NAME = GetDropDownListText(ddlLicensee)

    wa.GROUND_ELEV = GetTextBoxText(txtGroundElev)
    wa.GROUND_ELEV_OUOM = GetDropDownListSelectedValue(ddlGroundElevUnits)
    wa.KB_ELEV = GetTextBoxText(txtKBElev)
    wa.KB_ELEV_OUOM = GetDropDownListSelectedValue(ddlKBElevUnits)
    wa.ROTARY_TABLE_ELEV = GetTextBoxText(txtRotaryTableElev)
    wa.DERRICK_FLOOR_ELEV = GetTextBoxText(txtDerrickFloor)
    wa.DERRICK_FLOOR_ELEV_OUOM = GetDropDownListSelectedValue(ddlDerrickFloorUnits)
    wa.WATER_DEPTH = GetTextBoxText(txtWaterDepth)
    wa.WATER_DEPTH_OUOM = GetDropDownListSelectedValue(ddlWaterDepthUnits)
    wa.CASING_FLANGE_ELEV = GetTextBoxText(txtCasingFlange)
    wa.CASING_FLANGE_ELEV_OUOM = GetDropDownListSelectedValue(ddlCasingFlangeUnits)
    wa.DRILL_TD = GetTextBoxText(txtTotalDepth)
    wa.DRILL_TD_OUOM = GetDropDownListSelectedValue(ddlTotalDepthUnits)
    wa.LICENSE_NUM = GetTextBoxText(txtLicenseNumber)
    wa.LICENSE_DATE = GetTextBoxDate(txtLicenseDate)
    wa.RIG_TYPE_CODE = GetDropDownListSelectedValue(ddlRigType)
    wa.RIG_TYPE_NAME = GetDropDownListText(ddlRigType)
    wa.RIG_NAME = GetTextBoxText(txtRigName)

    wa.RIG_RELEASE_DATE = GetTextBoxDate(txtRigReleaseDate)
    wa.SPUD_DATE = GetTextBoxDate(txtSpudDate)
    wa.FINAL_DRILL_DATE = GetTextBoxDate(txtFinalDrillDate)

    wa.IPL_BASIN = GetDropDownListSelectedValue(ddlBasinName)
    wa.IPL_BASIN_NAME = GetDropDownListText(ddlBasinName)

    wa.IPL_AREA = GetTextBoxText(txtArea)
    wa.IPL_BLOCK = GetTextBoxText(txtBlock)

    If Not String.IsNullOrEmpty(GetDropDownListSelectedValue(ddlProvState)) Then
      wa.PROVINCE_STATE = GetDropDownListSelectedValue(ddlProvState).Substring(GetDropDownListSelectedValue(ddlProvState).IndexOf(",") + 1)
    End If

    wa.PROVINCE_STATE_NAME = GetDropDownListText(ddlProvState)
    wa.COUNTY = GetDropDownListSelectedValue(ddlCounty)
    wa.COUNTY_NAME = GetDropDownListText(ddlCounty)
    wa.DISTRICT = GetTextBoxText(txtDistrict)
    wa.LEASE_NAME = GetTextBoxText(txtLeaseName)
    wa.ASSIGNED_FIELD = GetTextBoxText(txtAssignedField)
    wa.IPL_POOL = GetTextBoxText(txtPool)
    wa.REMARK = GetTextBoxText(taRemark)

    wa.OLDEST_STRAT_AGE = GetDropDownListSelectedValue(ddlOldestStratAge)
    wa.OLDEST_STRAT_UNIT_ID = GetDropDownListText(ddlOldestStratAge)
    wa.TD_STRAT_AGE = GetDropDownListSelectedValue(ddlTDStratAge)
    wa.TD_STRAT_UNIT_ID = GetDropDownListText(ddlTDStratAge)
    wa.PLUGBACK_DEPTH = GetTextBoxText(txtPlugbackDepth)
    wa.PLUGBACK_DEPTH_OUOM = GetDropDownListSelectedValue(ddlPlugbackDepthUnits)
    wa.IPL_PLUGBACK_TVD = GetTextBoxText(txtPlugbackTVD)
    wa.MAX_TVD = GetTextBoxText(txtMaxTVD)
    wa.MAX_TVD_OUOM = GetDropDownListSelectedValue(ddlMaxTVDUnits)

    wa.USERID = Request.ServerVariables("AUTH_USER").Substring(Request.ServerVariables("AUTH_USER").IndexOf("\") + 1).ToUpper

    wa.IsWellVersionChanged = True

    'Need to check if Rig name or Rig Type entered. It is possible there no License #, but there Rig information
    If Not String.IsNullOrEmpty(wa.LICENSE_NUM) Or
      Not String.IsNullOrEmpty(wa.RIG_NAME) Or
      Not String.IsNullOrEmpty(wa.RIG_TYPE_NAME) Then
      wa.IsWellLicenseChanged = True
    End If



    If CType(Session("WIM_LocationInfo"), DataSet).Tables("LocationInfo").Rows.Count > 0 Then
      CType(Session("WIM_LocationInfo"), DataSet).EnforceConstraints = False
      wa.WELL_NODE_VERSION.Merge(CType(Session("WIM_LocationInfo"), DataSet).Tables("LocationInfo"))
      wa.IsWellNodeVersionChanged = True
    End If

    Return wa

  End Function

  Public Sub ClearPageSessionVars()

    Session("WellActionDTO") = Nothing
    Session(APP_COORD_SYSTEM_LOOKUP_DATA) = Nothing
    Session("PositionLookUpList") = Nothing
    Session("WIM_LocationInfo") = Nothing


  End Sub

  Public Sub HandleErrors(ByRef wa As WellActionDTO)

    Dim sErrMsg() = wa.ERRORMSG.Split(";")
    Dim sErrMsgText As String
    Dim sUnhandledErrors As String = String.Empty
    Dim blnTab1Error As Boolean = False
    Dim blnTab2Error As Boolean = False
    Dim blnTab12Error As Boolean = False
    Dim blnHasUnhandledErrors As Boolean = False
    Dim sHandledErrors As String = String.Empty

    Dim locationErrs As New List(Of LocationErr)

    For Each sErrMsgText In sErrMsg
      Dim sErr() = sErrMsgText.Split(",")
      Dim sErrAttr As String = sErr(0).ToString.ToUpper

      Select Case sErrAttr
        Case ATTR_SOURCE
          ddlSource.BackColor = Drawing.Color.Yellow
          pnlSource.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_SOURCE & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_UWI
          lblTLMIDval.BackColor = Drawing.Color.Yellow
          lblTLMIDval.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_UWI & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_IPL_UWI_LOCAL
          txtUWI.BackColor = Drawing.Color.Yellow
          txtUWI.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_IPL_UWI_LOCAL & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_COUNTRY
          ddlCountry.BackColor = Drawing.Color.Yellow
          pnlCountry.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_COUNTRY & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_WELL_NAME
          txtWellName.BackColor = Drawing.Color.Yellow
          txtWellName.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_WELL_NAME & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_PLOT_NAME
          txtPlotName.BackColor = Drawing.Color.Yellow
          txtPlotName.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_PLOT_NAME & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_IPL_OFFSHORE_IND
          ddlOnOffShoreInd.BackColor = Drawing.Color.Yellow
          pnlOnOffShoreInd.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_IPL_OFFSHORE_IND & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_PROFILE_TYPE
          ddlWellProfileType.BackColor = Drawing.Color.Yellow
          pnlWellProfileType.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_PROFILE_TYPE & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_CURRENT_STATUS
          ddlCurrentStatus.BackColor = Drawing.Color.Yellow
          pnlCurrentStatus.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_CURRENT_STATUS & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_OPERATOR
          ddlOperator.BackColor = Drawing.Color.Yellow
          pnlOperator.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_OPERATOR & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_IPL_LICENSEE
          ddlLicensee.BackColor = Drawing.Color.Yellow
          pnlLicensee.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_IPL_LICENSEE & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_GROUND_ELEV_OUOM, ATTR_WIM_GROUND_ELEV_CUOM
          ddlGroundElevUnits.BackColor = Drawing.Color.Yellow
          ddlGroundElevUnits.Enabled = True
          pnlGroundElevUnits.ToolTip += sErr(1).ToString() & vbCrLf
          sHandledErrors += ATTR_GROUND_ELEV_OUOM & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_KB_ELEV_OUOM, ATTR_WIM_KB_ELEV_CUOM
          ddlKBElevUnits.BackColor = Drawing.Color.Yellow
          ddlKBElevUnits.Enabled = True
          pnlKBElevUnits.ToolTip += sErr(1).ToString() & vbCrLf
          sHandledErrors += ATTR_KB_ELEV_OUOM & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_DERRICK_FLOOR_OUOM, ATTR_WIM_DERRICK_FLOOR_CUOM
          ddlDerrickFloorUnits.BackColor = Drawing.Color.Yellow
          ddlDerrickFloorUnits.Enabled = True
          pnlDerrickFloorUnits.ToolTip += sErr(1).ToString() & vbCrLf
          sHandledErrors += ATTR_DERRICK_FLOOR_OUOM & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_WATER_DEPTH_OUOM, ATTR_WIM_WATER_DEPTH_CUOM
          ddlWaterDepthUnits.BackColor = Drawing.Color.Yellow
          ddlWaterDepthUnits.Enabled = True
          pnlWaterDepthUnits.ToolTip += sErr(1).ToString() & vbCrLf
          sHandledErrors += ATTR_WATER_DEPTH_OUOM & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_CASING_FLANGE_OUOM, ATTR_WIM_CASING_FLANGE_CUOM
          ddlCasingFlangeUnits.BackColor = Drawing.Color.Yellow
          ddlCasingFlangeUnits.Enabled = True
          pnlCasingFlangeUnits.ToolTip += sErr(1).ToString() & vbCrLf
          sHandledErrors += ATTR_CASING_FLANGE_OUOM & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_DRILL_TD_OUOM, ATTR_WIM_DRILL_TD_CUOM
          ddlTotalDepthUnits.BackColor = Drawing.Color.Yellow
          ddlTotalDepthUnits.Enabled = True
          pnlTotalDepthUnits.ToolTip += sErr(1).ToString() & vbCrLf
          sHandledErrors += ATTR_DRILL_TD_OUOM & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_LICENSE_NUM
          txtLicenseNumber.BackColor = Drawing.Color.Yellow
          txtLicenseNumber.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_LICENSE_NUM & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_IPL_BASIN
          ddlBasinName.BackColor = Drawing.Color.Yellow
          ddlBasinName.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_IPL_BASIN & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_IPL_AREA
          txtArea.BackColor = Drawing.Color.Yellow
          txtArea.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_IPL_AREA & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_IPL_BLOCK
          txtBlock.BackColor = Drawing.Color.Yellow
          txtBlock.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_IPL_BLOCK & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_PROVINCE_STATE
          ddlProvState.BackColor = Drawing.Color.Yellow
          ddlProvState.Enabled = True
          pnlProvState.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_PROVINCE_STATE & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_COUNTY
          ddlCounty.BackColor = Drawing.Color.Yellow
          ddlCounty.Enabled = True
          pnlCounty.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_COUNTY & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_DISTRICT
          txtDistrict.BackColor = Drawing.Color.Yellow
          txtDistrict.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_DISTRICT & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_LEASE_NAME
          txtLeaseName.BackColor = Drawing.Color.Yellow
          txtLeaseName.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_LEASE_NAME & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_ASSIGNED_FIELD
          txtAssignedField.BackColor = Drawing.Color.Yellow
          txtAssignedField.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_ASSIGNED_FIELD & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_IPL_POOL
          txtPool.BackColor = Drawing.Color.Yellow
          txtPool.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_IPL_POOL & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_REMARK
          taRemark.BackColor = Drawing.Color.Yellow
          taRemark.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_REMARK & " => " & sErr(1).ToString() & "\n"
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_OLDEST_STRAT_UNIT_ID
          ddlOldestStratAge.BackColor = Drawing.Color.Yellow
          pnlOldestStratAge.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_OLDEST_STRAT_UNIT_ID & " => " & sErr(1).ToString() & "\n"
          If blnTab1Error Then
            blnTab12Error = True
          Else
            blnTab2Error = True
          End If
        Case ATTR_TD_STRAT_UNIT_ID
          ddlTDStratAge.BackColor = Drawing.Color.Yellow
          pnlTDStratAge.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_TD_STRAT_UNIT_ID & " => " & sErr(1).ToString() & "\n"
          If blnTab1Error Then
            blnTab12Error = True
          Else
            blnTab2Error = True
          End If
        Case ATTR_PLUGBACK_DEPTH_OUOM, ATTR_WIM_PLUGBACK_DEPTH_CUOM
          ddlPlugbackDepthUnits.BackColor = Drawing.Color.Yellow
          ddlPlugbackDepthUnits.Enabled = True
          pnlPlugbackDepthUnits.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_PLUGBACK_DEPTH_OUOM & " => " & sErr(1).ToString() & "\n"
          If blnTab1Error Then
            blnTab12Error = True
          Else
            blnTab2Error = True
          End If
        Case ATTR_MAX_TVD_OUOM, ATTR_WIM_MAX_TVD_CUOM
          ddlMaxTVDUnits.BackColor = Drawing.Color.Yellow
          ddlMaxTVDUnits.Enabled = True
          pnlMaxTVDUnits.ToolTip += sErr(1).ToString & vbCrLf
          sHandledErrors += ATTR_MAX_TVD_OUOM & " => " & sErr(1).ToString() & "\n"
          If blnTab1Error Then
            blnTab12Error = True
          Else
            blnTab2Error = True
          End If
        Case ATTR_NODE_POSITION
          sHandledErrors += ATTR_NODE_POSITION & " => " & sErr(1).ToString() & "\n"
          locationErrs.Add(New LocationErr(Integer.Parse(sErr(1).ToString().Replace("=>", ">").Split(">")(0)), _
                                              ATTR_NODE_POSITION, _
                                              sErr(1).ToString().Replace("=>", ">").Split(">")(1)))
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_LATITUDE
          sHandledErrors += ATTR_LATITUDE & " => " & sErr(1).ToString() & "\n"
          locationErrs.Add(New LocationErr(Integer.Parse(sErr(1).ToString().Replace("=>", ">").Split(">")(0)), _
                                              ATTR_LATITUDE, _
                                              sErr(1).ToString().Replace("=>", ">").Split(">")(1)))
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_LONGITUDE
          sHandledErrors += ATTR_LONGITUDE & " => " & sErr(1).ToString() & "\n"
          locationErrs.Add(New LocationErr(Integer.Parse(sErr(1).ToString().Replace("=>", ">").Split(">")(0)), _
                                              ATTR_LONGITUDE, _
                                              sErr(1).ToString().Replace("=>", ">").Split(">")(1)))
          If blnTab12Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_LOCATION_ACCURACY
          sHandledErrors += ATTR_LOCATION_ACCURACY & " => " & sErr(1).ToString() & "\n"
          locationErrs.Add(New LocationErr(Integer.Parse(sErr(1).ToString().Replace("=>", ">").Split(">")(0)), _
                                              ATTR_LOCATION_ACCURACY, _
                                              sErr(1).ToString().Replace("=>", ">").Split(">")(1)))
          If blnTab12Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If

        Case ATTR_GEOG_COORD_SYSTEM_ID
          sHandledErrors += ATTR_GEOG_COORD_SYSTEM_ID & " => " & sErr(1).ToString() & "\n"
          locationErrs.Add(New LocationErr(Integer.Parse(sErr(1).ToString().Replace("=>", ">").Split(">")(0)), _
                                              ATTR_GEOG_COORD_SYSTEM_ID, _
                                              sErr(1).ToString().Replace("=>", ">").Split(">")(1)))
          If blnTab2Error Then
            blnTab12Error = True
          Else
            blnTab1Error = True
          End If
        Case ATTR_WIM_GATEWAY_WELL_ACTION
          Dim myscript As String = "window.onload = function() {alert('" + sErr(1) + "');}"
          Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), "myscript", myscript, True)
          TabStrip1.SelectedTab = TabStrip1.Tabs(0)
          MultiPage1.SelectedIndex = 0
        Case Else
          blnHasUnhandledErrors = True
          sUnhandledErrors += sErr(0).ToString.ToUpper & " => " & sErr(1) & "\n"
      End Select
    Next

    Dim lblError As Label = CType(FindControl("lblError"), Label)
    lblError.Text = "TLM ID [" & wa.UWI & "] Source [" & wa.SOURCE & "] - FAILED!"
    lblError.ForeColor = Drawing.Color.DarkRed

    If blnTab12Error Then
      lblMessageTabStrip1.Text = "Please correct errors highlighted in yellow on both tabs!"
      lblMessageTabStrip1.Visible = True
      lblMessageTabStrip2.Text = "Please correct errors highlighted in yellow on both tabs!"
      lblMessageTabStrip2.Visible = True
      TabStrip1.SelectedTab = TabStrip1.Tabs(0)
      MultiPage1.SelectedIndex = 0
    ElseIf blnTab1Error Then
      lblMessageTabStrip1.Text = "Please correct errors highlighted in yellow on this tab!"
      lblMessageTabStrip1.Visible = True
      lblMessageTabStrip2.Text = "Please correct errors highlighted in yellow on Key Identity Attributes tab!"
      lblMessageTabStrip2.Visible = True
      TabStrip1.SelectedTab = TabStrip1.Tabs(0)
      MultiPage1.SelectedIndex = 0
    ElseIf blnTab2Error Then
      lblMessageTabStrip1.Text = "Please correct errors highlighted in yellow on Stratigraphy/WellBore tab!"
      lblMessageTabStrip1.Visible = True
      lblMessageTabStrip2.Text = "Please correct errors highlighted in yellow on this tab!"
      lblMessageTabStrip2.Visible = True
      'TabStrip1.SelectedTab = TabStrip1.Tabs(1)
      'MultiPage1.SelectedIndex = 1
      TabStrip1.SelectedTab = TabStrip1.Tabs(0)
      MultiPage1.SelectedIndex = 0
    End If

    If locationErrs.Count > 0 Then
      If Not wa.WELL_NODE_VERSION.Columns.Contains("ErrorMessage") Then
        wa.WELL_NODE_VERSION.Columns.Add("ErrorMessage")
      End If

      For Each dr As DataRow In wa.WELL_NODE_VERSION.Rows
        dr("ErrorMessage") = String.Empty
      Next

      For Each locErr As LocationErr In locationErrs
        wa.WELL_NODE_VERSION.DefaultView.RowFilter = "IsNull(WIM_SEQ, 0) = " & locErr.seqNo
        For Each dr As DataRowView In wa.WELL_NODE_VERSION.DefaultView
          If String.IsNullOrEmpty(dr("ErrorMessage").ToString()) Then
            dr("ErrorMessage") = locErr.ShowError
          Else
            dr("ErrorMessage") += ";" & locErr.ShowError
          End If
        Next
      Next

      DataGrid1.Levels(0).Columns("ErrorMessage").Visible = True
      lblNodeMessage.Visible = True

    Else

      'DataGrid1.Levels(0).Columns("ErrorMessage").Visible = False
      lblNodeMessage.Visible = False

    End If

    'Dim reqCallback As String = "window.onload = function() {alert('DataGrid1: '+FindControl('DataGrid1')); FindControl('DataGrid1').Callback();}"
    'Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), "reqCallback", reqCallback, True)

    Dim ds As DataSet = CType(Session("WIM_LocationInfo"), DataSet)
    ds.Tables("LocationInfo").Merge(wa.WELL_NODE_VERSION, False, MissingSchemaAction.Ignore)

    Session("WIM_LocationInfo") = ds

    DataGrid1.DataBind()

    If blnHasUnhandledErrors Then
      Dim sErrorText As String
      sErrorText = "Please review & resubmit entries made to this version, as the following failure occurred:\n\n"
      sErrorText += sUnhandledErrors.Replace("'", "''")
      sErrorText += "\n\nFor assistance, please send eMail to: zTIS_Support"
      lblMessageTabStrip1.ToolTip = sErrorText.Replace("\n", vbCrLf)
      lblMessageTabStrip2.ToolTip = sErrorText.Replace("\n", vbCrLf)
      TabStrip1.SelectedTab = TabStrip1.Tabs(0)
      MultiPage1.SelectedIndex = 0
      Dim myscript As String = "window.onload = function() {alert('" + sErrorText + "');}"
      Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), "myscript", myscript, True)
    End If

  End Sub

  Public Sub ResetControls()

    pnlSource.ToolTip = ""
    ddlSource.BackColor = Drawing.Color.Transparent

    txtUWI.ToolTip = ""
    txtUWI.BackColor = Drawing.Color.Transparent

    pnlCountry.ToolTip = ""
    ddlCountry.BackColor = Drawing.Color.Transparent

    txtWellName.ToolTip = ""
    txtWellName.BackColor = Drawing.Color.Transparent

    txtPlotName.ToolTip = ""
    txtPlotName.BackColor = Drawing.Color.Transparent

    pnlOnOffShoreInd.ToolTip = ""
    ddlOnOffShoreInd.BackColor = Drawing.Color.Transparent

    pnlWellProfileType.ToolTip = ""
    ddlWellProfileType.BackColor = Drawing.Color.Transparent

    pnlCurrentStatus.ToolTip = ""
    ddlCurrentStatus.BackColor = Drawing.Color.Transparent

    pnlOperator.ToolTip = ""
    ddlOperator.BackColor = Drawing.Color.Transparent

    pnlLicensee.ToolTip = ""
    ddlLicensee.BackColor = Drawing.Color.Transparent

    txtGroundElev.ToolTip = ""
    txtGroundElev.BackColor = Drawing.Color.Transparent

    pnlGroundElevUnits.ToolTip = ""
    ddlGroundElevUnits.BackColor = Drawing.Color.Transparent

    txtKBElev.ToolTip = ""
    txtKBElev.BackColor = Drawing.Color.Transparent

    pnlKBElevUnits.ToolTip = ""
    ddlKBElevUnits.BackColor = Drawing.Color.Transparent

    txtRotaryTableElev.ToolTip = ""
    txtRotaryTableElev.BackColor = Drawing.Color.Transparent

    txtDerrickFloor.ToolTip = ""
    txtDerrickFloor.BackColor = Drawing.Color.Transparent

    pnlDerrickFloorUnits.ToolTip = ""
    ddlDerrickFloorUnits.BackColor = Drawing.Color.Transparent

    txtWaterDepth.ToolTip = ""
    txtWaterDepth.BackColor = Drawing.Color.Transparent

    pnlWaterDepthUnits.ToolTip = ""
    ddlWaterDepthUnits.BackColor = Drawing.Color.Transparent

    txtCasingFlange.ToolTip = ""
    txtCasingFlange.BackColor = Drawing.Color.Transparent

    pnlCasingFlangeUnits.ToolTip = ""
    ddlCasingFlangeUnits.BackColor = Drawing.Color.Transparent

    txtTotalDepth.ToolTip = ""
    txtTotalDepth.BackColor = Drawing.Color.Transparent

    pnlTotalDepthUnits.ToolTip = ""
    ddlTotalDepthUnits.BackColor = Drawing.Color.Transparent

    txtLicenseNumber.ToolTip = ""
    txtLicenseNumber.BackColor = Drawing.Color.Transparent

    txtLicenseDate.ToolTip = ""
    txtLicenseDate.BackColor = Drawing.Color.Transparent

    txtRigReleaseDate.ToolTip = ""
    txtRigReleaseDate.BackColor = Drawing.Color.Transparent

    txtSpudDate.ToolTip = ""
    txtSpudDate.BackColor = Drawing.Color.Transparent

    txtFinalDrillDate.ToolTip = ""
    txtFinalDrillDate.BackColor = Drawing.Color.Transparent

    ddlBasinName.ToolTip = ""
    ddlBasinName.BackColor = Drawing.Color.Transparent

    txtArea.ToolTip = ""
    txtArea.BackColor = Drawing.Color.Transparent

    txtBlock.ToolTip = ""
    txtBlock.BackColor = Drawing.Color.Transparent

    pnlProvState.ToolTip = ""
    ddlProvState.BackColor = Drawing.Color.Transparent

    pnlCounty.ToolTip = ""
    ddlCounty.BackColor = Drawing.Color.Transparent

    txtDistrict.ToolTip = ""
    txtDistrict.BackColor = Drawing.Color.Transparent

    txtLeaseName.ToolTip = ""
    txtLeaseName.BackColor = Drawing.Color.Transparent

    txtAssignedField.ToolTip = ""
    txtAssignedField.BackColor = Drawing.Color.Transparent

    txtPool.ToolTip = ""
    txtPool.BackColor = Drawing.Color.Transparent

    pnlOldestStratAge.ToolTip = ""
    ddlOldestStratAge.BackColor = Drawing.Color.Transparent

    pnlTDStratAge.ToolTip = ""
    ddlTDStratAge.BackColor = Drawing.Color.Transparent

    txtPlugbackDepth.ToolTip = ""
    txtPlugbackDepth.BackColor = Drawing.Color.Transparent

    pnlPlugbackDepthUnits.ToolTip = ""
    ddlPlugbackDepthUnits.BackColor = Drawing.Color.Transparent

    txtPlugbackTVD.ToolTip = ""
    txtPlugbackTVD.BackColor = Drawing.Color.Transparent

    txtMaxTVD.ToolTip = ""
    txtMaxTVD.BackColor = Drawing.Color.Transparent

    pnlMaxTVDUnits.ToolTip = ""
    ddlMaxTVDUnits.BackColor = Drawing.Color.Transparent

    lblMessageTabStrip1.Visible = False
    lblMessageTabStrip2.Visible = False

  End Sub

  Public Sub InitializeLookUpListControls()

    Dim SourceLookUpList As DataTable = CType(Session("UserPermissions"), DataSet).Tables(Permission)
    ddlSource.DataSource = SourceLookUpList
    If Not IsNothing(SourceLookUpList) Then
      ddlSource.DataValueField = SourceLookUpList.Columns.Item("SOURCE").ToString()
      ddlSource.DataTextField = SourceLookUpList.Columns.Item("SHORT_NAME").ToString()
      ddlSource.DataBind()
    End If

    Dim CountryLookUpList As DataTable = GetLookUpList(APP_COUNTRY_LOOKUP_DATA)
    ddlCountry.DataSource = CountryLookUpList
    ddlCountry.DataValueField = CountryLookUpList.Columns.Item("COUNTRY").ToString()
    ddlCountry.DataTextField = CountryLookUpList.Columns.Item("LONG_NAME").ToString()
    ddlCountry.DataBind()

    'Dim ProvStateLookUpList As DataTable = GetLookUpList(APP_PROVINCESTATE_LOOKUP_DATA)
    'ddlProvState.DataSource = ProvStateLookUpList
    'ddlProvState.DataValueField = ProvStateLookUpList.Columns.Item("PROVINCE_STATE").ToString()
    'ddlProvState.DataTextField = ProvStateLookUpList.Columns.Item("LONG_NAME").ToString()
    'ddlProvState.DataBind()

    'Dim CountyLookUpList As DataTable = GetLookUpList(APP_COUNTY_LOOKUP_DATA)
    'ddlCounty.DataSource = CountyLookUpList
    'ddlCounty.DataValueField = CountyLookUpList.Columns.Item("COUNTY").ToString()
    'ddlCounty.DataTextField = CountyLookUpList.Columns.Item("LONG_NAME").ToString()
    'ddlCounty.DataBind()

    Dim WellProfileTypeLookUpList As DataTable = GetLookUpList(APP_WELL_PROFILE_TYPE_LOOKUP_DATA)
    ddlWellProfileType.DataSource = WellProfileTypeLookUpList
    ddlWellProfileType.DataValueField = WellProfileTypeLookUpList.Columns.Item("WELL_PROFILE_TYPE").ToString()
    ddlWellProfileType.DataTextField = WellProfileTypeLookUpList.Columns.Item("LONG_NAME").ToString()
    ddlWellProfileType.DataBind()

    Dim NodePositionLookUpList As DataTable = GetPositionLookUp()
    ddlNodePos.DataSource = NodePositionLookUpList
    ddlNodePos.DataValueField = NodePositionLookUpList.Columns.Item("NODE_POSITION").ToString()
    ddlNodePos.DataTextField = NodePositionLookUpList.Columns.Item("NODE_POSITION_LONGNAME").ToString()
    ddlNodePos.DataBind()

    Dim NodeDatumLookUpList As DataTable = GetGeographicDatumLookUp()
    ddlNodeDatum.DataSource = NodeDatumLookUpList
    ddlNodeDatum.DataValueField = NodeDatumLookUpList.Columns.Item("VALUE").ToString()
    ddlNodeDatum.DataTextField = NodeDatumLookUpList.Columns.Item("DISPLAY_TEXT").ToString()
    ddlNodeDatum.DataBind()

    Dim CurrentStatusLookUpList As DataTable = GetLookUpList(APP_CURRENT_STATUS_LOOKUP_DATA)
    ddlCurrentStatus.DataSource = CurrentStatusLookUpList
    ddlCurrentStatus.DataValueField = CurrentStatusLookUpList.Columns.Item("STATUS").ToString()
    ddlCurrentStatus.DataTextField = CurrentStatusLookUpList.Columns.Item("LONG_NAME").ToString()
    ddlCurrentStatus.DataBind()


    Dim RigTypeLookUpList As DataTable = GetLookUpList(APP_RIG_TYPE_LOOKUP_DATA)
    ddlRigType.DataSource = RigTypeLookUpList
    ddlRigType.DataValueField = RigTypeLookUpList.Columns.Item("RIG_TYPE_CODE").ToString()
    ddlRigType.DataTextField = RigTypeLookUpList.Columns.Item("RIG_TYPE_NAME").ToString()
    ddlRigType.DataBind()

    LoadOldestStratAgeItems(0, ddlOldestStratAge.DropDownPageSize * 2, "")
    LoadTDStratAgeItems(0, ddlTDStratAge.DropDownPageSize * 2, "")

  End Sub

  Public Sub AddControlAttributes()

    txtUWI.Attributes.Add("onblur", "handleUWI()")
    txtWellName.Attributes.Add("onblur", "handleWellName()")
    txtPlotName.Attributes.Add("onblur", "handlePlotName()")
    txtGroundElev.Attributes.Add("onblur", "handleGroundElev()")
    txtKBElev.Attributes.Add("onblur", "handleKBElev()")
    txtRotaryTableElev.Attributes.Add("onblur", "handleRotaryTableElev()")
    txtDerrickFloor.Attributes.Add("onblur", "handleDerrickFloor()")
    txtWaterDepth.Attributes.Add("onblur", "handleWaterDepth()")
    txtCasingFlange.Attributes.Add("onblur", "handleCasingFlange()")
    txtTotalDepth.Attributes.Add("onblur", "handleTotalDepth()")
    txtLicenseDate.Attributes.Add("onblur", "handleLicenseDate()")
    txtRigReleaseDate.Attributes.Add("onblur", "handleRigReleaseDate()")
    txtSpudDate.Attributes.Add("onblur", "handleSpudDate()")
    txtFinalDrillDate.Attributes.Add("onblur", "handleFinalDrillDate()")
    txtPlugbackDepth.Attributes.Add("onblur", "handlePlugbackDepth()")
    txtPlugbackTVD.Attributes.Add("onblur", "handlePlugbackTVD()")
    txtMaxTVD.Attributes.Add("onblur", "handleMaxTVD()")

    If Session("FilterOnDB") Is Nothing Then Session("FilterOnDB") = True
    rblFilter.SelectedIndex = IIf(Session("FilterOnDB"), 1, 0)

  End Sub

  Public Function GetwaUpdates(ByRef wa As WellActionDTO) As WellActionDTO

    If wa.IsWellVersionChanged Then
      wa.IPL_UWI_LOCAL = GetTextBoxText(txtUWI)
      wa.COUNTRY = GetDropDownListSelectedValue(ddlCountry, wa.COUNTRY, wa.COUNTRY_NAME)
      wa.COUNTRY_NAME = GetDropDownListText(ddlCountry)
      wa.WELL_NAME = GetTextBoxText(txtWellName)
      wa.PLOT_NAME = GetTextBoxText(txtPlotName)
      wa.IPL_OFFSHORE_IND = GetDropDownListSelectedValue(ddlOnOffShoreInd, wa.IPL_OFFSHORE_IND, wa.IPL_OFFSHORE_IND)
      wa.PROFILE_TYPE = GetDropDownListSelectedValue(ddlWellProfileType, wa.PROFILE_TYPE, wa.PROFILE_TYPE_NAME)
      wa.PROFILE_TYPE_NAME = GetDropDownListText(ddlWellProfileType)

      wa.CURRENT_STATUS = GetDropDownListSelectedValue(ddlCurrentStatus, wa.CURRENT_STATUS, wa.CURRENT_STATUS_NAME)
      wa.CURRENT_STATUS_NAME = GetDropDownListText(ddlCurrentStatus)

      If Not String.IsNullOrEmpty(wa.CURRENT_STATUS) Then
        wa.WELL_VERSION.Rows(0)("STATUS_TYPE") = STATUS_TYPE_WELL
      Else
        wa.WELL_VERSION.Rows(0)("STATUS_TYPE") = String.Empty
      End If

      wa.WV_OPERATOR = GetDropDownListSelectedValue(ddlOperator, wa.WV_OPERATOR, wa.WV_OPERATOR_NAME)
      wa.WV_OPERATOR_NAME = GetDropDownListText(ddlOperator)
      wa.IPL_LICENSEE = GetDropDownListSelectedValue(ddlLicensee, wa.IPL_LICENSEE, wa.IPL_LICENSEE_NAME)
      wa.IPL_LICENSEE_NAME = GetDropDownListText(ddlLicensee)

      wa.GROUND_ELEV = GetTextBoxText(txtGroundElev)
      wa.GROUND_ELEV_OUOM = GetDropDownListSelectedValue(ddlGroundElevUnits, wa.GROUND_ELEV_OUOM, wa.GROUND_ELEV_OUOM)
      wa.KB_ELEV = GetTextBoxText(txtKBElev)
      wa.KB_ELEV_OUOM = GetDropDownListSelectedValue(ddlKBElevUnits, wa.KB_ELEV_OUOM, wa.KB_ELEV_OUOM)
      wa.ROTARY_TABLE_ELEV = GetTextBoxText(txtRotaryTableElev)
      wa.DERRICK_FLOOR_ELEV = GetTextBoxText(txtDerrickFloor)
      wa.DERRICK_FLOOR_ELEV_OUOM = GetDropDownListSelectedValue(ddlDerrickFloorUnits, wa.DERRICK_FLOOR_ELEV_OUOM, wa.DERRICK_FLOOR_ELEV_OUOM)
      wa.WATER_DEPTH = GetTextBoxText(txtWaterDepth)
      wa.WATER_DEPTH_OUOM = GetDropDownListSelectedValue(ddlWaterDepthUnits, wa.WATER_DEPTH_OUOM, wa.WATER_DEPTH_OUOM)
      wa.CASING_FLANGE_ELEV = GetTextBoxText(txtCasingFlange)
      wa.CASING_FLANGE_ELEV_OUOM = GetDropDownListSelectedValue(ddlCasingFlangeUnits, wa.CASING_FLANGE_ELEV_OUOM, wa.CASING_FLANGE_ELEV_OUOM)
      wa.DRILL_TD = GetTextBoxText(txtTotalDepth)
      wa.DRILL_TD_OUOM = GetDropDownListSelectedValue(ddlTotalDepthUnits, wa.DRILL_TD_OUOM, wa.DRILL_TD_OUOM)
      wa.RIG_RELEASE_DATE = GetTextBoxText(txtRigReleaseDate)
      wa.SPUD_DATE = GetTextBoxText(txtSpudDate)
      wa.FINAL_DRILL_DATE = GetTextBoxText(txtFinalDrillDate)
      'vrjapoot
      'If Not String.IsNullOrEmpty(GetDropDownListSelectedValue(ddlBasinName, wa.IPL_BASIN, wa.IPL_BASIN_NAME)) Then
      If Not String.IsNullOrEmpty(GetDropDownListSelectedValue(ddlBasinName)) Then
        'wa.IPL_BASIN = GetDropDownListSelectedValue(ddlBasinName, wa.IPL_BASIN, wa.IPL_BASIN_NAME)
        wa.IPL_BASIN = GetDropDownListSelectedValue(ddlBasinName)
        wa.IPL_BASIN_NAME = GetDropDownListText(ddlBasinName)
      Else
        wa.IPL_BASIN = ""
        wa.IPL_BASIN_NAME = ""
      End If

      wa.IPL_AREA = GetTextBoxText(txtArea)
      wa.IPL_BLOCK = GetTextBoxText(txtBlock)

      If Not String.IsNullOrEmpty(GetDropDownListSelectedValue(ddlProvState)) Then
        wa.PROVINCE_STATE = GetDropDownListSelectedValue(ddlProvState).Substring(GetDropDownListSelectedValue(ddlProvState).IndexOf(",") + 1)
      End If

      wa.PROVINCE_STATE_NAME = GetDropDownListText(ddlProvState)
      wa.COUNTY = GetDropDownListSelectedValue(ddlCounty, wa.COUNTY, wa.COUNTY_NAME)
      wa.COUNTY_NAME = GetDropDownListText(ddlCounty)
      wa.DISTRICT = GetTextBoxText(txtDistrict)
      wa.LEASE_NAME = GetTextBoxText(txtLeaseName)
      wa.ASSIGNED_FIELD = GetTextBoxText(txtAssignedField)
      wa.IPL_POOL = GetTextBoxText(txtPool)
      wa.REMARK = GetTextBoxText(taRemark)

      wa.OLDEST_STRAT_AGE = GetDropDownListSelectedValue(ddlOldestStratAge, wa.OLDEST_STRAT_AGE, wa.OLDEST_STRAT_UNIT_ID)
      wa.OLDEST_STRAT_UNIT_ID = GetDropDownListText(ddlOldestStratAge)
      wa.TD_STRAT_AGE = GetDropDownListSelectedValue(ddlTDStratAge, wa.TD_STRAT_AGE, wa.TD_STRAT_UNIT_ID)
      wa.TD_STRAT_UNIT_ID = GetDropDownListText(ddlTDStratAge)
      wa.PLUGBACK_DEPTH = GetTextBoxText(txtPlugbackDepth)
      wa.PLUGBACK_DEPTH_OUOM = GetDropDownListSelectedValue(ddlPlugbackDepthUnits, wa.PLUGBACK_DEPTH_OUOM, wa.PLUGBACK_DEPTH_OUOM)
      wa.IPL_PLUGBACK_TVD = GetTextBoxText(txtPlugbackTVD)
      wa.MAX_TVD = GetTextBoxText(txtMaxTVD)
      wa.MAX_TVD_OUOM = GetDropDownListSelectedValue(ddlMaxTVDUnits, wa.MAX_TVD_OUOM, wa.MAX_TVD_OUOM)
    End If

    If wa.IsWellLicenseChanged Then
      wa.IPL_LICENSEE = GetDropDownListSelectedValue(ddlLicensee, wa.IPL_LICENSEE, wa.IPL_LICENSEE_NAME)
      wa.IPL_LICENSEE_NAME = GetDropDownListText(ddlLicensee)
      wa.LICENSE_NUM = GetTextBoxText(txtLicenseNumber)
      wa.LICENSE_DATE = GetTextBoxText(txtLicenseDate)
      wa.RIG_TYPE_CODE = GetDropDownListSelectedValue(ddlRigType, wa.RIG_TYPE_CODE, wa.RIG_TYPE_NAME)
      wa.RIG_TYPE_NAME = GetDropDownListText(ddlRigType)
      wa.RIG_NAME = GetTextBoxText(txtRigName)

      wa.IsWellVersionChanged = True
    End If

    If wa.IsWellNodeVersionChanged Then
      If CType(Session("WIM_LocationInfo"), DataSet).Tables("LocationInfo").Rows.Count > 0 Then
        CType(Session("WIM_LocationInfo"), DataSet).EnforceConstraints = True
        wa.WELL_NODE_VERSION.PrimaryKey = New DataColumn() {wa.WELL_NODE_VERSION.Columns("LIST_ID")}
        wa.WELL_NODE_VERSION.Merge(CType(Session("WIM_LocationInfo"), DataSet).Tables("LocationInfo"))
        wa.IsWellVersionChanged = True
        ' DO NOT set WIM_ACTION_CD. Causes QC defect 113
        'wa.WELL_VERSION.Rows(0)("WIM_ACTION_CD") = WELL_ACTION_UPDATE_VERSION
      End If
    End If

    wa.USERID = Request.ServerVariables("AUTH_USER").Substring(Request.ServerVariables("AUTH_USER").IndexOf("\") + 1).ToUpper

    Return wa

  End Function

  Public Sub CheckForUpdates(ByRef wa As WellActionDTO)

    'Check for updates in Well  Version
    If Not wa.IPL_UWI_LOCAL = GetTextBoxText(txtUWI) Then wa.IsWellVersionChanged = True
    If Not wa.COUNTRY = GetDropDownListSelectedValue(ddlCountry, wa.COUNTRY, wa.COUNTRY_NAME) Then wa.IsWellVersionChanged = True
    If Not wa.COUNTRY_NAME = GetDropDownListText(ddlCountry) Then wa.IsWellVersionChanged = True
    If Not wa.WELL_NAME = GetTextBoxText(txtWellName) Then wa.IsWellVersionChanged = True
    If Not wa.PLOT_NAME = GetTextBoxText(txtPlotName) Then wa.IsWellVersionChanged = True
    If Not wa.IPL_OFFSHORE_IND = GetDropDownListSelectedValue(ddlOnOffShoreInd, wa.IPL_OFFSHORE_IND, wa.IPL_OFFSHORE_IND) Then wa.IsWellVersionChanged = True
    If Not wa.PROFILE_TYPE = GetDropDownListSelectedValue(ddlWellProfileType, wa.PROFILE_TYPE, wa.PROFILE_TYPE_NAME) Then wa.IsWellVersionChanged = True
    If Not wa.PROFILE_TYPE_NAME = GetDropDownListText(ddlWellProfileType) Then wa.IsWellVersionChanged = True
    If Not wa.CURRENT_STATUS = GetDropDownListSelectedValue(ddlCurrentStatus, wa.CURRENT_STATUS, wa.CURRENT_STATUS_NAME) Then wa.IsWellVersionChanged = True
    If Not wa.CURRENT_STATUS_NAME = GetDropDownListText(ddlCurrentStatus) Then wa.IsWellVersionChanged = True
    If Not wa.WV_OPERATOR = GetDropDownListSelectedValue(ddlOperator, wa.WV_OPERATOR, wa.WV_OPERATOR_NAME) Then wa.IsWellVersionChanged = True
    If Not wa.WV_OPERATOR_NAME = GetDropDownListText(ddlOperator) Then wa.IsWellVersionChanged = True
    If Not wa.IPL_LICENSEE = GetDropDownListSelectedValue(ddlLicensee, wa.IPL_LICENSEE, WellActionDTO.BA_DisplayName(wa.IPL_LICENSEE_NAME, wa.IPL_LICENSEE)) Then wa.IsWellVersionChanged = True
    If Not wa.IPL_LICENSEE_NAME = GetDropDownListText(ddlLicensee) Then wa.IsWellVersionChanged = True
    If Not wa.GROUND_ELEV = GetTextBoxText(txtGroundElev) Then wa.IsWellVersionChanged = True
    If Not wa.GROUND_ELEV_OUOM = GetDropDownListSelectedValue(ddlGroundElevUnits, wa.GROUND_ELEV_OUOM, wa.GROUND_ELEV_OUOM) Then wa.IsWellVersionChanged = True
    If Not wa.KB_ELEV = GetTextBoxText(txtKBElev) Then wa.IsWellVersionChanged = True
    If Not wa.KB_ELEV_OUOM = GetDropDownListSelectedValue(ddlKBElevUnits, wa.KB_ELEV_OUOM, wa.KB_ELEV_OUOM) Then wa.IsWellVersionChanged = True
    If Not wa.ROTARY_TABLE_ELEV = GetTextBoxText(txtRotaryTableElev) Then wa.IsWellVersionChanged = True
    If Not wa.DERRICK_FLOOR_ELEV = GetTextBoxText(txtDerrickFloor) Then wa.IsWellVersionChanged = True
    If Not wa.DERRICK_FLOOR_ELEV_OUOM = GetDropDownListSelectedValue(ddlDerrickFloorUnits, wa.DERRICK_FLOOR_ELEV_OUOM, wa.DERRICK_FLOOR_ELEV_OUOM) Then wa.IsWellVersionChanged = True
    If Not wa.WATER_DEPTH = GetTextBoxText(txtWaterDepth) Then wa.IsWellVersionChanged = True
    If Not wa.WATER_DEPTH_OUOM = GetDropDownListSelectedValue(ddlWaterDepthUnits, wa.WATER_DEPTH_OUOM, wa.WATER_DEPTH_OUOM) Then wa.IsWellVersionChanged = True
    If Not wa.CASING_FLANGE_ELEV = GetTextBoxText(txtCasingFlange) Then wa.IsWellVersionChanged = True
    If Not wa.CASING_FLANGE_ELEV_OUOM = GetDropDownListSelectedValue(ddlCasingFlangeUnits, wa.CASING_FLANGE_ELEV_OUOM, wa.CASING_FLANGE_ELEV_OUOM) Then wa.IsWellVersionChanged = True
    If Not wa.DRILL_TD = GetTextBoxText(txtTotalDepth) Then wa.IsWellVersionChanged = True
    If Not wa.DRILL_TD_OUOM = GetDropDownListSelectedValue(ddlTotalDepthUnits, wa.DRILL_TD_OUOM, wa.DRILL_TD_OUOM) Then wa.IsWellVersionChanged = True
    If Not wa.RIG_RELEASE_DATE = GetTextBoxDate(txtRigReleaseDate) Then wa.IsWellVersionChanged = True
    If Not wa.SPUD_DATE = GetTextBoxDate(txtSpudDate) Then wa.IsWellVersionChanged = True
    If Not wa.FINAL_DRILL_DATE = GetTextBoxDate(txtFinalDrillDate) Then wa.IsWellVersionChanged = True

    'If Not wa.IPL_BASIN_NAME = GetDropDownListSelectedValue(ddlBasinName) Then wa.IsWellVersionChanged = True
    'vrajpoot
    ' If Not wa.IPL_BASIN = GetDropDownListSelectedValue(ddlBasinName, wa.IPL_BASIN, wa.IPL_BASIN_NAME) Then wa.IsWellVersionChanged = True
    'If Not wa.IPL_BASIN_NAME = GetDropDownListText(ddlBasinName) Then wa.IsWellVersionChanged = True




    If Not wa.IPL_AREA = GetTextBoxText(txtArea) Then wa.IsWellVersionChanged = True
    If Not wa.IPL_BLOCK = GetTextBoxText(txtBlock) Then wa.IsWellVersionChanged = True
    If Not String.IsNullOrEmpty(GetDropDownListSelectedValue(ddlProvState)) Then
      If Not wa.PROVINCE_STATE = GetDropDownListSelectedValue(ddlProvState).Substring(GetDropDownListSelectedValue(ddlProvState).IndexOf(",") + 1) Then wa.IsWellVersionChanged = True
    End If
    If Not wa.PROVINCE_STATE_NAME = GetDropDownListText(ddlProvState) Then wa.IsWellVersionChanged = True
    If Not wa.COUNTY = GetDropDownListSelectedValue(ddlCounty, wa.COUNTY, wa.COUNTY_NAME) Then wa.IsWellVersionChanged = True
    If Not wa.COUNTY_NAME = GetDropDownListText(ddlCounty) Then wa.IsWellVersionChanged = True
    If Not wa.DISTRICT = GetTextBoxText(txtDistrict) Then wa.IsWellVersionChanged = True
    If Not wa.LEASE_NAME = GetTextBoxText(txtLeaseName) Then wa.IsWellVersionChanged = True
    If Not wa.ASSIGNED_FIELD = GetTextBoxText(txtAssignedField) Then wa.IsWellVersionChanged = True
    If Not wa.IPL_POOL = GetTextBoxText(txtPool) Then wa.IsWellVersionChanged = True
    If Not wa.REMARK = GetTextBoxText(taRemark) Then wa.IsWellVersionChanged = True
    If Not wa.OLDEST_STRAT_AGE = GetDropDownListSelectedValue(ddlOldestStratAge, wa.OLDEST_STRAT_AGE, wa.OLDEST_STRAT_UNIT_ID) Then wa.IsWellVersionChanged = True
    If Not wa.OLDEST_STRAT_UNIT_ID = GetDropDownListText(ddlOldestStratAge) Then wa.IsWellVersionChanged = True
    If Not wa.TD_STRAT_AGE = GetDropDownListSelectedValue(ddlTDStratAge, wa.TD_STRAT_AGE, wa.TD_STRAT_UNIT_ID) Then wa.IsWellVersionChanged = True
    If Not wa.TD_STRAT_UNIT_ID = GetDropDownListText(ddlTDStratAge) Then wa.IsWellVersionChanged = True
    If Not wa.PLUGBACK_DEPTH = GetTextBoxText(txtPlugbackDepth) Then wa.IsWellVersionChanged = True
    If Not wa.PLUGBACK_DEPTH_OUOM = GetDropDownListSelectedValue(ddlPlugbackDepthUnits, wa.PLUGBACK_DEPTH_OUOM, wa.PLUGBACK_DEPTH_OUOM) Then wa.IsWellVersionChanged = True
    If Not wa.IPL_PLUGBACK_TVD = GetTextBoxText(txtPlugbackTVD) Then wa.IsWellVersionChanged = True
    If Not wa.MAX_TVD = GetTextBoxText(txtMaxTVD) Then wa.IsWellVersionChanged = True
    If Not wa.MAX_TVD_OUOM = GetDropDownListSelectedValue(ddlMaxTVDUnits, wa.MAX_TVD_OUOM, wa.MAX_TVD_OUOM) Then wa.IsWellVersionChanged = True

    If Not wa.IsWellVersionChanged Then
      wa.WELL_VERSION.Rows(0)("WIM_ACTION_CD") = WELL_ACTION_NONE
    Else
      wa.WELL_VERSION.Rows(0)("WIM_ACTION_CD") = WELL_ACTION_UPDATE_VERSION
    End If

    'Check for updates in Well License
    If Not wa.IPL_LICENSEE = GetDropDownListSelectedValue(ddlLicensee, wa.IPL_LICENSEE, wa.IPL_LICENSEE_NAME) Then wa.IsWellLicenseChanged = True
    If Not wa.IPL_LICENSEE_NAME = GetDropDownListText(ddlLicensee) Then wa.IsWellLicenseChanged = True
    If Not wa.LICENSE_NUM = GetTextBoxText(txtLicenseNumber) Then wa.IsWellLicenseChanged = True
    If Not wa.LICENSE_DATE = GetTextBoxDate(txtLicenseDate) Then wa.IsWellLicenseChanged = True
    '??
    If Not wa.RIG_TYPE_CODE = GetDropDownListSelectedValue(ddlRigType, wa.RIG_TYPE_CODE, wa.RIG_TYPE_NAME) Then wa.IsWellLicenseChanged = True
    If Not wa.RIG_TYPE_NAME = GetDropDownListText(ddlRigType) Then wa.IsWellLicenseChanged = True
    If Not wa.RIG_NAME = GetTextBoxText(txtRigName) Then wa.IsWellLicenseChanged = True

    If wa.IsWellLicenseChanged Then
      wa.WELL_LICENSE.Rows(0)("WIM_ACTION_CD") = WELL_ACTION_UPDATE_VERSION
    End If

    'Check for updates in Well Node Version
    Dim dt As DataTable = CType(Session("WIM_LocationInfo"), DataSet).Tables("LocationInfo")
    dt.DefaultView.RowFilter = Nothing
    dt.DefaultView.RowStateFilter = DataViewRowState.ModifiedCurrent Or DataViewRowState.Added Or DataViewRowState.Deleted
    If dt.DefaultView.Count > 0 Then
      wa.IsWellNodeVersionChanged = True
    End If

  End Sub

#End Region

#Region "Private Functions"

  Private Function GetDropDownListSelectedValue(ByRef ddl As ComboBox, _
                                                  Optional ByVal origSelectedValue As String = "", _
                                                  Optional ByVal origText As String = "") As String

    Dim value As String = String.Empty

    If Not ddl.SelectedValue Is Nothing Then
      value = ddl.SelectedValue.ToString
    Else
      If ddl.Text = origText Then
        value = origSelectedValue
      End If
    End If

    Return value

  End Function

  Private Function GetDropDownListText(ByRef ddl As ComboBox) As String

    Dim value As String = String.Empty

    If Not String.IsNullOrEmpty(ddl.Text) Then
      value = ddl.Text.ToString
    End If

    Return value

  End Function

  Private Function GetTextBoxText(ByRef txt As TextBox) As String

    Dim value As String = String.Empty

    If Not String.IsNullOrEmpty(txt.Text) Then
      value = txt.Text.ToString
    End If

    Return value

  End Function

  Private Function GetTextBoxDate(ByRef txt As TextBox) As String

    Dim value As String = String.Empty

    If Not String.IsNullOrEmpty(txt.Text) Then
      value = txt.Text.ToString
      Dim dt() = value.Split("/")
      value = String.Format("{0:00}/{1:00}/{2}", dt(0), dt(1), dt(2))
    End If

    Return value

  End Function

  Private Class LocationErr
    Public seqNo As Integer = 0
    Public DataField As String = String.Empty
    Public locationErrMsg As String = String.Empty
    Public Sub New(ByVal seqNo As Integer, ByVal DataField As String, ByVal locationErrMsg As String)
      Me.seqNo = seqNo
      Me.DataField = DataField
      Me.locationErrMsg = locationErrMsg
    End Sub
    Public Function ShowErrorFullFormat() As String
      Dim sErrMsg As String = String.Format("SEQ_NO {0}:{1}=>{2}", seqNo, DataField, locationErrMsg)
      Return sErrMsg
    End Function
    Public Function ShowError() As String
      Dim sErrMsg As String = String.Format("{0}:{1}", DataField, locationErrMsg)
      Return sErrMsg
    End Function
  End Class

  Private Function GetLookUpList(ByVal lookUp As String) As DataTable

    Diagnostics.Trace.WriteLine(String.Format("Entering GetLookUpList for lookup table {0}. Cache {1}.", _
                                              lookUp, _
                                              (IIf(Cache(lookUp) Is Nothing, "miss", "hit"))))
    Dim dt As DataTable = Nothing

    Try
      dt = CType(Cache(lookUp), DataTable)
      If dt Is Nothing Then

        Dim lookupFile As String

        dt = New DataTable(lookUp)
        lookupFile = String.Format("{0}{1}.xml", Server.MapPath("~/App_LocalResources/"), dt.TableName)
        Diagnostics.Trace.WriteLine(String.Format("Reading lookup file: {0} into Cache({1}) datatable.", lookupFile, dt.TableName))
        dt.ReadXml(lookupFile)
        If dt.TableName = APP_TLM_BUSINESS_ASSOCIATE_LOOKUP_DATA Then
          dt.PrimaryKey = New DataColumn() {dt.Columns(0)}
          dt.DefaultView.Sort = "DISPLAY_TEXT"
        End If

        Cache.Insert(dt.TableName, _
                     dt, _
                     New CacheDependency(lookupFile), _
                     Cache.NoAbsoluteExpiration, _
                     Cache.NoSlidingExpiration, _
                     CacheItemPriority.NotRemovable, _
                     Nothing)
        Diagnostics.Trace.WriteLine(String.Format("Done reading lookup file: {0} into Cache({1}) datatable.", lookupFile, dt.TableName))
      End If

    Catch ex As Exception
      Diagnostics.Trace.TraceError(ex.ToString)

    Finally
      'Diagnostics.Trace.WriteLine(String.Format("Exiting GetLookUpList for lookup table {0}.", lookUp))

    End Try

    Return dt

  End Function

  Private Sub SetLocationValues(ByVal dtNL As DataTable)

    Dim ds As DataSet
    Dim dt As DataTable

    ds = New DataSet("LocationDTO")
    dt = New DataTable("LocationInfo")

    dt.Columns.Add("LIST_ID", System.Type.GetType("System.Decimal"))
    dt.Columns.Add("WIM_SEQ", System.Type.GetType("System.Decimal"))
    dt.Columns.Add("WIM_ACTION_CD")
    dt.Columns.Add("NODE_OBS_NO", System.Type.GetType("System.Decimal"))
    dt.Columns.Add("NODE_POSITION")
    dt.Columns.Add("LATITUDE", System.Type.GetType("System.Decimal"))
    dt.Columns.Add("LONGITUDE", System.Type.GetType("System.Decimal"))
    dt.Columns.Add("GEOG_COORD_SYSTEM_ID")

    dt.Columns.Add("LOCATION_ACCURACY", System.Type.GetType("System.Decimal"))
    'dt.Columns.add("LOCATION_ACCURACY", SYSTEM.TYPE.GETTYPE(Nullable(Of Decimal))

    dt.Columns.Add("REMARK")
    dt.Columns.Add("ErrorMessage")

    'Select auto increment primary key
    Dim nextID As Integer = 1

    If Not dtNL Is Nothing Then
      dt.Merge(dtNL, False, MissingSchemaAction.Ignore)
      nextID += dtNL.Rows.Count  ' Query of existing rows sets LIST_ID to RowNum
    End If

    dt.PrimaryKey = New DataColumn() {dt.Columns("LIST_ID")}
    dt.Columns("LIST_ID").AutoIncrement = True
    dt.Columns("LIST_ID").AutoIncrementSeed = nextID
    dt.Columns("LIST_ID").ReadOnly = True

    ds.Tables.Add(dt)
    ds.Tables.Add(GetGeographicDatumLookUp())
    ds.Tables.Add(GetPositionLookUp())

    ds.Tables("LocationInfo").DefaultView.RowFilter = "IsNull(WIM_ACTION_CD, '') <> '" & NODE_ACTION_INACTIVATE_VERSION & "'"
    DataGrid1.DataSource = ds.Tables("LocationInfo").DefaultView

    Session("WIM_LocationInfo") = ds

  End Sub

#End Region

End Class