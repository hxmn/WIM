Imports TalismanEnergy.WIM.Common
Imports TalismanEnergy.WIM.Common.AppConstants
Imports TalismanEnergy.WIM.GatewayProxy

Partial Public Class _Default
  Inherits System.Web.UI.Page

  Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    If Not Page.IsPostBack Then

      Dim msg As String = " * Loading Default.aspx under " & Request.ServerVariables("AUTH_USER")
      Diagnostics.Trace.TraceInformation(msg)

      HandleRequiredProcessing()

      If Not String.IsNullOrEmpty(Request.Params("HiddenTLMIdsForWIM")) Then
        Try
          Dim updatedWellsList = buildGrid(Request.Params("HiddenTLMIdsForWIM").ToString)
          Session("SearchedWells") = updatedWellsList
          LblSearch.Text = "Search Results"
        Catch ex As Exception
          LblSearch.Text = "Error building grid for TLMIDs: " + Request.Params("HiddenTLMIdsForWIM").ToString
        End Try
        GetUserPermissions()
      Else
        If Not String.IsNullOrEmpty(Session("SearchedWells")) Then
          Try
            buildGrid(Session("SearchedWells").ToString)
            LblSearch.Text = "Search Results"
          Catch ex As Exception
            LblSearch.Text = "Error building grid for TLMIDs: " + Session("SearchedWells").ToString
          End Try
          GetUserPermissions()
        Else
          'TODO: Comment first three statements when publishing to test or production
          'Dim sTLMIDs As String = "1000206285,1003609478,142686,50126669000,2000800396,1000272350,142005,143262,1000057494,124090,142868,1005021381,300000004717,1000160924"
          'Dim sTLMIDs As String = "141686"
          'Session("SearchedWells") = sTLMIDs
          btnAddVersion.Visible = False
          btnDeleteVersion.Visible = False
          btnViewVersion.Visible = False
          btnEditVersion.Visible = False
          btnInactivateVersion.Visible = False
          btnReactivateVersion.Visible = False
          btnMoveVersion.Visible = False
        End If
      End If
    End If

  End Sub

  Private Sub HandleRequiredProcessing()

    Dim Action As String = Server.HtmlDecode(Request.QueryString("Action"))
    If String.IsNullOrEmpty(Action) Then Exit Sub

    Dim WellInfos As String = Server.HtmlDecode(Request.QueryString("Wellkey"))
    If String.IsNullOrEmpty(WellInfos) Then Exit Sub

    Dim WellInfo() As String = WellInfos.Split(",")
    Dim TLMId As String = WellInfo(0)
    Dim Source As String = WellInfo(1)
    Session("RemoveThisTLMId") = TLMId

    If Action = WELL_ACTION_INACTIVATE_VERSION Then
      InactivateVersion(TLMId, Source)
    ElseIf Action = WELL_ACTION_REACTIVATE_VERSION Then
      ReactivateVersion(TLMId, Source)
    ElseIf Action = WELL_ACTION_DELETE_VERSION Then
      DeleteVersion(TLMId, Source)
    Else
      Exit Sub
    End If

  End Sub

  Private Sub GetUserPermissions()

    AddVersionsAllowed.Value = GetVersionsAllowed(USER_ADD_PERMISSION)
    DeleteVersionsAllowed.Value = GetVersionsAllowed(USER_DELETE_PERMISSION)
    EditVersionsAllowed.Value = GetVersionsAllowed(USER_UPDATE_PERMISSION)
    InactivateVersionsAllowed.Value = GetVersionsAllowed(USER_INACTIVATE_PERMISSION)
    ReactivateVersionsAllowed.Value = GetVersionsAllowed(USER_REACTIVATE_PERMISSION)
    MoveVersionsAllowed.Value = GetVersionsAllowed(USER_MOVE_PERMISSION)

  End Sub

  Private Function buildGrid(ByVal tlmIds As String) As String

    Dim dsResult As New DataSet
    Dim dtWell, dtVersion As DataTable

    Dim arrWell() As String = tlmIds.Split(",")
    Dim arrVersion() As String
    Dim sbInvalidWellList As New Text.StringBuilder
    Dim sbActiveWellList As New Text.StringBuilder
    Dim sWellList As String = String.Empty

    Try
      Dim dbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
      Dim gw As New GatewayAccess(dbconnection)

      'If ConfigurationManager.AppSettings("DemoCachedDataMode").ToString() = "TRUE" Then
      '    dsResult.ReadXml(Server.MapPath("App_LocalResources/SearchResults.xml"), XmlReadMode.ReadSchema)
      'Else
      dtWell = New DataTable
      dtWell = gw.FindWellsStdUOM(tlmIds, "Well")

      If Not arrWell.Length = dtWell.Rows.Count Then
        For Each sWell As String In arrWell
          If dtWell.Select("UWI='" & sWell & "'").Length = 0 Then
            sbInvalidWellList.Append(sWell).Append(",")
          Else
            sbActiveWellList.Append(sWell).Append(",")
          End If
        Next
        If sbActiveWellList.Length > 0 Then
          sWellList = sbActiveWellList.Remove(sbActiveWellList.Length - 1, 1).ToString
        End If
      Else
        sWellList = tlmIds
      End If

      If Not sWellList = String.Empty Then
        dtVersion = New DataTable
        dtVersion = gw.FindVersionsStdUOM(sWellList, "Version")
        arrVersion = sWellList.Split(",")

        For Each dr As DataRow In dtWell.Rows
          If dtVersion.Select("UWI='" & dr.Item("UWI") & "'").Length = 0 Then
            sbInvalidWellList.Append(dr.Item("UWI")).Append(",")
            dr.Delete()
          End If
        Next

        dtWell.AcceptChanges()

        dsResult.Tables.Add(dtWell)
        dsResult.Tables.Add(dtVersion)

        dsResult.Relations.Add("rel", dsResult.Tables("Well").Columns("UWI"), dsResult.Tables("Version").Columns("UWI"))
        'dsResult.WriteXml(Server.MapPath("App_LocalResources/SearchResults.xml"), XmlWriteMode.WriteSchema)
      End If

      'End If

      If dsResult.Tables.Count > 0 Then
        CreateSourceKey(dsResult.Tables(1))
        DataGrid1.DataSource = dsResult
        DataGrid1.DataBind()
      End If

      If Not String.IsNullOrEmpty(sbInvalidWellList.ToString) Then
        If sbInvalidWellList.ToString.EndsWith(",") Then
          sbInvalidWellList = sbInvalidWellList.Remove(sbInvalidWellList.Length - 1, 1)
        End If
        If Not Session("RemoveThisTLMId") Is Nothing Then
          Dim TLMId As String = CType(Session("RemoveThisTLMId"), String)
          If sbInvalidWellList.ToString.Contains(TLMId) Then
            RemoveWellFromGrid(TLMId)
            sbInvalidWellList = RemoveWellFromList(sbInvalidWellList, TLMId)
            Session("RemoveThisTLMId") = Nothing
          End If
        End If
        If Not String.IsNullOrEmpty(sbInvalidWellList.ToString) Then
          lblMessage1.Text = "No valid composite well exist for TLM ID(s) " + sbInvalidWellList.ToString() + ". Please contact TIS Support!"
          lblMessage1.ForeColor = Drawing.Color.DarkRed
        End If
      End If

    Catch ex As Exception
      lblMessage1.Text = "Error building list of wells and versions for TLM ID(s) " + tlmIds + ". Please contact TIS Support!"
      lblMessage1.ForeColor = Drawing.Color.DarkRed
      lblMessage2.Text = ex.Message
      lblMessage2.ForeColor = Drawing.Color.DarkRed
      sWellList = ""
    Finally

    End Try
    Return sWellList

  End Function

  Sub CreateSourceKey(ByRef dt As DataTable)

    If Not dt.Columns.Contains("ID") Then
      dt.Columns.Add("ID", Type.GetType("System.Int32"))
      Dim ctr As Int32 = 0

      For Each dr As DataRow In dt.Rows
        ctr += 1
        dr("ID") = ctr
      Next

    End If

  End Sub

  Private Function GetVersionsAllowed(ByVal table As String) As String

    Dim dt As DataTable = CType(Session("UserPermissions"), DataSet).Tables(table)
    Dim AllowedVersions As String = String.Empty

    If dt.Rows.Count > 0 Then

      For Each dr As DataRow In dt.Rows
        AllowedVersions += dr.Item("SOURCE") + ","
      Next

      AllowedVersions = AllowedVersions.Remove(AllowedVersions.Length - 1, 1)

    End If

    Return AllowedVersions

  End Function

  Private Sub InactivateVersion(ByVal tlmId As String, ByVal source As String)

    Try
      Dim dbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
      Dim gw As New GatewayAccess(dbconnection)
      Dim wa As New WellActionDTO(gw.GetVersionOrigUOM(tlmId, source))

      wa.ACTION = WELL_ACTION_INACTIVATE_VERSION
      wa.ACTIVE_IND = WELL_INACTIVE_IND
      wa.IsWellVersionChanged = True
      wa.USERID = Request.ServerVariables("AUTH_USER").Substring(Request.ServerVariables("AUTH_USER").IndexOf("\") + 1).ToUpper

      wa = gw.ProcessWellAction(wa)

      If wa.STATUS_CD = WELL_ACTION_COMPLETE Then
        lblMessage2.Text = "<br/>Inactivate Version - TLM ID [" & tlmId & "] Source [" & source & "] - SUCCESSFUL!"
        lblMessage2.ForeColor = Drawing.Color.Black
      Else
        lblMessage2.Text = "<br/>Inactivate Version - TLM ID [" & tlmId & "] Source [" & source & "] - FAILED! "
        lblMessage2.Text += wa.ERRORMSG.Split(";")(0).Split(",")(1)
        lblMessage2.ForeColor = Drawing.Color.DarkRed
      End If

    Catch ex As Exception
      Throw ex

    End Try

  End Sub

  Private Sub ReactivateVersion(ByVal tlmId As String, ByVal source As String)

    Try
      Dim dbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
      Dim gw As New GatewayAccess(dbconnection)
      Dim wa As New WellActionDTO(gw.GetVersionOrigUOM(tlmId, source))

      wa.ACTION = WELL_ACTION_REACTIVATE_VERSION
      wa.ACTIVE_IND = WELL_ACTIVE_IND
      wa.IsWellVersionChanged = True
      wa.USERID = Request.ServerVariables("AUTH_USER").Substring(Request.ServerVariables("AUTH_USER").IndexOf("\") + 1).ToUpper

      wa = gw.ProcessWellAction(wa)

      If wa.STATUS_CD = WELL_ACTION_COMPLETE Then
        lblMessage2.Text = "<br/>Reactivate Version - TLM ID [" & tlmId & "] Source [" & source & "] - SUCCESSFUL!"
        lblMessage2.ForeColor = Drawing.Color.Black
      Else
        lblMessage2.Text = "<br/>Reactivate Version - TLM ID [" & tlmId & "] Source [" & source & "] - FAILED! "
        lblMessage2.Text += wa.ERRORMSG.Split(";")(0).Split(",")(1)
        lblMessage2.ForeColor = Drawing.Color.DarkRed
      End If

    Catch ex As Exception
      Throw ex

    End Try

  End Sub

  Private Sub DeleteVersion(ByVal tlmId As String, ByVal source As String)

    Try
      Dim dbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
      Dim gw As New GatewayAccess(dbconnection)
      Dim wa As New WellActionDTO(gw.GetVersionOrigUOM(tlmId, source))

      wa.ACTION = WELL_ACTION_DELETE_VERSION
      wa.ACTIVE_IND = WELL_INACTIVE_IND
      wa.IsWellVersionChanged = True
      wa.USERID = Request.ServerVariables("AUTH_USER").Substring(Request.ServerVariables("AUTH_USER").IndexOf("\") + 1).ToUpper

      wa = gw.ProcessWellAction(wa)

      If wa.STATUS_CD = WELL_ACTION_COMPLETE Then
        lblMessage2.Text = "<br/>Delete Version - TLM ID [" & tlmId & "] Source [" & source & "] - SUCCESSFUL!"
        lblMessage2.ForeColor = Drawing.Color.Black
      Else
        lblMessage2.Text = "<br/>Delete Version - TLM ID [" & tlmId & "] Source [" & source & "] - FAILED! "
        lblMessage2.Text += wa.ERRORMSG.Split(";")(0).Split(",")(1)
        lblMessage2.ForeColor = Drawing.Color.DarkRed
      End If

    Catch ex As Exception
      Throw ex

    End Try

  End Sub

  Private Sub RemoveWellFromGrid(ByVal TLMId As String)

    Dim aTLMIds() As String
    Dim sTLMIds As String = String.Empty

    If Not Session("SearchedWells") Is Nothing Then
      aTLMIds = CType(Session("SearchedWells"), String).Split(",")

      For Each s As String In aTLMIds
        If s <> TLMId Then
          sTLMIds += s + ","
        End If
      Next

      If sTLMIds.EndsWith(",") Then
        sTLMIds = sTLMIds.Remove(sTLMIds.Length - 1, 1)
      End If

      Session("SearchedWells") = sTLMIds
    End If

  End Sub

  Private Sub AddWellToGrid(ByVal TLMId As String)

    Dim sTLMIds As String = String.Empty

    If Session("SearchedWells") Is Nothing Then
      sTLMIds = TLMId
    Else
      sTLMIds = CType(Session("SearchedWells"), String) & "," & TLMId
    End If

    Session("SearchedWells") = sTLMIds

  End Sub

  Private Function RemoveWellFromList(ByVal wl As Text.StringBuilder, ByVal w As String) As Text.StringBuilder

    Dim sbInvalidWellList As New Text.StringBuilder
    Dim aTLMIds() As String = wl.ToString.Split(",")

    For Each s As String In aTLMIds
      If s <> w Then
        sbInvalidWellList.Append(s).Append(",")
      End If
    Next

    If sbInvalidWellList.ToString.EndsWith(",") Then
      sbInvalidWellList = sbInvalidWellList.Remove(sbInvalidWellList.Length - 1, 1)
    End If

    Return sbInvalidWellList

  End Function

  Public Sub cbckFind_Callback(ByVal sender As Object, ByVal e As ComponentArt.Web.UI.CallBackEventArgs) Handles cbckFind.Callback
    Dim aliasType As String = e.Parameters(0)
    Dim aliasValue As String = e.Parameters(1)

    Dim dbconnection As String = ConfigurationManager.ConnectionStrings("WIMDBORAConnection").ToString()
    Dim gw As New GatewayAccess(dbconnection)
    Dim tlmId As String = gw.FindWellTLMID(aliasType, aliasValue)

    If String.IsNullOrEmpty(tlmId) Then
      lblFindError.Visible = True
      lblFindError.Text = "Did not find a unique " & aliasType & " of " & aliasValue
      lblFindError.RenderControl(e.Output)
    Else
      AddWellToGrid(tlmId)
      e.Output.Write("<script type='text/javascript'>RefreshMe();</script>")
    End If
  End Sub

  Public Sub cbckRemove_Callback(ByVal sender As Object, ByVal e As ComponentArt.Web.UI.CallBackEventArgs) Handles cbckRemove.Callback
    Dim tlmIds() As String = e.Parameters(0).ToString.Split(",")

    For Each tlmId As String In tlmIds
      RemoveWellFromGrid(tlmId)
    Next

    e.Output.Write("<script type='text/javascript'>RefreshMe();</script>")
  End Sub

End Class