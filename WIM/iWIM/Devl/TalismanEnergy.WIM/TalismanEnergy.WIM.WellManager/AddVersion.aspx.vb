Imports TalismanEnergy.WIM.Common
Imports TalismanEnergy.WIM.Common.AppConstants
Imports TalismanEnergy.WIM.GatewayProxy
Imports ComponentArt.Web.UI

Partial Public Class AddVersion
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If Not Page.IsPostBack _
            And Not ddlSource.CausedCallback _
            And Not ddlCountry.CausedCallback _
            And Not ddlProvState.CausedCallback _
            And Not ddlCounty.CausedCallback _
            And Not ddlOnOffShoreInd.CausedCallback _
            And Not ddlWellProfileType.CausedCallback _
            And Not ddlCurrentStatus.CausedCallback _
            And Not ddlOperator.CausedCallback _
            And Not ddlLicensee.CausedCallback _
            And Not ddlGroundElevUnits.CausedCallback _
            And Not ddlKBElevUnits.CausedCallback _
            And Not ddlDerrickFloorUnits.CausedCallback _
            And Not ddlWaterDepthUnits.CausedCallback _
            And Not ddlCasingFlangeUnits.CausedCallback _
            And Not ddlTotalDepthUnits.CausedCallback _
            And Not DataGrid1.CausedCallback _
            And Not ddlOldestStratAge.CausedCallback _
            And Not ddlTDStratAge.CausedCallback _
            And Not ddlPlugbackDepthUnits.CausedCallback _
            And Not ddlMaxTVDUnits.CausedCallback Then

            Dim WellInfo() As String = Server.HtmlDecode(Request.QueryString("Wellkey")).Split(",")
            Dim TLMId As String = WellInfo(0)
            Dim Source As String = WellInfo(1)

            ClearPageSessionVars()
            SetControlValues(TLMId)
            InitializeLookUpListControls()
            AddControlAttributes()

        End If

    End Sub

    Protected Sub btnSave_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnSave.Click

        Try
            Dim wa As WellActionDTO = CType(Session("WellActionDTO"), WellActionDTO)
            wa = PopulateWellActionDTO(wa)

            If Not wa.IsWellVersionChanged Then
                Dim srMsg As String = "Incomplete data entered to create well. Save to database not done."
                Dim myscript As String = "window.onload = function() {alert('" + srMsg + "');}"
                Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), "myscript", myscript, True)
                Exit Sub
            End If

            Dim dbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
            Dim gw As New GatewayAccess(dbconnection)

            wa = gw.ProcessWellAction(wa)

            If wa.STATUS_CD = WELL_ACTION_COMPLETE Then

                ClearPageSessionVars()
                Page.Response.Redirect("~/WellVersion.aspx?Wellkey=" & Server.HtmlEncode(wa.UWI & "," & wa.SOURCE) & "&Mode=A")

            Else

                ResetControls()
                HandleErrors(wa)

            End If

        Catch ex As Exception
            Throw ex

        End Try

    End Sub

    Protected Sub btnCancel_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles btnCancel.Click

        ClearPageSessionVars()
        Page.Response.Redirect("~/Default.aspx")

    End Sub

#Region "Source"

    Private Sub LoadSourceItems(ByVal iStartIndex As Integer, ByVal iNumItems As Integer, ByVal sFilter As String)

        Dim SourceLookUpList As DataTable = CType(Session("UserPermissions"), DataSet).Tables(USER_ADD_PERMISSION)

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

    Public Sub ddlSource_DataRequested(ByVal sender As System.Object, ByVal e As ComponentArt.Web.UI.ComboBoxDataRequestedEventArgs) Handles ddlSource.DataRequested

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

#Region "Operator"

    Private Sub LoadOperatorItems(ByVal iStartIndex As Integer, ByVal iNumItems As Integer, ByVal sFilter As String)

        Dim OperatorLookUpList As DataTable = GetLookUpList(APP_TLM_BUSINESS_ASSOCIATE_LOOKUP_DATA)

        ddlOperator.Items.Clear()

        If sFilter.Length > 0 Then
            If sFilter.IndexOf("'") > 0 Then
                sFilter = sFilter.Replace("'", "''")
            End If
            OperatorLookUpList.DefaultView.RowFilter = "BA_NAME LIKE '" + sFilter + "%'"
        Else
            OperatorLookUpList.DefaultView.RowFilter = "BA_NAME LIKE '%'"
        End If

        OperatorLookUpList.DefaultView.Sort = "BA_NAME ASC"

        Dim rowViewCount As Integer = OperatorLookUpList.DefaultView.Count
        Dim i As Integer = iStartIndex
        Dim iEndIndex As Integer = Math.Min(iStartIndex + iNumItems, rowViewCount)
        Dim oRow As DataRowView
        Dim oItem As ComboBoxItem

        Do While (i < iEndIndex And i < rowViewCount)
            oRow = OperatorLookUpList.DefaultView(i)
            oItem = New ComboBoxItem
            oItem.Value = oRow("BUSINESS_ASSOCIATE").ToString()
            oItem.Text = oRow("BA_NAME").ToString()
            ddlOperator.Items.Add(oItem)
            i += 1
        Loop

        ddlOperator.ItemCount = Math.Min(rowViewCount, iEndIndex + ddlOperator.DropDownPageSize)

    End Sub

    Public Sub ddlOperator_DataRequested(ByVal sender As System.Object, ByVal e As ComponentArt.Web.UI.ComboBoxDataRequestedEventArgs) Handles ddlOperator.DataRequested

        LoadOperatorItems(e.StartIndex, e.NumItems, e.Filter)

    End Sub

#End Region

#Region "Licensee"

    Private Sub LoadLicenseeItems(ByVal iStartIndex As Integer, ByVal iNumItems As Integer, ByVal sFilter As String)

        Dim LicenseeLookUpList As DataTable = GetLookUpList(APP_TLM_BUSINESS_ASSOCIATE_LOOKUP_DATA)

        ddlLicensee.Items.Clear()

        If sFilter.Length > 0 Then
            If sFilter.IndexOf("'") > 0 Then
                sFilter = sFilter.Replace("'", "''")
            End If
            LicenseeLookUpList.DefaultView.RowFilter = "BA_NAME LIKE '" + sFilter + "%'"
        Else
            LicenseeLookUpList.DefaultView.RowFilter = "BA_NAME LIKE '%'"
        End If

        LicenseeLookUpList.DefaultView.Sort = "BA_NAME ASC"

        Dim rowViewCount As Integer = LicenseeLookUpList.DefaultView.Count
        Dim i As Integer = iStartIndex
        Dim iEndIndex As Integer = Math.Min(iStartIndex + iNumItems, rowViewCount)
        Dim oRow As DataRowView
        Dim oItem As ComboBoxItem

        Do While (i < iEndIndex And i < rowViewCount)
            oRow = LicenseeLookUpList.DefaultView(i)
            oItem = New ComboBoxItem
            oItem.Value = oRow("BUSINESS_ASSOCIATE").ToString()
            oItem.Text = oRow("BA_NAME").ToString()
            ddlLicensee.Items.Add(oItem)
            i += 1
        Loop

        ddlLicensee.ItemCount = Math.Min(rowViewCount, iEndIndex + ddlLicensee.DropDownPageSize)

    End Sub

    Public Sub ddlLicensee_DataRequested(ByVal sender As System.Object, ByVal e As ComponentArt.Web.UI.ComboBoxDataRequestedEventArgs) Handles ddlLicensee.DataRequested

        LoadLicenseeItems(e.StartIndex, e.NumItems, e.Filter)

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

#Region "Location Grid"

    Protected Sub DataGrid1_NeedRebind(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles DataGrid1.NeedRebind
        DataGrid1.DataBind()
    End Sub

    Protected Sub DataGrid1_NeedDataSource(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles DataGrid1.NeedDataSource
        BindLocationGrid()
    End Sub

    Protected Sub DataGrid1_UpdateCommand(ByVal sender As System.Object, ByVal e As ComponentArt.Web.UI.GridItemEventArgs) Handles DataGrid1.UpdateCommand
        UpdateLocationGrid(e.Item, "UPDATE")
    End Sub

    Protected Sub DataGrid1_DeleteCommand(ByVal sender As System.Object, ByVal e As ComponentArt.Web.UI.GridItemEventArgs) Handles DataGrid1.DeleteCommand
        UpdateLocationGrid(e.Item, "DELETE")
    End Sub

    Protected Sub DataGrid1_InsertCommand(ByVal sender As System.Object, ByVal e As ComponentArt.Web.UI.GridItemEventArgs) Handles DataGrid1.InsertCommand
        UpdateLocationGrid(e.Item, "INSERT")
    End Sub

    Private Sub UpdateLocationGrid(ByVal item As ComponentArt.Web.UI.GridItem, ByVal Action As String)

        Dim ds As DataSet = CType(Session("WIM_LocationInfo"), DataSet)
        Dim dr As DataRow

        Select Case (Action)
            Case "INSERT"
                dr = ds.Tables("LocationInfo").NewRow()
                dr.Item("WIM_ACTION_CD") = NODE_ACTION_CREATE_VERSION
                dr.Item("NODE_POSITION") = IIf(String.IsNullOrEmpty(item("NODE_POSITION")), Nothing, item("NODE_POSITION").ToString())
                dr.Item("LATITUDE") = IIf(String.IsNullOrEmpty(item("LATITUDE")), System.DBNull.Value, item("LATITUDE"))
                dr.Item("LONGITUDE") = IIf(String.IsNullOrEmpty(item("LONGITUDE")), System.DBNull.Value, item("LONGITUDE"))
                dr.Item("GEOG_COORD_SYSTEM_ID") = IIf(String.IsNullOrEmpty(item("GEOG_COORD_SYSTEM_ID")), Nothing, item("GEOG_COORD_SYSTEM_ID").ToString())
                ds.Tables("LocationInfo").Rows.Add(dr)
            Case "UPDATE"
                dr = ds.Tables("LocationInfo").Rows.Find(item("LIST_ID"))
                If Not dr Is Nothing Then
                    dr.Item("NODE_POSITION") = IIf(String.IsNullOrEmpty(item("NODE_POSITION")), Nothing, item("NODE_POSITION").ToString())
                    dr.Item("LATITUDE") = IIf(String.IsNullOrEmpty(item("LATITUDE")), System.DBNull.Value, item("LATITUDE"))
                    dr.Item("LONGITUDE") = IIf(String.IsNullOrEmpty(item("LONGITUDE")), System.DBNull.Value, item("LONGITUDE"))
                    dr.Item("GEOG_COORD_SYSTEM_ID") = IIf(String.IsNullOrEmpty(item("GEOG_COORD_SYSTEM_ID")), Nothing, item("GEOG_COORD_SYSTEM_ID").ToString())
                End If
            Case "DELETE"
                ds.Tables("LocationInfo").Rows.Find(item("LIST_ID")).Delete()
        End Select

        Session("WIM_LocationInfo") = ds

    End Sub

    Private Sub BindLocationGrid()

        Dim ds As DataSet
        Dim dt As DataTable

        If Session("WIM_LocationInfo") Is Nothing Then

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
            dt.Columns.Add("ErrorMessage")

            'Select auto increment primary key
            dt.PrimaryKey = New DataColumn() {dt.Columns("LIST_ID")}
            dt.Columns("LIST_ID").AutoIncrement = True
            dt.Columns("LIST_ID").AutoIncrementSeed = 1
            dt.Columns("LIST_ID").ReadOnly = True

            ds.Tables.Add(dt)
            ds.Tables.Add(GetGeographicDatumLookUp())
            ds.Tables.Add(GetPositionLookUp())

            Session("WIM_LocationInfo") = ds
        Else
            ds = CType(Session("WIM_LocationInfo"), DataSet)
        End If

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
            dt.Columns.Add("COORD_SYSTEM_ID")
            dt.Columns.Add("COORD_SYSTEM_NAME")

            dr = dt.NewRow
            dr("COORD_SYSTEM_ID") = ""
            dr("COORD_SYSTEM_NAME") = ""
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
            dr("NODE_POSITION_LONGNAME") = "B"
            dt.Rows.Add(dr)

            dr = dt.NewRow
            dr("NODE_POSITION") = "S"
            dr("NODE_POSITION_LONGNAME") = "S"
            dt.Rows.Add(dr)

            Session("PositionLookUpList") = dt
        Else
            dt = CType(Session("PositionLookUpList"), DataTable)
        End If

        Return dt

    End Function

#End Region

#Region "Private Functions"

    Private Sub InitializeLookUpListControls()

        Dim SourceLookUpList As DataTable = CType(Session("UserPermissions"), DataSet).Tables(USER_ADD_PERMISSION)
        ddlSource.DataSource = SourceLookUpList
        ddlSource.DataValueField = SourceLookUpList.Columns.Item("SOURCE").ToString()
        ddlSource.DataTextField = SourceLookUpList.Columns.Item("SHORT_NAME").ToString()
        ddlSource.DataBind()

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

        Dim CurrentStatusLookUpList As DataTable = GetLookUpList(APP_CURRENT_STATUS_LOOKUP_DATA)
        ddlCurrentStatus.DataSource = CurrentStatusLookUpList
        ddlCurrentStatus.DataValueField = CurrentStatusLookUpList.Columns.Item("STATUS").ToString()
        ddlCurrentStatus.DataTextField = CurrentStatusLookUpList.Columns.Item("LONG_NAME").ToString()
        ddlCurrentStatus.DataBind()

        LoadOldestStratAgeItems(0, ddlOldestStratAge.DropDownPageSize * 2, "")
        LoadTDStratAgeItems(0, ddlTDStratAge.DropDownPageSize * 2, "")

    End Sub

    Private Sub AddControlAttributes()

        txtUWI.Attributes.Add("onblur", "handleUWI()")
        txtWellName.Attributes.Add("onblur", "handleWellName()")
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

    End Sub

    Private Sub SetControlValues(ByVal TLMId As String)

        Dim dbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
        Dim gw As New GatewayAccess(dbconnection)
        Dim wa As WellActionDTO = gw.FindWell(TLMId)

        Session("WellActionDTO") = wa

        lblTLMIDval.Text = wa.UWI
        lblTLMID2val.Text = lblTLMIDval.Text

        txtUWI.Text = wa.IPL_UWI_LOCAL
        lblUWI2val.Text = txtUWI.Text

        ddlCountry.Text = wa.COUNTRY_NAME
        lblCountry2val.Text = ddlCountry.Text

        If Not wa.COUNTRY = String.Empty Then
            LoadProvStateItems(0, ddlProvState.DropDownPageSize * 2, wa.COUNTRY)
            If ddlProvState.ItemCount > 0 Then
                ddlProvState.Enabled = True
            Else
                ddlProvState.Enabled = False
            End If
        End If

        txtWellName.Text = wa.WELL_NAME
        lblWellName2val.Text = txtWellName.Text

    End Sub

    Private Function PopulateWellActionDTO(ByRef wa As WellActionDTO) As WellActionDTO

        wa.ACTION = WELL_ACTION_ADD_VERSION

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
        wa.RIG_RELEASE_DATE = GetTextBoxDate(txtRigReleaseDate)
        wa.SPUD_DATE = GetTextBoxDate(txtSpudDate)
        wa.FINAL_DRILL_DATE = GetTextBoxDate(txtFinalDrillDate)

        wa.IPL_BASIN = GetTextBoxText(txtBasin)
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

        If Not String.IsNullOrEmpty(wa.LICENSE_NUM) Then
            wa.IsWellLicenseChanged = True
            wa.WELL_LICENSE.Rows(0)("WIM_ACTION_CD") = WELL_ACTION_CREATE_WELL
        End If

        If CType(Session("WIM_LocationInfo"), DataSet).Tables("LocationInfo").Rows.Count > 0 Then
            CType(Session("WIM_LocationInfo"), DataSet).EnforceConstraints = False
            wa.WELL_NODE_VERSION.Merge(CType(Session("WIM_LocationInfo"), DataSet).Tables("LocationInfo"))
            wa.IsWellNodeVersionChanged = True
        End If

        Return wa

    End Function

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

    Private Sub ResetControls()

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

        txtBasin.ToolTip = ""
        txtBasin.BackColor = Drawing.Color.Transparent

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

        lblMessage.Visible = False
        lblMessageTabStrip1.Visible = False
        lblMessageTabStrip2.Visible = False

    End Sub

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

    Private Sub HandleErrors(ByRef wa As WellActionDTO)

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
                Case ATTR_IPL_BASIN
                    txtBasin.BackColor = Drawing.Color.Yellow
                    txtBasin.ToolTip += sErr(1).ToString & vbCrLf
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

        lblAddVersion.Text = "Add Version - TLM ID [" & wa.UWI & "] Source [" & wa.SOURCE & "] - FAILED!"
        lblAddVersion.ForeColor = Drawing.Color.DarkRed

        If blnTab12Error Then
            lblMessage.Text = "Please correct errors highlighted in yellow on both tabs!"
            lblMessage.Visible = True
            TabStrip1.SelectedTab = TabStrip1.Tabs(0)
            MultiPage1.SelectedIndex = 0
        ElseIf blnTab1Error Then
            lblMessageTabStrip1.Text = "Please correct errors highlighted in yellow on this tab!"
            lblMessageTabStrip1.Visible = True
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

            DataGrid1.Levels(0).Columns("ErrorMessage").Visible = False
            lblNodeMessage.Visible = False

        End If

        Dim ds As DataSet = CType(Session("WIM_LocationInfo"), DataSet)
        ds.Tables("LocationInfo").Merge(wa.WELL_NODE_VERSION, False, MissingSchemaAction.Ignore)
        Session("WIM_LocationInfo") = ds

        If blnHasUnhandledErrors Then
            Dim sErrorText As String = String.Empty
            sErrorText = "Please review & resubmit entries made to this version, as the following failure occurred:" & "\n\n"
            sErrorText += sUnhandledErrors.Replace("'", "''")
            lblMessage.ToolTip = sErrorText.Replace("\n", vbCrLf)
            TabStrip1.SelectedTab = TabStrip1.Tabs(0)
            MultiPage1.SelectedIndex = 0
            Dim myscript As String = "window.onload = function() {alert('" + sErrorText + "');}"
            Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), "myscript", myscript, True)
        End If

    End Sub
    Private Function GetLookUpList(ByVal lookUp As String) As DataTable

        Diagnostics.Trace.WriteLine(String.Format("Entering GetLookUpList for lookup table {0}.", lookUp))
        Diagnostics.Trace.WriteLine(String.Format("Cache({0}) Is Nothing ? {1}.", lookUp, Cache(lookUp) Is Nothing))

        Dim dt As DataTable = Nothing

        Try
            If Cache(lookUp) Is Nothing Then

                Dim lookupFile As String

                dt = New DataTable(lookUp)
                lookupFile = String.Format("{0}{1}.xml", Server.MapPath("~/App_LocalResources/"), dt.TableName)
                dt.ReadXml(lookupFile)

                Dim dep As New CacheDependency(lookupFile)
                Cache.Insert(dt.TableName, dt, dep, DateTime.MaxValue, TimeSpan.Zero, CacheItemPriority.NotRemovable, Nothing)
                Diagnostics.Trace.WriteLine(String.Format("Reading lookup file: {0} into Cache({1}) datatable.", lookupFile, dt.TableName))
            Else
                dt = CType(Cache(lookUp), DataTable)
                Diagnostics.Trace.WriteLine(String.Format("Returning lookup table: {0} from Cache({1}) datatable.", lookUp, dt.TableName))
            End If

        Catch ex As Exception
            Diagnostics.Trace.TraceError(ex.ToString)

        Finally
            Diagnostics.Trace.WriteLine(String.Format("Exiting GetLookUpList for lookup table {0}.", lookUp))

        End Try

        Return dt

    End Function

    Private Sub ClearPageSessionVars()

        Session("WellActionDTO") = Nothing
        Session(APP_COORD_SYSTEM_LOOKUP_DATA) = Nothing
        Session("PositionLookUpList") = Nothing
        Session("WIM_LocationInfo") = Nothing

    End Sub

#End Region

End Class